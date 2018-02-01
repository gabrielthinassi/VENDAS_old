unit UPaiCadastro;

interface

uses
  Classes, Windows, Messages, SysUtils, Variants, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, CategoryButtons, StdCtrls,
  Mask, JvBaseEdits, DB, DBClient, JvDBCombobox, Buttons, DBGrids, newbtn, Menus,
  System.StrUtils, JvExMask, JvToolEdit,
  UPai, UDMPaiCadastro;

type
  TFPaiCadastro = class(TFPai)
    PanelChave: TPanel;
    Label1: TLabel;
    EditCodigo: TJvCalcEdit;
    DS: TDataSource;
    PanelNavigator: TPanel;
    SBPrimeiro: TNewBtn;
    SBAnterior: TNewBtn;
    SBProximo: TNewBtn;
    SBUltimo: TNewBtn;
    Panel1: TPanel;
    BotaoIncluir: TNewBtn;
    BotaoExcluir: TNewBtn;
    BotaoGravar: TNewBtn;
    BotaoCancelar: TNewBtn;
    BotaoConsultar: TNewBtn;
    BotaoRelatorio: TNewBtn;
    BotaoOutros: TNewBtn;
    PanelFundoTela: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    BotaoImpressao: TNewBtn;

    // Formulario
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    // Botoes
    procedure BotaoIncluirClick(Sender: TObject);
    procedure BotaoExcluirClick(Sender: TObject);
    procedure BotaoGravarClick(Sender: TObject);
    procedure BotaoCancelarClick(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoRelatorioClick(Sender: TObject);
    procedure SBNavegadorClick(Sender: TObject);

    // Outros
    procedure DSStateChange(Sender: TObject);
    procedure PanelChaveExit(Sender: TObject);
    procedure Esquerda1Click(Sender: TObject);
    procedure Direita1Click(Sender: TObject);
    procedure EditCodigoButtonClick(Sender: TObject);
    procedure BotaoOutrosClick(Sender: TObject);
    procedure Responsabilidade1Click(Sender: TObject);
    procedure ExportarRegistro1Click(Sender: TObject);
    procedure ImportarContedo1Click(Sender: TObject);
    procedure AntesDeAceitarImportacao(CDS: TDataSet); virtual;
    procedure AntesDeGravarImportacao(DataSet: TDataSet); virtual;
    procedure BotaoImpressaoClick(Sender: TObject);
    procedure TrocaDeCodigosReferencias1Click(Sender: TObject);
    procedure SBBotaoFiltroDinamicoClick(Sender: TObject);
    procedure DuplicarRegistro1Click(Sender: TObject);
    procedure LogDeAlteracoesClick(Sender: TObject);
    procedure LogAcessoTelaClick(Sender: TObject);
    procedure ConfigValidaoRegistrosClick(Sender: TObject);
  private
    Sec, Ide, Con: array [1 .. 1] of string;
    FProcConsulta: string;
    FChamadoPelaConsulta, BloquearManipulacao, FechandoCadastro: Boolean;
    FRetornoCadastro: Variant;
    FDMCadastro: TDMPaiCadastro;
    FBotaoAbrirHabilitado: Boolean;
    FBotaoExcluirHabilitado: Boolean;
    FBotaoImpressaoHabilitado: Boolean;
    FBotaoConsultarHabilitado: Boolean;
    FBotaoGravarHabilitado: Boolean;
    FBotaoIncluirHabilitado: Boolean;
    FBotaoCancelarHabilitado: Boolean;
    FBotaoOutrosHabilitado: Boolean;
    FBotaoRelatorioHabilitado: Boolean;
    procedure ConfiguraPermissoes;
    procedure AlinharBotoesPanelNavigator;
  protected
    procedure VerificarOutrasPermissoesDeExclusao; virtual;

    property BotaoIncluirHabilitado: Boolean read FBotaoIncluirHabilitado write FBotaoIncluirHabilitado;
    property BotaoExcluirHabilitado: Boolean read FBotaoExcluirHabilitado write FBotaoExcluirHabilitado;
    property BotaoGravarHabilitado: Boolean read FBotaoGravarHabilitado write FBotaoGravarHabilitado;
    property BotaoCancelarHabilitado: Boolean read FBotaoCancelarHabilitado write FBotaoCancelarHabilitado;
    property BotaoConsultarHabilitado: Boolean read FBotaoConsultarHabilitado write FBotaoConsultarHabilitado;
    property BotaoRelatorioHabilitado: Boolean read FBotaoRelatorioHabilitado write FBotaoRelatorioHabilitado;
    property BotaoImpressaoHabilitado: Boolean read FBotaoImpressaoHabilitado write FBotaoImpressaoHabilitado;
    property BotaoAbrirHabilitado: Boolean read FBotaoAbrirHabilitado write FBotaoAbrirHabilitado;
    property BotaoOutrosHabilitado: Boolean read FBotaoOutrosHabilitado write FBotaoOutrosHabilitado;

  public
    property ChamadoPelaConsulta: Boolean read FChamadoPelaConsulta write FChamadoPelaConsulta;
    property ProcConsulta: string read FProcConsulta write FProcConsulta;
    property RetornoCadastro: Variant read FRetornoCadastro write FRetornoCadastro;
    property DMCadastro: TDMPaiCadastro read FDMCadastro write FDMCadastro;
  end;

var
  FPaiCadastro: TFPaiCadastro;

implementation

uses
  Constantes, ConstantesRelatorios, Consultas,
  ClassCaixasDeDialogos, ClassArquivoINI, ClassFuncoesString, ClassFuncoesForm, ClassHelperDataSet,
  UDMConexao, UPrincipal, UPaiModulo, UResponsabilidade, UPaiRelatorioGrafico, UTrocaCodigos, UPaiRelatorioHibrido, ULogTabela,
  UCadConfigValidacaoRegistro, UAguarde2;

{$R *.dfm}


procedure TFPaiCadastro.FormCreate(Sender: TObject);
begin
  inherited;
  if (Self.Width < 460) and
    (DelphiRodando) then
    TCaixasDeDialogo.Aviso('Largura mínima da tela de cadastro deve ser 460');
  if (Self.Height < 285) and
    (DelphiRodando) then
    TCaixasDeDialogo.Aviso('Altura mínima da tela de cadastro deve ser 285');

  ChamadoPelaConsulta := False;
  RetornoCadastro     := null;
  BloquearManipulacao := False;
  FechandoCadastro    := False;

  FBotaoIncluirHabilitado   := True;
  FBotaoExcluirHabilitado   := True;
  FBotaoGravarHabilitado    := True;
  FBotaoCancelarHabilitado  := True;
  FBotaoConsultarHabilitado := True;
  FBotaoRelatorioHabilitado := True;
  FBotaoImpressaoHabilitado := True;
  FBotaoAbrirHabilitado     := True;
  FBotaoOutrosHabilitado    := True;

  ConfiguraPermissoes;

  Sec[1] := 'Cadastros';
  Ide[1] := 'AlinhamentoBotoes';
  Con[1] := 'E';
  Con[1] := TArquivoIni.Ler(Sec[1], Ide[1], Con[1]);
  if Con[1] = 'E' then
    Panel1.Align := alLeft
  else
    Panel1.Align := alRight;
  Esquerda1.Checked := (Con[1] = 'E');
  Direita1.Checked  := (Con[1] = 'D');

  if PageControl1.PageCount = 1 then
  begin
    TabSheet1.TabVisible := False;
    PageControl1.TabStop := False;
  end;
  PageControl1.ActivePageIndex := 0;

  DS.DataSet := DMCadastro.CDSCadastro;

  DMCadastro.CarregaBloqueioDosCampos(Self);

  LogDeAlteracoes.Visible := (DMConexao.SecaoAtual.Parametro.RegistraLog_Tabela) or (DMCadastro.ClasseFilha.ForcarRegistraLogTabela);
  LogAcessoTela.Visible     := DMConexao.SecaoAtual.Parametro.RegistraLog_Tela;
  ConfigValidaoRegistros.Visible := FPrincipal.miConfigValidaoRegistros.Visible and FPrincipal.miConfigValidaoRegistros.Enabled;
end;

procedure TFPaiCadastro.ConfiguraPermissoes;
begin
  with DMCadastro do
  begin
    BotaoPermissaoInclui.Enabled := UsuarioInclui;
    BotaoPermissaoAltera.Enabled := UsuarioAltera;
    BotaoPermissaoExclui.Enabled := UsuarioExclui;
  end;

  if BotaoPermissaoInclui.Enabled then
    BotaoPermissaoInclui.Hint := 'Você tem permissão para Incluir'
  else
    BotaoPermissaoInclui.Hint := 'Você NÃO tem permissão para Incluir';

  if BotaoPermissaoAltera.Enabled then
    BotaoPermissaoAltera.Hint := 'Você tem permissão para Alterar'
  else
    BotaoPermissaoAltera.Hint := 'Você NÃO tem permissão para Alterar';

  if BotaoPermissaoExclui.Enabled then
    BotaoPermissaoExclui.Hint := 'Você tem permissão para Excluir'
  else
    BotaoPermissaoExclui.Hint := 'Você NÃO tem permissão para Excluir';
end;

procedure TFPaiCadastro.FormShow(Sender: TObject);
var
  PosicionarNoCodigo: String;
begin
  inherited;
  if not ChamadoPelaConsulta then
    FDMCadastro.CDSCadastro.Close;

  if Assigned(DS.OnStateChange) then
    DS.OnStateChange(FDMCadastro.CDSCadastro);

  if (PanelChave.Enabled) and (PanelChave.Visible) and EditCodigo.Canfocus then
    EditCodigo.SetFocus;

  if ChamadoPelaConsulta then
  begin
    BotaoIncluir.Click;
    BotaoIncluir.Visible   := False;
    BotaoExcluir.Visible   := False;
    BotaoConsultar.Visible := False;
    BotaoRelatorio.Visible := False;
    BotaoOutros.Visible    := False;
    PanelChave.Visible     := False;
  end
  else
  begin
    // Lendo Parâmetros passados ao cadastro
    PosicionarNoCodigo  := TFuncoesString.SoNumero(Parametros.Values[sCadastro_PosicionarNoCodigo]);
    BloquearManipulacao := (Parametros.Values[sCadastro_BloquearManipulacao] = 'S');

    if BloquearManipulacao then
    begin
      DMCadastro.UsuarioInclui := False;
      DMCadastro.UsuarioAltera := False;
      DMCadastro.UsuarioExclui := False;
    end;

    if (PosicionarNoCodigo <> '') then
    begin
      EditCodigo.Text := PosicionarNoCodigo;
      TFuncoesForm.ProximoControle;
      if FDMCadastro.CDSCadastro.IsEmpty then
        if BloquearManipulacao then
          Close;
    end;
    if BloquearManipulacao then
    begin
      Panel1.Visible         := False;
      PanelChave.Enabled     := False;
      PanelNavigator.Visible := False;
      PanelPermissao.Visible := False;
      DS.AutoEdit            := False;
    end;
  end;
end;

procedure TFPaiCadastro.ImportarContedo1Click(Sender: TObject);
begin
  with FDMCadastro do
    try
      ImportandoRegistros := True;
      GerouNovoCodigo     := False;
      DMConexao.ImportarRegistrosParaCDS(
        BotaoIncluir, BotaoGravar,
        ClasseFilha.TabelaPrincipal,
        ClasseFilha.Descricao + ' - ' + IntToStr(EditCodigo.AsInteger),
        CDSCadastro,
        AntesDeGravarImportacao,
        AntesDeAceitarImportacao);
    finally
      ImportandoRegistros := False;
    end;
end;

procedure TFPaiCadastro.LogAcessoTelaClick(Sender: TObject);
begin
  ConsultasDisp.ConsultaLog_Tela(-1, 'LOG_TELAS.FORMULARIO_LOGTELAS = ' + QuotedStr(Self.Name));
end;

procedure TFPaiCadastro.LogDeAlteracoesClick(Sender: TObject);
var
 RegistroSecundario : Int64;
begin
  if DMCadastro.CDSCadastro.IsEmpty then
    Exit;

  RegistroSecundario := 0;
  if DMCadastro.ClasseFilha.CampoRegistroSecundario <> '' then
    RegistroSecundario := DMCadastro.CDSCadastro.FieldByName(DMCadastro.ClasseFilha.CampoRegistroSecundario).AsInteger;

  ExibeLogTabela(
    Self,
    DMCadastro.ClasseFilha.TabelaPrincipal,
    DMCadastro.ClasseFilha.Descricao,
    DMCadastro.CDSCadastro.FieldByName(DMCadastro.ClasseFilha.CampoChave).AsInteger,
    RegistroSecundario,
    DMCadastro.CDSCadastro,
    DMCadastro.ClasseFilha);
end;

procedure TFPaiCadastro.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TeclaAoEntrarNoEvento: Word;
  Controle_JvDBComboBoxFocado: TWinControl;
begin
  inherited;
  if Shift = [] then
  begin
    Controle_JvDBComboBoxFocado := ActiveControl;
    TeclaAoEntrarNoEvento       := Key;
    if (Key = VK_ESCAPE) then
    begin
      if (ActiveControl is TDBGrid) and
        ((ActiveControl as TDBGrid).DataSource.State in [dsEdit, dsInsert]) then
      begin
        (ActiveControl as TDBGrid).DataSource.DataSet.Cancel;
        Key := VK_CLEAR;
      end
      else if (FDMCadastro.CDSCadastro.State in [dsEdit, dsInsert]) then
        Key := VK_F6;
    end;
    case Key of
      VK_ESCAPE:
        if not Assigned(Parent) then
          Self.Close;
      VK_F3:
        if (Panel1.Enabled) and (BotaoIncluir.Enabled) and (BotaoIncluir.Visible) then
          BotaoIncluir.Click;
      VK_F4:
        if (Panel1.Enabled) and (BotaoExcluir.Enabled) and (BotaoExcluir.Visible) then
          BotaoExcluir.Click;
      VK_F5:
        if (Panel1.Enabled) and (BotaoGravar.Enabled) and (BotaoGravar.Visible) then
          BotaoGravar.Click;
      VK_F6:
        if (Panel1.Enabled) and (BotaoCancelar.Enabled) and (BotaoCancelar.Visible) then
          BotaoCancelar.Click;
      VK_F7:
        if (Panel1.Enabled) and (BotaoConsultar.Enabled) and (BotaoConsultar.Visible) then
          BotaoConsultar.Click;
      VK_F8:
        if (Panel1.Enabled) and (BotaoRelatorio.Enabled) and (BotaoRelatorio.Visible) then
          BotaoRelatorio.Click;
      VK_F9:
        if (Panel1.Enabled) and (BotaoOutros.Enabled) and (BotaoOutros.Visible) then
          BotaoOutros.Click;
      VK_F12:
        if (Panel1.Enabled) and (BotaoImpressao.Enabled) and (BotaoImpressao.Visible) then
          BotaoImpressao.Click;
    end;

    (* Para resolver o problema ao teclar esc no campo TJvDB
      Parece que o componente captura a tecla e faz evento, o que estaria ocasionando a edicao do
      dataset, quando trocado a tecla dentro desse escopo
    *)
    if (Controle_JvDBComboBoxFocado is TJvCustomDBComboBox) then // Essa Classe dá pau: TJvDBComboBox
      Key := TeclaAoEntrarNoEvento;
    // Informacao('TEcla prossegue com outro codigo, é controle jv');
  end
  else if (Shift = [ssCtrl]) and (Key = VK_F12) and (TrocaDeCodigosReferencias1.Visible) then
    TrocaDeCodigosReferencias1Click(TrocaDeCodigosReferencias1)
  else if (Shift = [ssAlt]) and (PanelChave.Enabled) and (PanelChave.Visible) and (PanelNavigator.Visible) then
  begin
    if (Key = VK_DELETE) and (SBBotaoFiltroDinamico.Enabled) then
      SBBotaoFiltroDinamico.Click;
    if (Key = VK_HOME) and (SBPrimeiro.Enabled) then
      SBPrimeiro.Click;
    if (Key = VK_LEFT) and (SBAnterior.Enabled) then
      SBAnterior.Click;
    if (Key = VK_RIGHT) and (SBProximo.Enabled) then
      SBProximo.Click;
    if (Key = VK_END) and (SBUltimo.Enabled) then
      SBUltimo.Click;
  end;
end;

procedure TFPaiCadastro.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;

  if not DMConexao.SQLConexao.Connected then
    Exit;

  with FDMCadastro.CDSCadastro do
    if (State in [dsEdit, dsInsert]) or (ChangeCount > 0) then
    begin
      case TCaixasDeDialogo.Confirma(sConfirmaGravacao, [mbYes, mbNo, mbCancel], mbYes) of
        mrYes:
          begin
            BotaoGravar.Click;
            // Se depois de gravar, continuar em edição, por um problema na gravação,
            // cancela o fechamento do form
            if (State in [dsEdit, dsInsert]) or (ChangeCount > 0) then
              CanClose := False;
          end;
        mrNo:
          begin
            FechandoCadastro := True;
            try
              BotaoCancelar.Click;
            finally
              FechandoCadastro := False;
            end;
          end;
        mrCancel:
          CanClose := False;
      end;

      if not CanClose then
        Abort;
    end;
end;

procedure TFPaiCadastro.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  PanelChave.OnExit := nil;

  Con[1] :=
    IfThen(Panel1.Align = alLeft, 'E',
    IfThen(Panel1.Align = alRight, 'D', Con[1]));
  TArquivoINI.Gravar(Sec, Ide, Con);

  if Assigned(FDMCadastro) then
    FreeAndNil(FDMCadastro);

  Action := caFree;
end;

procedure TFPaiCadastro.BotaoImpressaoClick(Sender: TObject);
var
  CDSTemp: TClientDataSet;
  sSQL: String;
  I, iCodModelo: Integer;
  Tela: TForm;
  NomeTelaAtual, NomeDaTelaRel: string;
  Persist: TPersistentClass;
begin
  // Forçar validação do campo onde estiver posicionado, antes de permitir a impressão
  // Ex: Não permitir impressão dos cadastros com códigos zero.
  ActiveControl := Panel1;
  if (ActiveControl <> Panel1) then
    Exit;

  if EditCodigo.AsInteger <= 0 then
    Exit;

  NomeTelaAtual := UpperCase(Self.Name);

  sSQL :=
    'select ' + #13 +
    '  CONFIG_SISTEMA_IMPRESSAO.MODELORELATORIO_CSI ' + #13 +
    'from CONFIG_SISTEMA_IMPRESSAO ' + #13 +
    'where CONFIG_SISTEMA_IMPRESSAO.FORMULARIO_CSI = ' + QuotedStr(UpperCase(Self.Name)) + #13 +
    '  and CONFIG_SISTEMA_IMPRESSAO.EMPRESA_CSI    = ' + IntToStr(DMConexao.SecaoAtual.Empresa.Codigo);

  NomeDaTelaRel := '';
  for I         := Low(mFormularioImpressao) to High(mFormularioImpressao) do
    if UpperCase(String(mFormularioImpressao[I].FormCadastro)) = NomeTelaAtual then
    begin
      NomeDaTelaRel := UpperCase(String(mFormularioImpressao[I].FormRelatorio));
      Break;
    end;

  if NomeDaTelaRel = '' then
    TCaixasDeDialogo.Erro(
      'Código de modelo configurado não pertence ao formulário atual.' + #13 +
      'Favor verificar as configurações de "modelos de impressão" no parâmetro do sistema.' + #13 +
      '(Menu principal do sistema, Utilitários, Parâmetro de funcionamento.', True);

  CDSTemp := TClientDataSet.Create(Self);
  try
    CDSTemp.Data := DMConexao.ExecuteReader(sSQL);

    iCodModelo := CDSTemp.FieldByName('MODELORELATORIO_CSI').AsInteger;
    if (iCodModelo > 0) then
    begin
      Persist := FindClass('T' + NomeDaTelaRel);

      if (Persist = nil) then
        raise Exception.Create('Formulário para a classe T' + NomeDaTelaRel + ' não disponível nesse módulo, entre em contato com a Tek-System');

      Tela := TFormClass(Persist).Create(Self);

      if Tela.InheritsFrom(TFPaiRelatorioGrafico) then
        TFPaiRelatorioGrafico(Tela).NomeFormularioDonoDoRelatorio := NomeDaTelaRel
      else if Tela.InheritsFrom(TFPaiRelatorioHibrido) then
        TFPaiRelatorioHibrido(Tela).NomeFormularioDonoDoRelatorio := NomeDaTelaRel
      else
        raise Exception.Create('Tela inválida para impressão.');

      FPrincipal.ImprimeDocumentos(Tela, TCustomFormClass(Tela), iCodModelo, EditCodigo.AsInteger);
    end
    else
      TCaixasDeDialogo.Informacao('Modelo de impressão não definido no parâmetro de funcionamento.');
  finally
    FreeAndNil(CDSTemp);
  end;
end;

procedure TFPaiCadastro.BotaoIncluirClick(Sender: TObject);
var
  EventoStateChange, EventoExit: procedure(Sender: TObject) of object;
begin
  if (FDMCadastro.CDSCadastro.State in [dsInsert, dsEdit]) then
    Exit;

  EventoExit        := PanelChave.OnExit;
  PanelChave.OnExit := nil;

  // Evitar que seja executado, duas vezes
  EventoStateChange := DS.OnStateChange;
  DS.OnStateChange  := nil;

  try
    EditCodigo.AsInteger         := 0;
    PageControl1.ActivePageIndex := 0;
    with FDMCadastro, CDSCadastro do
    begin
      Close;
      CodigoAtual := -1;
      Open;
      Insert;
    end;

    if PageControl1.Canfocus then
      PageControl1.SetFocus;

    if Assigned(EventoStateChange) then
      EventoStateChange(FDMCadastro.CDSCadastro);

    TFuncoesForm.ProximoControle;
  finally
    PanelChave.OnExit := EventoExit;
    DS.OnStateChange  := EventoStateChange;
  end;
end;

procedure TFPaiCadastro.BotaoExcluirClick(Sender: TObject);
begin
  if Panel1.Canfocus then
    Panel1.SetFocus;
  if Panel1.Visible and (ActiveControl <> Panel1) then
    Exit;

  with FDMCadastro.CDSCadastro do
    if (not Active) or (IsEmpty) then
      TCaixasDeDialogo.Informacao(sSemRegistroParaExcluir)
    else
    begin
      if (DMConexao.SecaoAtual.SistemaSomenteLeitura) then
      begin
        TCaixasDeDialogo.Informacao(sMensagemSistemaSomenteLeitura);
        Abort;
      end;
      if (not FDMCadastro.UsuarioExclui) then
      begin
        TCaixasDeDialogo.Informacao(sRestricaoExclusao);
        Exit;
      end;

      VerificarOutrasPermissoesDeExclusao;

      if not TCaixasDeDialogo.Confirma(Format(sDesejaExcluir, [DMCadastro.ClasseFilha.Descricao])) then
        Exit;

      try
        Delete;

        if (ChangeCount = 0) then
        begin
          Close;
          EditCodigo.AsInteger := 0;
          if EditCodigo.Canfocus then
            EditCodigo.SetFocus;
        end
        else // Retornar com o registro deletado e detalhes
        begin
          UndoLastChange(True);
          Close;
          Open;
        end;
      except
        // Retornar com o registro deletado e detalhes
        UndoLastChange(True);
        Close;
        Open;
        Raise;
      end;
    end;
end;

procedure TFPaiCadastro.SBBotaoFiltroDinamicoClick(Sender: TObject);
begin
  DMCadastro.FiltroDinamicoNavegacao := '';
  SBBotaoFiltroDinamico.Visible      := False;
  AlinharBotoesPanelNavigator;
end;

procedure TFPaiCadastro.BotaoGravarClick(Sender: TObject);
begin
  if Panel1.Canfocus then
    Panel1.SetFocus;
  with FDMCadastro.CDSCadastro do
    if State in [dsInsert, dsEdit] then
      Post;

  try
    // Chamada explicita, não passando pelo evento AfterPost
    FDMCadastro.AfterPost(FDMCadastro.CDSCadastro);
  finally
    EditCodigo.AsInteger := FDMCadastro.CodigoAtual;

    // Quando ocorria erro, posicionava no código e o usuário não tinha chance de corrigir
    // pois ao sair novamente do código, ele busca o registro original no banco de dados
    if (FDMCadastro.CDSCadastro.ChangeCount = 0) then
    begin
      if ChamadoPelaConsulta then
      begin
        RetornoCadastro := EditCodigo.AsInteger;
        ModalResult     := mrOk;
      end
      else
      begin
        if EditCodigo.Canfocus then
          EditCodigo.SetFocus;
      end;
    end
    else
      try
        FDMCadastro.EdicaoAposErro := True;
        FDMCadastro.CDSCadastro.Edit;
      finally
        FDMCadastro.EdicaoAposErro := False;
      end;
  end;
end;

procedure TFPaiCadastro.AntesDeAceitarImportacao(CDS: TDataSet);
begin
  // não apagar, método necessário pois é chamado na importação de registros
  // O código dele só existirá em classes derivadas
end;

procedure TFPaiCadastro.AntesDeGravarImportacao(DataSet: TDataSet);
var NovaDescr: string;
begin
  if (DMCadastro.ClasseFilha.CampoDescricao <> '') and (DataSet = DS.DataSet) then
    with DS.DataSet, DMCadastro.ClasseFilha do
    begin
      NovaDescr                            := FieldByName(CampoDescricao).AsString + '_COPIA';
      NovaDescr                            := InputBox('Informe nova descrição', 'Descrição', NovaDescr);
      FieldByName(CampoDescricao).AsString := AnsiUpperCase(NovaDescr);
    end
end;

procedure TFPaiCadastro.BotaoCancelarClick(Sender: TObject);
var Acao: String;
begin
  if Panel1.Canfocus then
    Panel1.SetFocus;

  if DS.State in [dsInsert, dsEdit] then
    begin
      if (not FechandoCadastro) then
        begin
          if (DS.State = dsInsert) then
            Acao := 'inclusão'
          else
            Acao := 'alteração';

          if not TCaixasDeDialogo.Confirma(Format('Cancelar a %s deste registro da tabela %s?', [Acao, DMCadastro.ClasseFilha.Descricao])) then
            Exit;
        end;

      FDMCadastro.CDSCadastro.Cancel;
    end;

  if (EditCodigo.AsInteger = 0) then
    FDMCadastro.CDSCadastro.Close;

  if ChamadoPelaConsulta then
    begin
      RetornoConsulta.LimparRetornos;
      ModalResult := mrCancel
    end
  else
    begin
      if EditCodigo.Canfocus then
        EditCodigo.SetFocus;
    end;
end;

procedure TFPaiCadastro.BotaoConsultarClick(Sender: TObject);
begin
  if (FProcConsulta <> '') then
  begin
    ConsultasDisp.Consulte(FProcConsulta, EditCodigo.AsInteger);
    if RetornoConsulta.Retorno[1] <> null then
    begin
      EditCodigo.Text := RetornoConsulta.Retorno[1];
      if (ActiveControl = EditCodigo) then
      begin
        if PageControl1.Canfocus then
          PageControl1.SetFocus;
        if (PageControl1.PageCount = 1) then
          TFuncoesForm.ProximoControle;
      end
      else if Assigned(PanelChave.OnExit) then
        PanelChave.OnExit(PanelChave);

      DMCadastro.FiltroDinamicoNavegacao := RetornoConsulta.SentencaFiltro;
      if (DMCadastro.FiltroDinamicoNavegacao = '') then
        SBBotaoFiltroDinamico.Click
      else
      begin
        SBBotaoFiltroDinamico.Visible := True;
        AlinharBotoesPanelNavigator;
      end;
    end;
  end;
end;

procedure TFPaiCadastro.BotaoRelatorioClick(Sender: TObject);
begin
  // não apagar
end;

procedure TFPaiCadastro.SBNavegadorClick(Sender: TObject);
var
  Atual, Ir: Integer;
begin
  Atual := EditCodigo.AsInteger;
  Ir    := 0;
  try
    case TSpeedButton(Sender).Tag of
      0:
        Ir := FDMCadastro.Primeiro;
      1:
        Ir := FDMCadastro.Anterior(EditCodigo.AsInteger);
      2:
        Ir := FDMCadastro.Proximo(EditCodigo.AsInteger);
      3:
        Ir := FDMCadastro.Ultimo;
    end;
  except
    on E: EVariantTypeCastError do
      Ir := Atual;
  end;
  if (Ir = 0) then
    Ir := Atual;
  if (Ir <> Atual) then // Evitar buscas desnecessárias
  begin
    EditCodigo.AsInteger := Ir;
    if (ActiveControl = EditCodigo) then
    begin
      if PageControl1.Canfocus then
        PageControl1.SetFocus;
      TFuncoesForm.ProximoControle;
    end
    else if Assigned(PanelChave.OnExit) then
      PanelChave.OnExit(PanelChave);
  end;
end;

procedure TFPaiCadastro.AlinharBotoesPanelNavigator;
begin
  if SBBotaoFiltroDinamico.Visible then
  begin
    SBPrimeiro.Width := 19;
    SBAnterior.Width := 19;
    SBProximo.Width  := 19;
    SBUltimo.Width   := 19;

    SBPrimeiro.Left            := 00;
    SBAnterior.Left            := 19;
    SBBotaoFiltroDinamico.Left := 38;
    SBProximo.Left             := 57;
    SBUltimo.Left              := 76;
  end
  else
  begin
    SBPrimeiro.Width := 23;
    SBAnterior.Width := 23;
    SBProximo.Width  := 23;
    SBUltimo.Width   := 23;

    SBPrimeiro.Left := 02;
    SBAnterior.Left := 25;
    SBProximo.Left  := 48;
    SBUltimo.Left   := 71;
  end;
end;

procedure TFPaiCadastro.DSStateChange(Sender: TObject);
var
  DSS: TDataSetState;
begin
  if (FDMCadastro = nil) then
    Exit;

  DSS := DS.State;

  BotaoIncluir.Enabled   := (DSS in [dsBrowse, dsInactive]) and FBotaoIncluirHabilitado;
  BotaoExcluir.Enabled   := (DSS in [dsBrowse]) and (not FDMCadastro.CDSCadastro.IsEmpty) and FBotaoExcluirHabilitado;
  BotaoGravar.Enabled    := (DSS in [dsInsert, dsEdit]) and FBotaoGravarHabilitado;
  BotaoCancelar.Enabled  := (DSS in [dsInsert, dsEdit]) and FBotaoCancelarHabilitado;
  BotaoConsultar.Enabled := (DSS in [dsBrowse, dsInactive]) and FBotaoConsultarHabilitado;
  BotaoRelatorio.Enabled := (DSS in [dsBrowse, dsInactive]) and FBotaoRelatorioHabilitado;
  BotaoImpressao.Enabled := (BotaoImpressao.Visible) and (DSS in [dsBrowse, dsInactive]) and FBotaoImpressaoHabilitado;
  BotaoOutros.Enabled    := FBotaoOutrosHabilitado;

  PanelChave.Enabled := (DSS in [dsBrowse, dsInactive]);
end;

procedure TFPaiCadastro.Direita1Click(Sender: TObject);
begin
  Direita1.Checked := True;
  Panel1.Align     := alRight;
end;

procedure TFPaiCadastro.EditCodigoButtonClick(Sender: TObject);
begin
  BotaoConsultar.Click;
  Abort;
end;

procedure TFPaiCadastro.Esquerda1Click(Sender: TObject);
begin
  Esquerda1.Checked := True;
  Panel1.Align      := alLeft;
end;

procedure TFPaiCadastro.PanelChaveExit(Sender: TObject);
var
  Evento: procedure(Sender: TObject) of object;
begin
  inherited;
  if (EditCodigo.AsInteger = 0) then
  begin
    if EditCodigo.Canfocus then
      EditCodigo.SetFocus;
    Abort;
  end;
  with FDMCadastro, CDSCadastro do
  begin
    // Evitar que seja executado, duas vezes
    Evento := DS.OnStateChange;
    try
      DS.OnStateChange := nil;

      Close;
      CodigoAtual := EditCodigo.AsInteger;
      Open;

      if IsEmpty then
      begin
        TCaixasDeDialogo.Informacao('Código ' + IntToStr(EditCodigo.AsInteger) + ' da tabela ' + ClasseFilha.Descricao + ' inexistente');
        Close;
        if EditCodigo.Canfocus then
          EditCodigo.SetFocus;
        Abort;
      end;

      // Se estiver atribuido, executar o evento
      if Assigned(Evento) then
        Evento(FDMCadastro.CDSCadastro);
    finally
      // Retornando com o evento anterior
      DS.OnStateChange := Evento;
    end;
  end;
end;

procedure TFPaiCadastro.BotaoOutrosClick(Sender: TObject);
// var P: TPoint;
begin
  DMConexao.KeyNavigator1.Active := False;
  try
    // Dessa forma não posiciona corretamente, se chamar pela tecla de atalho
    // P := BotaoOutros.ClientToScreen(P);
    // PopupMenuOutrasFuncoes.Popup(P.X, p.Y + BotaoOutros.Height);
    PopupMenuOutrasFuncoes.Popup(Left + Panel1.Left + BotaoOutros.Left,
      Top + Panel1.Top + BotaoOutros.Top + BotaoOutros.Height + 23);
  finally
    DMConexao.KeyNavigator1.Active := True;
  end;
end;

procedure TFPaiCadastro.Responsabilidade1Click(Sender: TObject);
begin
  ExibeResponsabilidade(Self, DMCadastro.CDSCadastro, DMCadastro.ClasseFilha);
end;

procedure TFPaiCadastro.TrocaDeCodigosReferencias1Click(Sender: TObject);
begin
  FTrocaCodigos := TFTrocaCodigos(FPrincipal.Tela(Self, FTrocaCodigos, TFTrocaCodigos, True,
    ['ProcedureConsulta=' + FProcConsulta,
    'ClasseFilha=' + FDMCadastro.ClasseFilha.ClassName]));
end;

procedure TFPaiCadastro.ConfigValidaoRegistrosClick(Sender: TObject);
begin
  inherited;
  FCadConfigValidacaoRegistro := TFCadConfigValidacaoRegistro(FPrincipal.Tela(Self, FCadConfigValidacaoRegistro, TFCadConfigValidacaoRegistro, True,
    ['ClassePai=' + FDMCadastro.ClasseFilha.ClassName, 'ClasseFilho=' + FDMCadastro.ClasseFilha.ClassName]));
end;

procedure TFPaiCadastro.VerificarOutrasPermissoesDeExclusao;
begin
  //
end;

procedure TFPaiCadastro.ExportarRegistro1Click(Sender: TObject);
var
  Obj: TWinControl;
begin
  Obj := ActiveControl;
  try
    if Panel1.Canfocus then
      Panel1.SetFocus;
    if Panel1.Visible and (ActiveControl <> Panel1) then
      Exit;
    with FDMCadastro do
      DMConexao.ExportarRegistrosCDS(
        ClasseFilha.TabelaPrincipal,
        ClasseFilha.Descricao + ' - ' + IntToStr(EditCodigo.AsInteger),
        CDSCadastro);
  finally
    ActiveControl := Obj;
  end;
end;

procedure TFPaiCadastro.DuplicarRegistro1Click(Sender: TObject);
var
  CDSTemp: TClientDataSet;
begin
  if Panel1.Canfocus then
    Panel1.SetFocus;
  if Panel1.Visible and (ActiveControl <> Panel1) then
    Exit;

  with FDMCadastro do
  begin
    if (not CDSCadastro.Active) or
      (CDSCadastro.IsEmpty) then
    begin
      TCaixasDeDialogo.Informacao('Não há registro para ser duplicado');
      Exit;
    end;
    if (CDSCadastro.State in [dsEdit, dsInsert]) then
    begin
      TCaixasDeDialogo.Informacao('Salve o registro antes de fazer a duplicação');
      Exit;
    end;

    ImportandoRegistros := True;
    CDSTemp             := TClientDataSet.Create(nil);
    try
      CDSTemp.Data    := CDSCadastro.Data;
      GerouNovoCodigo := False;

      AntesDeAceitarImportacao(CDSTemp);

      with CDSTemp do
      begin
        First;
        while (not Eof) do
        begin
          BotaoIncluir.Click;
          CDSCadastro.DisableControls;
          try
            CDSCadastro.CopiarRegistros(CDSTemp, False, AntesDeGravarImportacao);
          finally
            CDSCadastro.EnableControls;
          end;
          BotaoGravar.Click;

          Next;
        end;
      end;
    finally
      ImportandoRegistros := False;
      CDSTemp.Free;
    end;
  end;
end;

end.
