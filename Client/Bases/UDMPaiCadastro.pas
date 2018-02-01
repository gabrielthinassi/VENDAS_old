unit UDMPaiCadastro;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, Typinfo, DateUtils, DBCtrls, Grids, DBGrids,
  JvDBGrid, Datasnap.DSConnect, System.StrUtils, System.Math,
  UDMPai, ClassPaiCadastro, Data.DBXDataSnap, Data.DBXCommon, IPPeerClient,
  Data.SqlExpr;

type
  TFuncaoLogica = function: boolean of object;

  TDMPaiCadastro = class(TDMPai)
    CDSCadastro: TClientDataSet;
    DSPCCadastro: TDSProviderConnection;

    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

    procedure CDSCadastroBeforeOpen(DataSet: TDataSet);
    procedure CDSCadastroAfterOpen(DataSet: TDataSet);
    procedure CDSCadastroNewRecord(DataSet: TDataSet);
    procedure CDSCadastroBeforeCancel(DataSet: TDataSet);
    procedure CDSCadastroAfterCancel(DataSet: TDataSet);
    procedure CDSCadastroBeforeEdit(DataSet: TDataSet);
    procedure CDSCadastroBeforePost(DataSet: TDataSet);
    procedure CDSCadastroAfterPost(DataSet: TDataSet);
    procedure CDSCadastroBeforeDelete(DataSet: TDataSet);
    procedure CDSCadastroAfterDelete(DataSet: TDataSet);
    procedure CDSCadastroBeforeScroll(DataSet: TDataSet);
    procedure CDSCadastroAfterScroll(DataSet: TDataSet);
    procedure CDSCadastroBeforeClose(DataSet: TDataSet);
    procedure CDSCadastroReconcileError(DataSet: TCustomClientDataSet; e: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);

    procedure AfterPost(DataSet: TDataSet); virtual;
  private
    { GravandoEdicao: Boolean; }

    FClasseFilha: TFClassPaiCadastro;

    FCodigoAtual: integer;
    FIdDetalhe: integer;
    FRefreshRecordAfterPost: boolean;

    FFiltroDinamicoNavegacao: String;

    FAposRolarCadastro: TDataSetNotifyEvent;
    FClasseNavegacao: TFClassPaiCadastro;

    function GetIdDetalhe: integer;
  protected
    procedure AbreDetalhes; virtual;
    procedure Cancele; virtual;
    procedure ZeraParametros; virtual;
    procedure VerificarFechamento(DataSet: TDataSet; Classe: TFClassPaiCadastro); virtual;
  public
    property ClasseFilha: TFClassPaiCadastro read FClasseFilha write FClasseFilha;
    property CodigoAtual: integer read FCodigoAtual write FCodigoAtual;
    property RefreshRecordAfterPost: boolean read FRefreshRecordAfterPost write FRefreshRecordAfterPost;

    property ClasseNavegacao: TFClassPaiCadastro read FClasseNavegacao write FClasseNavegacao;
    property FiltroDinamicoNavegacao: String read FFiltroDinamicoNavegacao write FFiltroDinamicoNavegacao;

    property IdDetalhe: integer read GetIdDetalhe;

    function GetClassNameClasseFilha: string;

    function Primeiro: integer; virtual;
    function Anterior(Atual: integer): integer; virtual;
    function Proximo(Atual: integer): integer; virtual;
    function Ultimo: integer; virtual;
    function Novo: integer; virtual;

    function Aplique(Exclusao: boolean = false): integer; virtual;

    procedure AtribuiAutoIncDetalhe(DataSet: TDataSet; Classe: TFClassPaiCadastro; CampoChaveEstrangeira: String);

    class procedure ValidateGeral(Sender: TField; CampoDescricao: string; sClasseBusca: string; Filtro: string = ''; NomeCDSCache: string = ''; ValidaStatus: boolean = True; ValidaStatusBloqueio: boolean = False); overload;
    class procedure ValidateGeral(Sender: TField; CampoDescricao: string; ClasseBusca: TFClassPaiCadastro; Filtro: string = ''; NomeCDSCache: string = ''; ValidaStatus: boolean = True; ValidaStatusBloqueio: boolean = False); overload;
    class procedure ValidateGeral(Sender: TField; CampoDescricao: string; ClasseBusca: TFClassPaiCadastro; Filtro: string; ValidaStatusBloqueio: boolean); overload;
    class procedure ValidateGeral(Sender: TField; Campos: array of string; ClasseBusca: TFClassPaiCadastro; Empresa: integer = -1; Filtro: string = ''); overload;
    class procedure ValidateGeral(CampoBusca: TField; CamposRetorno: array of string; NomeCampoWhere: string; ClasseBusca: TFClassPaiCadastro; Filtro: string = ''); overload;
    class procedure ValidateGeral(Sender: TField; Campos: array of string; CamposDataSet: array of string; ClasseBusca: TFClassPaiCadastro; Empresa: integer = -1; Filtro: string = ''); overload;
  end;

