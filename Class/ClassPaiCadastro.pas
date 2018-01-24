unit ClassPaiCadastro;

interface

uses
  Classes, DB, SysUtils, DBClient, StrUtils, Variants, FMTBcd, Controls, SqlTimSt,
  {$IF DEFINED(servidor)} SqlExpr, {$endif}
  TypInfo, Rtti, ClassPai;

type
  TParametrosSql = record
    Nome: string;
    Tipo: TFieldType;
    Valor: Variant;
  end;
  TListaDeParametrosSql = array of TParametrosSql;

type
  TClassPaiCadastro = class(TClassPai)
  public
    class function Descricao: string; virtual;
    class function TabelaPrincipal: string; virtual;

    class function ClassOriginal: string; virtual;
    class function ClassRelacional: string; virtual;

    class function CampoEmpresa: string; virtual;
    class function CampoEstabelecimento: string; virtual;
    class function CampoChave: string; virtual;
    class function CampoRegistroSecundario: string; virtual;
    class function CamposFechamento: string; virtual;

    class function CampoDescricao: string; virtual;
    class function CampoStatus: string; virtual;
    class function UsuarioInc: string; virtual;
    class function UsuarioAlt: string; virtual;
    class function DataHoraInc: string; virtual;
    class function DataHoraAlt: string; virtual;

    class function PermiteConfigurarAcessos: Boolean; virtual;
    class function BloqueiaEdicaoSimultanea: Boolean; virtual;
    class function ForcarRegistraLogTabela: Boolean; virtual;

    class function ValorInicialCampoChave: integer; virtual;
    class function ValorFinalCampoChave: integer; virtual;

    class function CamposCadastro: string; virtual;
    class function SQLBaseCadastro: string; virtual; abstract;
    class function SQLBaseConsulta: string; virtual;
    class function SQLBaseRelatorio: string; overload; virtual; abstract;

    class function MapeamentoDeCampos: string; virtual;
    class function FiltroSql: string; virtual;

    class procedure CarregaConfigClasseCustomizados(CDS: TDataSet; NomeDaClassePai, NomeDaClasse: string);
    class procedure CarregaConfigClasseCampoCustomizados(CDS: TDataSet; NomeDaClassePai, NomeDaClasse: string);

    class procedure ConfigurarPropriedadesDoCampo(CDS: TDataSet; Campo: string); overload; virtual;
    class procedure ConfigurarPropriedadesDosCampos(CDS: TDataSet; CarregarConfigCustomizadas: Boolean = True); virtual;

    class procedure ConfigurarCampoNaoAtualizavel(CDS: TDataSet; Campo: string);
    class procedure ConfigurarResponsabilidade(DataSet: TDataSet; Campo: string);

    class function ParametrosSql: TListaDeParametrosSql; virtual;
    {$IF DEFINED(servidor)} class procedure CriarParametros(ASQLDataSet: TSQLDataSet); {$endif}

    class procedure ConfigurarCampoCompetencia(Sender: TField); // deprecated;
  end;

  TFClassPaiCadastro = class of TClassPaiCadastro;

function CriarClassePeloNome(const Nome: string): TClassPaiCadastro;

implementation

uses Constantes
    {$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(CLASSESTEK)) AND (not DEFINED(ATUALIZADOR))}
    , UDMConexao, UDMPaiCadastro, Validate
    {$IFEND}, ClassHelperDataSet, GetTexts;

class function TClassPaiCadastro.Descricao: string;
begin
  Result := ClassName;
end;

class function TClassPaiCadastro.TabelaPrincipal: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.ClassOriginal: string;
begin
  // Nome da classe o qual é derivada
  // ex: tabela de 'ClassPessoaCad_Cliente', a classe original é a 'ClassPessoa'
  Result := '';
end;

class function TClassPaiCadastro.ClassRelacional: string;
begin
  // Nome da classe o qual é relacionada (mestre detalhe), no caso o cliente setando o master.
  // ex: tabela de 'ClassPessoa_Endereco', a classe relacional é a 'ClassPessoa'
  Result := '';
