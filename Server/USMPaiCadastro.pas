unit USMPaiCadastro;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Data.DB, Data.SqlExpr, Datasnap.DBClient, Datasnap.Provider, Data.FMTBcd,
  ClassPaiCadastro, ClassSecaoAtualNovo, UControlaConexao, USMPai, USMConexao, System.StrUtils;

type
  TSMPaiCadastro = class(TSMPai)
    SQLDSCadastro: TSQLDataSet;
    DSPCadastro: TDataSetProvider;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);

    procedure DSPCadastroGetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);
    procedure DSPCadastroBeforeUpdateRecord(Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; var Applied: Boolean);
    procedure DSPCadastroUpdateError(Sender: TObject; DataSet: TCustomClientDataSet; E: EUpdateError; UpdateKind: TUpdateKind; var Response: TResolverResponse);
    procedure DSPCadastroAfterApplyUpdates(Sender: TObject; var OwnerData: OleVariant);
    procedure DSPCadastroBeforeApplyUpdates(Sender: TObject; var OwnerData: OleVariant);

    procedure SQLDSCadastroAfterOpen(DataSet: TDataSet);
  private
    FSMConexao: TSMConexao;
    FSecaoAtual: TClassSecaoNovo;
    FMeuSQLConnection: TSQLConnection;

    FSuspencoAtribuicaoResponsabilidade: Boolean;
    FLogCodigo: Int64;
    FLogOperacao: Integer;
    FLogTexto: WideString;
    FCampoSecundario: Int64;

    FCDSFormulasCadastro: TClientDataSet;

    FDataHoraGravacao: TDateTime;
  protected
    FClasseFilha: TFClassPaiCadastro;

    FDataHoraAltComoChave: Boolean;

    procedure DSServerModuleCreate_Filho(Sender: TObject); virtual;
    procedure DSServerModuleDestroy_Filho(Sender: TObject); virtual;

    procedure GetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String); virtual;
    procedure BeforeApplyUpdates(var OwnerData: OleVariant); virtual;
    procedure AfterApplyUpdates(var OwnerData: OleVariant); virtual;

    procedure ResetCommandTextSQLDSCadastro_Protected; virtual;

    procedure AposAbrirSQLDSCadastro(DataSet: TDataSet); virtual;

    procedure RegistraLogTabela(SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind); virtual;
    procedure AtribuiResponsabilidade(SourceDS: TDataSet; var DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; Classe: TFClassPaiCadastro; DataHoraFixa: TDateTime = 0); virtual;
    procedure VerificaSeFoiAlteradoOuExcluidoAntes(Delta: TCustomClientDataSet; Classe: TFClassPaiCadastro); virtual;

    procedure ProcessaFormula(Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; var Applied: Boolean); virtual;

    procedure CallBack_AbreTela(S: string = '');
    procedure CallBack_FechaTela;
    procedure CallBack_Mensagem(S: string);
    procedure CallBack_Incremento(Atual, Total: Integer; S: string = '');

    // - - \\

    property SMConexao: TSMConexao read FSMConexao write FSMConexao;
    property SecaoAtual: TClassSecaoNovo read FSecaoAtual write FSecaoAtual;
    property MeuSQLConnection: TSQLConnection read FMeuSQLConnection write FMeuSQLConnection;
  public
    ///	<summary>
    ///	  <para>
    ///	    Método criado para corrigir o problema de quando executa um filtro
    ///	    no cadastro e retorna muitos registros, ao sair da tela e entrar
    ///	    novamente, o SQL do CommandText ainda era o mesmo utilizado pela
    ///	    última vez, fazendo a tela demorar uma eternidade para abrir.
    ///	  </para>
    ///	  <para>
    ///	    Este método reseta o SQL do CommandText, setando o SQL original da
    ///	    Classe Filha: SQLBaseCadastro.
    ///	  </para>
    ///	</summary>
    procedure ResetCommandTextSQLDSCadastro; virtual;

    property SuspencoAtribuicaoResponsabilidade: Boolean read FSuspencoAtribuicaoResponsabilidade write FSuspencoAtribuicaoResponsabilidade;
  end;