var
  DMPaiCadastro: TDMPaiCadastro;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

uses Constantes, ClassDataSet;

{$R *.dfm}


procedure TDMPaiCadastro.DataModuleCreate(Sender: TObject);
begin
  inherited;
  FIdDetalhe := 0;
  FRefreshRecordAfterPost := True;

  DSPCCadastro.SQLConnection := ConexaoDS;

  FPrincipal.AdicionaLinhaRich(FClasseFilha.SQLBaseCadastro);

  if DSPCCadastro.ServerClassName <> '' then
    CDSCadastro.RemoteServer := DSPCCadastro;
  CDSCadastro.ProviderName := 'DSPCadastro';

  ZeraParametros;

  with FClasseFilha do
  begin
    //if Trim(CDSCadastro.CommandText) = '' then
    //  CDSCadastro.CommandText := SQLBaseCadastro;

    CDSCadastro.AdicionarCampos;
    ConfigurarPropriedadesDosCampos(CDSCadastro);
    DMConexao.AtribuirOutrosDefault(CDSCadastro, TabelaPrincipal);
  end;

  ConfiguraPermissoes;

  // Tags de controles diversos
  ValidarDetalheDuplicado := True;
  Excluindo := false;
  Gravando := false;
  FImportandoRegistros := false;
  FReplicandoRegistros := False;
  GerouNovoCodigo := false;
  EdicaoAposErro := false;
end;

procedure TDMPaiCadastro.DataModuleDestroy(Sender: TObject);
begin
  inherited;

  DSPCCadastro.Close;
  DSPCCadastro.SQLConnection := nil;
end;

function TDMPaiCadastro.FiltroFixoNavegacao: string;
begin
  Result := '';
end;

procedure TDMPaiCadastro.CDSCadastroBeforeOpen(DataSet: TDataSet);
var
  x: integer;
begin
  with CDSCadastro do
    for x := 0 to Params.Count - 1 do
    begin
      if AnsiUpperCase(Params.Items[x].Name) = 'COD' then
        Params.ParamByName('COD').AsInteger := FCodigoAtual
    end;
end;

procedure TDMPaiCadastro.CDSCadastroBeforeCancel(DataSet: TDataSet);
begin
  inherited;
  DesbloquearRegistros(false);
end;

procedure TDMPaiCadastro.CDSCadastroBeforeClose(DataSet: TDataSet);
begin
  CDSCadastro.SalvarIndice(Self.Name);
end;

procedure TDMPaiCadastro.CDSCadastroBeforeDelete(DataSet: TDataSet);
begin
  if (DMConexao.SecaoAtual.SistemaSomenteLeitura) then
  begin
    TCaixasDeDialogo.Aviso(sMensagemSistemaSomenteLeitura);
    Abort;
  end;

  // Esse teste foi deixado aqui, para prevenir o esquecimento
  // de colocar no DM que gerencia um PaiCadastroGrade
  if (not FUsuarioExclui) then
  begin
    TCaixasDeDialogo.Aviso(sRestricaoExclusao);
    Abort;
  end;

  VerificarFechamento(CDSCadastro, FClasseFilha);

  if FClasseFilha.CampoDescricao <> '' then
    DMLookup.AtualizaCDSLookup(FClasseFilha, CDSCadastro, True);

  Excluindo := True;
end;