end;

class function TClassPaiCadastro.CampoEmpresa: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoEstabelecimento: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CamposCadastro: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoChave: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoRegistroSecundario: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CamposFechamento: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoDescricao: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoStatus: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.UsuarioInc: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.UsuarioAlt: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.DataHoraInc: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.DataHoraAlt: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.ValorFinalCampoChave: integer;
begin
  // Este valor é testado na função Novo do PaiCadastro
  // Usado pada delimitar o valor máximo para o cadastro
  // Exemplo: O maior código do cadastro de eventos do DP é 9999
  Result := 0;
end;

class function TClassPaiCadastro.ValorInicialCampoChave: integer;
begin
  // Este valor é testado pela funçao ProximoCodigo
  // Usado para resevar uma faixa de códigos para uso interno do sistema
  // Exemplo: No cadastro de eventos do DP a faixa de código até 5000 é reservada para o sistema,
  // os eventos criados pelo usuário iniciam em 5001
  Result := 0;
end;

class function TClassPaiCadastro.ParametrosSql: TListaDeParametrosSql;
begin
  SetLength(Result, 0);
end;

class function TClassPaiCadastro.PermiteConfigurarAcessos: Boolean;
begin
  Result := False;
end;

class function TClassPaiCadastro.BloqueiaEdicaoSimultanea: Boolean;
begin
  Result := False;
end; 

class function TClassPaiCadastro.ForcarRegistraLogTabela: Boolean;
begin
  Result := False;
end;

class function TClassPaiCadastro.SQLBaseConsulta: string;
begin
  Result := '';
end;

class procedure TClassPaiCadastro.CarregaConfigClasseCustomizados(CDS: TDataSet; NomeDaClassePai, NomeDaClasse: string);
{$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) and (DEFINED(CLASSESTEK))}
var
  CDSTemp: TClientDataSet;
  ctxRtti: TRttiContext;
  typeRtti: TRttiType;
  metRtti: TRttiMethod;
{$IFEND}
begin
{$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(ATUALIZADOR))}
  if (UpperCase(ExtractFileName(ParamStr(0))) = 'TEKSERVER.EXE') then
    Exit;

{$IF (DEFINED(CLASSESTEK))}
  CDSTemp := TClientDataSet.Create(nil);
  try
    ctxRtti := TRttiContext.Create;
    try
      typeRtti := ctxRtti.GetType(Constantes.DMConexaoExistente.ClassType);
      metRtti := typeRtti.GetMethod('GetCDSConfigClasses');

      CDSTemp.Data := metRtti.Invoke(Constantes.DMConexaoExistente, []).AsVariant;
      CDSTemp.IndexFieldNames := 'CLASSEPAI_CFGC;CLASSE_CFGC';
    finally
      ctxRtti.Free;
    end;

    with CDSTemp do
{$ELSE}
    with DMConexao.CDSConfigClasses do
{$IFEND}
    begin
      if IsEmpty then
        Exit;

      if FindKey([NomeDaClassePai, NomeDaClasse]) then
      begin
        while (not eof) and
              (FieldByName('CLASSEPAI_CFGC').AsString = NomeDaClassePai) and
              (FieldByName('CLASSE_CFGC').AsString = NomeDaClasse) do
        begin
          with TClientDataSet(CDS).Constraints.Add do
          begin
            CustomConstraint := FieldByName('CONDICAO_CFGC').AsString;
            ErrorMessage :=
              FieldByName('MENSAGEM_CFGC').AsString + #13#13 +
              'Violação da validação definida pelo usuário';
          end;
          Next;
        end;
      end;
    end;
{$IF (DEFINED(CLASSESTEK))}
  finally
    CDSTemp.Free;
  end;
{$IFEND}
{$IFEND}
end;

