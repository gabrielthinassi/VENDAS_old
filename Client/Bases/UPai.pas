unit UPai;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBClient, DBGrids, DB, Mask, Math, ExtCtrls, JvToolEdit,
  Menus, JvBaseEdits, JvDBControls, ComCtrls, Grids, EditComp, JvDBGrid, DBCtrls,
  Buttons, JvTypes, JvgTypes, JvDBLookup, SynDBEdit, JvgGroupBox, CheckLst;

type
  TFPai = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

    procedure DBGridDrawColumnCellPadrao(Sender: TObject; const Rect: TRect;DataCol: integer; Column: TColumn; State: TGridDrawState); deprecated;

    procedure OnPopupMenuGrid(Sender: TObject);

    // Visualizar campo memo
    procedure VerCampoMemo(FormDono: TForm; DS: TDataSource; Campo: TField; Modal: Boolean = False);
    procedure FormKeyDownMemo(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClosePadrao(Sender: TObject; var Action: TCloseAction);

    procedure FuncoesDeMarcacaoClick(Sender: TObject);
    procedure FuncoesDeMarcacaoCheckList(Sender: TObject);
    procedure FuncoesMarcacaoCheckList(CkList: TCheckListBox; OpMenu: Integer);
  private
    fApenasDigitacaoMaiusculo: Boolean;
    fControlaMaximizar: Boolean;
    fParametros: TStrings;
    fRegistraLog: Boolean;
    fDtEntradaTela: TDateTime;
    FMarcandoRegistrosEmGrade: Boolean;

    FCodigoRegistroLog: Integer;

    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;

    procedure RegistrarLogDeEntrada;
    procedure RegistrarLogDeSaida;
  public
    procedure ConfiguraComponentes(ComponentePai: TComponent);
    procedure DefineParametros(AParametros: array of string);
    procedure AposFormShow; virtual;

    property ApenasDigitacaoMaiusculo: Boolean read fApenasDigitacaoMaiusculo write fApenasDigitacaoMaiusculo;
    property RegistraLog: Boolean              read fRegistraLog              write fRegistraLog;
    property MarcandoRegistrosEmGrade: Boolean read FMarcandoRegistrosEmGrade write FMarcandoRegistrosEmGrade;
  protected
    procedure PreencheItensDeMenuDeMarcacao(var MenuPopup: TPopupMenu; AtribuirOnClick: Boolean = True);
    procedure AoFinalizarFuncoesDeMarcacao; virtual;

    property ControlaMaximizar: Boolean read fControlaMaximizar write fControlaMaximizar;
    property Parametros: TStrings read fParametros;
  end;

var
  FPai: TFPai;

implementation

uses Constantes, ConstanteSistema,
  ClassArquivoINI, ClassCaixasDeDialogos, ClassHelperGrid, ClassHelperDataSet, ClassFuncoesForm, ClassFuncoesString,
  UFRSelecao, UDMConexao, UPrincipal, ClassHelperSynEdit;

{$R *.dfm}

procedure TFPai.FormCreate(Sender: TObject);
begin
  FCodigoRegistroLog        := 0;
  ApenasDigitacaoMaiusculo  := True;
  fRegistraLog              := DMConexao.SecaoAtual.Parametro.RegistraLog_Tela;
  FMarcandoRegistrosEmGrade := False;

  if (ConstanteSistema.Sistema in [cSistemaDepPessoal, cSistemaContabilidade, cSistemaLivrosFiscais, cSistemaESocial]) then
    ControlaMaximizar := True
  else
    ControlaMaximizar := False;

  ConfiguraComponentes(Self);

  if (Self.Name <> 'FPrincipal') and
    (Self.Width > 790) and
    (DelphiRodando) then
    TCaixasDeDialogo.Aviso('Largura máxima da tela deve ser 790. Atualmente está com ' + IntToStr(Self.Width));
  if (Self.Name <> 'FPrincipal') and
    (Self.Height > 500) and
    (DelphiRodando) then
    TCaixasDeDialogo.Aviso('Altura máxima da tela deve ser 500. Atualmente está com ' + IntToStr(Self.Height));

  Position := poOwnerFormCenter; // poScreenCenter;

  fParametros := TStringList.Create;
end;

procedure TFPai.FormClose(Sender: TObject; var Action: TCloseAction);
var
  X: integer;
  Sec, Ide, Con: array[1..1] of string;
begin
  with Self do
    for X := 0 to ComponentCount - 1 do
    begin
      if (Components[X] is TClientDataSet) then
        (Components[X] as TClientDataSet).Close;

      if (Components[X] is TJvDirectoryEdit) then
      begin
        with (Components[X] as TJvDirectoryEdit) do
        begin
          Sec[1] := Self.Name;
          Ide[1] := Name + '.Text';
          Con[1] := Text;
          TArquivoINI.Gravar(Sec, Ide, Con);
        end;
      end
      else if (Components[X] is TEditComp) then
      begin
{$IF DEFINED(DEPPESSOAL) or DEFINED(ESOCIAL)}
        with TEditComp(Components[X]) do
        begin
          if Tag = 1 then
            DMConexao.SecaoAtual.Competencia := Text;
        end;
{$IFEND}
      end;
    end;

  // if Assigned(fParametros) then
  //   FreeAndNil(fParametros);
end;

procedure TFPai.FormDestroy(Sender: TObject);
begin
  if Assigned(fParametros) then
    FreeAndNil(fParametros);

  RegistrarLogDeSaida;
end;

procedure TFPai.FormShow(Sender: TObject);
begin
  RegistrarLogDeEntrada;
end;

procedure TFPai.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  {  if (Shift = [ssShift]) and (Key = vk_F12) then FPrincipal.Calculadora1Click(nil);
    if (Shift = [ssCtrl]) and (Key = vk_F11) then FPrincipal.DesenvolvedorClick(nil);
    if (Shift = [ssCtrl]) and (Key = vk_tab) and
      ((Screen.ActiveControl is TDBDateEdit) or
      (Screen.ActiveControl is TDateEdit)) then Key := vk_clear;}

  if (Shift = [ssCtrl, ssAlt]) and (Key = VK_F2)then
    TFuncoesForm.ExibirNomeObjetoViaHint(Self);

  if (Shift = [ssCtrl, ssAlt]) and (Key = VK_F3)then
    TFuncoesForm.DestroirNomeObjetoViaHint(Self);

  if (Shift = [ssCtrl, ssAlt]) and (Key = VK_F4)then
    TFuncoesForm.ExibirFieldNameObjetoViaHint(Self);


  if (Shift = []) and (Key = VK_ESCAPE) then
    if (ActiveControl is TJvDBLookupCombo) then
      with (ActiveControl as TJvDBLookupCombo) do
      begin
        // o componente TJvDBLookupCombo possui a propriedade EscapeClear que serve
        // para limpar o seu conteúdo se a tecla esc for pressionada.
        // se essa propriedade estiver ativada e possuir valor para ser limpo
        // nao prosseguir com o teste da tecla esc.
        if EscapeKeyReset and (Value <> '') then
          Key := vk_clear
      end;

  if (Shift = []) and (Key = VK_F1) and
    (Screen.ActiveControl is TDBGrid) and
    Assigned((Screen.ActiveControl as TDBGrid).OnEditButtonClick) and
    ((Screen.ActiveControl as TDBGrid).SelectedField.Tag <> cTagConfigBloqCampo) then
    (Screen.ActiveControl as TDBGrid).OnEditButtonClick(Screen.ActiveControl as TDBGrid);
end;

procedure TFPai.FormKeyPress(Sender: TObject; var Key: Char);
var
  T: TComponent;
  DataDBGridIsNull: Boolean;
  Dia, Mes, Ano: Word;
  PrimeiroDiaProximoMes: TDate;
begin
  T := Screen.ActiveControl;

  if (T is TDBGrid) then
    TDBGrid(T).ProximaColunaNaGrade(Key);

  if (Key = '.') and
    ((T is TJvCalcEdit) or (T is TJvDBCalcEdit) or
    ((T is TDBGrid) and ((T as TDBGrid).SelectedField).CampoTipoFloat) or
    //    ((T as TDBGrid).SelectedField.DataType in [ftFloat, ftBCD, ftCurrency])) or

    ((T is TDBEdit) and ((T as TDBEdit).DataSource.DataSet.FieldByName((T as TDBEdit).DataField).CampoTipoFloat))) then

    //    ((T is TDBEdit) and ((T as TDBEdit).DataSource.DataSet.FieldByName((T as TDBEdit).DataField).DataType in [ftBCD, ftFloat]))) then
    Key := ','
  else if Key = #13 then
  begin
    if (T is TDBLookupComboBox) then
      with (T as TDBLookupComboBox) do
        if not ListVisible then
          TFuncoesForm.ProximoControle;

    if (T is TDBComboBox) then
      with (T as TDBComboBox) do
        if not DroppedDown then
          TFuncoesForm.ProximoControle;

    if (T is TJvDBLookupCombo) then
      with (T as TJvDBLookupCombo) do
        if not ListVisible then
          TFuncoesForm.ProximoControle;

    if (T is TPageControl) then
      TFuncoesForm.ProximoControle;

    if (T is TDBRadioGroup) then
      TFuncoesForm.ProximoControle;
  end
  else if ApenasDigitacaoMaiusculo and
          (not (T is TMemo)) and
          (not (T is TDBMemo)) and
          (not (T is TRichEdit)) and
          (not (T is TDBSynEdit)) then
    Key := Char(AnsiUpperCase(Key)[1]);

  if(T is TJvDateEdit) or (T is TJvDBDateEdit)then
  begin
  if (CharInSet(Key, [Char(Ord('I'))]))then
    begin
      if TJvDateEdit(T).Date > 0 then
        DecodeDate(TJvDateEdit(T).Date, Ano, Mes, Dia)
      else
        DecodeDate(Date, Ano, Mes, Dia);

      TJvDateEdit(T).Clear;
      TJvDateEdit(T).Date := EncodeDate(ano, mes, 1);
    end
  else if (CharInSet(Key, [Char(Ord('U'))]))then
    begin
      if TJvDateEdit(T).Date > 0 then
        DecodeDate(TJvDateEdit(T).Date, Ano, Mes, Dia)
      else
        DecodeDate(Date, Ano, Mes, Dia);

      if Mes = 12 then
      begin
        Mes := 1;
        Inc(Ano);
      end
      else
        inc(Mes);

      PrimeiroDiaProximoMes := EncodeDate(ano, mes, 1);
      TJvDateEdit(T).Clear;
      TJvDateEdit(T).Date   := PrimeiroDiaProximoMes-1;
    end;
  end;

  // Na grade ao pressionar T ou + ou - ou I ou U irá preencher a Data.
  // Pressionando 'T' irá preencher a Data de hoje.
  // Pressionando '+' irá Incrementear a Data com 1 dia.
  // Pressionando '-' irá Decrementar a Data com 1 dia.
  // Pressionando 'I' irá preencher com o primeiro dia do mês informado ou primeiro dia do mês corrente.
  // Pressionando 'U' irá preencher com o último dia do mês informado ou último dia do mês corrente.
  if ((T is TJvDBGrid) or (T is TDBGrid)) and
     (dgEditing in (T as TDBGrid).Options) and
     ((T as TDBGrid).SelectedField <> nil) and ((T as TDBGrid).SelectedField.CampoTipoData) and
     (not(T as TDBGrid).Columns[(T as TDBGrid).SelectedIndex].ReadOnly) then
  begin
    if (CharInSet(Key, [Char(Ord('-')), Char(Ord('+')), Char(Ord('T')), Char(Ord('I')), Char(Ord('U'))]))then
    begin
      // Verificar como está a Data, assim que pressionou uma das teclas ('T', '+', '-')
      DataDBGridIsNull := ((T as TDBGrid).SelectedField.IsNull) or ((T as TDBGrid).SelectedField.AsDateTime = 0);

      // Colocar o DataSet em Edição se o mesmo não estiver.
      with (T as TDBGrid).DataSource.DataSet  do
        if not(State in [dsEdit, dsInsert]) then
          Edit;

      // Se Antes de pressionar ('T', '+', '-') a Data estava vazia ou foi pressionado a Tecla 'T'
      // Preencher com da Data de Hoje
      if ((DataDBGridIsNull)and (Key <> Char(Ord('I'))) and (Key <> Char(Ord('U')))) or (Key = Char(Ord('T')))then
        (T as TDBGrid).SelectedField.AsDateTime := Date
      else
      // Se a Data estava vazia ou foi pressionado a Tecla 'I'
      if ((DataDBGridIsNull)and (Key <> char(Ord('U'))))or (Key = Char(Ord('I')))then
      begin
        // Se havia Data informada preencher com o primeiro dia do mês informado na data.
        if (T as TDBGrid).SelectedField.AsDateTime > 0 then
          DecodeDate((T as TDBGrid).SelectedField.AsDateTime, Ano, Mes, Dia)
        else
          // Se a data estava vazia informar o primeiro dia do mês corrente
          DecodeDate(Date, Ano, Mes, Dia);

        (T as TDBGrid).SelectedField.AsDateTime := EncodeDate(ano, mes, 1);
      end
      else
      // Se a Data estava vazia ou foi pressionado a Tecla 'U'
      if (DataDBGridIsNull)or (Key = Char(Ord('U')))then
      begin
        // Se havia data informada preencher com o último dia do mês informado na data.
        if (T as TDBGrid).SelectedField.AsDateTime > 0 then
          DecodeDate((T as TDBGrid).SelectedField.AsDateTime, Ano, Mes, Dia)
        else
          // Se a data estava vazia informar o último dia do mês corrente
          DecodeDate(Date, Ano, Mes, Dia);

        if Mes = 12 then
        begin
          Mes := 1;
          Inc(Ano);
        end
        else
          inc(Mes);

        PrimeiroDiaProximoMes := EncodeDate(ano, mes, 1);
        (T as TDBGrid).SelectedField.AsDateTime := PrimeiroDiaProximoMes-1;
      end
      else
        // Se a Data já estava preenchida e foi pressionado '+' ou '-'
        // Incrementar ou Decrementar conforme a tecla pressionada
        (T as TDBGrid).SelectedField.AsDateTime := (T as TDBGrid).SelectedField.AsDateTime + IfThen(Key = Char(Ord('+')), 1, -1);
    end;
  end;
end;

procedure TFPai.AposFormShow;
begin
  // é chamada pela funcao tela
end;

procedure TFPai.ConfiguraComponentes(ComponentePai: TComponent);
var
  X, I, J: integer;
  C: TComponent;
  TemGrade: Boolean;
  MenuItemPai, MenuItem: TMenuItem;

  function AtivarTabStopPageControl(PageControl: TPageControl): Boolean;
  var
    iCnt: integer;
    QTabVisiveis: integer;
  begin
    QTabVisiveis := 0;
    with PageControl do
      for iCnt := 0 to PageCount - 1 do
        if Pages[iCnt].TabVisible then
          Inc(QTabVisiveis);
    Result := (QTabVisiveis > 0);
  end;

begin
{$region 'Função'}
  TemGrade := False;
  for X := 0 to ComponentePai.ComponentCount - 1 do
  begin
    C := ComponentePai.Components[X];
    if (C.Tag = cTagAbortaConfig) then
      Continue;
    if (C is TEdit) then
      with TEdit(C) do
      begin
        if CharCase = ecNormal then
          CharCase := ecUpperCase;
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TSpeedButton) then
      with TSpeedButton(C) do
      begin
        Cursor := crHandPoint;
      end
    else if (C is TDBLookupComboBox) then
      with TDBLookupComboBox(C) do
      begin
        ShowHint := True;
      end
    else if (C is TCheckBox) then
      with TCheckBox(C) do
      begin
        Cursor := crHandPoint;
        ShowHint := True;
      end
    else if (C is TDBCheckBox) then
      with TDBCheckBox(C) do
      begin
        Cursor := crHandPoint;
        ShowHint := True;
      end
    else if (C is TDBEdit) then
      with TDBEdit(C) do
      begin
        if CharCase = ecNormal then
          CharCase := ecUpperCase;
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJVDateEdit) then
      with TJVDateEdit(C) do
      begin
        ClickKey := TextToShortCut('F1');
        CheckOnExit := True;
        YearDigits := dyFour;
        ShowHint := True;
        StartOfWeek := Sun;
        if (Hint = '') and (ShowButton) and (ButtonWidth > 0) then
          Hint := 'F1-Calendário';
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJvDBCalcEdit) then
      with TJvDBCalcEdit(C) do
      begin
        ClickKey := TextToShortCut('F1');
        ZeroEmpty := False;
        MaxLength := MaxDigitos;
        DecimalPlacesAlwaysShown := True;
        ShowHint := True;
        if (Hint = '') and (ShowButton) and (ButtonWidth > 0) then
        begin
          case ImageKind of
            ikEllipsis: Hint := 'F1-Consulta';
            ikDefault: Hint := 'F1-Calculadora';
          end;
        end;
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJvCalcEdit) then
      with TJvCalcEdit(C) do
      begin
        ClickKey := TextToShortCut('F1');
        ZeroEmpty := False;
        MaxLength := MaxDigitos;
        if (DecimalPlaces = 0) then
          MaxValue := MaxInt;
        DecimalPlacesAlwaysShown := True;
        ShowHint := True;
        if (Hint = '') and (ShowButton) and (ButtonWidth > 0) then
        begin
          case ImageKind of
            ikEllipsis: Hint := 'F1-Consulta';
            ikDefault: Hint := 'F1-Calculadora';
          end;
        end;
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJvFilenameEdit) then
      with TJvFilenameEdit(C) do
      begin
        AcceptFiles := True;
        ClickKey := TextToShortCut('F1');
        DialogOptions := DialogOptions + [ofDontAddToRecent];
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJvComboEdit) then
      with TJvComboEdit(C) do
      begin
        ClickKey := TextToShortCut('F1');
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJvDBDateEdit) then
      with TJvDBDateEdit(C) do
      begin
        ClickKey := TextToShortCut('F1');
        CheckOnExit := True;
        YearDigits := dyFour;
        ShowHint := True;
        StartOfWeek := Sun;
        if (Hint = '') and (ButtonWidth > 0) then
          Hint := 'F1-Calendário';
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TJvDBComboEdit) then
      with TJvDBComboEdit(C) do
      begin
        ClickKey := TextToShortCut('F1');
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TPageControl) then
      with TPageControl(C) do
      begin
        TabStop := AtivarTabStopPageControl(TPageControl(C));
        HotTrack := True;
      end
    else if (C is TMemo) then //servico 11454
      with (C as TMemo) do
      begin
        ScrollBars := ssBoth; // ssNone, ssHorizontal, ssVertical, ssBoth
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TDBMemo) then
      with (C as TDBMemo) do
      begin
        ScrollBars := ssBoth; // ssNone, ssHorizontal, ssVertical, ssBoth
        if ReadOnly then
        begin
          TabStop := False;
          Color := clSomenteLeitura;
        end;
      end
    else if (C is TCheckListBox) then
      with TCheckListBox(C) do
      begin
        Color := clWhite;
        Flat := True;
      end
    else if (C is TDBSynEdit) then
    begin
      with TDBSynEdit(C) do
        begin
          if not Assigned(OnKeyDown) then
          begin
            OnKeyDown := KeyDown_Padrao;
          end;
        end;
    end
    else if (C is TDBGrid) then
      with TDBGrid(C) do
      begin
        TemGrade := True;
        // FixedColor := $009CC99C;
        // FixedColor := $0084A242;
        TitleFont.Color := clBlack;
        Color := clGradeCorFundo;
        Ctl3D := False;
        BorderStyle := bsNone;
        TitleFont.Name := 'Tahoma';
        TitleFont.Size := 8;
        // TitleFont.Style := [fsBold];
        Options := Options - [dgTabs, dgConfirmDelete, dgCancelOnExit];
        DrawingStyle := gdsClassic;

        if (C is TJvDBGrid) then
          with TJvDBGrid(C) do
            begin
              AlternateRowColor := clGradeCorZebrado;
              ShowHint := True;
              ShowTitleHint := True;
            end;

        if Assigned(PopupMenu) then
        begin
          if not Assigned(PopupMenu.OnPopup) then
            PopupMenu.OnPopup := OnPopupMenuGrid;
          if PopupMenu.Items.Find(DMConexao.PesquisaIncremental1.Caption) = nil then
          begin
            // Separador
            MenuItem := TMenuItem.Create(Self);
            MenuItem.Caption := '-';
            TPopupMenu(PopupMenu).Items.Insert(0, MenuItem);

            // Adiciona os ITENS do Popup padrao no inicio
            for I := DMConexao.PopupMenuGrid.Items.Count - 1 downto 0 do
            begin
              MenuItem := TMenuItem.Create(Self);
              with MenuItem do
              begin
                Caption := DMConexao.PopupMenuGrid.Items[I].Caption;
                OnClick := DMConexao.PopupMenuGrid.Items[I].OnClick;
                ShortCut := DMConexao.PopupMenuGrid.Items[I].ShortCut;
                Tag := DMConexao.PopupMenuGrid.Items[I].Tag;
                Visible := DMConexao.PopupMenuGrid.Items[I].Visible;
                TPopupMenu(PopupMenu).Items.Insert(0, MenuItem);
              end;

              // Adiciona os SUBITENS do Popup padrao no inicio
              MenuItemPai := MenuItem;
              for J := DMConexao.PopupMenuGrid.Items[I].Count - 1 downto 0 do
              begin
                MenuItem := TMenuItem.Create(Self);
                with MenuItem do
                begin
                  Caption := DMConexao.PopupMenuGrid.Items[I].Items[J].Caption;
                  OnClick := DMConexao.PopupMenuGrid.Items[I].Items[J].OnClick;
                  ShortCut := DMConexao.PopupMenuGrid.Items[I].Items[J].ShortCut;
                  Tag := DMConexao.PopupMenuGrid.Items[I].Items[J].Tag;
                  MenuItemPai.Insert(0, MenuItem);
                end;
              end;
            end;
          end;
        end
        else
          PopupMenu := DMConexao.PopupMenuGrid;

        Configurar;
      end
    else if (C is TFrame) then
    begin
      if (C is TSelecao) then
        TSelecao(C).ConfigureAba;
      (C as TFrame).TabStop := False;
      ConfiguraComponentes(C);
    end
      //    else if (C is TJvAppIniFileStorage) then
      //      with TJvAppIniFileStorage(C) do
      //        FileName := ArquivoIniClient
    else if (C is TEditComp) then
    begin
{$IF DEFINED(DEPPESSOAL) or DEFINED(ESOCIAL)}
      TEditComp(C).Text := DMConexao.SecaoAtual.Competencia;
{$IFEND}
    end
    else if (C is TJvDirectoryEdit) then
    begin
      with (C as TJvDirectoryEdit) do
      begin
        Text := TArquivoINI.Ler(Self.Name, Name + '.Text', Text);
      end;
    end
    else if (C is TJvgGroupBox) then
    begin
      with (C as TJvgGroupBox) do
      begin
        Options := [fgoFilledCaption,fgoFluentlyExpand];
      end;
    end

    else if (pos('TRX', AnsiUpperCase(C.ClassName)) > 0)
      or (AnsiUpperCase(C.ClassName) = 'TDATEEDIT')
      or (AnsiUpperCase(C.ClassName) = 'TDBDATEEDIT') then
      TCaixasDeDialogo.Aviso('Caro Programador, favor não usar componentes da Rx, use os da JVCL')
    else if (pos('NUMEDIT', AnsiUpperCase(C.ClassName)) > 0) then
      TCaixasDeDialogo.Aviso('Caro Programador, favor não usar o componente NumEdit, use o JVCalcEdit');
  end;

  if (TemGrade) then
    BorderIcons := BorderIcons + [biMaximize];
{$endregion}
end;