implementation

uses Constantes, FuncoesGeraisServidor,
  ClassHelperDataSet, ClassInterpretadorDeFuncoesGeradorRelatorio, ClassAspecto, ClassFuncoesString;

{$R *.dfm}

procedure TSMPaiCadastro.DSServerModuleCreate(Sender: TObject);
var
  Conexao: TConexao;
  x: Integer;
begin
  inherited;

  Conexao := ControlaConexao.RetornaConexao;

  if Conexao <> nil then
  begin
    FSMConexao := Conexao.SMConexao;
    FSecaoAtual := Conexao.SecaoAtual;
    FMeuSQLConnection := Conexao.SMConexao.MeuSQLConnection;
  end;

  DSServerModuleCreate_Filho(Sender);

  for x := 0 to ComponentCount - 1 do
    if (Components[x] is TSQLDataSet) then
      (Components[x] as TSQLDataSet).SQLConnection := MeuSQLConnection;

  // Passado para este local para remover o erro de falta do parametro COD nos cadastros básico.
  ResetCommandTextSQLDSCadastro;

  FCDSFormulasCadastro := TClientDataSet.Create(Self);
  FCDSFormulasCadastro.Data := SMConexao.FormulasCadastro;
  FCDSFormulasCadastro.IndexFieldNames := 'TABELA_CTP';

  TClassAspecto.RegistrarObjeto(Self);
end;

procedure TSMPaiCadastro.DSServerModuleCreate_Filho(Sender: TObject);
begin
  // implementar no filho
end;

procedure TSMPaiCadastro.DSServerModuleDestroy(Sender: TObject);
begin
  DSServerModuleDestroy_Filho(Sender);

  FSMConexao := nil;
  FSecaoAtual := nil;
  FMeuSQLConnection := nil;

  FreeAndNil(FCDSFormulasCadastro);

  TClassAspecto.DesRegistrarObjeto(Self);

  inherited;
end;

procedure TSMPaiCadastro.DSServerModuleDestroy_Filho(Sender: TObject);
begin
  // implementar no filho
end;

procedure TSMPaiCadastro.DSPCadastroAfterApplyUpdates(Sender: TObject; var OwnerData: OleVariant);
begin
  inherited;
  if ((SecaoAtual.Parametro.RegistraLog_Tabela) or (FClasseFilha.ForcarRegistraLogTabela)) and (FLogTexto <> '') then
    SMConexao.RegistraLogTabela(VarArrayOf([
      FLogOperacao,
      FClasseFilha.TabelaPrincipal,
      SecaoAtual.Usuario.Nome,
      FLogCodigo,
      FLogTexto,
      FCampoSecundario]));

  AfterApplyUpdates(OwnerData);

  FDataHoraGravacao := 0;

  SMConexao.InformaAtividadeSecao;
end;

procedure TSMPaiCadastro.DSPCadastroBeforeApplyUpdates(Sender: TObject; var OwnerData: OleVariant);
begin
  inherited;
  FLogCodigo := 0;
  FCampoSecundario := 0;
  FLogTexto := '';

  if not FSuspencoAtribuicaoResponsabilidade then
    FDataHoraGravacao := SMConexao.DataHora;

  BeforeApplyUpdates(OwnerData);
end;

procedure TSMPaiCadastro.BeforeApplyUpdates(var OwnerData: OleVariant);
begin
  // será sobrescrito nos filhos
end;