class procedure TClassPaiCadastro.CarregaConfigClasseCampoCustomizados(CDS: TDataSet; NomeDaClassePai, NomeDaClasse: string);
{$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(CLASSESTEK)) AND (not DEFINED(ATUALIZADOR))}
var
  Campo: TField;
{$ELSEIF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(ATUALIZADOR))}
var
  Campo: TField;
  CDSTemp: TClientDataSet;
  ctxRtti: TRttiContext;
  typeRtti: TRttiType;
  metRtti: TRttiMethod;
{$IFEND}
begin
  // - Para funcionar nas classes dever trocar override da função ConfigurarPropriedadesDosCampos para overload e
  // adicionar inherited no inicio da função ConfigurarPropriedadesDosCampos, pondendo tirar tambem a chamada
  // da função ConfigurarPropriedadesDoCampo, veja como exemplo a ClassCarga.
  // - Para classes com derifadas deve setar na propriedade ClassOriginal o nome da classe de Pai como exemplo a
  // classe ClassPessoaCad_Cliente
  // - Para classes com relacionamento 1 x 1 ou N x 1 deve setar na propriedade ClassRelacional o nome da classe de
  // relacionamento, como exemplo a classe ClassDocumento_Pedido e ClassDocumento_Item
  // ** Alterado para não fazer o ReadOnly direto no cliente dataset pois ocorria problema com os campos que eram
  // setados valores pelo sistema, como exemplo bloquear campos de chaves de relacionamentos e default's; Então setado
  // apenas um valor na tag e na tela é alterado a propriedade ReadOnly do componente

{$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(ATUALIZADOR))}

  // Não retire o comando abaixo: como não consegue diferenciar atraves das directivas de compilação em tempo de execução,
  // mas mantido as directivas devido a debug no delphi
  if (UpperCase(ExtractFileName(ParamStr(0))) = 'TEKSERVER.EXE') then
    Exit;

{$IF (DEFINED(CLASSESTEK))}
  CDSTemp := TClientDataSet.Create(nil);
  try
    ctxRtti := TRttiContext.Create;
    try
      typeRtti := ctxRtti.GetType(Constantes.DMConexaoExistente.ClassType);
      metRtti := typeRtti.GetMethod('GetCDSConfigCamposClasses');

      CDSTemp.Data := metRtti.Invoke(Constantes.DMConexaoExistente, []).AsVariant;
    finally
      ctxRtti.Free;
    end;

    if CDSTemp.IsEmpty then
      Exit;

    CDSTemp.IndexFieldNames := 'CLASSE_USUCLASS;CLASSE_UCC;CAMPO_UCC';

    with CDSTemp do
{$ELSE}
    with DMConexao.CDSConfigCamposClasses do
{$IFEND}
    begin
      if IsEmpty then
        Exit;

      if FindKey([NomeDaClassePai, NomeDaClasse]) then
      begin
        while (not Eof) and
              (FieldByName('CLASSE_USUCLASS').AsString = NomeDaClassePai) and
              (FieldByName('CLASSE_UCC').AsString = NomeDaClasse) do
        begin
          Campo := CDS.FindField(FieldByName('CAMPO_UCC').AsString);
          if Campo <> nil then
          begin
            if (FieldByName('BLOQUEAR_UCC').AsString = 'S') or (FieldByName('OMITIR_UCC').AsString = 'S') then
              Campo.Tag := cTagConfigBloqCampo;
            {if FieldByName('OMITIR_UCC').AsString = 'S' then                           ** Projeto futuro do Marlon, ainda voltarei aqui apos migração para Delphi 10.1
              Campo.OnGetText := TGetTexts.GetText_OmitidoValor;
            if FieldByName('CONDICAO_UCC').AsString <> '' then
            begin
              if Campo.CustomConstraint <> '' then
                Campo.CustomConstraint := '(' + Campo.CustomConstraint + ') and ';
              Campo.CustomConstraint := Campo.CustomConstraint + FieldByName('CONDICAO_UCC').AsString;

              if FieldByName('MENSAGEM_UCC').AsString <> '' then
              begin
                if Campo.ConstraintErrorMessage <> '' then
                  Campo.ConstraintErrorMessage := Campo.ConstraintErrorMessage + #13;

                Campo.ConstraintErrorMessage := Campo.ConstraintErrorMessage +
                  FieldByName('MENSAGEM_UCC').AsString + #13#13 +
                  'Violação da validação definida pelo usuário';
              end;
            end;}
          end;
          Next;
        end;
      end;
    end;
{$IF (DEFINED(CLASSESTEK))}
  finally
    CDSTemp.Free;
  end;
{$IFEND}
{$IFEND}
end;