procedure TFPai.AoFinalizarFuncoesDeMarcacao;
begin
  //
end;

procedure TFPai.FuncoesDeMarcacaoClick(Sender: TObject);
var
  ItemMenuPopup: TMenuItem;
  Menu: TPopupMenu;
begin
  ItemMenuPopup := (Sender as TMenuItem);
  Menu := TPopupMenu(ItemMenuPopup.GetParentMenu);

  if not (Menu.PopupComponent is TDBGrid) then
  begin
    if (Menu.PopupComponent is TCheckListBox) then  // gambinha ...
      FuncoesDeMarcacaoCheckList(Sender);
    Exit;
  end;

  DMConexao.CallBack_AbreTela(Self.ClassName, 'Atribuindo marcação');
  try
    FMarcandoRegistrosEmGrade := True;
    TDBGrid(Menu.PopupComponent).FuncoesDeMarcacao(Integer(ItemMenuPopup.Tag), Self);
  finally
    FMarcandoRegistrosEmGrade := False;
    DMConexao.CallBack_FechaTela(Self.ClassName);
  end;

  AoFinalizarFuncoesDeMarcacao;
end;

procedure TFPai.FuncoesDeMarcacaoCheckList(Sender: TObject);
var
  ItemMenuPopup: TMenuItem;
  Menu: TPopupMenu;
