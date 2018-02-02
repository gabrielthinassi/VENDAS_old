unit USMPaiCadastro;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Data.DB,
  Data.SqlExpr,
  Data.FMTBcd,
  Data.DBXFirebird,
  Datasnap.DBClient,
  Datasnap.Provider,
  USMPai,
  ClassPaiCadastro,
  Data.DB,
  Data.SqlExpr,
  DBXCommon;

type
  TSMPaiCadastro = class(TSMPai)
    SQLDSCadastro: TSQLDataSet;
    DSPCadastro: TDataSetProvider;
    Conexao: TSQLConnection;
    SQLDSProximoCodigo: TSQLDataSet;
    DSPProximoCodigo: TDataSetProvider;
    CDSProximoCodigo: TClientDataSet;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);

    procedure DSPCadastroGetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);

    procedure SQLDSCadastroAfterOpen(DataSet: TDataSet);
  private

  protected
    FClasseFilha: TFClassPaiCadastro;

    procedure DSServerModuleCreate_Filho(Sender: TObject); virtual;
    procedure DSServerModuleDestroy_Filho(Sender: TObject); virtual;

    procedure GetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String); virtual;
    procedure BeforeApplyUpdates(var OwnerData: OleVariant); virtual;
    procedure AfterApplyUpdates(var OwnerData: OleVariant); virtual;

    procedure ResetCommandTextSQLDSCadastro_Protected; virtual;
    procedure AposAbrirSQLDSCadastro(DataSet: TDataSet); virtual;

  public
    procedure ResetCommandTextSQLDSCadastro; virtual;

    //Funções Gerais de Execução
    function ExecuteScalar(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;
    function ExecuteReader(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;
    function ExecuteCommand(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;
    function ExecuteCommand_Update(SQL, Campo: string; Valor: OleVariant; CriarTransacao: Boolean): OleVariant; virtual;
    function ProximoCodigo(Tabela: String; Acrescimo: Integer): Int64; virtual;
    procedure AcertaProximoCodigo(NomeDaClasse: String; CriarTransacao: Boolean = True); virtual;

  end;

implementation

uses ClassDataSet,
     Constantes;

{$R *.dfm}

procedure TSMPaiCadastro.DSServerModuleCreate(Sender: TObject);
var
  x: Integer;
begin
  inherited;
  DSServerModuleCreate_Filho(Sender);

  for x := 0 to ComponentCount - 1 do
    if (Components[x] is TSQLDataSet) then
      (Components[x] as TSQLDataSet).SQLConnection := Conexao;

  // Passado para este local para remover o erro de falta do parametro COD nos cadastros básico.
  ResetCommandTextSQLDSCadastro;
end;

procedure TSMPaiCadastro.DSServerModuleCreate_Filho(Sender: TObject);
begin
  // implementar no filho
end;

procedure TSMPaiCadastro.DSServerModuleDestroy(Sender: TObject);
begin
  DSServerModuleDestroy_Filho(Sender);
  //Verificar este FreeAndNil, pode não poder liberar este SQLDS ou tratar de uma outra forma
  FreeAndNil(SQLDSCadastro);
  inherited;
end;

procedure TSMPaiCadastro.DSServerModuleDestroy_Filho(Sender: TObject);
begin
  // implementar no filho
end;

function TSMPaiCadastro.ExecuteCommand(SQL: string;
  CriarTransacao: Boolean): OleVariant;
begin

end;

function TSMPaiCadastro.ExecuteCommand_Update(SQL, Campo: string;
  Valor: OleVariant; CriarTransacao: Boolean): OleVariant;
begin

end;

function TSMPaiCadastro.ExecuteReader(SQL: string;
  CriarTransacao: Boolean): OleVariant;
begin

end;

function TSMPaiCadastro.ExecuteScalar(SQL: string;
  CriarTransacao: Boolean): OleVariant;
begin

end;

procedure TSMPaiCadastro.BeforeApplyUpdates(var OwnerData: OleVariant);
begin
  // será sobrescrito nos filhos
end;

procedure TSMPaiCadastro.DSPCadastroGetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);
begin
  if (DataSet = SQLDSCadastro) then
    TableName := FClasseFilha.TabelaPrincipal;

  GetTableName(Sender, DataSet, TableName);
end;

procedure TSMPaiCadastro.GetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);
begin
  // será sobrescrito nos filhos
end;

function TSMPaiCadastro.ProximoCodigo(Tabela: String;
  Acrescimo: Integer): Int64;
var
  TD: TDBXTransaction;
begin
  if (CDSProximoCodigo.FieldDefs.Count = 0) then
  begin
    CDSProximoCodigo.Close;
    CDSProximoCodigo.FieldDefs.Clear;
    CDSProximoCodigo.FieldDefs.Add('TABELA_AUTOINC', ftString, 31);
    CDSProximoCodigo.FieldDefs.Add('CODIGO_AUTOINC', ftLargeint);
    CDSProximoCodigo.CreateDataSet;
  end;

  with Conexao do
  begin
    TD := BeginTransaction(TDBXIsolations.ReadCommitted);
    try
      with CDSProximoCodigo do
      begin
        repeat
          Close;
          Params.ParamByName('TABELA').AsString  := Tabela;
          Open;
          if IsEmpty then
          begin
            Insert;
            FieldByName('TABELA_AUTOINC').AsString  := Tabela;
            FieldByName('CODIGO_AUTOINC').Value     := Acrescimo;
          end
          else
          begin
            Edit;
            FieldByName('CODIGO_AUTOINC').AsFloat := FieldByName('CODIGO_AUTOINC').AsFloat + Acrescimo;
          end;
          Post;
        until (ApplyUpdates(0) = 0);
        Result := FieldByName('CODIGO_AUTOINC').AsLargeInt;
        Close;
      end;

      if HasTransaction(TD) then
        CommitFreeAndNil(TD);
    except
      on E: Exception do
      begin
        if HasTransaction(TD) then
          RollbackFreeAndNil(TD);
        raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ProximoCodigo', 'Tabela: ' + Tabela + #13 + E.Message));
      end;
    end;
  end;
end;

procedure TSMPaiCadastro.SQLDSCadastroAfterOpen(DataSet: TDataSet);
begin
  with FClasseFilha, DataSet do
    begin
      ConfigurarProviderFlags([CampoChave]);
      //ConfigurarPropriedadesDosCampos(DataSet);
    end;

  AposAbrirSQLDSCadastro(DataSet);
end;

procedure TSMPaiCadastro.AcertaProximoCodigo(NomeDaClasse: String;
  CriarTransacao: Boolean);
begin

end;

procedure TSMPaiCadastro.AfterApplyUpdates(var OwnerData: OleVariant);
begin
  // será sobrescrito nos filhos
end;

procedure TSMPaiCadastro.AposAbrirSQLDSCadastro(DataSet: TDataSet);
begin
  // será sobrescrito nos filhos
end;

procedure TSMPaiCadastro.ResetCommandTextSQLDSCadastro;
begin
  ResetCommandTextSQLDSCadastro_Protected;
end;

procedure TSMPaiCadastro.ResetCommandTextSQLDSCadastro_Protected;
begin
  if Assigned(FClasseFilha) then
  begin
    SQLDSCadastro.CommandText := FClasseFilha.SQLBaseCadastro;
    FClasseFilha.CriarParametros(SQLDSCadastro);
  end;
end;

end.