class procedure TClassPaiCadastro.ConfigurarPropriedadesDoCampo(CDS: TDataSet; Campo: string);
begin
  CDS.FieldByName(Campo).Configurar;
end;

class procedure TClassPaiCadastro.ConfigurarPropriedadesDosCampos(CDS: TDataSet; CarregarConfigCustomizadas: Boolean = True);
var
  x: Integer;
{$IF (not DEFINED(SERVIDOR)) and (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(ATUALIZADOR))}
  NomeDaClassePai: string;
{$IF (DEFINED(CLASSESTEK))}
  ctxRtti: TRttiContext;
  typeRtti: TRttiType;
  metRtti: TRttiMethod;
{$IFEND}
{$IFEND}
begin
{$IF DEFINED(SERVIDOR)}
  if (CDS is TClientDataSet) then
{$IFEND}
    begin
      // Ao converter o sistema para Delphi XE2,
      // se as linhas abaixo fossem executadas no servidor de aplicação,
      // ao abrir alguns cadastros mais pesados (com mestre detalhe, ex: Duplicatas)
      // o sistema travava. Às vezes não na primeira abertura, mas em aberturas subsequentes.
      // Por isto as linhas foram bloqueadas.
      // Contudo, em alguns locais do servidor foi feito uso de ClientDataSets
      // que são configurados através desta função (Ex. Planejamento financeiro)
      // Nestes casos se a função não for executada, o default dos campos, por exemplo, não é colocado apropriadamente.
      // Então, tome cuidado ao mexer aqui.

      with CDS do
      begin
        for x := 0 to FieldDefs.Count - 1 do
          Self.ConfigurarPropriedadesDoCampo(CDS, AnsiUpperCase(FieldDefs.Items[x].Name));

        for x := 0 to CDS.Fields.Count - 1 do
          CDS.Fields[x].AjustarConstraint(Descricao);
      end;
    end;

{$IF (not DEFINED(SERVIDOR)) and (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(ATUALIZADOR))}
  if CarregarConfigCustomizadas then
  begin
    if ClassRelacional = '' then
      NomeDaClassePai := ClassName
    else begin
      NomeDaClassePai := 'T' + ClassRelacional;

      if (CDS.Owner <> nil) then
      begin
{$IF (DEFINED(CLASSESTEK))}
        ctxRtti := TRttiContext.Create;
        try
          typeRtti := ctxRtti.GetType(CDS.Owner.ClassType);
          metRtti := typeRtti.GetMethod('GetClassNameClasseFilha');
          if Assigned(metRtti) then
            NomeDaClassePai := metRtti.Invoke(CDS.Owner, []).AsString;
        finally
          ctxRtti.Free;
        end;
{$ELSE}
        if (CDS.Owner is TDMPaiCadastro) then
          NomeDaClassePai := TDMPaiCadastro(CDS.Owner).ClasseFilha.ClassName;
{$IFEND}
      end;
    end;

    CarregaConfigClasseCampoCustomizados(CDS, NomeDaClassePai, ClassName);
    CarregaConfigClasseCustomizados(CDS, NomeDaClassePai, ClassName);
  end;
{$IFEND}
end;

class procedure TClassPaiCadastro.ConfigurarCampoNaoAtualizavel(CDS: TDataSet; Campo: string);
begin
{$IF DEFINED(SERVIDOR)}
  if (CDS is TClientDataSet) then
{$IFEND}
  begin
    Self.ConfigurarPropriedadesDoCampo(CDS, Campo);
  end;

  CDS.FieldByName(Campo).ConfigurarCampoNaoAtualizavel;