begin
  ItemMenuPopup := (Sender as TMenuItem);
  Menu := TPopupMenu(ItemMenuPopup.GetParentMenu);

  if not (Menu.PopupComponent is TCheckListBox) then
    Exit;

  FuncoesMarcacaoCheckList(TCheckListBox(Menu.PopupComponent), Integer(ItemMenuPopup.Tag));
end;

procedure TFPai.FuncoesMarcacaoCheckList(CkList: TCheckListBox; OpMenu: Integer);
var
  I, Y, Z, S: Integer;
begin
  S := CkList.ItemIndex;
  if S = -1 then
    S := 0;
  if OpMenu in [1,2,3,4,6] then
    Y := 0
  else
    Y := S;
  if OpMenu in [1,2,3,5,7] then
    Z := CkList.Count - 1
  else
    Z := S;

  with CkList do
    for I := Y to Z do
    begin
      case OpMenu of
        1,4,5:
          Checked[I] := True;
        2,6,7:
          Checked[I] := False;
        3:
          Checked[I] := not Checked[I];
      end;
    end;
end;

procedure TFPai.DefineParametros(AParametros: array of string);
var
  I: integer;
begin
  fParametros.Clear;
  for I := Low(AParametros) to High(AParametros) do
    fParametros.Add(AParametros[I]);