procedure TDMPaiCadastro.CDSCadastroBeforeEdit(DataSet: TDataSet);
var
  Quebra: integer;
  CodigoDesconsiderado, UsuBloq, DataHoraBloq: string;
  Retorno: OleVariant;

  procedure RelerRegistro(var CDSPrincipal: TClientDataSet);
  type
    TDetalhes = record
      Cds: TClientDataSet;
      BM: TBookMark;
      EvAfterScroll, EvBeforeScroll: procedure(DataSet: TDataSet) of object;
    end;
  var
    x: integer;
    Detalhes: array of TDetalhes;

    procedure PegaDetalhes(DS: TDataSource);
    var
      y, T: integer;
    begin
      // Pegar todos os CDS que recebem dados do DS em questão
      for y := 0 to ComponentCount - 1 do
        if (Components[y] is TClientDataSet) and
          ((Components[y] as TClientDataSet).DataSetField <> nil) and
          ((Components[y] as TClientDataSet).DataSetField.DataSet = DS.DataSet) then
        begin
          // grava o BookMark dele
          T := Length(Detalhes);
          SetLength(Detalhes, T + 1);
          Detalhes[T].Cds := (Components[y] as TClientDataSet);
          Detalhes[T].EvAfterScroll := Detalhes[T].Cds.AfterScroll;
          Detalhes[T].EvBeforeScroll := Detalhes[T].Cds.BeforeScroll;
          Detalhes[T].BM := Detalhes[T].Cds.GetBookmark;
          (Components[y] as TClientDataSet).AfterScroll := nil;
          (Components[y] as TClientDataSet).BeforeScroll := nil;
        end;
    end;

  begin
    SetLength(Detalhes, 0);

    try
      // Pegar todos os DataSources que apontam para o CDS em questão
      for x := 0 to Owner.ComponentCount - 1 do
        if (Owner.Components[x] is TDataSource) and
          ((Owner.Components[x] as TDataSource).DataSet = CDSPrincipal) then
          PegaDetalhes(Owner.Components[x] as TDataSource);

      CDSPrincipal.RefreshRecord;

      for x := Low(Detalhes) to High(Detalhes) do
        with Detalhes[x] do
          Cds.GotoBookmark(BM);
    finally
      for x := Low(Detalhes) to High(Detalhes) do
        with Detalhes[x] do
        begin
          Cds.FreeBookmark(BM);
          Cds.AfterScroll := EvAfterScroll;
          Cds.BeforeScroll := EvBeforeScroll;
        end;
    end;
  end;

begin
  if (DMConexao.SecaoAtual.SistemaSomenteLeitura) then
  begin
    TCaixasDeDialogo.Aviso(sMensagemSistemaSomenteLeitura);
    Abort;
  end;

  if (CDSCadastro.UpdateStatus <> usInserted) and (not FUsuarioAltera) then
  begin
    TCaixasDeDialogo.Aviso(sRestricaoAlteracao);
    Abort;
  end;

  if (CDSCadastro.UpdateStatus <> usInserted) then
    VerificarFechamento(CDSCadastro, FClasseFilha);

  // Tratamento de edicao simultanea
  with CDSCadastro, ClasseFilha do
    if (BloqueiaEdicaoSimultanea) and (not EdicaoAposErro) and (not ImportandoRegistros) and not(ReplicandoRegistros) then
    begin
      if (CampoEmpresa = '') then
        Quebra := 0
      else
        Quebra := FieldByName(CampoEmpresa).AsInteger;

      Retorno := DMConexao.ExecuteMethods('TSMConexao.IncluiRegistroEmEdicao', [TabelaPrincipal, Quebra, FieldByName(CampoChave).AsString, 0]);

      CodigoDesconsiderado := Retorno[0];
      UsuBloq := Retorno[1];
      DataHoraBloq := Retorno[2];

      if (UsuBloq <> '') then
      begin
        TCaixasDeDialogo.Aviso(Format(Constantes.sRegistroBloqueado, [Descricao, AnsiUpperCase(UsuBloq), DataHoraBloq, CodigoDesconsiderado]));
        Abort;
      end else
        CodigoBloqueio := CodigoDesconsiderado;
    end;

  // if (CDSCadastro.ChangeCount = 0) then
  // RefreshRecord é necessário, pois senão a atribuição de responsabilidade pela última edição ficará comprometida.
  // Ou seja, se o campo USUARIOALTERACAO não for modificado, não será gerada SQL de atualização do campo.
  // E se durante o período entre a visualização do registro e edição do mesmo, outro usuário editar e gravar o registro.
  // A responsabilidade permaneceria para ele, quando na verdade deveria ser do que está editando.

  // Em contrapartida, RefreshRecord pode gerar um comportamento estranho:
  // Se no período entre a visualização e edição do registro, outro usuário fizer uma alteração no registro,
  // ao digitar no meio de um campo string, o conteúdo do campo será atualizado e o caracter digitado sairá no princípio do campo
  // CDSCadastro.RefreshRecord;
  // RelerRegistro(CDSCadastro);
