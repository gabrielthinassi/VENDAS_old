unit USMPaiCadastro;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Data.DB, Data.SqlExpr, Datasnap.DBClient, Datasnap.Provider, Data.FMTBcd,
  ClassPaiCadastro, ClassSecaoAtualNovo, UControlaConexao, USMPai, USMConexao, System.StrUtils,
  Data.DBXFirebird;

type
  TSMPaiCadastro = class(TSMPai)
    SQLDSCadastro: TSQLDataSet;
    DSPCadastro: TDataSetProvider;
    Conexao: TSQLConnection;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);

    procedure DSPCadastroGetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);
    procedure DSPCadastroUpdateError(Sender: TObject; DataSet: TCustomClientDataSet; E: EUpdateError; UpdateKind: TUpdateKind; var Response: TResolverResponse);

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

    procedure VerificaSeFoiAlteradoOuExcluidoAntes(Delta: TCustomClientDataSet; Classe: TFClassPaiCadastro); virtual;

    procedure ProcessaFormula(Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; var Applied: Boolean); virtual;

    procedure CallBack_AbreTela(S: string = '');
    procedure CallBack_FechaTela;
    procedure CallBack_Mensagem(S: string);
    procedure CallBack_Incremento(Atual, Total: Integer; S: string = '');
  public
    procedure ResetCommandTextSQLDSCadastro; virtual;
  end;

implementation

uses Constantes, ClassHelperDataSet, ClassPaiCadastro;

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

procedure TSMPaiCadastro.DSPCadastroUpdateError(Sender: TObject; DataSet: TCustomClientDataSet; E: EUpdateError; UpdateKind: TUpdateKind; var Response: TResolverResponse);
begin
  // Isso permite que o erro seja capturado em um try except no ApplyUpdates do ClientDataSet
  raise Exception.Create(E.Message);
end;

procedure TSMPaiCadastro.SQLDSCadastroAfterOpen(DataSet: TDataSet);
begin
  with FClasseFilha, DataSet do
    begin
      ConfigurarProviderFlags([CampoChave]);
      ConfigurarPropriedadesDosCampos(DataSet);
    end;

  AposAbrirSQLDSCadastro(DataSet);
end;

procedure TSMPaiCadastro.AfterApplyUpdates(var OwnerData: OleVariant);
begin
  // será sobrescrito nos filhos
end;

procedure TSMPaiCadastro.AposAbrirSQLDSCadastro(DataSet: TDataSet);
begin
  // será sobrescrito nos filhos
end;

procedure TSMPaiCadastro.AtribuiResponsabilidade(SourceDS: TDataSet; var DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; Classe: TFClassPaiCadastro; DataHoraFixa: TDateTime = 0);
begin
  if FSuspencoAtribuicaoResponsabilidade then
    Exit;

  if DataHoraFixa = 0 then
    DataHoraFixa := FDataHoraGravacao;

  FuncoesGeraisServidor.AtribuiResponsabilidade(SMConexao, ClassName, DeltaDS, UpdateKind, Classe, DataHoraFixa);
end;

procedure TSMPaiCadastro.VerificaSeFoiAlteradoOuExcluidoAntes(Delta: TCustomClientDataSet; Classe: TFClassPaiCadastro);
var
  SQL, Codigo: string;
  Empresa: Integer;
  CDS: TClientDataSet;
begin
  // Verifica se a Data e Hora de Alteração do registro que está sendo gravado
  // é a mesma desde o princípio da edição.
  // Se não for, indica que o registro foi alterado por outro usuário no intervalo de visualização, edição e gravação
  // Esse teste é bem semelhante ao que faz o DataSetProvider com a propriedade UpDateMode = upWhereChanged
  with Classe, Delta do
    if (DataHoraAlt <> '') then
    begin
      CDS := TClientDataSet.Create(Self);
      try
        // Pegando dados anteriores do registro atual
        Codigo := FieldByName(CampoChave).OldValue;
        if (CampoEmpresa = '') then
          Empresa := 0
        else
          Empresa := FieldByName(CampoEmpresa).OldValue;

        // Montagem da SQL
        SQL :=
          ' select ' + #13 +
          TabelaPrincipal + '.' + DataHoraAlt + ',' + #13 +
          TabelaPrincipal + '.' + UsuarioAlt + #13 +
          ' from ' + TabelaPrincipal + #13 +
          ' where (' + TabelaPrincipal + '.' + CampoChave + ' = ' + Codigo + ')' + #13;
        if (CampoEmpresa <> '') then
          SQL := SQL + ' and (' + TabelaPrincipal + '.' + CampoEmpresa + ' = ' + IntToStr(Empresa) + ')';

        CDS.Data := SMConexao.ExecuteReader(SQL, 1, True);

        if (CDS.IsEmpty) then
          raise Exception.Create(MensagemServidorApl + Format(
            'O registro de %s cuja sequencia é %s foi excluído por outro usuário ' +
            'no intervalo em que você visualizava, editava e confirmava. ' +
            'Portanto a sua alteração nesse registro não pode ser efetivada. ' + #13 +
            'Tente fazer uma releitura do registro e refazer a alteração.',
            [Descricao, Codigo]))
        else if (VarToStr(FieldByName(DataHoraAlt).OldValue) <> CDS.FieldByName(DataHoraAlt).AsString) then
          raise Exception.Create(MensagemServidorApl + Format(
            'O registro de %s cuja sequencia é %s foi alterado pelo usuário %s ' +
            'no intervalo em que você visualizava, editava e confirmava. ' +
            'Portanto a sua alteração nesse registro não pode ser efetivada. ' + #13 +
            'Tente fazer uma releitura do registro e refazer a alteração.',
            [Descricao, Codigo, CDS.FieldByName(UsuarioAlt).AsString]));
      finally
        FreeAndNil(CDS);
      end;
    end;
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

procedure TSMPaiCadastro.ProcessaFormula(Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; var Applied: Boolean);
var
  Tabela: String;
  Interpretador: TInterpretadorDeFuncoesDoGeradorRelatorio;
begin
  Self.DSPCadastroGetTableName(DSPCadastro, SourceDS, Tabela);

  if FCDSFormulasCadastro.FindKey([Tabela]) then
  begin
    Interpretador := TInterpretadorDeFuncoesDoGeradorRelatorio.Create(SMConexao, Self);
    try
      Interpretador.Tabela := Tabela;
      Interpretador.DeltaDS := DeltaDS;
      Interpretador.UpdateKind := UpdateKind;

      Interpretador.Interpretar(
        FCDSFormulasCadastro.FieldByName('FORMULA_CTP').AsString,
        'Fórmula da tabela: ' + Tabela,
        TiProcesso,
        Null);
    finally
      Interpretador.Free;
    end;
  end;
end;

procedure TSMPaiCadastro.CallBack_AbreTela(S: string = '');
begin
  SMConexao.CallBack_AbreTela(Self.ClassName, S);
end;

procedure TSMPaiCadastro.CallBack_FechaTela;
begin
  SMConexao.CallBack_FechaTela(Self.ClassName);
end;

procedure TSMPaiCadastro.CallBack_Mensagem(S: string);
begin
  SMConexao.CallBack_Mensagem(Self.ClassName, S);
end;

procedure TSMPaiCadastro.CallBack_Incremento(Atual, Total: Integer; S: string = '');
begin
  SMConexao.CallBack_Incremento(Self.ClassName, Atual, Total, S);
end;

end.
