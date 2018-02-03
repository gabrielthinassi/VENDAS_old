unit USMConexao;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Data.SqlExpr, DBXCommon, Data.FMTBcd,
  Winapi.Windows, Data.DB, DBClient, Provider, Vcl.Forms, Data.SqlConst, System.StrUtils, System.Math,
  Datasnap.DSServer, acQBBase, acQBdbExMetaProvider, acAST, acFbSynProvider, Graphics, jpeg, Generics.Collections,
  Data.DBXJSONReflect, Datasnap.DSCommonServer, Datasnap.DSProviderDataModuleAdapter,
  Data.DBXFirebird;

type
  TSMConexao = class(TDSServerModule)
    CDSProximoCodigo: TClientDataSet;
    DSPProximoCodigo: TDataSetProvider;
    SQLDSProximoCodigo: TSQLDataSet;
    Conexao: TSQLConnection;
    procedure DSServerModuleDestroy(Sender: TObject);
  private
  public

    function ExecuteScalar(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;
    function ExecuteReader(SQL: string; TamanhoPacote: Integer; CriarTransacao: Boolean): OleVariant; virtual;
    function ExecuteCommand(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;
    function ExecuteCommand_Update(SQL, Campo: string; Valor: OleVariant; CriarTransacao: Boolean): OleVariant; virtual;
    function ProximoCodigo(Tabela: String; Acrescimo: Integer): Int64; virtual;
    procedure AcertaProximoCodigo(NomeDaClasse: String; Quebra: Integer; CriarTransacao: Boolean = True); virtual;

    property FConexao: TSQLConnection read Conexao;
  end;

var
  SMConexao: TSMConexao;

implementation

{$R *.dfm}


uses Constantes, ClassPaiCadastro;

procedure TSMConexao.DSServerModuleDestroy(Sender: TObject);
begin
  if Assigned(Conexao) then
  begin
    if (Conexao.Connected) then
      try
        Conexao.Connected := False;
        Conexao := nil;
      except
        // Implementar
      end;
  end;
  inherited;
end;

function TSMConexao.ExecuteScalar(SQL: string; CriarTransacao: Boolean): OleVariant;
var
  DataSet     : TSQLDataSet;
  TipoDeCampo : TFieldType;
  Transacao   : TDBXTransaction;
begin
{  try
    if CriarTransacao then
      Transacao := Conexao.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not Conexao.InTransaction) then
      raise Exception.Create('Precisa ter uma Transação Ativa!');

    try
      Conexao.Execute(SQL, nil, TDataSet(DataSet));

      DataSet.ParamCheck := False;

      TipoDeCampo := DataSet.Fields[0].DataType;

      if (DataSet <> nil) and (not DataSet.eof) then
        case TipoDeCampo of
          ftSmallint, ftInteger, ftWord:
            Result := DataSet.Fields[0].AsInteger;
          ftFloat, ftFMTBcd, ftLargeint, ftAutoInc, ftBCD:
            Result := DataSet.Fields[0].AsFloat;
          ftCurrency:
            Result := DataSet.Fields[0].AsCurrency;
          ftString, ftFixedChar, ftWideString, ftFixedWideChar, ftMemo, ftWideMemo, ftFmtMemo:
            Result := DataSet.Fields[0].AsString;
          ftDate, ftTime, ftDateTime, ftTimeStamp, ftOraTimeStamp:
            Result := DataSet.Fields[0].AsDateTime;
          ftBlob:
            begin
              Result := TBlobField(DataSet.Fields[0]).Value; // Value nesse caso Devolve string
              // Campos BLOB binário poderiam retornar assim, mas não consegui distingui-los dos BLOB textos.
              // Então preferi deixar a função retornando como Texto.
              // Para retornar BLOB binário, usar a função ExecuteReader.
              // MS := TMemoryStream.Create;
              //  try
              //  TBlobField(DataSet.Fields[0]).SaveToStream(MS);
              //  MS.Position := 0;
              //  Result := StreamToOleVariantBytes(MS);
              //  finally
              //  MS.Free;
              //  end; 
            end
        else
          Result := DataSet.Fields[0].Value;
        end
      else
        case TipoDeCampo of
          ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftLargeint, ftAutoInc:
            Result := 0;
          ftString, ftFixedChar, ftWideString, ftFixedWideChar, ftMemo, ftWideMemo, ftFmtMemo:
            Result := '';
          ftDate, ftTime, ftDateTime, ftTimeStamp, ftOraTimeStamp:
            Result := 0;
          ftUnknown, ftVariant:
            Result := Null;
          ftBlob:
            Result := '';
        end;
      // Tipos de Campos não tratados:
      //  ftBoolean, ftBytes, ftVarBytes, ftMemo, ftGraphic, ,
      //  ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftADT, ftArray,
      //  ftReference, ftDataSet, ftOraBlob, ftOraClob, ftInterface, ftIDispatch, ftGuid, ftOraInterval 
    finally
      FreeAndNil(DataSet);
      if CriarTransacao then
        Conexao.CommitFreeAndNil(Transacao);
    end;
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        Conexao.Connected := False;

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteScalar', 'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;

  InformaAtividadeSecao;
}
end;

function TSMConexao.ExecuteReader(SQL: string; TamanhoPacote: Integer; CriarTransacao: Boolean): OleVariant;
var
  TransacaoLocal: TDBXTransaction;
  DataSet   : TSQLDataSet;
  DSP           : TDataSetProvider;
begin
{  try
    if CriarTransacao then
      TransacaoLocal := Conexao.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not Conexao.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteReader deve estar dentro de um contexto transacional');

    DSP         := TDataSetProvider.Create(nil);
    DataSet := TSQLDataSet.Create(nil);
    try
      with DataSet do
      begin
        SQLConnection := Conexao;
        ParamCheck    := False;
        CommandText   := SQL;
        GetMetadata   := False;
      end;
      with DSP do
      begin
        Exported    := False;
        Constraints := False;
        DataSet     := DataSet;
        Result      := DSP.Data;
      end;
    finally
      FreeAndNil(DSP);
      FreeAndNil(DataSet);
      if CriarTransacao then
        Conexao.CommitFreeAndNil(TransacaoLocal);
    end;
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        Conexao.Connected := False;

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteReader', 'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;
}end;

function TSMConexao.ExecuteCommand(SQL: string; CriarTransacao: Boolean): OleVariant;
var
  TransacaoLocal: TDBXTransaction;
begin
{  try
    if CriarTransacao then
      TransacaoLocal := Conexao.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not Conexao.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteCommand deve estar dentro de um contexto transacional');

    with Conexao.DBXConnection.CreateCommand do
      try
        Text := SQL;
        // Prepare;
        ExecuteQuery;
        Result := IntToStr(RowsAffected);
      finally
        Free;
      end;

    if CriarTransacao and (Conexao.HasTransaction(TransacaoLocal)) then
      Conexao.CommitFreeAndNil(TransacaoLocal);
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        Conexao.Connected := False
      else if CriarTransacao then
        if (Conexao.HasTransaction(TransacaoLocal)) then
          Conexao.RollbackFreeAndNil(TransacaoLocal)
        else
          Conexao.RollbackIncompleteFreeAndNil(TransacaoLocal);

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteCommand', 'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;
}end;

function TSMConexao.ExecuteCommand_Update(SQL, Campo: string; Valor: OleVariant; CriarTransacao: Boolean): OleVariant;
var
  DS            : TSQLDataSet;
  DSP           : TDataSetProvider;
  CDS           : TClientDataSet;
  TransacaoLocal: TDBXTransaction;
begin
{  try
    if CriarTransacao then
      TransacaoLocal := Conexao.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not Conexao.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteCommand_Update deve estar dentro de um contexto transacional');

    try
      CDS := TClientDataSet.Create(Self);
      DSP := TDataSetProvider.Create(Self);
      DS  := TSQLDataSet.Create(Self);
      with DS do
      begin
        CommandText   := SQL;
        CommandType   := CtQuery;
        SQLConnection := Conexao;
      end;
      with DSP do
      begin
        DataSet := DS;
        Name    := 'DSProviderECU' + IntToStr(Random(100));
      end;
      with CDS do
      begin
        ProviderName := DSP.Name;
        Open;
        if IsEmpty then
          raise Exception.Create('Não encontrado registro para atualização do campo "' + Campo + '".');
        if RecordCount > 1 then
          raise Exception.Create('Encontrado multiplos registros para atualização do campo "' + Campo + '".');
        Edit;
        FieldByName(Campo).Value := Valor;
        Post;
        Result := ApplyUpdates(0);
      end;
    finally
      FreeAndNil(DS);
      FreeAndNil(DSP);
      FreeAndNil(CDS);

      if CriarTransacao and (Conexao.HasTransaction(TransacaoLocal)) then
        Conexao.CommitFreeAndNil(TransacaoLocal);
    end;
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        Conexao.Connected := False
      else if CriarTransacao then
        if (Conexao.HasTransaction(TransacaoLocal)) then
          Conexao.RollbackFreeAndNil(TransacaoLocal)
        else
          Conexao.RollbackIncompleteFreeAndNil(TransacaoLocal);

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteCommand_Update',
        'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;
}end;


function TSMConexao.ProximoCodigo(Tabela: String; Acrescimo: Integer): Int64;
var
  Transacao: TDBXTransaction;
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
    Transacao := BeginTransaction(TDBXIsolations.ReadCommitted);
    try
      with CDSProximoCodigo do
      begin
        repeat //similar ao DO WHILE
          Close;
          Params.ParamByName('TABELA').AsString  := Tabela;
          Open;
          if IsEmpty then
          begin
            Insert;
            FieldByName('TABELA_AUTOINC').AsString  := Tabela;
            FieldByName('CODIGO_AUTOINC').AsInteger := Acrescimo;
          end
          else
          begin
            Edit;
            FieldByName('CODIGO_AUTOINC').AsInteger := FieldByName('CODIGO_AUTOINC').AsInteger + Acrescimo;
          end;
          Post;
        until (ApplyUpdates(0) = 0);
        Result := FieldByName('CODIGO_AUTOINC').AsLargeInt;
        Close;
      end;

      if HasTransaction(Transacao) then
        CommitFreeAndNil(Transacao);
    except on E: Exception do
      begin
        if HasTransaction(Transacao) then
          RollbackFreeAndNil(Transacao);
        raise Exception.Create('Erro na Tabela: ' + Tabela + #13 + E.Message);
      end;
    end;
  end;
end;

procedure TSMConexao.AcertaProximoCodigo(NomeDaClasse: String; Quebra: Integer; CriarTransacao: Boolean = True);
var
  SQL   : String;
  Codigo: Int64;
  CDS   : TClientDataSet;
  TD    : TDBXTransaction;
  Classe: TFClassPaiCadastro;
begin
{  if CriarTransacao then
    TD := Conexao.BeginTransaction(TDBXIsolations.ReadCommitted);
  try
    Classe := TFClassPaiCadastro(FindClass(NomeDaClasse));

    if (Classe.TabelaPrincipal = '') or
      (Classe.CampoChave = '') then
      Exit;

    // Montagem da SQL para pegar o último código
    SQL := ' select ';
    if (Classe.CampoEmpresa = '') then
      SQL := SQL + '0'
    else
      SQL := SQL + Classe.TabelaPrincipal + '.' + Classe.CampoEmpresa;
    SQL   := SQL + ' QUEBRA,' +
      ' max(' + Classe.TabelaPrincipal + '.' + Classe.CampoChave + ') ULTIMO' + #13 +
      ' from ' + Classe.TabelaPrincipal;

    if (Classe.CampoEmpresa <> '') then
    begin
      if Quebra > 0 then
        SQL := SQL + #13 +
          'where ' + Classe.TabelaPrincipal + '.' + Classe.CampoEmpresa + ' = ' + IntToStr(Quebra);

      SQL := SQL + #13 +
        'group by ' + Classe.TabelaPrincipal + '.' + Classe.CampoEmpresa;
    end;

    CDS := TClientDataSet.Create(Self);
    try
      with CDS do
      begin
        Data := ExecuteReader(SQL, -1, False);
        First;
        while (not eof) do
        begin
          Codigo := Max(TFuncoesConversao.VariantParaInt64(FieldByName('ULTIMO').Value), 0);
          if Codigo < (Classe.ValorInicialCampoChave - 1) then
            Codigo := (Classe.ValorInicialCampoChave - 1);

          AtualizarProximoCodigo(Classe.TabelaPrincipal, FieldByName('QUEBRA').AsInteger, Codigo, False);

          Next;
        end;
      end;
    finally
      FreeAndNil(CDS);
    end;

    if CriarTransacao and Conexao.HasTransaction(TD) then
      Conexao.CommitFreeAndNil(TD);
  except
    on E: Exception do
    begin
      if CriarTransacao and Conexao.HasTransaction(TD) then
        Conexao.RollbackFreeAndNil(TD);
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'AcertaProximoCodigo', 'Classe: ' + NomeDaClasse + #13 + E.Message));
    end;
  end;
}end;


end.