end;

procedure TFPai.OnPopupMenuGrid(Sender: TObject);
begin
  if not (Screen.ActiveControl is TDBGrid) then
    Abort;
  DMConexao.PopupMenuGridPopup(Sender);
end;

procedure TFPai.PreencheItensDeMenuDeMarcacao(var MenuPopup: TPopupMenu; AtribuirOnClick: Boolean = True);
var
  X: integer;
  ItemMenu: TMenuItem;
begin
  for X := 0 to 7 do
    with MenuPopup do
    begin
      ItemMenu := TMenuItem.Create(MenuPopup);
      ItemMenu.Tag := X;
      case X of
        0: ItemMenu.Caption := '-';
        1: ItemMenu.Caption := 'Marcar todos';
        2: ItemMenu.Caption := 'Desmarcar todos';
        3: ItemMenu.Caption := 'Inverter Seleção';
        4: ItemMenu.Caption := 'Marcar todos daqui para cima';
        5: ItemMenu.Caption := 'Marcar todos daqui para baixo';
        6: ItemMenu.Caption := 'Desmarcar todos daqui para cima';
        7: ItemMenu.Caption := 'Desmarcar todos daqui para baixo';
      end;
      if AtribuirOnClick then
        ItemMenu.OnClick := FuncoesDeMarcacaoClick;
      TPopupMenu(MenuPopup).Items.Insert(TPopupMenu(MenuPopup).Items.Count, ItemMenu);
    end;
