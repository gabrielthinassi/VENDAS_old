unit ClassDataSet;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DBClient,
  Data.DB,
  Data.SqlExpr,
  System.DateUtils,
  System.Variants,
  Data.FMTBcd,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  System.JSON.Writers,
  System.StrUtils;

type
  TFieldTek = class helper for TField
  public
    function CampoTipoData: Boolean;
    function CampoTipoFloat: Boolean;
    function CampoTipoInteiro: Boolean;
    function CampoTipoNumerico: Boolean;
    function CampoTipoString: Boolean;
    function CampoBoolean: Boolean;

    procedure ConfigurarTipoBoolean(const bGetSet: boolean = True);
    procedure ConfigurarTipoNumerico(const iDigFracionario: Integer = -1; const bOcultaZeroFracionario: Boolean = False);
    procedure ConfigurarTipoData;
    procedure ConfigurarTipoDataHora(const bUtilizarSegundos: Boolean = True);
    procedure ConfigurarTipoHora(const bUtilizarSegundos: Boolean = False; const bUtilizarMiliSegundos: Boolean = False; const bUtilizarViradaDeDia: Boolean = False);

    procedure ConfigurarCampoNaoAtualizavel;

    procedure Configurar;
    procedure AjustarConstraint(Origem: string = '');

    function Formato(const bCalculadoNumerico: Boolean = False): string;

    function ValorAtual: Variant;
    function ValorFormatado(const sFormato: string = ''; const iTamanho: Integer = 0): string;
    function ValorParaSQL: string;

    procedure SetarValor(const sValor: string; const sFormato: string = '');

    procedure Salvar(Dados: OleVariant);
    procedure Recuperar(var imgDestino: TPicture); overload;
    procedure Recuperar(var imgDestino: TImage); overload;
  end;

  TDataSetTek = class helper for TDataSet
  private
  public
    // Verificação
    function EstaEditando: Boolean;

    // Manipulação
    procedure EditarDataSet;
    procedure PostarDataSet;

    procedure AdicionarCampos(const bVerificarSeJaExiste: Boolean = True);
    procedure RemoverCampos;

    procedure MarcarTodos;
    procedure Desmarcar;
    procedure InverterSelecao(const sCampo: string = 'MARQUE');

    //
    procedure ConfigurarProviderFlags(const aChavePrimaria: array of const);
    procedure AtribuirOutrosDefault(CDSDefaults: TClientDataSet; Tabela: string);
    procedure AcertarDefaultDinamico(const sUsuario: string; const dtAtual: TDateTime);
  end;

  TSQLDataSetSetTek = class helper for TSQLDataSet
  public
    procedure CriarParametrosTipoInteiro(Parametros: array of string; DataSource: TDataSource = nil; LimparAntes: Boolean = True);
    procedure CriarParametrosTipos(Parametros: array of string; TipoDeParametro: array of TFieldType; DataSource: TDataSource = nil; LimparAntes: Boolean = True);
  end;

  TClientDataSetTek = class helper for TClientDataSet
  private
    // Ordenação: Persistência dos Indices
    procedure PersistirIndice(const iPosicao: Integer);
    function LerIndice(const sNomeTela: String; sNomeCDS: String = ''): Integer;

    // Ordenação: Auxiliares
    function LocalizarIndice(const sNomeTela, sNomeCDS: String): Integer;
    function AcrescentarIndiceNoVetor: Integer;
  public
    // Manipulação da estrutura
    procedure AdicionarCampoLookup(DataSetLookup: TDataSet;
      const sNomeCampo, sCampoKeyLookup, sCamposLookup, sCampoResultLookup: string;
      const ftTipoCampo: TFieldType; const iTamanho: Integer = 0; const sLabelCampo: string = '');
    procedure AdicionarCampoCalculado(const sNomeCampo: string; const ftTipoCampo: TFieldType; const iTamanho: integer = 0; const fkFieldKind: TFieldKind = fkInternalCalc);

    procedure RemoverCampos; overload;
    procedure RemoverCampos(const aCampos: array of string); overload;

    procedure CriarCampoFloat(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer); deprecated;
    procedure CriarCampoCurrency(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
    procedure CriarCampoFmtBCD(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
    procedure CriarCampoData(const sFieldName, sDisplayLabel: string; const iTag: Integer);
    procedure CriarCampoDataHora(const sFieldName, sDisplayLabel: string; const iTag: Integer);
    procedure CriarCampoInteiro(const sFieldName, sDisplayLabel: string; const iTag: Integer);
    procedure CriarCampoString(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
    procedure CriarCampoMemo(const sFieldName, sDisplayLabel: string; const iTag: Integer);

    procedure CopiarEstrutura(cdsOrigem: TClientDataSet; const aCamposAIgnorar: array of string; const bCriarAbrir: Boolean = True);
    procedure Clonar(cdsOrigem: TClientDataSet; const sCamposIndice: string = '');

    procedure ConfigurarCampos;
    procedure RetirarDefaultExpressionDosCampos;
    function ListarParametros: string;

    // Manipulação de registros
    procedure CopiarRegistro(cdsOrigem: TClientDataSet; const VerificarExistenciaCampo: Boolean = True); overload;
    procedure CopiarRegistro(cdsOrigem: TClientDataSet; const aCamposManter: array of string); overload;
    procedure CopiarRegistros(cdsOrigem: TDataSet; const bGrava: Boolean = True; neAntesDeGravar: TDataSetNotifyEvent = nil);
    procedure CopiarDadosModificados(cdsOrigem: TClientDataSet; const bCopiarMarcadosTambem: Boolean = False; const bMergeChangeLogAoFinal: Boolean = True);

    procedure CarregarDeCampoOleVariant(fCampo: TField);

    procedure LimparRegistros(const bRetiraBeforDelete: Boolean = True; const sCondicaoExclusao: string = '');
    procedure LimparRegistros_Recursivamente;
    procedure DeletarEProximo;

    procedure DuplicarRegistroCorrente;

    // Percorrer
    procedure Percorrer(pExecutarACadaIteracao: TMetodoSimples; fCondicaoContinuarLoop: TFuncaoRetornoBoolean = nil; bPosicionarPrimeiroRegistro: Boolean = True; bDesabilitarControles: Boolean = True);
    procedure TransformarMarcadosEmUm;

    // Ordenação
    function IndexAtivo: Integer;
    function IndexOf(const sNome: string): Integer;

    procedure Ordenar(const sCampos, sCamposDescendente: string);
    procedure SalvarIndice(const sNomeTela: String);
    procedure RestaurarIndice(const sNomeTela: string; const bReposicionarDetalhes:Boolean = True; sNomeCDS: String = ''; sAdicionalCampoIndice: String = '');

  end;

  TFuncoesClientDataSet = class
  public
    class function ContidoIn(CDS: TClientDataSet; CampoCds, CampoSql: string; CondicaoConsiderar: TFuncaoRetornoBoolean = nil): string;
  end;

implementation

uses Constantes;
     //ClassArquivoINI,
     //ClassFuncoesNumero,
     //ClassFuncoesConversao,
     //ClassFuncoesString,
     //ClassFuncoesVetor,
     //ClassFuncoesBaseDados,
     //ClassFuncoesImagem;

{$region 'TFieldTek'}

function TFieldTek.CampoTipoData: Boolean;
begin
  Result := (DataType in [ftDate, ftDateTime, ftTimeStamp]);
end;

function TFieldTek.CampoTipoFloat: Boolean;
begin
  Result := (DataType in [ftExtended, ftFloat, ftCurrency, ftBCD, ftFMTBcd]);
end;

function TFieldTek.CampoTipoInteiro: Boolean;
begin
  Result := (DataType in [ftSmallint, ftInteger, ftLargeint, ftAutoInc, ftShortint, ftLongWord, ftWord]);
end;

function TFieldTek.CampoTipoNumerico: Boolean;
begin
  Result := CampoTipoInteiro or CampoTipoFloat;
end;

function TFieldTek.CampoTipoString: Boolean;
begin
  Result := (DataType in [ftString, ftWideString, ftMemo, ftWideMemo, ftFixedWideChar, ftFmtMemo]);
end;

function TFieldTek.CampoBoolean: Boolean;
begin
  Result := (CustomConstraint = sCC_ValueSimNao);
end;

procedure TFieldTek.ConfigurarTipoBoolean(const bGetSet: boolean = True);
begin
  Alignment := taCenter;
  CustomConstraint := sCC_ValueSimNao;

  if DisplayLabel <> '' then
    ConstraintErrorMessage := DisplayLabel + ' deve ser S ou N!';
end;

procedure TFieldTek.ConfigurarTipoNumerico(const iDigFracionario: Integer = -1; const bOcultaZeroFracionario: Boolean = False);
// Utilizar -1 para usar a configuração automática
var
  iDec, iFrac: Integer;
  F, D: string;
begin
  iDec := 10;
  iFrac := 0;

  // Campo BigInt é mapeado como FMTBCDField, com size zero, logo está ficando com aparencia de campo numeric
  if Self is TBCDField then
    iFrac := TBCDField(Self).Size
  else if Self is TFMTBCDField then
  begin
    iDec := 12;
    iFrac := TFMTBCDField(Self).Size;
  end
  else if CampoTipoFloat then
    iFrac := 2;

  if iDigFracionario >= 0 then
    iFrac := iDigFracionario;

  if iFrac > 0 then
  begin
    if bOcultaZeroFracionario then
      D := TFuncoesString.Completar('#', iFrac, '#')
    else
      D := TFuncoesString.Completar('0', iFrac, '0');

    F := '#0.' + D;
    // Primeiro valor: Positivo, depois negativo
    D := ',0.' + D + ';-,0.' + D;
  end else begin
    D := '';
    F := '#0';
  end;

  with Self as TNumericField do
  begin
    Alignment := taRightJustify;
    DisplayWidth := iDec + iFrac;
    DisplayFormat := D;
    EditFormat := F;
  end;

  if Self.DataType = ftCurrency then
    TCurrencyField(Self).Currency := False;
end;

procedure TFieldTek.ConfigurarTipoData;
begin
  with TDateField(Self) do
  begin
    Alignment := taCenter;
    DisplayWidth := 12;
    DisplayFormat := sDisplayFormatData;
    EditMask := sMascaraData;
  end;
end;

procedure TFieldTek.ConfigurarTipoDataHora(const bUtilizarSegundos: Boolean = True);
begin
  with TDateTimeField(Self) do
  begin
    Alignment := taCenter;

    if bUtilizarSegundos then
    begin
      DisplayWidth := 19;
      DisplayFormat := sDisplayFormatDataHora_HoraMinSeg;
      EditMask := sMascaraDataHoraMinSeg;
    end
    else begin
      DisplayWidth := 16;
      DisplayFormat := sDisplayFormatDataHora;
      EditMask := sMascaraDataHora;
    end;
  end;
end;

procedure TFieldTek.ConfigurarTipoHora(const bUtilizarSegundos: Boolean = False; const bUtilizarMiliSegundos: Boolean = False; const bUtilizarViradaDeDia: Boolean = False);
begin
  with TTimeField(Self) do
  begin
    Alignment := taCenter;

    if bUtilizarViradaDeDia then
    begin
      DisplayWidth := 12;
      DisplayFormat := '999:99:99';
      EditMask := sMascaraHoraMinSeg2;
    end
    else if bUtilizarMiliSegundos then
    begin
      DisplayWidth := 12;
      DisplayFormat := sDisplayFormatHora_HoraMinSegMS;
      EditMask := sMascaraHoraMinSegMS;
    end
    else if bUtilizarSegundos then
    begin
      DisplayWidth := 8;
      DisplayFormat := sDisplayFormatHora_HoraMinSeg;
      EditMask := sMascaraHoraMinSeg;
    end
    else begin
      DisplayWidth := 6;
      DisplayFormat := sDisplayFormatHora;
      EditMask := sMascaraHora;
    end;
  end;
end;

procedure TFieldTek.ConfigurarCampoNaoAtualizavel;
begin
  ProviderFlags := [];
  CustomConstraint := '';
  ConstraintErrorMessage := '';
end;

procedure TFieldTek.Configurar;
begin
  case DataType of
    ftDateTime, ftTimeStamp:
      ConfigurarTipoData;
    ftDate:
      ConfigurarTipoData;
    ftTime:
      ConfigurarTipoHora(True);
    ftCurrency, ftFloat, ftExtended, ftBCD, ftFMTBcd:
      begin
        ConfigurarTipoNumerico;
        CustomConstraint := sCC_ValueIsNotNull;
        DefaultExpression := '0';
      end;
    ftInteger, ftSmallint, ftLargeint, ftWord, ftLongWord, ftAutoInc:
      begin
        CustomConstraint := sCC_ValueIsNotNull;
        DefaultExpression := '0';
        DisplayWidth := 9;
        TIntegerField(Self).DisplayFormat := '#,##0';
        TIntegerField(Self).EditFormat    := '#0';
      end;
    ftString:
      if (Size = 1) then
      begin
        Alignment := taCenter;
        DisplayWidth := 6;
        if not Assigned(OnSetText) then
          OnSetText := TGetTexts.SetText_Campo1Digito;
      end;
    ftMemo, ftBlob:
      Alignment := taCenter;
  end;

  if (FieldName = 'MARQUE') then
    ProviderFlags := [];

  if Required and (CustomConstraint = '') then
    CustomConstraint := sCC_ValueIsNotNull;
end;

procedure TFieldTek.AjustarConstraint(Origem: string = '');
begin
  if (ConstraintErrorMessage = '') and (pfInUpdate in ProviderFlags) then
  begin
    ConstraintErrorMessage := '"';

    if (DisplayLabel = '') then
      ConstraintErrorMessage := ConstraintErrorMessage + FieldName + '"'
    else
      ConstraintErrorMessage := ConstraintErrorMessage + DisplayLabel + '"';

    if Origem <> '' then
      ConstraintErrorMessage := ConstraintErrorMessage + ' de "' + Origem + '"';

    ConstraintErrorMessage := ConstraintErrorMessage + ' deve ser preenchido(a)';

    if (CustomConstraint <> '') and
       (CustomConstraint <> 'VALUE IS NOT NULL'{Constantes.sCC_ValueIsNotNull}) then
      ConstraintErrorMessage := ConstraintErrorMessage + ' obedecendo à condição ' + CustomConstraint;
  end;
end;

function TFieldTek.Formato(const bCalculadoNumerico: Boolean = False): string;
begin
  Result := '';
  case DataType of
    ftInteger, ftSmallint, ftLargeint, ftWord, ftLongWord, ftAutoInc:
      begin
        if bCalculadoNumerico then
          Result := '0##'
        else
          Result := TIntegerField(Self).DisplayFormat;
      end;
    ftBCD:
      begin
        if bCalculadoNumerico then
          Result := ',0.' + StringOfChar('0', TBCDField(Self).Size)
        else
          Result := TBCDField(Self).DisplayFormat;
      end;
    ftFMTBcd:
      begin
        if bCalculadoNumerico then
          Result := ',0.' + StringOfChar('0', TFMTBCDField(Self).Size)
        else
          Result := TFMTBCDField(Self).DisplayFormat;
      end;
    ftCurrency, ftExtended:
      begin
        if bCalculadoNumerico then
          Result := ',0.00##'
        else
          Result := TCurrencyField(Self).DisplayFormat;
      end;
    ftFloat:
      begin
        if bCalculadoNumerico then
          Result := ',0.00#'
        else
          Result := TFloatField(Self).DisplayFormat;
      end;
    ftDate:
      begin
        Result := TDateField(Self).DisplayFormat;
        if Result = '' then
          Result := FormatSettings.ShortDateFormat;
      end;
    ftDateTime, ftTimeStamp:
      begin
        Result := TDateTimeField(Self).DisplayFormat;
        if Result = '' then
          Result := FormatSettings.ShortDateFormat + ' ' + FormatSettings.ShortTimeFormat;
      end;
    ftTime:
      begin
        Result := TTimeField(Self).DisplayFormat;
        if Result = '' then
          Result := FormatSettings.ShortTimeFormat;
      end;
  end;
end;

procedure TFieldTek.Recuperar(var imgDestino: TPicture);
var
  stMem: TMemoryStream;
begin
  imgDestino.Graphic := nil;
  imgDestino.Bitmap := nil;

  if Self.IsNull then
    Exit;

  stMem := TMemoryStream.Create;
  try
    TBlobField(Self).SaveToStream(stMem);
    TFuncoesImagem.MemoryStreamParaPicture(stMem, imgDestino);
  finally
    FreeAndNil(stMem);
  end;
end;

procedure TFieldTek.Recuperar(var imgDestino: TImage);
var
  PICImg: TPicture;
begin
  PICImg := TPicture.Create;
  try
    Self.Recuperar(PICImg);
    imgDestino.Picture.Assign(PICImg);
  finally
    FreeAndNil(PICImg);
  end;
end;

function TFieldTek.ValorAtual: Variant;
begin
  if VarIsEmpty(NewValue) then
    Result := OldValue
  else
    Result := NewValue;
end;

function TFieldTek.ValorFormatado(const sFormato: string = ''; const iTamanho: Integer = 0): string;
var
  FormatoAplic: string;
begin
  Result := '';

  {if sFormato = '' then
    FormatoAplic := Self.Formato
  else}
    FormatoAplic := Trim(sFormato);

  case DataType of
    ftString, ftWideString, ftWideMemo, ftBlob, ftMemo:
      begin
        if (Trim(FormatoAplic) <> '') then
          Result := Format(FormatoAplic, [Self.AsString])
        else
          Result := Self.AsString;
      end;
    ftInteger, ftSmallint, ftLargeint, ftWord, ftLongWord, ftAutoInc:
      begin
        if (Pos('%', FormatoAplic) > 0) then
        begin
          Result := Format(FormatoAplic, [Self.AsCurrency]);
          Result := TFuncoesString.Trocar(Result, FormatSettings.DecimalSeparator, '');
          if iTamanho > 0 then
          begin
            Result := TFuncoesString.Completar(Result, iTamanho, ' ', 2);
            Result := TFuncoesString.Trocar(Result, ' ', '0');
          end;
        end
        else if (Trim(FormatoAplic) <> '') then
          Result := FormatFloat(FormatoAplic, Self.AsCurrency)
        else
          Result := TFuncoesConversao.CurrencyParaString_SemSeparadoDecimal(Self.AsCurrency, iTamanho, 0);
      end;
    ftFloat, ftCurrency, ftExtended, ftBCD, ftFMTBcd:
      begin
        if (Pos('%', FormatoAplic) > 0) then
        begin
          Result := Format(FormatoAplic, [Self.AsCurrency]);
          Result := TFuncoesString.Trocar(Result, FormatSettings.DecimalSeparator, '');
          if iTamanho > 0 then
          begin
            Result := TFuncoesString.Completar(Result, iTamanho, ' ', 2);
            Result := TFuncoesString.Trocar(Result, ' ', '0');
          end;
        end
        else if (Trim(FormatoAplic) <> '') then
          Result := FormatFloat(FormatoAplic, Self.AsCurrency)
        else begin
          if Self is TBCDField then
            Result := TFuncoesConversao.CurrencyParaString_SemSeparadoDecimal(Self.AsCurrency, iTamanho, TBCDField(Self).Size)
          else if Self is TFMTBCDField then
            Result := TFuncoesConversao.CurrencyParaString_SemSeparadoDecimal(Self.AsCurrency, iTamanho, TFMTBCDField(Self).Size)
          else
            Result := TFuncoesConversao.CurrencyParaString_SemSeparadoDecimal(Self.AsCurrency, iTamanho, 2);
        end;
      end;
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      begin
        if (Self.AsDateTime > 0) then
        begin
          if (Trim(FormatoAplic) <> '') then
            Result := FormatDateTime(FormatoAplic, Self.AsDateTime)
          else
            Result := Self.AsString;
        end;
      end
    else
      raise Exception.Create('Função CampoParaStr não preparado para o tipo "' + Self.ClassType.ClassName + '" do campo "' + Self.FieldName + '"');
  end;

  if iTamanho > 0 then
  begin
    case Alignment of
      taLeftJustify: Result := TFuncoesString.Completar(Result, iTamanho, ' ', 0);
      taCenter: Result := TFuncoesString.Completar(Result, iTamanho, ' ', 1);
      taRightJustify: Result := TFuncoesString.Completar(Result, iTamanho, ' ', 2);
    end;
  end;
end;

function TFieldTek.ValorParaSQL: string;
begin
  if CampoTipoData then
    Result := TFuncoesSQL.DataSQL(Self.AsDateTime, 3)
  else if Self.DataType in [ftBCD, ftFMTBcd] then
    Result := TFuncoesSQL.NumeroSQL(BcdToDouble(Self.AsBCD))
  else if CampoTipoFloat then
    Result := TFuncoesSQL.NumeroSQL(Self.AsExtended)
  else if CampoTipoInteiro then
    Result := IntToStr(Self.AsInteger)
  else if Self.IsNull then
    Result := 'null'
  else if CampoTipoString then
    Result := Quotedstr(Self.AsString)
  else
    raise Exception.Create('Função ValorParaSQL não preparado para o tipo "' + Self.ClassType.ClassName + '" do campo "' + Self.FieldName + '"');
end;

procedure TFieldTek.SetarValor(const sValor: string; const sFormato: string = '');
var
  Conteudo: string;
  FormatoAplic: string;
begin
  Conteudo := sValor;

  if sFormato = '' then
  begin
    FormatoAplic := Self.Formato;
    if CampoTipoFloat and (Pos(';', FormatoAplic) > 0) then
      FormatoAplic := TFuncoesString.CorteAte(FormatoAplic, ';');
  end else
    FormatoAplic := sFormato;

  case Self.DataType of
    ftString, ftWideString, ftWideMemo, ftBlob, ftMemo:
      begin
        if (Trim(FormatoAplic) <> '') then
          Self.AsString := Format(FormatoAplic, [Conteudo])
        else
          Self.AsString := Conteudo;
      end;
    ftInteger, ftSmallint, ftLargeint, ftWord, ftLongWord, ftAutoInc:
      begin
        Conteudo := TFuncoesString.Trocar(Conteudo, FormatSettings.ThousandSeparator, '');

        if (Pos('%', FormatoAplic) > 0) then
          Self.AsString := Format(FormatoAplic, [Conteudo])
        else if (FormatoAplic <> '') then
          Self.AsInteger := Trunc(TFuncoesConversao.StringParaExtended(Conteudo, FormatoAplic))
        else
          Self.AsInteger := StrToInt64(Conteudo);
      end;
    ftFloat, ftCurrency, ftExtended, ftBCD, ftFMTBcd:
      begin
        Conteudo := TFuncoesString.Trocar(Conteudo, FormatSettings.ThousandSeparator, '');

        if (Pos('%', FormatoAplic) > 0) then
          Self.AsString := Format(FormatoAplic, [StrToFloat(Conteudo)])
        else if (FormatoAplic <> '') then
          Self.AsCurrency := TFuncoesConversao.StringParaExtended(Conteudo, FormatoAplic)
        else
          Self.AsCurrency := StrToCurr(Conteudo);
      end;
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      begin
        if (Pos('%', FormatoAplic) > 0) then
          Self.AsString := Format(FormatoAplic, [Conteudo])
        else if (FormatoAplic <> '') then
          Self.AsDateTime := TFuncoesConversao.StringParaDataHora(Conteudo, FormatoAplic)
        else
          Self.AsDateTime := StrToDateTime(Conteudo);

        if Self.AsDateTime = 0 then
          Self.Clear;
      end;
    else
      raise Exception.Create('Função SetarValor não preparado para o tipo "' + Self.ClassName + '" do campo "' + Self.FieldName + '"');
  end;
end;

procedure TFieldTek.Salvar(Dados: OleVariant);
var
  ST: TStream;
begin
  if not (DataType in [ftBlob, ftMemo, ftFmtMemo]) then
    raise Exception.Create('O campo "' + FieldName + '" não é do tipo Blob.');

  ST := TMemoryStream.Create;
  try
    TFuncoesConversao.OleVariantParaStream(Dados, ST);
    ST.Position := 0;
    TBlobField(Self).LoadFromStream(ST);
  finally
    FreeAndNil(ST);
  end;
end;

{$endregion}

{$region 'TDataSetTek'}

function TDataSetTek.EstaEditando: Boolean;
begin
  Result := (State in [dsInsert, dsEdit]);
end;

procedure TDataSetTek.EditarDataSet;
begin
  if not Active then
    Exit;

  if not(State in [dsInsert, dsEdit]) then
    Edit;
end;

procedure TDataSetTek.PostarDataSet;
begin
  if (State in [dsInsert, dsEdit]) then
    Post;
end;

procedure TDataSetTek.AdicionarCampos(const bVerificarSeJaExiste: Boolean = True);
var
  X: Integer;
begin
  // Atualizando os tipos dos TFields, conforme tipos dos campos definidos no banco de dados
  Active := False;
  FieldDefs.Update;

  // Criar os TFields inserindo-os no DataSet.
  for X := 0 to FieldDefs.Count - 1 do
    if (not bVerificarSeJaExiste) or (FindField(FieldDefs[x].Name) = nil) then
      FieldDefs.Items[X].CreateField(Self);
end;

procedure TDataSetTek.RemoverCampos;
begin
  Close;
  if (FieldCount > 0) then
    Fields.Clear;
  if (FieldDefs.Count > 0) then
    FieldDefs.Clear;
end;

procedure TDataSetTek.Desmarcar;
begin
  First;
  while (not Eof) do
  begin
    if (FieldByName('MARQUE').AsInteger = 1) then
    begin
      Edit;
      FieldByName('MARQUE').AsInteger := 0;
      Post;
    end;
    Next;
  end;
end;

procedure TDataSetTek.MarcarTodos;
begin
  First;
  while (not Eof) do
  begin
    if (FieldByName('MARQUE').AsInteger = 0) then
    begin
      Edit;
      FieldByName('MARQUE').AsInteger := 1;
      Post;
    end;
    Next;
  end;
end;

procedure TDataSetTek.InverterSelecao(const sCampo: string = 'MARQUE');
var
  F: TField;
begin
  F := FindField(sCampo);
  if IsEmpty or (F = nil) then
    Exit;
  Edit;
  if F.AsInteger = 0 then
    F.AsInteger := 1
  else
    F.AsInteger := 0;
  Post;
end;

procedure TDataSetTek.ConfigurarProviderFlags(const aChavePrimaria: array of const);
var
  x, Y: integer;
begin
  for x := 0 to FieldDefList.Count - 1 do
  begin
    // Para todos os campos
    Fields[x].ProviderFlags := [pfInUpdate];
    Fields[x].Required := False;

    // Para as Chaves Primárias
    for Y := Low(aChavePrimaria) to High(aChavePrimaria) do
      if (AnsiUpperCase(FieldDefList[x].Name) = AnsiUpperCase(aChavePrimaria[Y].{$IFDEF VER185} VPChar {$ELSE} VPWideChar {$endif})) then
      begin
        Fields[x].ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
        Break;
      end;
  end;
end;

procedure TDataSetTek.AtribuirOutrosDefault(CDSDefaults: TClientDataSet; Tabela: string);
var
  Def: string;
  F: TField;
begin
  // Atribui os defaults carregados para o DS, sobrescrevendo os defaults da classe
  Tabela := AnsiUpperCase(Tabela);
  CDSDefaults.DisableControls;
  try
    CDSDefaults.First;
    CDSDefaults.FindKey([Tabela]);
    while ((not CDSDefaults.Eof) and (CDSDefaults.FieldByName('TABELA').AsString = Tabela)) do
      begin
        Def := CDSDefaults.FieldByName('DEFAULT').AsString;
        F   := FindField(Trim(CDSDefaults.FieldByName('CAMPO').AsString));
        if Assigned(F) then
          F.DefaultExpression := Def;

        CDSDefaults.Next;
      end;
  finally
    CDSDefaults.EnableControls;
  end;
end;

procedure TDataSetTek.AcertarDefaultDinamico(const sUsuario: string; const dtAtual: TDateTime);
var X: Integer;
begin
  for X := 0 to Fields.Count - 1 do
    with Fields[X] do
      if (ProviderFlags <> []) and (DefaultExpression <> '') then
        begin
          if (AnsiUpperCase(DefaultExpression) = 'USUARIO') then
            Value := sUsuario
          else if (AnsiUpperCase(DefaultExpression) = 'HOJE') then
            Value := DateToStr(dtAtual)
          else if (AnsiUpperCase(DefaultExpression) = 'AGORA') then
            Value := DateTimeToStr(dtAtual)
          else if (AnsiUpperCase(DefaultExpression) = 'ONTEM') then
            Value := DateToStr(dtAtual - 1)
          else if (AnsiUpperCase(DefaultExpression) = 'AMANHA') then
            Value := DateToStr(dtAtual + 1)
          else if (AnsiUpperCase(DefaultExpression) = 'ANO') then
            Value := IntToStr(YearOf(dtAtual))
          else if (AnsiUpperCase(DefaultExpression) = 'MES') then
            Value := IntToStr(MonthOf(dtAtual))
          else if (AnsiUpperCase(DefaultExpression) = QuotedStr('+')) then
            Value := '+'
          else if (AnsiUpperCase(DefaultExpression) = QuotedStr('-')) then
            Value := '-'
          else if (AnsiUpperCase(DefaultExpression) = 'DATAHORAZERADA') then
            Value := StrToDateTimeDef('30/12/1899 00:00:00', 0)
          else if (AnsiUpperCase(DefaultExpression) = 'NULO') then
            Fields[X].Clear
          else
            AsString := AnsiDequotedStr(DefaultExpression, '''');
        end;
end;

{$endregion}

{$region 'TSQLDataSetSetTek'}
{$if defined(servidor)}
procedure TSQLDataSetSetTek.CriarParametrosTipoInteiro(Parametros: array of string; DataSource: TDataSource = nil; LimparAntes: Boolean = True);
var
  P: array of TFieldType;
  I: Integer;
begin
  SetLength(P, High(Parametros) + 1);
  for I := Low(Parametros) to High(Parametros) do
    P[I] := ftInteger;

  CriarParametrosTipos(Parametros, P, DataSource, LimparAntes);
end;

procedure TSQLDataSetSetTek.CriarParametrosTipos(Parametros: array of string; TipoDeParametro: array of TFieldType; DataSource: TDataSource = nil; LimparAntes: Boolean = True);
var
  iCnt: Integer;
begin
  // Copiado da funcao de cima, alterado apenas o modo de criar
  // if High(Parametros) <> High(TipoDeParametro) then
  // raise Exception.Create('Quantidade de "parâmetros e TipoDeParametro" para função: CriarParametrosTipos devem ser iguais.');

  if LimparAntes then
    Params.Clear;

  for iCnt := Low(Parametros) to High(Parametros) do
    with TParam(Params.Add) do
    begin
      Name := Parametros[iCnt];
      DataType := TipoDeParametro[iCnt];
      ParamType := ptInput;
      if (DataSource = nil) then
      begin
        case DataType of
          ftInteger, ftSmallint, ftLargeint, ftWord, ftLongWord, ftAutoInc, ftBCD, ftCurrency, ftFloat, ftExtended, ftFMTBcd:
            Value := -1;
          ftString, ftWideString:
            begin
              if Size = 1 then
                Value := '0'
              else
                Value := '-1';
            end;
          ftDate:
            Value := DateOf(MinDateTime);
          ftDateTime:
            Value := MinDateTime;
          ftTime:
            Value := TimeOf(MinDateTime);
          ftTimeStamp:
            Value := MinDateTime;
        else
          Value := '-1';
        end;
      end
      else
        Self.DataSource := DataSource;
    end;
end;
{$endif}
{$endregion}

{$region 'TClientDataSetTek'}

procedure TClientDataSetTek.AdicionarCampoLookup(DataSetLookup: TDataSet;
  const sNomeCampo, sCampoKeyLookup, sCamposLookup, sCampoResultLookup: string;
  const ftTipoCampo: TFieldType; const iTamanho: Integer = 0; const sLabelCampo: string = '');
var
  objField: TField;
begin
  if (FindField(sNomeCampo) <> nil) then
    Exit;

  // Cria um TField calculado.
  case ftTipoCampo of
    ftString:
      objField := TStringField.Create(Self);
    ftInteger:
      objField := TIntegerField.Create(Self);
    ftBCD:
      begin
        objField := TBCDField.Create(Self);
        TBCDField(objField).Precision := 9;
        TBCDField(objField).DisplayFormat := '#,###,##0.00';
      end;
    ftDateTime:
      objField := TDateTimeField.Create(Self);
    ftFloat:
      objField := TFloatField.Create(Self);
    ftBoolean:
      objField := TBooleanField.Create(Self);
    ftMemo:
      objField := TMemoField.Create(Self);
  else
    objField := TField.Create(Self);
  end;

  with objField do
  begin
    Name := Self.Name + sNomeCampo;
    FieldName := sNomeCampo;
    if sLabelCampo <> '' then
      DisplayLabel := sLabelCampo
    else
      DisplayLabel := sNomeCampo;
    Calculated := False;
    DataSet := Self;
    FieldKind := fkLookup;
    KeyFields := sCampoKeyLookup;
    Lookup := True;
    LookupDataSet := DataSetLookup;
    LookupKeyFields := sCamposLookup;
    LookupResultField := sCampoResultLookup;
    if (iTamanho > 0) then
      Size := iTamanho;
  end;
end;

procedure TClientDataSetTek.AdicionarCampoCalculado(const sNomeCampo: string; const ftTipoCampo: TFieldType; const iTamanho: integer = 0; const fkFieldKind: TFieldKind = fkInternalCalc);
var
 objField: TField;
 S: string;
begin
  //  Exemplo de uso:
  //  AdicionarCampoCalculado('DESCRICAO_STATUS', ftString, 30, fkCalculated);

  // Verifica antes de criar se o nome já não existe.
  if (FindField(sNomeCampo) <> nil) then
    Exit;

  // Cria um TField calculado.
  case ftTipoCampo of
    ftString: objField  := TStringField.Create(Self);
    ftInteger: objField := TIntegerField.Create(Self);
    ftBCD:
      begin
        objField := TBCDField.Create(Self);
        TBCDField(objField).Precision     := 9;
        TBCDField(objField).DisplayFormat := '#,###,##0.00';
      end;
    ftFMTBcd: // Antonio adicionou
      begin
        objField := TFMTBCDField.Create(Self);
        TFMTBCDField(objField).Precision := 15;
        if iTamanho > 0 then
          S :='#,###,##0.' + TFuncoesNumero.StrZero('0', iTamanho)
        else
          S := '#,###,##0.00';
        TFMTBCDField(objField).DisplayFormat := S;
      end;
    ftDate: objField     := TDateField.Create(Self);
    ftTime: objField     := TTimeField.Create(Self);
    ftDateTime: objField := TDateTimeField.Create(Self);
    ftFloat: objField    := TFloatField.Create(Self);
    ftBoolean: objField  := TBooleanField.Create(Self);
    ftMemo: objField     := TMemoField.Create(Self);
    ftCurrency:
      begin
        objField := TCurrencyField.Create(Self);
        TCurrencyField(objField).Precision     := 15;
        TCurrencyField(objField).DisplayFormat := '#,###,##0.00##';
        TCurrencyField(objField).Currency      := False;
      end
    else
      objField := TField.Create(Self);
  end;

  with objField do
  begin
    Name         := Self.Name + sNomeCampo;
    FieldName    := sNomeCampo;
    DisplayLabel := sNomeCampo;
    Calculated   := True;
    DataSet      := Self;
    // FieldKind := fkInternalCalc;
    FieldKind    := fkFieldKind; // Adicionado como parametro, pois em uma alteração no UFichaCliente
                                // que precisou-se criar um field calculado em tempo de execução, dava
                                // erro ao executar a query mais de duas vezes.
                                // Utilizei o fkCalculated. Alexsander
    if (iTamanho > 0) then
      Size := iTamanho;
  end;
end;

procedure TClientDataSetTek.RemoverCampos(const aCampos: array of string);
var
  CDSTemp: TClientDataSet;
begin
  // Criará um outro CDS
  CDSTemp := TClientDataSet.Create(nil);
  try
    // Copiará a estrutura, exceto os campos a excluir
    CDSTemp.CopiarEstrutura(Self, aCampos);

    // Copiará os registros, exceto os campos que não existem na nova estrutura
    First;
    while (not Eof) do
      begin
        CDSTemp.Insert;
        CDSTemp.CopiarRegistro(Self);
        CDSTemp.Post;
        Next;
      end;

    // Substituirá a estrutura do CDS com a nova sem os campos
    Data := CDSTemp.Data;
  finally
    FreeAndNil(CDSTemp);
  end;
end;

procedure TClientDataSetTek.CriarCampoFmtBCD(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TFMTBCDField.Create(Self);
  with TFMTBCDField(Campo) do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Precision := 15;
    Size := iTamanho;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoFloat(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TFloatField.Create(Self);
  with TFloatField(Campo) do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Precision := iTamanho;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoCurrency(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TCurrencyField.Create(Self);
  with TCurrencyField(Campo) do
  begin
    DisplayLabel := sDisplayLabel;
    Currency := False;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Precision := iTamanho;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoData(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TDateField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoDataHora(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TDateTimeField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoInteiro(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TIntegerField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoString(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TStringField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Size := iTamanho;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoMemo(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TMemoField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CopiarEstrutura(cdsOrigem: TClientDataSet; const aCamposAIgnorar: array of string; const bCriarAbrir: Boolean = True);
var
  X: Integer;
begin
  if (cdsOrigem.FieldCount = 0) then
    Exit;

  with FieldDefs do
  begin
    Close;
    Clear;
    for X := 0 to cdsOrigem.FieldCount - 1 do
      if (cdsOrigem.Fields[X].DataType <> ftDataSet) and (TFuncoesVetor.ContidoNoVetor(aCamposAIgnorar, cdsOrigem.Fields[x].FieldName) = -1) then
        Add(cdsOrigem.Fields[X].FieldName, cdsOrigem.Fields[X].DataType, cdsOrigem.Fields[X].Size, cdsOrigem.Fields[X].Required);
  end;

  if bCriarAbrir then
  begin
    CreateDataSet;
    Open;
  end;
end;

procedure TClientDataSetTek.Clonar(cdsOrigem: TClientDataSet; const sCamposIndice: string = '');
var
  IndiceAnt, CamposIndiceAnt: string;
begin
  if not (cdsOrigem.Active) then
    Exit;

  try
    try
      // Gambiarra, pois esse clone estava copiando com o índice ativo
      // e aí dava pau na função de ordenação, quando tentava excluir o índice
      IndiceAnt := cdsOrigem.IndexName;
      CamposIndiceAnt := cdsOrigem.IndexFieldNames;
      cdsOrigem.IndexName := '';

      Self.CloneCursor(cdsOrigem, True);

      Self.IndexFieldNames := sCamposIndice;
    except
      on E: Exception do
        raise Exception.Create('Ocorreu o seguinte erro ao tentar clonar ' + cdsOrigem.Name + #13 + E.Message);
    end;
  finally
    if (IndiceAnt <> '') then
      cdsOrigem.IndexName := IndiceAnt;
    if (CamposIndiceAnt <> '') then
      cdsOrigem.IndexFieldNames := CamposIndiceAnt;
  end;
end;

procedure TClientDataSetTek.ConfigurarCampos;
var
  x: Integer;
  Campo: string;
begin
  for x := 0 to FieldDefs.Count - 1 do
  begin
    Campo := AnsiUpperCase(FieldDefs.Items[x].Name);
    FieldByName(Campo).Configurar;
  end;
end;

procedure TClientDataSetTek.RetirarDefaultExpressionDosCampos;
var
  x: Integer;
begin
  for x := 0 to Fields.Count - 1 do
    Fields[x].DefaultExpression := '';
end;

function TClientDataSetTek.ListarParametros: string;
var
  iCnt: Integer;
  S: string;
begin
  Result := 'Parametros: ';
  for iCnt := 0 to Pred(Params.Count) do
  begin
    S := TFuncoesString.PadR(Params[iCnt].Name, 15) + ' ==> ' + Params[iCnt].AsString;
    if Pos(S, Result) = 0 then
      Result := Result + S;
  end;
end;

procedure TClientDataSetTek.CopiarRegistro(cdsOrigem: TClientDataSet; const VerificarExistenciaCampo: Boolean = True);
var
  I, UltimoCampo: Integer;
  F: TField;
begin
  if not (State in [dsInsert, dsEdit]) then
    Exit;

  if VerificarExistenciaCampo then
  begin
    for I := 0 to cdsOrigem.FieldCount - 1 do
    begin
      F := FindField(cdsOrigem.Fields[I].FieldName);
      if (F <> nil) and (not F.ReadOnly) then
        F.Assign(cdsOrigem.Fields[I]);
    end;
  end else begin
    // ESTA FUNÇÃO VISA SER MAIS RÁPIDA,
    // deve ser usada quando se tem certeza que a estrutura é a mesma (possui todos os campos e na mesma ordem)

    UltimoCampo := (cdsOrigem.FieldCount - 1);
    for I := 0 to UltimoCampo do
      Fields[I].Assign(cdsOrigem.Fields[I]);
  end;
end;

procedure TClientDataSetTek.CopiarRegistro(cdsOrigem: TClientDataSet; const aCamposManter: array of string);
var
  I, Y: Integer;
  F: TField;
  Flag: Boolean;
begin
  if not (State in [dsInsert, dsEdit]) then
    Exit;

  for I := 0 to cdsOrigem.FieldCount - 1 do
  begin
    Flag := False;
    for Y := Low(aCamposManter) to High(aCamposManter) do
      if (AnsiUpperCase(aCamposManter[Y]) = AnsiUpperCase(cdsOrigem.Fields[I].FieldName)) then
      begin
        Flag := True;
        Break;
      end;
    if Flag then
      Continue;

    F := FindField(cdsOrigem.Fields[I].FieldName);
    if (F <> nil) and (not F.ReadOnly) then
      F.Assign(cdsOrigem.Fields[I]);
  end;
end;

procedure TClientDataSetTek.CopiarRegistros(cdsOrigem: TDataSet; const bGrava: Boolean = True; neAntesDeGravar: TDataSetNotifyEvent = nil);
var
  X: Integer;
  Campo: TField;
begin
  if cdsOrigem.IsEmpty then
    Exit;

  cdsOrigem.First;
  while not cdsOrigem.Eof do
  begin
    if not(Self.State in [dsInsert, dsEdit]) then
      Self.Insert;

    for X := 0 to cdsOrigem.Fields.Count - 1 do
      if (cdsOrigem.Fields[X].FieldKind = fkData) and (Self.FindField(cdsOrigem.Fields[X].FieldName) <> nil) then
      begin
        Campo := Self.FindField(cdsOrigem.Fields[X].FieldName);
        if (Campo.DataType = ftDataSet) then
          TClientDataSet(TDataSetField(Campo).NestedDataSet).CopiarRegistros(TDataSetField(cdsOrigem.Fields[X]).NestedDataSet, True, neAntesDeGravar)
        else
          Campo.Value := cdsOrigem.Fields[X].Value;
      end;

    if Assigned(neAntesDeGravar) then
      neAntesDeGravar(Self);

    PostarDataSet;

    cdsOrigem.Next;
  end;
end;

procedure TClientDataSetTek.CopiarDadosModificados(cdsOrigem: TClientDataSet; const bCopiarMarcadosTambem: Boolean = False; const bMergeChangeLogAoFinal: Boolean = True);
begin
  // Prepara CDS para ser enviado para o servidor, sem delta, apenas dos registros que foram modificados
  Data := cdsOrigem.Data;
  DisableControls;
  try
    ReadOnly := False;
    First;
    while not Eof do
    begin
      if (UpdateStatus = usModified) or ((bCopiarMarcadosTambem) and (FieldByName('MARQUE').AsInteger = 1)) then
        Next
      else
        Delete;
    end;
    if bMergeChangeLogAoFinal then
      MergeChangeLog;
  finally
    EnableControls;
  end;
end;

procedure TClientDataSetTek.CarregarDeCampoOleVariant(fCampo: TField);
var
  ST: TStream;
  CDSTemp: TClientDataSet;
begin
  // Importar o clientdataset de um campos

  CDSTemp := TClientDataSet.Create(nil);
  ST := TMemoryStream.Create;
  try
    TBlobField(fCampo).SaveToStream(ST);
    ST.Position := 0;

    CDSTemp.LoadFromStream(ST);
    CDSTemp.First;

    if Fields.Count = 0 then
      Self.CopiarEstrutura(CDSTemp, []);

    Self.ReadOnly := False;
    Self.CopiarRegistros(CDSTemp);
  finally
    FreeAndNil(ST);
    FreeAndNil(CDSTemp);
  end;
end;

procedure TClientDataSetTek.LimparRegistros(const bRetiraBeforDelete: Boolean; const sCondicaoExclusao: string);
var
  sIndiceCamposAnt, sIndiceAnt, sFilterAnt: string;
  bReadOnly, bFiltroAnt: Boolean;
  EventoFilterRecord: TFilterRecordEvent;
  EventoBeforeScroll, EventoAfterScroll, EventoBeDelete, EventoAfDelete: TDataSetNotifyEvent;
begin
  if (not Active) then
    Exit;

  if (State in [dsInsert, dsEdit]) then
    Cancel;

  sIndiceAnt         := IndexName;
  sIndiceCamposAnt   := IndexFieldNames;
  bReadOnly          := ReadOnly;
  sFilterAnt         := Filter;
  bFiltroAnt         := Filtered;
  EventoBeforeScroll := BeforeScroll;
  EventoAfterScroll  := AfterScroll;
  EventoBeDelete     := BeforeDelete;
  EventoAfDelete     := AfterDelete;
  EventoFilterRecord := OnFilterRecord;
  try
    BeforeScroll   := nil;
    AfterScroll    := nil;
    AfterDelete    := nil;
    OnFilterRecord := nil;
    ReadOnly       := False;
    if bRetiraBeforDelete then
      BeforeDelete := nil;

    IndexFieldNames := '';
    IndexName       := '';

    Filtered := False;
    Filter   := '';
    if (sCondicaoExclusao <> '') then
    begin
      Filter := sCondicaoExclusao;
      Filtered := True;
    end;
    First;
    if (not IsEmpty) then
    begin
      DisableControls;
      while not Eof do
        Delete;
    end;
  finally
    if (sIndiceCamposAnt <> '') then
      IndexFieldNames := sIndiceCamposAnt;
    if sIndiceAnt <> '' then
      IndexName := sIndiceAnt;
    Filter         := sFilterAnt;
    Filtered       := bFiltroAnt;
    ReadOnly       := bReadOnly;
    BeforeScroll   := EventoBeforeScroll;
    AfterScroll    := EventoAfterScroll;
    BeforeDelete   := EventoBeDelete;
    AfterDelete    := EventoAfDelete;
    OnFilterRecord := EventoFilterRecord;
    EnableControls;
  end;
end;

procedure TClientDataSetTek.LimparRegistros_Recursivamente;
var
  I: Integer;
begin
  for I := 0 to FieldCount - 1 do
  begin
    if Fields[I].DataType = ftDataSet then
      TClientDataSet(TDataSetField(Fields[I]).NestedDataSet).LimparRegistros_Recursivamente;
  end;

  if RecordCount > 0 then
    LimparRegistros(False);
end;

procedure TClientDataSetTek.DeletarEProximo;
begin
  Next;
  if Eof then
  begin
    Delete;
    Next;
  end else begin
    Prior;
    Delete;
  end;
end;

procedure TClientDataSetTek.DuplicarRegistroCorrente;
var
  CdsAux: TClientDataSet;
begin
  if Active and (not IsEmpty) and (State = dsBrowse) then
  begin
    CdsAux := TClientDataSet.Create(nil);
    try
      CdsAux.CopiarEstrutura(Self, []);
      CdsAux.Append;
      CdsAux.CopiarRegistro(Self);
      CdsAux.Post;

      Self.Append;
      Self.CopiarRegistro(CdsAux);
    finally
      FreeAndNil(CdsAux);
    end;
  end;
end;

procedure TClientDataSetTek.Percorrer(pExecutarACadaIteracao: TMetodoSimples; fCondicaoContinuarLoop: TFuncaoRetornoBoolean = nil;
  bPosicionarPrimeiroRegistro: Boolean = True;  bDesabilitarControles: Boolean = True);
var
  BM: TBookmark;
  DepoisDeRolar: TDataSetNotifyEvent;
begin
  // Filtros, Ordenação e Posicionamento Inicial devem ser atribuídos antes de chamar este método.
  DepoisDeRolar := nil;
  if bDesabilitarControles then
  begin
    DisableControls;
    DepoisDeRolar := AfterScroll;
    AfterScroll := nil;
  end;
  BM := GetBookmark;
  try
    if bPosicionarPrimeiroRegistro then
      First;

    while (not Eof) and
          ( (not Assigned(fCondicaoContinuarLoop)) or
            fCondicaoContinuarLoop) do
    begin
      pExecutarACadaIteracao;
      Next;
    end;
    GotoBookmark(BM);
  finally
    if bDesabilitarControles then
    begin
      EnableControls;
      AfterScroll := DepoisDeRolar;
    end;
    FreeBookmark(BM);
  end;
end;

procedure TClientDataSetTek.ToJson(
  JSON: TJsonWriter;
  const DelimitaObjeto: boolean;
  ListaExcecao: array of string;
  const NomeObjetoRegistro: String = '';
  MetodoAnonimo: TExecutaProcedureInterface = nil);
var
  Field: TField;
  CampoExcecao: string;
begin
  if (MasterFields <> '') and (IndexFieldNames <> '') then
    CampoExcecao := IndexFieldNames;

  First;
  while not Eof do
  begin
    if (Trim(NomeObjetoRegistro) <> '') then
      begin
        JSON.WriteStartObject;
        JSON.WritePropertyName(NomeObjetoRegistro);
      end;

    if DelimitaObjeto then
      JSON.WriteStartObject;

    for Field in Fields do
      if ((not MatchStr(Field.FieldName, ListaExcecao)) and (Field.FieldName <> CampoExcecao)) then
      begin
        if DelimitaObjeto then
          JSON.WritePropertyName(Field.FieldName);
        case Field.DataType of
          ftString:   JSON.WriteValue(Field.AsString);
          ftInteger:  JSON.WriteValue(Field.AsInteger);
          ftLargeInt: JSON.WriteValue(Field.AsLargeInt);
          ftDateTime: JSON.WriteValue(Field.AsDateTime);
          ftCurrency,
           ftFloat,
           ftExtended,
           ftBCD: JSON.WriteValue(Field.AsFloat);
          ftBoolean: JSON.WriteValue(Field.AsBoolean);
          else       JSON.WriteValue(Field.AsString);
        end;
      end;

    if (Assigned(MetodoAnonimo)) then
      MetodoAnonimo;

    if DelimitaObjeto then
      JSON.WriteEndObject;

    if (Trim(NomeObjetoRegistro) <> '') then
      JSON.WriteEndObject;

    Next;
  end;
end;

procedure TClientDataSetTek.TransformarMarcadosEmUm;
var
  BP: TDataSetNotifyEvent;
  BE: TDataSetNotifyEvent;
  IndiceAnt, CampoIndiceAnt: string;
begin
  // Por não poder usar a claúsula "case" na SQL (devido a compatibilidade com SQLServer)
  // pode-se usar esse procedimento para fazer a troca de todo campo MARQUE diferente de zero para 1

  DisableControls;
  BE := BeforeEdit;
  BP := BeforePost;
  IndiceAnt := IndexName;
  CampoIndiceAnt := IndexFieldNames;

  BeforeEdit := nil;
  BeforePost := nil;
  IndexName := '';
  IndexFieldNames := '';
  try
    First;
    while not Eof do
    begin
      if (FieldByName('MARQUE').AsInteger <> 0) then
      begin
        Edit;
        FieldByName('MARQUE').AsInteger := 1;
        Post;
      end;
      Next;
    end;
    MergeChangeLog;
  finally
    EnableControls;
    BeforeEdit := BE;
    BeforePost := BP;
    if (IndiceAnt <> '') then
      IndexName := IndiceAnt;
    if (CampoIndiceAnt <> '') then
      IndexFieldNames := CampoIndiceAnt;
  end;
end;

function TClientDataSetTek.IndexAtivo: Integer;
begin
  Result := -1;

  if IndexName = '' then
    Exit;

  Result := IndexOf(IndexName);
end;

function TClientDataSetTek.IndexOf(const sNome: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  IndexDefs.Update;
  for I := 0 to IndexDefs.Count - 1 do
    if (IndexDefs[I].Name = sNome) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TClientDataSetTek.Ordenar(const sCampos, sCamposDescendente: string);
var
  I: Integer;
  NomeIndex: string;
  FlagIncluirIdx: boolean;
  idOptions: TIndexOptions;
  B: TBookmark;
begin
  if (not Self.Active) or
     (Assigned(Self.MasterSource)) then
    Exit;

  B := GetBookmark;
  IndexName := idxDefault;

  if (sCampos = '') then
    Exit;

  DisableControls;
  try
    NomeIndex := idxOrdenacao;
    FlagIncluirIdx := True;

    if sCamposDescendente = sCampos then
      idOptions := [ixDescending]
    else
      idOptions := [];

    with IndexDefs do
    begin
      Update;
      for I := 0 to Count - 1 do
        if (Items[I].Name = idxOrdenacao) then
        begin
          if (Items[I].Fields <> sCampos) or (Items[I].DescFields <> sCamposDescendente) or (Items[I].Options <> idOptions) then
            DeleteIndex(idxOrdenacao)
          else
            FlagIncluirIdx := False;
          Break;
        end;
    end;

    if FlagIncluirIdx then
    begin
      try
        AddIndex(NomeIndex, sCampos, idOptions, sCamposDescendente);
      except
        NomeIndex := idxDefault;
      end;
    end;

    try
      IndexName := NomeIndex;
    except
      on E: Exception do
      begin
        IndexName := idxDefault;
        raise Exception.Create('Ocorreu o seguinte erro ao tentar ordenar: ' + #13 + E.Message + #13 + 'Será usada a ordenação padrão');
      end;
    end;

    if BookmarkValid(B) then
      GotoBookmark(B);
  finally
    FreeBookmark(B);
    EnableControls;
  end;
end;

procedure TClientDataSetTek.SalvarIndice(const sNomeTela: String);
// Essa função deve ser chamada no evento BeforeClose
// Para salvar o último índice usado
var
  Posicao: Integer;
  IndiceTemp: TIndexDef;
begin
  if IndexName = '' then
    Exit;

  IndexDefs.Update;

  Posicao := LocalizarIndice(sNomeTela, Self.Name);

  // Se não localizou no vetor, acrescente.
  if (Posicao = -1) then
  begin
    Posicao := AcrescentarIndiceNoVetor;
    with IndicesCDS[Posicao] do
    begin
      Tela         := sNomeTela;
      NomeCDS      := Self.Name;
      IndiceTemp   := Self.IndexDefs.Find(Self.IndexName);
      NomeIndice   := IndiceTemp.Name;
      CamposIndice := IndiceTemp.Fields;
      OpcoesIndice := IndiceTemp.Options;
    end;
  end
  // Se localizou, atualize.
  else
    with IndicesCDS[Posicao] do
    begin
      IndiceTemp   := Self.IndexDefs.Find(Self.IndexName);
      NomeIndice   := IndiceTemp.Name;
      CamposIndice := IndiceTemp.Fields;
      OpcoesIndice := IndiceTemp.Options;
    end;

  PersistirIndice(Posicao);
end;

procedure TClientDataSetTek.RemoverCampos;
begin
  Close;
  if (FieldCount > 0) then
    Fields.Clear;
  if (FieldDefs.Count > 0) then
    FieldDefs.Clear;
end;

procedure TClientDataSetTek.RestaurarIndice(const sNomeTela: string; const bReposicionarDetalhes: Boolean = True; sNomeCDS: String = ''; sAdicionalCampoIndice: String = '');
// Essa função deve ser chamada no evento AfterOpen
// Para restaurar o último índice usado
var
  Posicao: Integer;
begin
  if (sNomeCDS = '') then
    sNomeCDS := Self.Name;

  Posicao := LocalizarIndice(sNomeTela, sNomeCDS);

  // Se não localizou no vetor, olhe no arquivo ini
  if (Posicao = -1) then
    Posicao := LerIndice(sNomeTela, sNomeCDS);

  if (Posicao = -1) then
    Exit;

  // Se conseguiu localizar, recrie o índice
  with IndicesCDS[Posicao] do
    if Self.Active then   // Erro ao debugar
      try
        if (NomeIndice <> idxDefault) then
          AddIndex(NomeIndice, sAdicionalCampoIndice + CamposIndice, OpcoesIndice);
        IndexName := NomeIndice;

         // Gambiarra para resolver o problema de posicionamento em CDS detalhes relacionados
        if bReposicionarDetalhes then // Por causa da producao coloquei isso. Não precisa de movimentar, já que
        begin
          Next;
          Prior;
        end;
      except
        // Caso o campo não exista mais, simplesmente ignore o bloco
      end;
end;

procedure TClientDataSetTek.PersistirIndice(const iPosicao: Integer);
// Grava a configuração do Indice do CDS no arquivo INI
var
  x: Integer;
  Sec, Ide, Con: array[0..2] of string;
begin
  with IndicesCDS[iPosicao] do
  begin
    for x := Low(Sec) to High(Sec) do
      Sec[x] := Tela + '==>' + NomeCDS;
    Ide[0] := 'Nome';       Con[0] := NomeIndice;
    Ide[1] := 'Campos';     Con[1] := CamposIndice;
    Ide[2] := 'Opcoes';     Con[2] := '';
    if (ixPrimary          in OpcoesIndice) then Con[2] := Con[2] + 'ixPrimary;';
    if (ixUnique           in OpcoesIndice) then Con[2] := Con[2] + 'ixUnique;';
    if (ixDescending       in OpcoesIndice) then Con[2] := Con[2] + 'ixDescending;';
    if (ixCaseInsensitive  in OpcoesIndice) then Con[2] := Con[2] + 'ixCaseInsensitive;';
    if (ixExpression       in OpcoesIndice) then Con[2] := Con[2] + 'ixExpression;';
  end;
  TArquivoINI.Gravar(Sec, Ide, Con, '', ArquivoIniIndicesGrade);
end;

function TClientDataSetTek.LerIndice(const sNomeTela: String; sNomeCDS: String = ''): Integer;
// Tenta ler as informações de Indices de CDS gravadas no arquivo INI
var
  Secao, cNomeIndice, Campos, Op: String;
  Posicao: Integer;
begin
  if sNomeCDS = '' then
    sNomeCDS := Self.Name;

  Secao := sNomeTela + '==>' + sNomeCDS;
  cNomeIndice := TArquivoINI.Ler(Secao, 'Nome', '', '', ArquivoIniIndicesGrade);

  // Se não existe a configuração de indice gravada para esse CDS
  if (cNomeIndice = '') then
    Result := -1
  // Se existe
  else begin
    Campos := TArquivoINI.Ler(Secao, 'Campos', '', '', ArquivoIniIndicesGrade);
    Op     := TArquivoINI.Ler(Secao, 'Opcoes', '', '', ArquivoIniIndicesGrade);

    // Recria a Configuração no Vetor
    Posicao := AcrescentarIndiceNoVetor;
    with IndicesCDS[Posicao] do
    begin
      Tela         := sNomeTela;
      NomeCDS      := sNomeCDS;
      NomeIndice   := cNomeIndice;
      CamposIndice := Campos;
      OpcoesIndice := [];
      if Pos('ixPrimary',         Op) > 0 then OpcoesIndice := OpcoesIndice + [ixPrimary];
      if Pos('ixUnique',          Op) > 0 then OpcoesIndice := OpcoesIndice + [ixUnique];
      if Pos('ixDescending',      Op) > 0 then OpcoesIndice := OpcoesIndice + [ixDescending];
      if Pos('ixCaseInsensitive', Op) > 0 then OpcoesIndice := OpcoesIndice + [ixCaseInsensitive];
      if Pos('ixExpression',      Op) > 0 then OpcoesIndice := OpcoesIndice + [ixExpression];
    end;
    Result := High(IndicesCDS);
  end;
end;

function TClientDataSetTek.LocalizarIndice(const sNomeTela, sNomeCDS: String): Integer;
// Localiza a posição da configuração de indice dentro do vetor
var
  x: Integer;
begin
  Result := -1;
  for x := Low(IndicesCDS) to High(IndicesCDS) do
    if (IndicesCDS[x].Tela    = sNomeTela) and
       (IndicesCDS[x].NomeCDS = sNomeCDS) then
    begin
      Result := x;
      Break;
    end;
end;

function TClientDataSetTek.AcrescentarIndiceNoVetor: Integer;
// Provê acesso para um novo elemento do vetor
var
  Tam: Integer;
begin
  Tam := Length(IndicesCDS);
  SetLength(IndicesCDS, Tam + 1);
  Result := Tam;
end;

{$endregion}

class function TFuncoesClientDataSet.ContidoIn(CDS: TClientDataSet; CampoCds, CampoSql: string; CondicaoConsiderar: TFuncaoRetornoBoolean = nil): string;
var
  X: Integer;
  Ant: string;
  r, IndexFieldAnt, IndexNameAnt: string;
  AQuote: Boolean;
begin
  r := '';
  Ant := '-1';

  with CDS do
  begin
    AQuote := FieldByName(CampoCds).CampoTipoString;

    IndexFieldAnt := CDS.IndexFieldNames;
    IndexNameAnt := CDS.IndexName;
    try
      DisableControls;
      if State in [dsInsert, dsEdit] then
        Post;

      IndexFieldNames := CampoCds;
      First;
      r := '(' + CampoSql + ' in (';
      X := 0;
      while (not Eof) do
      begin
        if (Assigned(CondicaoConsiderar)) and (not CondicaoConsiderar) then
        begin
          Next;
          Continue;
        end;

        if (Ant <> FieldByName(CampoCds).AsString) then
        begin
          Ant := FieldByName(CampoCds).AsString;
          if AQuote then
            r := r + QuotedStr(FieldByName(CampoCds).AsString)
          else
          begin
            if (FieldByName(CampoCds).AsString = '') and (FieldByName(CampoCds).CampoTipoNumerico) then
              r := r + '0'
            else
              r := r + FieldByName(CampoCds).AsString;
          end;
          if ((X mod 1498) = 0) and (X <> 0) then
            r := r + ') ' + #10 + ' or ' + CampoSql + ' in ('
          else
            r := r + ',';
          Inc(X);
        end;
        Next;
      end;

      if AQuote then
        r := r + QuotedStr('-1') + '))'
      else
        r := r + '-1))';
    finally
      EnableControls;
      IndexFieldNames := '';
      if (Trim(IndexFieldAnt) <> '') then
        IndexFieldNames := IndexFieldAnt;
      if (Trim(IndexNameAnt) <> '') then
        IndexName := IndexNameAnt;
    end;
  end;
  Result := r;
end;

initialization
  SetLength(IndicesCDS, 0);

finalization
  SetLength(IndicesCDS, 0);

end.