end;

{$IF DEFINED(servidor)}
class procedure TClassPaiCadastro.CriarParametros(ASQLDataSet: TSQLDataSet);
var
  Parametros: TListaDeParametrosSql;
  i: integer;
begin
  Parametros := Self.ParametrosSql;
  if Length(Parametros) > 0 then
  begin
     ASQLDataSet.Params.Clear;
     for i := Low(Parametros) to High(Parametros) do
     begin
       with TParam(ASQLDataSet.Params.Add) do
       begin
         Name := Parametros[i].Nome;
         DataType := Parametros[i].Tipo;
         ParamType := ptInput;
         Value := Parametros[i].Valor;
       end;
     end;
  end;
end;
{$endif}

class procedure TClassPaiCadastro.ConfigurarResponsabilidade(DataSet: TDataSet; Campo: string);
begin
  with DataSet.FieldByName(Campo) do
    if (Campo = DataHoraInc) then
      begin
        ConfigurarTipoDataHora;
        DisplayLabel := 'Data/Hora de Inclusão';
        DefaultExpression := 'AGORA';
      end
    else if (Campo = DataHoraAlt) then
      begin
        ConfigurarTipoDataHora;
        DisplayLabel := 'Data/Hora Última Edição';
      end
    else if (Campo = UsuarioInc) then
      begin
        DisplayLabel := 'Usuário Inclusão';
        DefaultExpression := 'USUARIO';
        DisplayWidth := 19;
      end
    else if (Campo = UsuarioAlt) then
      begin
        DisplayLabel := 'Usuário Última Edição';
        DisplayWidth := 19;
      end;
end;

class function TClassPaiCadastro.MapeamentoDeCampos: string;
var
  Lista: TStrings;
  x, T: Integer;
  S: String;
begin
  Lista := TStringList.Create;
  try
    Result := '';
    if (CamposCadastro = '') then Exit;
    ExtractStrings([','], [' ', #9, #13], {$IFDEF VER185} PAnsiChar {$ELSE} PWideChar {$endif}(CamposCadastro), Lista);
    with Lista do
      begin
        // Tamanho do nome da tabela principal mais o ponto
        T := Length(TabelaPrincipal) + 2;

        for x := Count - 1 downto 0 do
          begin
            S := Trim(Strings[x]);
            if Pos(TabelaPrincipal, S) = 1 then
              Strings[x] := Copy(S, T, MaxInt) + '=' + Strings[x]
            else
              Delete(x);
          end;
      end;
    Result := Lista.Text;
  finally
    Lista.Free;
  end;
end;

class function TClassPaiCadastro.FiltroSql: string;
begin
  Result := '';
end;

function CriarClassePeloNome(const Nome: string): TClassPaiCadastro;
var
  Classe: TFClassPaiCadastro;
  Persist: TPersistentClass;
begin
  // Cria uma classe derivada de ClassPaiCadastro, pelo nome dela
  // Isso evita que essa unit tenha referência a todas as classes
  try
    Result := nil;
    try
      Persist := FindClass(Nome);
    except
      raise Exception.Create('A classe ' + Nome + ' não está disponível nesse módulo, entre em contato com a Tek-System');
    end;
    Classe := TFClassPaiCadastro(Persist);
    Result := Classe.Create;
  finally
  end;
end;

class procedure TClassPaiCadastro.ConfigurarCampoCompetencia(Sender: TField);
begin
  with TStringField(Sender) do
  begin
    Alignment := taCenter;
    EditMask := '99/9999';
    OnGetText := TGetTexts.GetText_Competencia;
    OnSetText := TGetTexts.SetText_Competencia;

    {$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT)) AND (not DEFINED(CLASSESTEK)) AND (not DEFINED(ATUALIZADOR))}
    OnValidate := TValidates.Validate_Competencia;
    {$IFEND}
  end;
end;

end.