end;

procedure TFPai.VerCampoMemo(FormDono: TForm; DS: TDataSource; Campo: TField; Modal: Boolean);
var
  X: integer;
  NomeDoForm: String;
  FrmMemo: TForm;
begin
  NomeDoForm := 'FrmViewMemo_' + FormDono.Name + '_' + TFuncoesString.Deletar(Campo.FieldName, ' ');

  FrmMemo := nil;
  for X := 0 to Screen.FormCount - 1 do
    if (Screen.Forms[X].Name = NomeDoForm) then
      begin
        FrmMemo := Screen.Forms[X];
        Break;
      end;

  if Assigned(FrmMemo) then
    begin
      if (FrmMemo.WindowState = wsMinimized) then
        FrmMemo.WindowState := wsNormal;
    end
  else
    begin
      FrmMemo := TForm.CreateNew(FormDono);
      FrmMemo.Name := NomeDoForm;
      with FrmMemo do
        begin
          Width := 600;
          Height := 300;
          Top := Mouse.CursorPos.Y;
          Left := Mouse.CursorPos.X;
          BorderStyle := bsSizeable;
          BorderIcons := BorderIcons;
          KeyPreview := True;
          FormStyle := fsStayOnTop;
          Position := poOwnerFormCenter;
          Caption := Campo.DisplayName;
          OnClose := FormClosePadrao;
          OnKeyDown := FormKeyDownMemo;
          with TDBMemo.Create(nil) do
            begin
              Parent := FrmMemo;
              Align := alClient;
              ScrollBars := ssBoth;
              DataSource := DS;
              DataField := Campo.FieldName;
              Font.Name := 'Courier New';
              Font.Size := 9;
            end;
        end;
    end;

  if Modal then
    FrmMemo.ShowModal
  else
    FrmMemo.Show;