procedure TSMPaiCadastro.DSPCadastroBeforeUpdateRecord(Sender: TObject; SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind; var Applied: Boolean);
begin
  if SecaoAtual.SistemaSomenteLeitura then
    raise Exception.Create(sMensagemSistemaSomenteLeitura);

  ProcessaFormula(Sender, SourceDS, DeltaDS, UpdateKind, Applied);

  if (SourceDS = SQLDSCadastro) and (not FDataHoraAltComoChave) then
    AtribuiResponsabilidade(SourceDS, DeltaDS, UpdateKind, FClasseFilha);

  RegistraLogTabela(SourceDS, DeltaDS, UpdateKind);
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
      ConfigurarProviderFlags([CampoEmpresa, CampoChave]);
      ConfigurarPropriedadesDosCampos(DataSet);
    end;

  if (FDataHoraAltComoChave) then
    SQLDSCadastro.FieldByName(FClasseFilha.DataHoraAlt).ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];

  AposAbrirSQLDSCadastro(DataSet);

  SMConexao.InformaAtividadeSecao;
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

procedure TSMPaiCadastro.RegistraLogTabela(SourceDS: TDataSet; DeltaDS: TCustomClientDataSet; UpdateKind: TUpdateKind);
var
  i: Integer;
  Prefixo, S: string;
  bModificado: Boolean;
  FieldCodigo: TField;
  tpStrPasswordFields: string;
  DSF: TDataSetField;