end;

procedure TDMPaiCadastro.CDSCadastroBeforePost(DataSet: TDataSet);
begin
  VerificarFechamento(CDSCadastro, FClasseFilha);

  // GravandoEdicao := (CDSCadastro.State = dsEdit);
  with CDSCadastro, FClasseFilha do
    // Foi trocado de (State = dsInsert) para (UpdateStatus = usInserted)
    // Pois em alguns locais pode ser interessante não executar esse evento
    // quando um dataset detalhe for inserir e voltar a executá-lo depois.
    // Ex: Borderô de Remessa Bancária
    if { (State = dsInsert) } (UpdateStatus = usInserted) and
      ((FieldByName(CampoChave).IsNull) or (FieldByName(CampoChave).AsInteger <= 0) or
      ((FImportandoRegistros) and (not GerouNovoCodigo))) then
    begin
      FCodigoAtual := Novo;
      FieldByName(CampoChave).AsInteger := FCodigoAtual;
      GerouNovoCodigo := True;
    end;
  // Atribuição de resposabilidade aqui é só para alterar o registro,
  // ela será realizada pelo servidor de aplicação.
  AtribuiResponsabilidade(CDSCadastro, FClasseFilha);
end;

procedure TDMPaiCadastro.AfterPost(DataSet: TDataSet);
var
  BM: TBookMark;
begin
  ContinuarTentandoGravar := True;
  repeat
    if (not ContinuarTentandoGravar) then
    begin
      // CDSCadastro.Edit;
      Break;
    end;
  until (Aplique = 0);

  GerouNovoCodigo := false;

  DesbloquearRegistros(false);

  // Reler informações modificadas no servidor, como por exemplo a atribuição de responsabilidade
  if (CDSCadastro.ChangeCount = 0) then
  begin
    // O RefreshRecord funciona, mas se por algum motivo o registro
    // após a gravação não estiver disponível, ocorre erro.
    // Ex: Cadastro de contas: se excluir todos os usuários e gravar a conta
    BM := CDSCadastro.GetBookmark;
    try
      if FRefreshRecordAfterPost then
        CDSCadastro.RefreshRecord
      else
      begin
        CDSCadastro.Close;
        CDSCadastro.Open;
      end;
      if BM <> nil then
        if CDSCadastro.BookmarkValid(BM) then
          CDSCadastro.GotoBookmark(BM);
    finally
      CDSCadastro.FreeBookmark(BM);
    end;
  end;

  if FClasseFilha.CampoDescricao <> '' then
    DMLookup.AtualizaCDSLookup(FClasseFilha, CDSCadastro, True);
end;

procedure TDMPaiCadastro.CDSCadastroAfterCancel(DataSet: TDataSet);
begin
  Cancele;
end;

procedure TDMPaiCadastro.CDSCadastroAfterDelete(DataSet: TDataSet);
begin
  try
    Aplique(True);
  finally
    Excluindo := false;
  end;
end;

procedure TDMPaiCadastro.CDSCadastroAfterOpen(DataSet: TDataSet);
begin
  CDSCadastro.RestaurarIndice(Self.Name);
end;

procedure TDMPaiCadastro.CDSCadastroAfterPost(DataSet: TDataSet);
begin
  // Esse evento não deve ter código algum, pois em estruturas master/detalhe o
  // master é gravado (se estiver inserindo) e for inserido um detalhe.
  // Neste caso, o tratamento é feito na função Aplique e
  // nos demais é chamada a procedure AfterPost explicitamente.
end;