end;

procedure TFPai.WMSysCommand(var Msg: TWMSysCommand);
const
  iAlt = 100;
begin
  if fControlaMaximizar then
  begin
    case Msg.CmdType of
      SC_MAXIMIZE, 61490:
        begin
         Self.Constraints.MaxHeight := FPrincipal.Height - iAlt;
         inherited;
         Self.Top := iAlt;
        end;
    else
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TFPai.FormKeyDownMemo(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = []) and (Key = VK_ESCAPE) and (Sender is TForm) then
    (Sender as TForm).Close;
end;

procedure TFPai.FormClosePadrao(Sender: TObject; var Action: TCloseAction);
begin
  Action := Cafree;
end;

procedure TFPai.RegistrarLogDeEntrada;
begin
  try
    if (fRegistraLog) and (DMConexao.SQLConexao.Connected) then
    begin
      fDtEntradaTela := DMConexao.DataHoraServidor;

      FCodigoRegistroLog := DMConexao.ExecuteMethods('TSMConexao.RegistroLogTela', [Sistema, DMConexao.SecaoAtual.Usuario.Codigo, Self.Name, fDtEntradaTela]);
    end;
  except
    // Se der erro na coleta dessa informação não deve atrapalhar o usuário
  end;
end;

procedure TFPai.RegistrarLogDeSaida;
var
  Saida, TempoDecorrido: TDateTime;
begin
  try
    if (fRegistraLog) and (FCodigoRegistroLog > 0) and (DMConexao.SQLConexao.Connected) then
    begin
      Saida := DMConexao.DataHoraServidor;
      TempoDecorrido := (Saida - fDtEntradaTela);

      DMConexao.ExecuteMethods('TSMConexao.AtualizaLogTela', [FCodigoRegistroLog, Saida, TempoDecorrido]);
    end;
  except
    // Se der erro na coleta dessa informação não deve atrapalhar o usuário
  end;
end;

procedure TFPai.DBGridDrawColumnCellPadrao(Sender: TObject; const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  TDBGrid(Sender).DrawColumnCell_Padrao(Sender, Rect, DataCol, Column, State);
end;

end.