begin
  if (not((SecaoAtual.Parametro.RegistraLog_Tabela) or (FClasseFilha.ForcarRegistraLogTabela))) or
    ((SourceDS = SQLDSCadastro) and (UpdateKind = ukInsert)) then // não será necessário registrar log de inclusão
    Exit;

  //lista de campos de senha
  tpStrPasswordFields := DeltaDS.GetOptionalParam('PasswordFields');

  FieldCodigo := nil;

  if (SourceDS = SQLDSCadastro) then
  begin
    FieldCodigo := DeltaDS.FieldByName(FClasseFilha.CampoChave);
    if FClasseFilha.CampoRegistroSecundario <> '' then
      FCampoSecundario := DeltaDS.FieldByName(FClasseFilha.CampoRegistroSecundario).ValorAtual;
  end else begin
    DSF := DeltaDS.DataSetField;
    while Assigned(DSF) do
    begin
      FieldCodigo := DSF.DataSet.FindField(FClasseFilha.CampoChave);
      if FieldCodigo <> nil then
        Break;
      if DSF = DeltaDS.DataSetField.DataSet.DataSetField then
        Exit;
      DSF := DeltaDS.DataSetField.DataSet.DataSetField;
    end;
  end;

  if FieldCodigo = nil then
    Exit;

  case UpdateKind of
    ukInsert:
      begin
        FLogOperacao := 1;
        FLogCodigo := FieldCodigo.NewValue;
      end;
    ukModify:
      begin
        FLogOperacao := 2;
        FLogCodigo := FieldCodigo.OldValue;
      end;
    ukDelete:
      begin
        FLogOperacao := 3;
        FLogCodigo := FieldCodigo.Value;
      end;
  end;

  Prefixo := '  ';
  S := '';
  bModificado := False;

  if FLogTexto <> '' then
    FLogTexto := FLogTexto + #10;

  case UpdateKind of
    ukInsert:
      begin
        for i := 0 to DeltaDS.FieldCount - 1 do
          if (pfinUpdate in DeltaDS.Fields[i].ProviderFlags) and
            (DeltaDS.Fields[i].DataType <> ftDataSet) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.UsuarioInc) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.DataHoraInc) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.UsuarioAlt) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.DataHoraAlt) then
          begin
            bModificado := True;
            if (DeltaDS.Fields[i].DataType in [ftBlob, ftMemo]) then
              S := S + Prefixo + DeltaDS.Fields[i].FieldName + ': >> TIPO DE CAMPO NÃO MONITORADO <<' + #10
            else
              begin
                S := S + Prefixo + DeltaDS.Fields[i].FieldName + ': "';
                if (Pos(DeltaDS.Fields[i].FieldName, tpStrPasswordFields) > 0) then
                  S := S + '***********'
                else
                  S := S + VarToStr(DeltaDS.Fields[i].Value);
                S := S + '"' + #10;
              end;
          end;

        if bModificado then
        begin
          FLogTexto := FLogTexto + '=> Inserindo (';
          if (SourceDS <> SQLDSCadastro) then
            FLogTexto := FLogTexto + SourceDS.Name + '):' + #10
          else
            FLogTexto := FLogTexto + FClasseFilha.Descricao + '):' + #10;
          FLogTexto := FLogTexto + S;
        end;
      end;
    ukModify:
      begin
        for i := 0 to DeltaDS.FieldCount - 1 do
        begin
          if (SourceDS <> SQLDSCadastro) and
            (pfInKey in DeltaDS.Fields[i].ProviderFlags) and
            (DeltaDS.Fields[i].DataType <> ftDataSet) then
            S := S + Prefixo + '*' + DeltaDS.Fields[i].FieldName + ' = ' + VarToStr(DeltaDS.Fields[i].OldValue) + #10;
          if (pfinUpdate in DeltaDS.Fields[i].ProviderFlags) and
            (DeltaDS.Fields[i].DataType <> ftDataSet) and
            (not VarIsEmpty(DeltaDS.Fields[i].NewValue)) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.UsuarioInc) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.DataHoraInc) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.UsuarioAlt) and
            (DeltaDS.Fields[i].FieldName <> FClasseFilha.DataHoraAlt) then
          begin
            bModificado := True;
            if (DeltaDS.Fields[i].DataType in [ftBlob, ftMemo]) then
              S := S + Prefixo + DeltaDS.Fields[i].FieldName + ': >> TIPO DE CAMPO NÃO MONITORADO <<' + #10
            else
              begin
                S := S + Prefixo + DeltaDS.Fields[i].FieldName + ': "';
                if (Pos(DeltaDS.Fields[i].FieldName, tpStrPasswordFields) > 0) then
                  S := S + '***********" para "***********'
                else
                  S := S + VarToStr(DeltaDS.Fields[i].OldValue) + '" para "' + VarToStr(DeltaDS.Fields[i].NewValue);
                S := S + '"' + #10;
              end;
          end;
        end;
        if bModificado then
        begin
          FLogTexto := FLogTexto + '=> Modificado (';
          if (SourceDS <> SQLDSCadastro) then
            FLogTexto := FLogTexto + SourceDS.Name + '):' + #10
          else
            FLogTexto := FLogTexto + FClasseFilha.Descricao + '):' + #10;
          FLogTexto := FLogTexto + S;
        end;
      end;
    ukDelete:
      begin
        for i := 0 to DeltaDS.FieldCount - 1 do
          if (pfinUpdate in DeltaDS.Fields[i].ProviderFlags) and
            (DeltaDS.Fields[i].DataType <> ftDataSet) then
          begin
            bModificado := True;
            if (DeltaDS.Fields[i].DataType in [ftBlob, ftMemo]) then
              S := S + Prefixo + DeltaDS.Fields[i].FieldName + ': >> TIPO DE CAMPO NÃO MONITORADO <<' + #10
            else begin
              S := S + Prefixo + DeltaDS.Fields[i].FieldName + ': "';
              if (Pos(DeltaDS.Fields[i].FieldName, tpStrPasswordFields) > 0) then
                S := S + '***********'
              else
                S := S + VarToStr(DeltaDS.Fields[i].Value);
              S := S +  '"' + #10;
            end;
          end;
        if bModificado then
        begin
          FLogTexto := FLogTexto + '=> Deletado (';
          if (SourceDS <> SQLDSCadastro) then
            FLogTexto := FLogTexto + SourceDS.Name + '):' + #10
          else
            FLogTexto := FLogTexto + FClasseFilha.Descricao + '):' + #10;
          FLogTexto := FLogTexto + S;
        end;
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