procedure TDMPaiCadastro.CDSCadastroReconcileError(DataSet: TCustomClientDataSet; e: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
var
  x: integer;
  CodigoErro: string;
begin
  // denis falou que podia tirar, veja com ele {$MESSAGE 'MELHORAR O TRATAMENTO DE ERRO'}

  x := Pos('ERROR CODE: ', AnsiUpperCase(e.Message));
  CodigoErro := Trim(Copy(e.Message, x + 12, MaxInt));

  ContinuarTentandoGravar := false;

  if (CodigoErro = '345') and (UpdateKind = ukInsert) then
  begin
    // Violação de chave primária, Em tese não deve ocorrer nunca, mas se ocorrer...
    ContinuarTentandoGravar := TCaixasDeDialogo.Confirma('Código já existe, tentar próximo? Se escolher "NÃO" o registro será perdido.');
    if ContinuarTentandoGravar then
    begin
      FCodigoAtual := Novo;
      DataSet.FieldByName(FClasseFilha.CampoChave).NewValue := FCodigoAtual;
      Action := raCorrect;
    end
    else
      Action := raAbort;
  end
  else
  begin
    Action := raAbort;
    TrataErro(e);
  end;
end;

procedure TDMPaiCadastro.AbreDetalhes;
begin
  // Não apagar, o código dessa função só existirá em alguns cadastros
end;

procedure TDMPaiCadastro.AcertarDefaultDinamico(DataSet: TDataSet);
begin
  DataSet.AcertarDefaultDinamico(DMConexao.SecaoAtual.Usuario.Nome, DMConexao.DataHora);
end;

function TDMPaiCadastro.Primeiro: integer;
var
  s: string;
  e: integer;
  Classe: TFClassPaiCadastro;
begin
  // Retorna o primeiro registro da tabela em questão
  if Assigned(FClasseNavegacao) then
    Classe := FClasseNavegacao
  else
    Classe := FClasseFilha;

  with Classe do
  begin
    s := 'select min(' + TabelaPrincipal + '.' + CampoChave + ')' + #13 +
      ' from ' + TabelaPrincipal + #13 +
      ' where (' + TabelaPrincipal + '.' + CampoChave + ' <> 0)';
    if (CampoEmpresa <> '') then
    begin
      if (ConstanteSistema.Sistema in [ConstanteSistema.cSistemaDepPessoal, ConstanteSistema.cSistemaContabilidade]) then
        e := DMConexao.SecaoAtual.Empresa.Estabelecimento
      else
        e := DMConexao.SecaoAtual.Empresa.Codigo;
      s := s + #13 + ' and (' + TabelaPrincipal + '.' + CampoEmpresa + ' = ' + IntToStr(e) + ')';
    end;
    if (FiltroFixoNavegacao <> '') then
      s := s + #13 + ' and ' + FiltroFixoNavegacao;
    if (FiltroDinamicoNavegacao <> '') then
      s := s + #13 + ' and ' + FiltroDinamicoNavegacao;
  end;
  Result := DMConexao.ExecuteScalar(s);
end;

function TDMPaiCadastro.Proximo(Atual: integer): integer;
var
  s: string;
  e: integer;
  Classe: TFClassPaiCadastro;
begin
  // Retorna o proximo registro da tabela em questão
  if Assigned(FClasseNavegacao) then
    Classe := FClasseNavegacao
  else
    Classe := FClasseFilha;

  with Classe do
  begin
    s := 'select min(' + TabelaPrincipal + '.' + CampoChave + ')' + #13 +
      ' from ' + TabelaPrincipal + #13 +
      ' where (' + TabelaPrincipal + '.' + CampoChave + ' > ' + IntToStr(Atual) + ')';

    if (Atual < 0) then
      S := S + ' and (' + TabelaPrincipal + '.' + CampoChave + ' <> 0)';

    if (CampoEmpresa <> '') then
    begin
      if (ConstanteSistema.Sistema in [ConstanteSistema.cSistemaDepPessoal, ConstanteSistema.cSistemaContabilidade]) then
        e := DMConexao.SecaoAtual.Empresa.Estabelecimento
      else
        e := DMConexao.SecaoAtual.Empresa.Codigo;
      s := s + #13 + ' and (' + TabelaPrincipal + '.' + CampoEmpresa + ' = ' + IntToStr(e) + ')';
    end;
    if (FiltroFixoNavegacao <> '') then
      s := s + #13 + ' and ' + FiltroFixoNavegacao;
    if (FiltroDinamicoNavegacao <> '') then
      s := s + #13 + ' and ' + FiltroDinamicoNavegacao;
  end;
  Result := DMConexao.ExecuteScalar(s);
end;


function TDMPaiCadastro.Anterior(Atual: integer): integer;
var
  s: string;
  e: integer;
  Classe: TFClassPaiCadastro;
begin
  // Retorna o registro anterior da tabela em questão
  if Assigned(FClasseNavegacao) then
    Classe := FClasseNavegacao
  else
    Classe := FClasseFilha;

  with Classe do
  begin
    s := 'select max(' + TabelaPrincipal + '.' + CampoChave + ')' + #13 +
      ' from ' + TabelaPrincipal + #13 +
      ' where (' + TabelaPrincipal + '.' + CampoChave + ' < ' + IntToStr(Atual) + ')' + #13 +
      ' and (' + TabelaPrincipal + '.' + CampoChave + ' <> 0)';
    if (CampoEmpresa <> '') then
    begin
      if (ConstanteSistema.Sistema in [ConstanteSistema.cSistemaDepPessoal, ConstanteSistema.cSistemaContabilidade]) then
        e := DMConexao.SecaoAtual.Empresa.Estabelecimento
      else
        e := DMConexao.SecaoAtual.Empresa.Codigo;
      s := s + #13 + ' and (' + TabelaPrincipal + '.' + CampoEmpresa + ' = ' + IntToStr(e) + ')';
    end;
    if (FiltroFixoNavegacao <> '') then
      s := s + #13 + ' and ' + FiltroFixoNavegacao;
    if (FiltroDinamicoNavegacao <> '') then
      s := s + #13 + ' and ' + FiltroDinamicoNavegacao;
  end;
  Result := DMConexao.ExecuteScalar(s);
end;

function TDMPaiCadastro.Ultimo: integer;
var
  s: string;
  e: integer;
  Classe: TFClassPaiCadastro;
begin
  // Retorna o último registro da tabela em questão
  if Assigned(FClasseNavegacao) then
    Classe := FClasseNavegacao
  else
    Classe := FClasseFilha;

  with Classe do
  begin
    s := 'select max(' + TabelaPrincipal + '.' + CampoChave + ')' + #13 +
      ' from ' + TabelaPrincipal;
    if (CampoEmpresa <> '') then
    begin
      if (ConstanteSistema.Sistema in [ConstanteSistema.cSistemaDepPessoal, ConstanteSistema.cSistemaContabilidade]) then
        e := DMConexao.SecaoAtual.Empresa.Estabelecimento
      else
        e := DMConexao.SecaoAtual.Empresa.Codigo;
      s := s + #13 + ' where (' + TabelaPrincipal + '.' + CampoEmpresa + ' = ' + IntToStr(e) + ')';
    end;
    if (FiltroFixoNavegacao <> '') then
      s := s + #13 + IfThen(Pos('where', s) > 0, ' and ', ' where ') + FiltroFixoNavegacao;
    if (FiltroDinamicoNavegacao <> '') then
      s := s + #13 + IfThen(Pos('where', s) > 0, ' and ', ' where ') + FiltroDinamicoNavegacao;
  end;
  Result := DMConexao.ExecuteScalar(s);
end;

class procedure TDMPaiCadastro.ValidateGeral(Sender: TField; Campos,
  CamposDataSet: array of string; ClasseBusca: TFClassPaiCadastro;
  Empresa: integer; Filtro: string);
var
  ValidacaoAnt: TFieldNotifyEvent;
begin
  if not(Sender.DataSet.State in [dsEdit, dsInsert]) then
    Exit;
  with Sender do
  begin
    ValidacaoAnt := OnValidate;
    OnValidate := nil;
    try
      DMLookup.BuscaCampos(ClasseBusca, Campos, CamposDataSet, DataSet, AsInteger, Empresa, Filtro);
    finally
      OnValidate := ValidacaoAnt;
    end;
  end;
end;

class procedure TDMPaiCadastro.ValidateGeral(Sender: TField; CampoDescricao: string; ClasseBusca: TFClassPaiCadastro; Filtro: string;
  ValidaStatusBloqueio: boolean);
var
  ValidacaoAnt: TFieldNotifyEvent;
begin
  if not(Sender.DataSet.State in [dsEdit, dsInsert]) then
    Exit;
  with Sender do
  begin
    ValidacaoAnt := OnValidate;
    OnValidate := nil;
    try
      DataSet.FieldByName(CampoDescricao).AsString := DMLookup.BuscaDescricao(ClasseBusca, AsInteger, -1, True, Filtro, '', ValidaStatusBloqueio);
    finally
      OnValidate := ValidacaoAnt;
    end;
  end;
end;

procedure TDMPaiCadastro.VerificarFechamento(DataSet: TDataSet; Classe: TFClassPaiCadastro);
var
  ListaDeCampos: TStrings;
  i: integer;
  DataUltimoFechamento: TDateTime;

  {$IF DEFINED(DEPPESSOAL)}
  CodEmpresa: integer;
  {$IFEND}
begin
  with Classe do
  begin
    if CamposFechamento = '' then
      Exit;

    ListaDeCampos := TStringList.Create;
    try
      ExtractStrings([';'], [' '], PWideChar(CamposFechamento), ListaDeCampos);
      with DataSet do
      begin
        if not IsEmpty then
        begin
{$IF DEFINED(DEPPESSOAL)}
          if ConstanteSistema.Sistema in [ConstanteSistema.cSistemaDepPessoal] then
          begin
            if ListaDeCampos[0] = 'GERAL' then
              CodEmpresa := 0
            else if ListaDeCampos[0] = 'ATUAL' then
              CodEmpresa := DMConexao.SecaoAtual.Empresa.Estabelecimento
            else
              CodEmpresa := FieldByName(ListaDeCampos[0]).AsInteger;

            DataUltimoFechamento := DP_DataFechamento(DMConexao, CodEmpresa, 0, 0, True);
          end;
{$ELSE}
          DataUltimoFechamento := 0;
{$IFEND}
          for i := 0 to ListaDeCampos.Count - 1 do
          begin
            if (FindField(ListaDeCampos[i]) <> nil) and (FieldByName(ListaDeCampos[i]).DataType in [ftTimeStamp, ftDate, ftDateTime]) then
            begin
              if (FieldByName(ListaDeCampos[i]).AsDateTime > 0) and (Trunc(FieldByName(ListaDeCampos[i]).AsDateTime) <= Trunc(DataUltimoFechamento)) then
              begin
                TCaixasDeDialogo.Aviso('Alteração bloqueada para data anterior ao último fechamento - ' + FormatDateTime('dd/mm/yyyy', DataUltimoFechamento));
                Abort;
              end;
            end;
          end;
        end;
      end;
    finally
      FreeAndNil(ListaDeCampos);
    end;
  end;
end;

function TDMPaiCadastro.Novo: integer;
var
  Quebra: integer;
begin
  // Retorna o novo código a ser usado na inserção
  with FClasseFilha do
  begin
    if (ConstanteSistema.Sistema in [ConstanteSistema.cSistemaDepPessoal, ConstanteSistema.cSistemaContabilidade]) then
      Quebra := IfThen(CampoEmpresa = '', 0, DMConexao.SecaoAtual.Empresa.Estabelecimento)
    else
    begin
      // Quebra := IfThen(CampoEmpresa = '', 0, DMConexao.SecaoAtual.Empresa.Codigo);
      // não estamos utilizando chave composta
      Quebra := 0;
    end;

    Result := DMConexao.ProximoCodigo(TabelaPrincipal, Quebra);

    if Result < ValorInicialCampoChave then
      Result := DMConexao.ProximoCodigoAcrescimo(TabelaPrincipal, Quebra, (ValorInicialCampoChave - Result));

    if (ValorFinalCampoChave > 0) and (Result > ValorFinalCampoChave) then
    begin
      TCaixasDeDialogo.Aviso('Limite de código superado para o cadastro ' + Descricao + '!');
      Abort;
    end;
  end;
end;

function TDMPaiCadastro.Aplique(Exclusao: boolean = false): integer;
begin
  // O parâmetro "Exclusao" é usado em funções herdadas, não apague.
  Result := CDSCadastro.ApplyUpdates(0);
end;

procedure TDMPaiCadastro.Cancele;
begin
  CDSCadastro.CancelUpdates;
end;

class procedure TDMPaiCadastro.ValidateGeral(Sender: TField; CampoDescricao: string; sClasseBusca: string; Filtro: string = ''; NomeCDSCache: string = ''; ValidaStatus: boolean = True; ValidaStatusBloqueio: boolean = False);
var
  ClasseBusca: TFClassPaiCadastro;
  Persist: TPersistentClass;
begin
  try
    Persist := FindClass(sClasseBusca);
  except
    raise Exception.Create('A classe ' + sClasseBusca + ' não está disponível nesse módulo, entre em contato com a Tek-System');
  end;
  ClasseBusca := TFClassPaiCadastro(Persist);
  ValidateGeral(Sender, CampoDescricao, ClasseBusca, Filtro, NomeCDSCache, ValidaStatus, ValidaStatusBloqueio);
end;

class procedure TDMPaiCadastro.ValidateGeral(Sender: TField; CampoDescricao: string; ClasseBusca: TFClassPaiCadastro; Filtro: string = ''; NomeCDSCache: string = ''; ValidaStatus: boolean = True; ValidaStatusBloqueio: boolean = False);
var
  ValidacaoAnt: TFieldNotifyEvent;
begin
  if not(Sender.DataSet.State in [dsEdit, dsInsert]) then
    Exit;
  with Sender do
  begin
    ValidacaoAnt := OnValidate;
    OnValidate := nil;
    try
      DataSet.FieldByName(CampoDescricao).AsString := DMLookup.BuscaDescricao(ClasseBusca, AsInteger, -1, ValidaStatus, Filtro, NomeCDSCache, ValidaStatusBloqueio);
    finally
      OnValidate := ValidacaoAnt;
    end;
  end;
end;

class procedure TDMPaiCadastro.ValidateGeral(Sender: TField; Campos: array of string;
  ClasseBusca: TFClassPaiCadastro; Empresa: integer = -1; Filtro: string = '');
var
  ValidacaoAnt: TFieldNotifyEvent;
begin
  if not(Sender.DataSet.State in [dsEdit, dsInsert]) then
    Exit;
  with Sender do
  begin
    ValidacaoAnt := OnValidate;
    OnValidate := nil;
    try
      DMLookup.BuscaCampos(ClasseBusca, Campos, DataSet, AsInteger, Empresa, Filtro);
    finally
      OnValidate := ValidacaoAnt;
    end;
  end;
end;

class procedure TDMPaiCadastro.ValidateGeral(CampoBusca: TField; CamposRetorno: array of string;
  NomeCampoWhere: string; ClasseBusca: TFClassPaiCadastro; Filtro: string = '');
var
  ValidacaoAnt: TFieldNotifyEvent;
begin
  if not(CampoBusca.DataSet.State in [dsEdit, dsInsert]) then
    Exit;
  with CampoBusca do
  begin
    ValidacaoAnt := OnValidate;
    OnValidate := nil;
    try
      DMLookup.BuscaCampos(ClasseBusca, NomeCampoWhere, CampoBusca, CamposRetorno, Filtro);
    finally
      OnValidate := ValidacaoAnt;
    end;
  end;
end;

procedure TDMPaiCadastro.ZeraParametros;
var
  x: integer;
begin
  with CDSCadastro do
  begin
    //Isso faz com que os parametros sejam atualizados
    FetchParams;
    for x := 0 to CDSCadastro.Params.Count - 1 do
    begin
      if AnsiUpperCase(Params.Items[x].Name) = 'COD' then
        Params.ParamByName('COD').AsInteger := -1
      else if AnsiUpperCase(Params.Items[x].Name) = 'REGISTRO' then
        Params.ParamByName('REGISTRO').AsInteger := -1;
    end;
  end;
end;

function TDMPaiCadastro.GetClassNameClasseFilha: string;
begin
  if Assigned(FClasseFilha) then
    Result := FClasseFilha.ClassName
  else
    Result := '';
end;

function TDMPaiCadastro.GetIdDetalhe: integer;
begin
  FIdDetalhe := FIdDetalhe - 1;
  Result := FIdDetalhe;
end;

procedure TDMPaiCadastro.AtribuiAutoIncDetalhe(DataSet: TDataSet; Classe: TFClassPaiCadastro; CampoChaveEstrangeira: String);
var
  QtdeAutoIncNegativos: Integer;
  AutoIncDetalhe: Integer;
begin
  with DataSet, Classe do
  begin
    QtdeAutoIncNegativos := 0;
    DisableControls;

    try
      First;
      while not EOF do
      begin
        if FieldByName(CampoChave).AsInteger <= 0 then
          inc(QtdeAutoIncNegativos);
        Next;
      end;

      if QtdeAutoIncNegativos > 0 then
      begin
        AutoIncDetalhe := DMConexao.ProximoCodigoAcrescimo(TabelaPrincipal, 0, QtdeAutoIncNegativos);
        AutoIncDetalhe := AutoIncDetalhe - QtdeAutoIncNegativos;

        First;
        while not Eof do
        begin
          if FieldByName(CampoChave).AsInteger <= 0 then
          begin
            Edit;
            FieldByName(CampoChave).AsInteger := AutoIncDetalhe;
            FieldByName(CampoChaveEstrangeira).AsInteger := CDSCadastro.FieldByName(FClasseFilha.CampoChave).AsInteger;
            Post;
            inc(AutoIncDetalhe);
          end;
          Next;
        end;
      end;
    finally
      EnableControls;
    end;
  end;
end;

end.
