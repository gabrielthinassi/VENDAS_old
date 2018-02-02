/// <summary>
/// Absorve a funções comuns de banco de dados e sessão do usuário
/// </summary>
/// <remarks>
/// Vamos manter aqui apenas as funções de execução com bancos de dados.
/// As demais funções criaremos em outros ServerModules
/// </remarks>
unit USMConexao;

interface

uses
  System.SysUtils, System.Classes, System.Variants, Data.SqlExpr, DBXCommon, Data.FMTBcd,
  Winapi.Windows, Data.DB, DBClient, Provider, Vcl.Forms, Data.SqlConst, System.StrUtils, System.Math,
  Datasnap.DSServer, acQBBase, acQBdbExMetaProvider, acAST, acFbSynProvider, Graphics, jpeg, Generics.Collections,
  Data.DBXJSONReflect, Datasnap.DSCommonServer, Datasnap.DSProviderDataModuleAdapter, System.Json,
  ClassSecaoAtual, ClassSecaoAtualNovo;

type
  EFuncionalidadeNaoLiberada = class(Exception);

  TSMConexao = class(TDSServerModule)
    CDSProximoCodigo: TClientDataSet;
    DSPProximoCodigo: TDataSetProvider;
    SQLDSProximoCodigo: TSQLDataSet;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);
    procedure DSPProximoCodigoGetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);
    procedure DSPProximoCodigoUpdateData(Sender: TObject; DataSet: TCustomClientDataSet);
  private
    FSecaoAtual      : TClassSecaoNovo;
    FMeuSQLConnection: TSQLConnection;

    FCodigoAcesso    : Int64;
    FCodigoClienteTek: string;

    FFormulasCadastro: OleVariant;

    FCDSFuncionalidadesLiberadas: TClientDataSet;

    FOnSetAtividade: TProc;

    procedure RetiraRegistrosDeEdicao; virtual;
    procedure AtualizaLogAcesso(const DtHrSaida: TDateTime); virtual;
    function MontaStringCodigos(CDS: TClientDataSet): String; virtual;
    function GetFormulasCadastro: OleVariant; virtual;
    function GetSetorDesenvolvimentoTekSystem: Boolean;
    procedure CarregaEmail(Codigo: Integer; var EMail: TConfigEMailNovo);
  public
    CDSUnitsProtegidas         : TClientDataSet;
    CDSProcessamentosProtegidos: TClientDataSet;

    /// <summary>
    /// Cria a instancia do SM, não deve ser chamada de aplicações externas
    /// </summary>
    /// <param name="pDono">
    /// Owner
    /// </param>
    /// <param name="pSecaoAtual">
    /// Instancia da SecaoAtual
    /// </param>
    /// <param name="pModoAutenticacao">
    /// Modo de autenticação do usuário
    /// 0 - Conecta no BDD, loga com Usuário e senha
    /// 1 - Conecta no BDD, carrega Guid, loga com Usuário e senha do Guid
    /// 2 - Conecta no BDD, carrega configuração geral
    /// 3 - Conecta no BDD
    /// 4 - Não faz validação alguma
    /// </param>
    /// <param name="pOmitirAcesso">
    /// Se não irá registrar o acesso ao sistema
    /// </param>
    /// <param name="pOnSetAtividade">
    /// Metodo de SetAtividade
    /// </param>
    /// <returns>
    /// Instancia do SM
    /// </returns>
    class function CreateInstance(pDono: TComponent; pSecaoAtual: TClassSecaoNovo; pModoAutenticacao: Integer; pOmitirAcesso: Boolean; pOnSetAtividade: TProc): TSMConexao;

    /// <summary>
    /// Conexão da base de dados corrente
    /// </summary>
    /// <returns>
    /// Drive + string de conexão do BD
    /// </returns>
    function ConexaoBDD: String; virtual;

    /// <summary>
    /// Versão da procedure da base de dados
    /// </summary>
    /// <returns>
    /// String da versão
    /// </returns>
    function VersaoBDD: String; virtual;

    /// <summary>
    /// Se a Conexão da base de dados corrente é uma base:
    /// cTipoBDD_Producao = 0;
    /// cTipoBDD_Homologacao = 1;
    /// cTipoBDD_Limpo = 2;
    /// </summary>
    /// <returns>
    /// Lógico
    /// </returns>
    function ConexaoBDD_Tipo: Integer; virtual;

    /// <summary>
    /// Grupo de informações da conexão da base de dados
    /// </summary>
    /// <returns>
    /// Vertor: ConexaoBDD, VersaoBDD, ConexaoBDD_Tipo
    /// </returns>
    function InformacoesDaConexaoBDD: OleVariant; virtual;

    /// <summary>
    /// Número de conexões ativas no servidor de aplicação
    /// </summary>
    /// <param name="Tipo">
    /// Tipo de conexões de retorno
    /// 0 - Tudo
    /// 1 - Do usuário
    /// 2 - Similares
    /// </param>
    /// <returns>
    /// Coleção de dados das conexões ativas
    /// </returns>
    function ConexoesAtivas(Tipo: Integer): OleVariant; virtual;

    /// <summary>
    /// Usuários online
    /// </summary>
    /// <returns>
    /// Vetor de nome de usuários online
    /// </returns>
    function UsuariosOnLine: OleVariant; virtual;

    /// <summary>
    /// Atribuir sistema somente leitura
    /// </summary>
    /// <remarks>
    /// Utilizado pelo TekProt quando o sistema está bloqueado
    /// </remarks>
    procedure AtribuirSistemaSomenteLeitura; virtual;

    /// <summary>
    /// Executa instrução SQL
    /// </summary>
    /// <param name="SQL">
    /// Texto da SQL
    /// </param>
    /// <param name="CriarTransacao">
    /// Se irá cria uma transação local independente
    /// </param>
    /// <returns>
    /// Valor do processamento da SQL, com retorno de único campo e registro (valor único)
    /// </returns>
    /// <remarks>
    /// No caso de não criar uma transação local independente, a função deve ser chamada dentro do contexto de outra transação.
    /// Motivo: Quando não usa uma transação independente, a transação implícita fica ativa até a execução de um próximo comando.
    /// Isto enquanto estivermos usando a dbexpida40.dll versão 2.20.08 como driver de acesso ao firebird.
    /// 1 - Cria uma transação local independente (caso se queira)
    /// 2 - Executa um comando SQL no BDD
    /// 3 - Retorna o primeiro campo do primeiro registro, já tipado
    /// 4 - Dá um COMMIT na transação local (caso tenha sido criada)
    /// </remarks>
    function ExecuteScalar(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;

    /// <summary>
    /// Executa instrução SQL
    /// </summary>
    /// <param name="SQL">
    /// Texto da SQL
    /// </param>
    /// <param name="TamanhoPacote">
    /// ** Atualmente não faz nada **
    /// </param>
    /// <param name="CriarTransacao">
    /// Se irá cria uma transação local independente
    /// </param>
    /// <returns>
    /// Coleção de dados do processamento da SQL
    /// </returns>
    /// <remarks>
    /// No caso de não criar uma transação local independente, a função deve ser chamada dentro do contexto de outra transação.
    /// Motivo: Quando não usa uma transação independente, a transação implícita fica ativa sendo reutilizada a cada comando.
    /// Isto enquanto estivermos usando a dbexpida40.dll versão 2.20.08 como driver de acesso ao firebird.
    /// 1 - Cria uma transação local independente (caso se queira)
    /// 2 - Executa um comando SQL no BDD
    /// 3 - Retorna a coleção de dados
    /// 4 - Dá um COMMIT na transação local (caso tenha sido criada)
    /// </remarks>
    function ExecuteReader(SQL: string; TamanhoPacote: Integer; CriarTransacao: Boolean): OleVariant; virtual;

    /// <summary>
    /// Executa instrução SQL
    /// </summary>
    /// <param name="SQL">
    /// Texto da SQL
    /// </param>
    /// <param name="CriarTransacao">
    /// Se irá cria uma transação local independente
    /// </param>
    /// <returns>
    /// Número de registros afetados
    /// </returns>
    /// <remarks>
    /// No caso de não criar uma transação local independente, a função deve ser chamada dentro do contexto de outra transação.
    /// Motivo: Quando não usa uma transação independente, a transação implícita fica ativa até a execução de um próximo comando.
    /// Isto enquanto estivermos usando a dbexpida40.dll versão 2.20.08 como driver de acesso ao firebird.
    /// 1 - Cria uma transação local independente (caso se queira)
    /// 2 - Tenta executar o comando SQL
    /// 3 - Se o comando executar com sucesso: efetua commit na transação local (caso tenha sido criada)
    /// - Se o comando não executar com sucesso: efetua rollback na transação local (caso tenha sido criada)
    /// </remarks>
    function ExecuteCommand(SQL: string; CriarTransacao: Boolean): OleVariant; virtual;

    /// <summary>
    /// Seleciona registro, modifica valor do campo e aplica
    /// </summary>
    /// <param name="SQL">
    /// Texto da SQL se seleção do registro, ex: select CODIGO, OBS from TABELA where CODIGO = 1;
    /// </param>
    /// <param name="Campo">
    /// Nome do campo que será submetido a modificação, ex: OBS
    /// </param>
    /// <param name="Valor">
    /// Valor que será atribuido
    /// </param>
    /// <param name="CriarTransacao">
    /// Se irá cria uma transação local independente
    /// </param>
    /// <returns>
    /// Número de registros afetados
    /// </returns>
    /// <remarks>
    /// No caso de não criar uma transação local independente, a função deve ser chamada dentro do contexto de outra transação.
    /// Motivo: Quando não usa uma transação independente, a transação implícita fica ativa até a execução de um próximo comando.
    /// Isto enquanto estivermos usando a dbexpida40.dll versão 2.20.08 como driver de acesso ao firebird.
    /// 1 - Cria uma transação local independente (caso se queira)
    /// 2 - Tenta executar o comando SQL de seleção
    /// 4 - Atribuido o novo valor ao campo
    /// 3 - Se o comando executar com sucesso: efetua commit na transação local (caso tenha sido criada)
    /// - Se o comando não executar com sucesso: efetua rollback na transação local (caso tenha sido criada)
    /// </remarks>
    function ExecuteCommand_Update(SQL, Campo: string; Valor: OleVariant; CriarTransacao: Boolean): OleVariant; virtual;

    /// <summary>
    /// Data e hora do servidor de banco de dados.
    /// </summary>
    /// <returns>
    /// Data e hora
    /// </returns>
    /// <remarks>
    /// Não foi usado NOW para não haver problemas de sincronização no caso de mais de um servidor de aplicação.
    /// Só vai criar transação se ainda não tiver nenhuma ativa.
    /// Se já existir uma transação aberta, vai usá-la para buscar a data/hora do servidor de banco de dados.
    /// Evitando assim excesso de transações no banco de dados
    /// Tomar cuidado com constantes chamada desse método, pois, executa instrução na base de dados
    /// </remarks>
    function DataHora: TDateTime; virtual;

    /// <summary>
    /// Proximo código de uma tabela
    /// </summary>
    /// <param name="Tabela">
    /// Nome da tabela
    /// </param>
    /// <param name="Quebra">
    /// Código da quebra, ex: código da empresa (atualmente não usamos)
    /// </param>
    /// <returns>
    /// Valor inteiro do próximo código
    /// </returns>
    /// <remarks>
    /// Chama a função ProximoCodigoAcrescimo com acrescimo de 1
    /// </remarks>
    function ProximoCodigo(Tabela: String; Quebra: Integer): Int64; virtual;

    /// <summary>
    /// Proximo código de uma tabela
    /// </summary>
    /// <param name="Tabela">
    /// Nome da tabela
    /// </param>
    /// <param name="Quebra">
    /// Código da quebra, ex: código da empresa (atualmente não usamos)
    /// </param>
    /// <param name="Acrescimo">
    /// Número a acrescer ao número atual de código da tabela
    /// </param>
    /// <returns>
    /// Valor inteiro do próximo código
    /// </returns>
    /// <remarks>
    /// Retorna o próximo código de uma tabela, com uma transação independente
    /// </remarks>
    function ProximoCodigoAcrescimo(Tabela: String; Quebra, Acrescimo: Integer): Int64; virtual;

    /// <summary>
    /// Acerta próximo código de uma tabela
    /// </summary>
    /// <param name="NomeDaClasse">
    /// Nome da Classe
    /// </param>
    /// <param name="Quebra">
    /// Código da quebra, ex: código da empresa (atualmente não usamos)
    /// </param>
    /// <param name="CriarTransacao">
    /// Se irá cria uma transação local independente
    /// </param>
    /// <remarks>
    /// Recalcula o proximo código da tabela e gravar o novo valor
    /// </remarks>
    procedure AcertaProximoCodigo(NomeDaClasse: String; Quebra: Integer; CriarTransacao: Boolean = True); virtual;

    /// <summary>
    /// Ajustar código AutoInc de uma referida tabela
    /// </summary>
    /// <param name="Tabela">
    /// Nome da tabela
    /// </param>
    /// <param name="Valor">
    /// Novo código
    /// </param>
    /// <param name="Quebra">
    /// Código da quebra, ex: empresa (atualmente não usamos)
    /// </param>
    /// <param name="CriarTransacao">
    /// Se irá cria uma transação local independente
    /// </param>
    procedure AtualizarProximoCodigo(Tabela: String; Quebra, Valor: Integer; CriarTransacao: Boolean = True); virtual;

    /// <summary>
    /// Registra o número da registros afetados e faz a troca do código
    /// </summary>
    /// <param name="Tabela">
    /// Nome da tabela
    /// </param>
    /// <param name="CampoChave">
    /// Nome do campo chave da tabela
    /// </param>
    /// <param name="CodigoAntigo">
    /// Código atual do registro
    /// </param>
    /// <param name="CodigoNovo">
    /// Código do novo registro
    /// </param>
    /// <remarks>
    /// A função registra log da alteração na tabela ALTERACAO_DE_CODIGOS.
    /// Deveria ser uma função genérica, mas um certo alguem ja foi la adicinou funcionalidade e não tratou, aff ...
    /// Essa função é específica do Firebird, se for disponibilizar no SQLServer, ajustar
    /// </remarks>
    procedure TrocarCodigo(Tabela, CampoChave: String; CodigoAntigo, CodigoNovo: Int64); virtual;

    /// <summary>
    /// Defaults Personalizados
    /// </summary>
    /// <param name="Tabela">
    /// Nome da tabela
    /// </param>
    /// <returns>
    /// Data de CDS dos defaults
    /// </returns>
    /// <returns>
    /// Utilizar Defaults registrado na tabela PADROES, são personalizados.
    /// </returns>
    function CarregaDefaults(Tabela: String): OleVariant; virtual;

    /// <summary>
    /// Fórmula aplicada de manipulação de registros
    /// </summary>
    procedure CarregaFormulasCadastro; virtual;

    /// <summary>
    /// Registra Ação
    /// </summary>
    /// <param name="Descricao">
    /// Descrição resumida da ação
    /// </param>
    /// <param name="Inicio">
    /// Data/Hora de inicio da ação
    /// </param>
    /// <param name="Fim">
    /// Data/Hora de término da ação
    /// </param>
    /// <param name="Observacao">
    /// Observações da ação
    /// </param>
    procedure RegistraAcao(Descricao: String; Inicio, Fim: TDateTime; Observacao: OleVariant); virtual;

    /// <summary>
    /// Dados de registros bloqueado
    /// </summary>
    /// <returns>
    /// Data de CDS dos registros bloqueados
    /// </returns>
    function RegistrosEmEdicao: OleVariant; virtual;

    /// <summary>
    /// Inclui registro em edição
    /// </summary>
    /// <param name="Tabela">
    /// Nome da tabela
    /// </param>
    /// <param name="Quebra">
    /// Código da quebra, ex: empresa (atualmente não usamos)
    /// </param>
    /// <param name="Codigo">
    /// Código do registro
    /// </param>
    /// <param name="Vinculo">
    /// Código do registro da tabela principal
    /// </param>
    /// <returns>
    /// Vetor de dados [CodBloqueio, UsuarioBloqueio, DataHoraBloqueio];
    /// </returns>
    /// <remarks>
    /// Verifica se o registro já está bloqueado.
    /// Caso esteja retorna o código do bloqueio, o usuário, a data e hora do bloqueio.
    /// Caso não esteja, bloqueia e retorna o código de bloqueio
    /// </remarks>
    function IncluiRegistroEmEdicao(Tabela: String; Quebra: Integer; Codigo, Vinculo: String): OleVariant; virtual;

    /// <summary>
    /// Retira bloqueio de registro e suas dependencias
    /// </summary>
    /// <param name="Codigo">
    /// Código do registro de bloqueio
    /// </param>
    /// <param name="Vinculo">
    /// Se irá retirar o bloqueio apenas dos registros vinculados
    /// </param>
    procedure RetiraRegistroDeEdicao(AutoInc: Int64; Registrar, ApenasVinculados: Boolean); virtual;

    /// <summary>
    /// Retira bloqueio de registros vinculados
    /// </summary>
    /// <param name="Vinculo">
    /// Código do registro vinculado
    /// </param>
    /// <remarks>
    /// Exclui todos os registros bloqueados que estão vinculado a um outro registro bloqueado.
    /// Tem a função de agilizar os cadastros onde muitos registros serão marcados/desmarcados. Ex: Exportação de Títulos.
    /// Sendo usada antes da RetiraRegistrosDeEdicao, elimina os vínculos diretos com o cadastro, não entrando em recursividade ao procurar dependências.
    /// Não deve ser usada se possuir sub-detalhes vinculados ou se precisar registrar o desbloqueio.
    /// </remarks>
    procedure RetiraRegistrosVinculadosDeEdicao(Vinculo: String); virtual;

    /// <summary>
    /// Registra log de acesso ao sistema
    /// </summary>
    /// <param name="IP">
    /// IP da conexão
    /// </param>
    procedure RegistraLogAcesso(const DataHora: TDateTime); virtual;

    /// <summary>
    /// Registra log de modicações em registros
    /// </summary>
    /// <param name="Dados">
    /// Vetor de dados [Acao, Tabela, Usuario, CodigoRegistro, Observacao]
    /// </param>
    procedure RegistraLogTabela(Dados: OleVariant); virtual;

    /// <summary>
    /// Registra log de acesso e permanencia em telas do sistema
    /// </summary>
    /// <param name="Sistema">
    /// Código do sistema
    /// </param>
    /// <param name="Usuario">
    /// Código do usuário
    /// </param>
    /// <param name="Formulario">
    /// Nome do formulário
    /// </param>
    /// <param name="DtHrEntrada">
    /// Data/Hora de entrada
    /// </param>
    /// <returns>
    /// Código do log registradao
    /// </returns>
    function RegistroLogTela(Sistema, Usuario: Integer; Formulario: String; DtHrEntrada: TDateTime): Int64; virtual;

    /// <summary>
    /// Atualiza informações de log de tela já gravado
    /// </summary>
    /// <param name="Codigo">
    /// Código do log
    /// </param>
    /// <param name="DtHrSaida">
    /// Data/Hora saída do formulário
    /// </param>
    /// <param name="Tempo">
    /// Tempo de permanencia no formulário
    /// </param>
    procedure AtualizaLogTela(Codigo: Int64; DtHrSaida, Tempo: TDateTime); virtual;

    /// <summary>
    /// Registra log do gerador de relatório
    /// </summary>
    /// <param name="Descricao">
    /// Descrição resumida do log
    /// </param>
    /// <param name="Conteudo">
    /// Observações do log
    /// </param>
    /// <param name="Tipo">
    /// Código do tipo de log
    /// </param>
    function RegistraLogGR_Relatorio(Descricao: String; Conteudo: String; Relatorio, Tipo: Integer): Int64; virtual;

    /// <summary>
    /// Atualiza informações de log do gerador de relatório (TIPO = EXECUÇÃO DE RELATÓRIO)
    /// </summary>
    /// <param name="Codigo">
    /// Código do log
    /// </param>
    /// <param name="DtHrTermino">
    /// Data/Hora do fim do processamento
    /// </param>
    /// <param name="Tempo">
    /// Tempo do processamento
    /// </param>
    /// <param name="Conteudo">
    /// Observações do log
    /// </param>
    procedure AtualizaLogGR_Relatorio(Codigo: Int64; DtHrTermino, Tempo: TDateTime; Conteudo: String); virtual;

    /// <summary>
    /// Registra log do coletor
    /// </summary>
    /// <param name="DtHrInicio">
    /// Data e hora de Inicio
    /// </param>
    /// <param name="Entrada">
    /// Observações / texto de entrada
    /// </param>
    function RegistroLogColetor(DtHrInicio: TDateTime; Entrada: string): Int64; virtual;

    /// <summary>
    /// Atualiza informações de log do coletor
    /// </summary>
    /// <param name="Codigo">
    /// Código do log
    /// </param>
    /// <param name="DtHrTermino">
    /// Data/Hora do fim do processamento
    /// </param>
    /// <param name="Saida">
    /// Observações do log de saída
    /// </param>
    procedure AtualizaLogColetor(Codigo: Int64; DtHrTermino: TDateTime; Saida: string); virtual;

    /// <summary>
    /// Carregar informações do usuário para a secão
    /// </summary>
    /// <param name="sNome">
    /// Nome do usuário
    /// </param>
    /// <param name="sSenha">
    /// Senha do usuário
    /// </param>
    /// <remarks>
    /// Usado como há acesso do usuário ao sistema ou troca
    /// </remarks>
    procedure CarregaUsuario(sNome, sSenha: string); virtual;

    /// <summary>
    /// Carregar informações do usuário para a secão pelo Token
    /// </summary>
    /// <param name="sValue">
    /// Token do usuário
    /// </param>
    procedure CarregaUsuarioPeloToken(sValue: string); virtual;

    /// <summary>
    /// Carregar informações da quebra (empresa ou estabelecimento ou conta)
    /// </summary>
    /// <param name="iQuebra">
    /// Código da quebra
    /// </param>
    /// <remarks>
    /// Usado como há acesso do usuário ao sistema ou troca da quebra
    /// </remarks>
    procedure CarregaEmpresa(iQuebra: Integer); virtual;

    /// <summary>
    /// Carregar informações do parametro
    /// </summary>
    /// <remarks>
    /// Usado como há acesso do usuário ao sistema ou troca da quebra ou modificação nas configurações
    /// </remarks>
    procedure CarregaConfiguracoes; virtual;

    /// <summary>
    /// Carregar informações da conta do usuário
    /// </summary>
    /// <remarks>
    /// Usado quando usuário acessa o cadastro e faz alguma modificação
    /// </remarks>
    procedure CarregaContasDisponiveisUsuario; virtual;

    /// <summary>
    /// Seção atual em Json
    /// </summary>
    /// <returns>
    /// Classe da seção atual serializado em Json
    /// </returns>
    /// <remarks>
    /// Transporta a seção atual no servidor para o cliente para não realizar novamente as sql no cliente
    /// </remarks>
    function SecaoAtualSerializada: TJsonValue; virtual; deprecated 'Usar SecaoAtualSerializadaNovo';
    function SecaoAtualSerializadaNovo(const prVersaoSistema: string): TJsonValue; virtual;

    /// <summary>
    /// Verifica se o servidor está executando rotina de atualização
    /// </summary>
    /// <remarks>
    /// Verifica se o servidor está executando rotina de atualização, se não e for necessário executa rotinas diversas
    /// </remarks>
    procedure VerificaProcAtualizacao(cCodigoClienteTek: string); virtual;

    /// <summary>
    /// Faz exclusão de registros qualificação extra
    /// </summary>
    /// <param name="Ativa">
    /// Se deseja ativar/executar ou desativar (condições especiais para isso)
    /// </param>
    /// <returns>
    /// Log de erros
    /// </returns>
    function LimpezaBDD(Ativa: Boolean): OleVariant; virtual;

    /// <summary>
    /// Altera/Inclui realizações
    /// </summary>
    /// <param name="Realizacoes">
    /// Data do CDS de realizações
    /// </param>
    /// <param name="Atualizador">
    /// Nome do responsável pela atualização
    /// </param>
    procedure SincronizarRealizacoes(Realizacoes: OleVariant; Atualizador: String); virtual;

    /// <summary>
    /// Classes de cadastro
    /// </summary>
    /// <param name="iTipo">
    /// Tipo de classe:
    /// 0 - Todas as Classes;
    /// 1 - Apenas Classes Primárias;
    /// 2 - Apenas Classes que Permite Configurar Acessos;
    /// 3 - Todas as Classes e todos os campos;
    /// <param name="sNomeClasse">
    /// Nome da classe de origem, se vazia irá trazer tudo
    /// </param>
    /// <returns>
    /// 0 - Data de CDS de classe
    /// 1 - Data de CDS dos ampos das classes
    /// </returns>
    function ClassesDeCadastro(const iTipo: Integer; const sNomeClasse: string): OleVariant; virtual;

    /// <summary>
    /// Solicitação de desconexão no servidor de uma conexão especifica
    /// </summary>
    /// <remarks>
    /// - Envia notificação para usuários conectados via callback
    /// - Força desconexão
    /// </remarks>
    procedure RequisitarDesconexao(Guid: string); virtual;

    /// <summary>
    /// Solicitação de finalização do servidor
    /// </summary>
    /// <remarks>
    /// - Registra ação
    /// - Envia notificação para usuários conectados via callback
    /// - Finaliza o servidor
    /// </remarks>
    procedure RequisitarHalt; virtual;

    /// <summary>
    /// Verifica disponibilidade de internet
    /// </summary>
    /// <returns>
    /// Se há ou não
    /// </returns>
    function InternetAtiva: Boolean; virtual;

    /// <summary>
    /// Atualizar mascara de grupo de resultado na seção atual
    /// </summary>
    /// <param name="MskGrupoResultado">
    /// Nova mascara
    /// </param>
    procedure AtualizarMascaraGrupoResultado(MskGrupoResultado: string); virtual;

    /// <summary>
    /// Atualizar mascara do nível de documento na seção atual
    /// </summary>
    /// <param name="MskNivelDocumento">
    /// Nova mascara
    /// </param>
    procedure AtualizarMascaraNivelDeDocumento(MskNivelDocumento: string); virtual;

    /// <summary>
    /// Estrutura do banco de dados em XML
    /// </summary>
    /// <returns>
    /// XML da base de dados para TacQueryBuilder
    /// </returns>
    /// <remarks>
    /// Ao processar é gravado o xml na pasta do servidor para que na proxima solicitação poder ser utilizado,
    /// evitando um novo processamento que é demorado
    /// </remarks>
    function EstruturaDoBancoDeDadosEmXML: String; virtual;

    /// <summary>
    /// Atualizar número de atendimentos SAC
    /// </summary>
    /// <param name="CodigoUsuario">
    /// Código do Usuário responsável pela atualização
    /// </param>
    /// <remarks>
    /// Função responsável por atualizar contador de SAC no módulo Gestão de
    /// Qualidade. Esse contador é filtrado por usuário logado.
    /// </remarks>
    procedure AtualizarContadorSAC(const CodigoUsuario: Integer); virtual;

    /// <summary>
    /// Abrir tela de callback no cliente
    /// </summary>
    /// <param name="ID">
    /// Identificação da tela
    /// </param>
    /// <param name="Mensagem">
    /// Texto do "processamento"
    /// </param>
    /// <returns>
    /// Se mensagem foi entregue
    /// </returns>
    /// <remarks>
    /// Necessár
    /// </remarks>
    function CallBack_AbreTela(ID: string; Mensagem: string = ''): Boolean; virtual;

    /// <summary>
    /// Fecha tela de callback no cliente conforme o id
    /// </summary>
    /// <param name="ID">
    /// Identificação da tela
    /// </param>
    /// <returns>
    /// Se mensagem foi entregue
    /// </returns>
    /// <remarks>
    /// Necessário inicialmente ter chamado a função CallBack_AbreTela com esse mesmo ID
    /// </remarks>
    function CallBack_FechaTela(ID: string): Boolean; virtual;

    /// <summary>
    /// Envia mensagem texto para o cliente
    /// </summary>
    /// <param name="ID">
    /// Identificação da tela
    /// </param>
    /// <param name="Mensagem">
    /// Texto da mensagem
    /// </param>
    /// <returns>
    /// Se mensagem foi entregue
    /// </returns>
    /// <remarks>
    /// Necessário inicialmente ter chamado a função CallBack_AbreTela com esse mesmo ID
    /// </remarks>
    function CallBack_Mensagem(ID, Mensagem: string): Boolean; virtual;

    /// <summary>
    /// Envia mensagem o incremento de uma progress para o cliente
    /// </summary>
    /// <param name="ID">
    /// Identificação da tela
    /// </param>
    /// <param name="Atual">
    /// Posição atual da progress
    /// </param>
    /// <param name="Total">
    /// Posição total da progress
    /// </param>
    /// <param name="Mensagem">
    /// Mensagem opcional, seria o mesmo que chamar a função CallBack_Mensagem mas aqui diminui um callback
    /// </param>
    /// <returns>
    /// Se mensagem foi entregue
    /// </returns>
    /// <remarks>
    /// Necessário inicialmente ter chamado a função CallBack_AbreTela com esse mesmo ID
    /// </remarks>
    function CallBack_Incremento(ID: string; Atual, Total: Integer; Mensagem: string = ''): Boolean; virtual;

    /// <summary>
    /// Retorna a lista de tabelas do banco de dados.
    /// </summary>
    function GetTableNames(ApenasTabelasDeSistema: Boolean): string;

    /// <summary>
    /// Retorna a lista de procedure do banco de dados.
    /// </summary>
    function GetProcedureNames: string;

    /// <summary>
    /// Informa se uma determinada funcionalidade está liberada via Tekprot
    /// </summary>
    /// <param name="LabelFuncionalidade">
    /// código único correspondente à funcionalidade
    /// </param>
    /// <returns>
    /// True se estiver liberada, False se não foi localizada ou não está
    /// liberada.
    /// </returns>
    function FuncionalidadeLiberada(LabelFuncionalidade: String): Boolean;

    /// <summary>
    /// Carrega as unidades de codificação protegidas via Tekprot para um
    /// ClientDataSet em memória, se ainda não foi carregada.
    /// </summary>
    procedure CarregarUnitsProtegidas;

    /// <summary>
    /// Carrega os processamentos protegidos via Tekprot para um
    /// ClientDataSet em memória, se ainda não foi carregado.
    /// </summary>
    procedure CarregarProcessamentosProtegidos;

    /// <summary>
    /// Devolve uma coleção de dados com o nome das units protegidas e as
    /// suas codificações criptografadas.
    /// </summary>
    function UnitsProtegidas: OleVariant;

    /// <summary>
    /// Devolve uma coleção de dados com o nome dos processamentos protegidos e as
    /// suas codificações criptografadas.
    /// </summary>
    function ProcessamentosProtegidos: OleVariant;

    /// <summary>
    /// Verifica se uma unidade de codificação é protegida e se está liberada para uso pela empresa.
    /// </summary>
    /// <param name="CodigoTekSystemDaUnidadeCodifica">
    /// Código único da unidade de codificação definido pela Tek-system
    /// </param>
    procedure VerificarUsoUnidadeCodificaoLiberado(CodigoTekSystemDaUnidadeCodifica: string);

    /// <summary>
    /// Registra atividade na seção do usuário, usado apenas no próprio servidor
    /// </summary>
    procedure InformaAtividadeSecao;

    // Funcoes utilizadas como property nas Units de emissão de NFe/CTe/MDFe
    function Funcao_AcbrExecuteCommand(s: string): Int64;
    function Funcao_AcbrExecuteReader(s: string): OleVariant;
    function Funcao_AcbrExecuteScalar(s: string): OleVariant;
    function Funcao_AcbrProximoCodigo(s: string): OleVariant;

    property SecaoAtual: TClassSecaoNovo read FSecaoAtual;
    property MeuSQLConnection: TSQLConnection read FMeuSQLConnection;

    property CodigoClienteTek: string read FCodigoClienteTek;

    property FormulasCadastro: OleVariant read GetFormulasCadastro;

    property SetorDesenvolvimentoTekSystem: Boolean read GetSetorDesenvolvimentoTekSystem;
  end;

implementation

{$R *.dfm}


uses Constantes, ConstanteSistema, ConstantesCallBack, LF_Constantes, ClassAspecto,
  ClassArquivoINI, ClassFuncoesBaseDados, ClassFuncoesData, ClassFuncoesString, ClassFuncoesRede, ClassFuncoesSistemaOperacional,
  ClassFuncoesConversao, ClassFuncoesVetor, ClassFuncoesCriptografia, ClassHelperDataSet,
  FuncoesCallBack2, FuncoesDataSnap, Funcoes_TekConnects, FuncoesGeraisServidor, EnumerarClasses,
  ClassPaiCadastro, ClassAcoes, ClassRealizacoes, ClassConfigSistema, ClassConfigSistemaEmp, ClassPCP_Config, ClassConfigSistemaBuscaComposicao, ClassItem,
  UControlaConexao, UControlaConexaoBDD, UServerContainer, UPrincipal, TekProtClient, UTekProtConsts,
  ConstantesModelosUnidadesCodificacao, ConstantesModelosProcessamentos, ClassUsuario_CFG_Email,
  ClassConfigSistemaVigencia;

procedure TSMConexao.DSServerModuleCreate(Sender: TObject);
begin
  inherited;

  FCDSFuncionalidadesLiberadas := TClientDataSet.Create(Self);
  CDSUnitsProtegidas           := TClientDataSet.Create(Self);
  CDSProcessamentosProtegidos  := TClientDataSet.Create(Self);

  TClassAspecto.RegistrarObjeto(Self);
end;

class function TSMConexao.CreateInstance(pDono: TComponent; pSecaoAtual: TClassSecaoNovo; pModoAutenticacao: Integer; pOmitirAcesso: Boolean; pOnSetAtividade: TProc): TSMConexao;
begin
  Result := TSMConexao.Create(pDono);

  if not Assigned(Result) then
    raise Exception.Create('Falha na criação do SMConexão');

  try
    Result.FSecaoAtual     := pSecaoAtual;
    Result.FOnSetAtividade := pOnSetAtividade;

    if pModoAutenticacao in [0, 1, 2, 3] then
    begin
      Result.FMeuSQLConnection                := ControlaConexaoBDD.CriaConexao(Result.SecaoAtual.Guid, Result.SecaoAtual.Usuario.Nome, Result.SecaoAtual.Usuario.Senha);
      Result.SQLDSProximoCodigo.SQLConnection := Result.MeuSQLConnection;

      case pModoAutenticacao of
        0:
          begin
            Result.CarregaUsuario(Result.SecaoAtual.Usuario.Nome, Result.SecaoAtual.Usuario.Senha);
            Result.CarregaEmpresa(Result.SecaoAtual.Empresa.Codigo);
          end;
        1:
          begin
            Result.CarregaUsuarioPeloToken(Result.SecaoAtual.Usuario.Token);

            Result.FMeuSQLConnection.Close;
            Result.FMeuSQLConnection.Params.Values[szUSERNAME] := TFuncoesBaseDados.PrepararNomeUsuario(Result.SecaoAtual.Usuario.Nome);
            Result.FMeuSQLConnection.Params.Values[szPASSWORD] := TFuncoesBaseDados.PrepararSenhaUsuario(Result.SecaoAtual.Usuario.Senha);
            Result.FMeuSQLConnection.Open;

            Result.CarregaEmpresa(Result.SecaoAtual.Empresa.Codigo);
          end;
        2:
          Result.CarregaConfiguracoes;
      end;

      if (not pOmitirAcesso) then
        Result.RegistraLogAcesso(Now);
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TSMConexao.DSServerModuleDestroy(Sender: TObject);
begin
  if Assigned(MeuSQLConnection) then
  begin
    if (MeuSQLConnection.Connected) then
      try
        RetiraRegistrosDeEdicao;
        AtualizaLogAcesso(Now);
      except
        // pode ocorrer de não haver mais conexão com a base de dados mas o componente de conexão ao bd
        // ainda está active. Como essa função é um ponto critico de desconexão foi omitido o erro
      end;

    ControlaConexaoBDD.DestroiConexao(SecaoAtual.Guid);
  end;

  FSecaoAtual       := nil;
  FMeuSQLConnection := nil;

  FCDSFuncionalidadesLiberadas.Free;
  CDSUnitsProtegidas.Free;
  CDSProcessamentosProtegidos.Free;

  TClassAspecto.DesRegistrarObjeto(Self);

  inherited;
end;

procedure TSMConexao.DSPProximoCodigoGetTableName(Sender: TObject; DataSet: TDataSet; var TableName: String);
begin
  TableName := 'AUTOINCREMENTOS';
end;

procedure TSMConexao.DSPProximoCodigoUpdateData(Sender: TObject; DataSet: TCustomClientDataSet);
begin
  with DataSet do
  begin
    FieldByName('TABELA_AUTOINC').ProviderFlags := [pfinUpdate, pfInWhere, pfInKey];
    FieldByName('QUEBRA_AUTOINC').ProviderFlags := [pfinUpdate, pfInWhere, pfInKey];
    FieldByName('CODIGO_AUTOINC').ProviderFlags := [pfinUpdate, pfInWhere, pfInKey];
  end;
end;

function TSMConexao.ConexaoBDD: String;
begin
  with MeuSQLConnection do
    if Connected then
      Result := Params.Values[DATABASENAME_KEY]
    else
      Result := '';
end;

function TSMConexao.VersaoBDD: String;
begin
  Result := ControlaConexaoBDD.VersaoBD;
end;

function TSMConexao.ConexaoBDD_Tipo: Integer;
begin
  Result := ControlaConexaoBDD.TipoBD;
end;

procedure TSMConexao.InformaAtividadeSecao;
begin
  if Assigned(FOnSetAtividade) then
    FOnSetAtividade;
end;

function TSMConexao.InformacoesDaConexaoBDD: OleVariant;
begin
  Result := VarArrayOf([ConexaoBDD, VersaoBDD, ConexaoBDD_Tipo, DriverBDDAtual]);
end;

function TSMConexao.ConexoesAtivas(Tipo: Integer): OleVariant;
var
  CDS: TClientDataSet;
begin
  Result := UControlaConexao.ControlaConexao.RetornaConexoes;

  if Tipo in [1, 2] then
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data       := Result;
      CDS.LogChanges := False;

      CDS.First;
      while not CDS.eof do
      begin
        if (Tipo = 1) and
          (CDS.FieldByName('Usuario').AsInteger <> SecaoAtual.Usuario.Codigo) then
        begin
          CDS.Delete;
          Continue;
        end;

        if (Tipo = 2) then
        begin
          if (CDS.FieldByName('Guid').AsString = SecaoAtual.Guid) then
          begin
            CDS.Delete;
            Continue;
          end;

          if (CDS.FieldByName('Usuario').AsInteger <> SecaoAtual.Usuario.Codigo) or
            (CDS.FieldByName('Modulo').AsInteger <> SecaoAtual.Sistema) or
            (CDS.FieldByName('Host').AsString <> SecaoAtual.Host) or
            (CDS.FieldByName('IP').AsString <> SecaoAtual.IP) then
          begin
            CDS.Delete;
            Continue;
          end;
        end;

        CDS.Next;
      end;

      Result := CDS.Data;
    finally
      CDS.Free;
    end;
  end;
end;

function TSMConexao.UsuariosOnLine: OleVariant;
var
  Count     : Integer;
  UsuarioAnt: string;
  CDS       : TClientDataSet;
begin
  CDS := TClientDataSet.Create(Self);
  try
    CDS.Data            := UControlaConexao.ControlaConexao.RetornaConexoes;
    CDS.LogChanges      := False;
    CDS.IndexFieldNames := 'Desc_Usuario';

    Count := 0;
    CDS.First;
    while not CDS.eof do
    begin
      if (CDS.FieldByName('Desc_Usuario').AsString <> UsuarioAnt) then
      begin
        Inc(Count);
        UsuarioAnt := CDS.FieldByName('Desc_Usuario').AsString;
      end;
      CDS.Next;
    end;

    Result := VarArrayCreate([0, Count - 1], varVariant);

    Count := 0;
    CDS.First;
    while not CDS.eof do
    begin
      if (CDS.FieldByName('Desc_Usuario').AsString = UsuarioAnt) then
      begin
        CDS.Next;
        Continue;
      end;

      UsuarioAnt    := CDS.FieldByName('Desc_Usuario').AsString;
      Result[Count] := UsuarioAnt;
      Inc(Count);

      CDS.Next;
    end;
  finally
    CDS.Free;
  end;

{$REGION 'Formas de execuções anterior'}
  { var
    I: integer;
    Lista: TList<string>;
    begin
    try
    Lista := ServerContainer.DSServer.GetAllChannelCallbackId(cCanal);
    Result := VarArrayCreate([0, Lista.Count -1], varVariant);
    for I := 0 to Lista.Count -1 do
    Result[I] := Lista.Items[I];
    except
    on E: Exception do
    raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'UsuariosOnLine', E.Message));
    end; }
{$ENDREGION}
end;

procedure TSMConexao.AtribuirSistemaSomenteLeitura;
begin
  SecaoAtual.SistemaSomenteLeitura := True;
end;

function TSMConexao.ExecuteScalar(SQL: string; CriarTransacao: Boolean): OleVariant;
var
  DataSetPesq   : TSQLDataSet;
  TipoDeCampo   : TFieldType;
  TransacaoLocal: TDBXTransaction;
begin
  try
    if CriarTransacao then
      TransacaoLocal := MeuSQLConnection.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not MeuSQLConnection.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteScalar deve estar dentro de um contexto transacional');

    try
      MeuSQLConnection.Execute(SQL, nil, TDataSet(DataSetPesq));

      DataSetPesq.ParamCheck := False;

      TipoDeCampo := DataSetPesq.Fields[0].DataType;

      if (DataSetPesq <> nil) and (not DataSetPesq.eof) then
        case TipoDeCampo of
          ftSmallint, ftInteger, ftWord:
            Result := DataSetPesq.Fields[0].AsInteger;
          ftFloat, ftFMTBcd, ftLargeint, ftAutoInc, ftBCD:
            Result := DataSetPesq.Fields[0].AsFloat;
          ftCurrency:
            Result := DataSetPesq.Fields[0].AsCurrency;
          ftString, ftFixedChar, ftWideString, ftFixedWideChar, ftMemo, ftWideMemo, ftFmtMemo:
            Result := DataSetPesq.Fields[0].AsString;
          ftDate, ftTime, ftDateTime, ftTimeStamp, ftOraTimeStamp:
            Result := DataSetPesq.Fields[0].AsDateTime;
          ftBlob:
            begin
              Result := TBlobField(DataSetPesq.Fields[0]).Value; // Value nesse caso Devolve string
              // Campos BLOB binário poderiam retornar assim, mas não consegui distingui-los dos BLOB textos.
              // Então preferi deixar a função retornando como Texto.
              // Para retornar BLOB binário, usar a função ExecuteReader.
              { MS := TMemoryStream.Create;
                try
                TBlobField(DataSetPesq.Fields[0]).SaveToStream(MS);
                MS.Position := 0;
                Result := StreamToOleVariantBytes(MS);
                finally
                MS.Free;
                end; }
            end
        else
          Result := DataSetPesq.Fields[0].Value;
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
      { Tipos de Campos não tratados:
        ftBoolean, ftBytes, ftVarBytes, ftMemo, ftGraphic, ,
        ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftADT, ftArray,
        ftReference, ftDataSet, ftOraBlob, ftOraClob, ftInterface, ftIDispatch, ftGuid, ftOraInterval }
    finally
      FreeAndNil(DataSetPesq);
      if CriarTransacao then
        MeuSQLConnection.CommitFreeAndNil(TransacaoLocal);
    end;
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        MeuSQLConnection.Connected := False;

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteScalar', 'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;

  InformaAtividadeSecao;
end;

function TSMConexao.ExecuteReader(SQL: string; TamanhoPacote: Integer; CriarTransacao: Boolean): OleVariant;
var
  TransacaoLocal: TDBXTransaction;
  DataSetPesq   : TSQLDataSet;
  DSP           : TDataSetProvider;
begin
  try
    if CriarTransacao then
      TransacaoLocal := MeuSQLConnection.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not MeuSQLConnection.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteReader deve estar dentro de um contexto transacional');

    DSP         := TDataSetProvider.Create(nil);
    DataSetPesq := TSQLDataSet.Create(nil);
    try
      with DataSetPesq do
      begin
        SQLConnection := MeuSQLConnection;
        ParamCheck    := False;
        CommandText   := SQL;
        GetMetadata   := False;
      end;
      with DSP do
      begin
        Exported    := False;
        Constraints := False;
        DataSet     := DataSetPesq;
        Result      := DSP.Data;
      end;
    finally
      FreeAndNil(DSP);
      FreeAndNil(DataSetPesq);
      if CriarTransacao then
        MeuSQLConnection.CommitFreeAndNil(TransacaoLocal);
    end;
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        MeuSQLConnection.Connected := False;

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteReader', 'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;

{$REGION 'Formas de execuções anteriores'}
  // SEGUNDO MÉTODO
  { DSP := TDataSetProvider.Create(nil);
    try
    try
    MeuSQLConnection.Execute(sql, nil, @DataSetPesq);
    with DSP do
    begin
    Exported := false;
    Options := [poReadOnly];
    DataSet := DataSetPesq;
    Result := Data;
    end;
    except
    on E: Exception do
    raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteReader', 'Comando SQL: ' + sql + #13 + E.Message));
    end;
    finally
    FreeAndNil(DSP);
    FreeAndNil(DataSetPesq);
    end; }

  // PRIMEIRO MÉTODO
  { DSP := TDataSetProvider.Create(nil);
    DataSetPesq := TCustomSQLDataSet.Create(nil);
    CDS := TClientDataSet.Create(Self);
    try
    try
    MeuSQLConnection.Execute(sql, nil, @DataSetPesq);
    with DSP do
    begin
    Exported := false;
    Options := [poReadOnly];
    DataSet := DataSetPesq;
    end;
    with CDS do
    begin
    DisableControls;
    SetProvider(DSP);
    if (TamanhoPacote <> 0) then
    begin
    FetchOnDemand := False;
    PacketRecords := TamanhoPacote;
    end;
    ReadOnly := True;
    Open;
    LogChanges := False;
    while (GetNextPacket <> 0) do
    Application.ProcessMessages;
    Result := Data;
    Close;
    end;
    except
    on E: Exception do
    raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteReader', 'Comando SQL: ' + sql + #13 + E.Message));
    end;
    finally
    FreeAndNil(CDS);
    FreeAndNil(DSP);
    FreeAndNil(DataSetPesq);
    end; }
{$ENDREGION}
  InformaAtividadeSecao;
end;

function TSMConexao.ExecuteCommand(SQL: string; CriarTransacao: Boolean): OleVariant;
var
  TransacaoLocal: TDBXTransaction;
begin
  try
    if CriarTransacao then
      TransacaoLocal := MeuSQLConnection.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not MeuSQLConnection.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteCommand deve estar dentro de um contexto transacional');

    with MeuSQLConnection.DBXConnection.CreateCommand do
      try
        Text := SQL;
        // Prepare;
        ExecuteQuery;
        Result := IntToStr(RowsAffected);
      finally
        Free;
      end;

    if CriarTransacao and (MeuSQLConnection.HasTransaction(TransacaoLocal)) then
      MeuSQLConnection.CommitFreeAndNil(TransacaoLocal);
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        MeuSQLConnection.Connected := False
      else if CriarTransacao then
        if (MeuSQLConnection.HasTransaction(TransacaoLocal)) then
          MeuSQLConnection.RollbackFreeAndNil(TransacaoLocal)
        else
          MeuSQLConnection.RollbackIncompleteFreeAndNil(TransacaoLocal);

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteCommand', 'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;

  InformaAtividadeSecao;
end;

function TSMConexao.ExecuteCommand_Update(SQL, Campo: string; Valor: OleVariant; CriarTransacao: Boolean): OleVariant;
{const
  TamanhoMaximoComandoSql = 65535; // 64Kb }
var
  DS            : TSQLDataSet;
  DSP           : TDataSetProvider;
  CDS           : TClientDataSet;
  TransacaoLocal: TDBXTransaction;
begin
{  SQL :=
    'update ' + TFuncoesString.CorteEntre(SQL, 'from', 'where') + ' set' + #13 +
    '  ' + Campo + ' = ' + QuotedStr(Valor) + #13 +
    'where ' + TFuncoesString.CorteApos(SQL, 'where');

  if Length(Sql) < TamanhoMaximoComandoSql then
  begin
    ExecuteCommand(Sql, CriarTransacao);
    Exit;
  end; }

  try
    if CriarTransacao then
      TransacaoLocal := MeuSQLConnection.BeginTransaction(TDBXIsolations.ReadCommitted)
    else if (not MeuSQLConnection.InTransaction) then
      raise Exception.Create('Toda execução da função ExecuteCommand_Update deve estar dentro de um contexto transacional');

    try
      CDS := TClientDataSet.Create(Self);
      DSP := TDataSetProvider.Create(Self);
      DS  := TSQLDataSet.Create(Self);
      with DS do
      begin
        CommandText   := SQL;
        CommandType   := CtQuery;
        SQLConnection := MeuSQLConnection;
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

      if CriarTransacao and (MeuSQLConnection.HasTransaction(TransacaoLocal)) then
        MeuSQLConnection.CommitFreeAndNil(TransacaoLocal);
    end;
  except
    on E: Exception do
    begin
      if (Pos('Unable to complete network request to host', E.Message) > 0) or
        (Pos('Error writing data to the connection', E.Message) > 0) or
        (Pos('connection shutdown', E.Message) > 0) then
        MeuSQLConnection.Connected := False
      else if CriarTransacao then
        if (MeuSQLConnection.HasTransaction(TransacaoLocal)) then
          MeuSQLConnection.RollbackFreeAndNil(TransacaoLocal)
        else
          MeuSQLConnection.RollbackIncompleteFreeAndNil(TransacaoLocal);

      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'ExecuteCommand_Update',
        'Comando SQL: ' + SQL + #13 + E.Message));
    end;
  end;
end;

function TSMConexao.DataHora: TDateTime;
begin
  Result := VarAsType(ExecuteScalar(ParticularidadesBDD.SQLDataHora, not MeuSQLConnection.InTransaction), varDate);
end;

function TSMConexao.ProximoCodigo(Tabela: String; Quebra: Integer): Int64;
begin
  Result := ProximoCodigoAcrescimo(Tabela, Quebra, 1);
end;

function TSMConexao.ProximoCodigoAcrescimo(Tabela: String; Quebra, Acrescimo: Integer): Int64;
var
  TD: TDBXTransaction;
begin
  if (CDSProximoCodigo.FieldDefs.Count = 0) then
    with CDSProximoCodigo do
    begin
      Close;
      with FieldDefs do
      begin
        Clear;
        Add('TABELA_AUTOINC', ftString, 31);
        Add('QUEBRA_AUTOINC', ftInteger);
        Add('CODIGO_AUTOINC', ftLargeint);
      end;
      CreateDataSet;
    end;

  with MeuSQLConnection do
  begin
    // No Delphi 2006 era assim
    // Randomize;
    // TD.TransactionID := Random(65635);
    // TD.IsolationLevel := xilREADCOMMITTED;
    // StartTransaction(TD);
    TD := BeginTransaction(TDBXIsolations.ReadCommitted);
    try
      with CDSProximoCodigo do
      begin
        repeat
          Close;
          Params.ParamByName('TABELA').AsString  := Tabela;
          Params.ParamByName('QUEBRA').AsInteger := Quebra;
          Open;
          if IsEmpty then
          begin
            Insert;
            FieldByName('TABELA_AUTOINC').AsString  := Tabela;
            FieldByName('QUEBRA_AUTOINC').AsInteger := Quebra;
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

procedure TSMConexao.AcertaProximoCodigo(NomeDaClasse: String; Quebra: Integer; CriarTransacao: Boolean = True);
var
  SQL   : String;
  Codigo: Int64;
  CDS   : TClientDataSet;
  TD    : TDBXTransaction;
  Classe: TFClassPaiCadastro;
begin
  if CriarTransacao then
    TD := MeuSQLConnection.BeginTransaction(TDBXIsolations.ReadCommitted);
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

    if CriarTransacao and MeuSQLConnection.HasTransaction(TD) then
      MeuSQLConnection.CommitFreeAndNil(TD);
  except
    on E: Exception do
    begin
      if CriarTransacao and MeuSQLConnection.HasTransaction(TD) then
        MeuSQLConnection.RollbackFreeAndNil(TD);
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'AcertaProximoCodigo', 'Classe: ' + NomeDaClasse + #13 + E.Message));
    end;
  end;
end;

procedure TSMConexao.AtualizarProximoCodigo(Tabela: String; Quebra, Valor: Integer; CriarTransacao: Boolean = True);
const
  SQLAutoInc_U =
    'update AUTOINCREMENTOS set ' + #13 +
    '  AUTOINCREMENTOS.CODIGO_AUTOINC = %s' + #13 +
    'where (AUTOINCREMENTOS.TABELA_AUTOINC = %s)' + #13 +
    '  and (AUTOINCREMENTOS.QUEBRA_AUTOINC = %s)';
  SQLAutoInc_I =
    ' insert into AUTOINCREMENTOS (TABELA_AUTOINC, QUEBRA_AUTOINC, CODIGO_AUTOINC)' + #13 +
    ' values (%s, %s, %s)';
var
  SQL: string;
begin
  // SQL para Atualizar
  SQL := Format(SQLAutoInc_U, [
    IntToStr(Valor),
    QuotedStr(AnsiUpperCase(Tabela)),
    IntToStr(Quebra)]);

  if (ExecuteCommand(SQL, CriarTransacao) = 0) then
  begin
    // Se não atualizou nenhum registro então é para Inserir
    SQL := Format(SQLAutoInc_I, [
      QuotedStr(AnsiUpperCase(Tabela)),
      IntToStr(Quebra),
      IntToStr(Valor)]);
    ExecuteCommand(SQL, CriarTransacao);
  end;
end;

procedure TSMConexao.TrocarCodigo(Tabela, CampoChave: String; CodigoAntigo, CodigoNovo: Int64);
const
  SQLTrocaRef = 'update %s set %s = %s where %s = %s';
  SQLSaldoCTB =
    'select CTB_SALDO.PARTICIPANTE_SAL ' +
    ' from CTB_SALDO ' +
    ' where CTB_SALDO.PARTICIPANTE_SAL in (%s,%s)' +
    ' group by  PARTICIPANTE_SAL';
  SQLRegistraTrocaRef =
    'insert into ALTERACAO_DE_CODIGOS (' +
    'AUTOINC_ALTCOD, TABELA_ALTCOD, CAMPO_ALTCOD,' +
    'CODIGOANTERIOR_ALTCOD, NOVOCODIGO_ALTCOD,' +
    'REGISTROSAFETADOS_ALTCOD,' +
    'USUARIO_ALTCOD, DATAHORA_ALTCOD)' +
    'values (%s, %s, %s, %s, %s, %s, %s, %s)';
  TabelasDeExcecao: array [1 .. 13] of string = (
    'PESSOA_CLIENTE',
    'PESSOA_CLIENTECONSULTOR',
    'PESSOA_CONSULTORSUPERVISOR',
    'PESSOA_CONSULTORVENDAS',
    // 'PESSOA_ENDERECO',
    'PESSOA_FISICA',
    'PESSOA_FORNECEDOR',
    'PESSOA_FUNCIONARIO',
    'PESSOA_JURIDICA',
    'PESSOA_PRAZOS',
    'PESSOA_PREPOSTOCONSULTOR',
    'PESSOA_REVISAODOCUMENTOS',
    'PESSOA_TABELA',
    // 'PESSOA_TELEFONE',
    'PESSOA_TRANSPORTADOR');

var
  CDSTemp                        : TClientDataSet;
  SQL, sDataHora, cTabela, cCampo: String;
  TD                             : TDBXTransaction;
  Qtde                           : Integer;

  function TrocaReferencia: Integer;
  begin
    SQL    := Format(SQLTrocaRef, [cTabela, cCampo, IntToStr(CodigoNovo), cCampo, IntToStr(CodigoAntigo)]);
    Result := ExecuteCommand(SQL, False);
  end;

  procedure RegistraTroca;
  var
    ID: String;
  begin
    ID  := IntToStr(ProximoCodigo('ALTERACAO_DE_CODIGOS', 0));
    SQL := Format(SQLRegistraTrocaRef, [ID, QuotedStr(cTabela), QuotedStr(cCampo), IntToStr(CodigoAntigo),
      IntToStr(CodigoNovo), IntToStr(Qtde), QuotedStr(SecaoAtual.Usuario.Nome), sDataHora]);
    ExecuteCommand(SQL, False);
  end;

  function ExisteSaldoCTB: Boolean;
  var
    CDSTmp: TClientDataSet;
  begin
    CDSTmp := TClientDataSet.Create(Self);
    Result := False;
    try
      SQL         := Format(SQLSaldoCTB, [IntToStr(CodigoNovo), IntToStr(CodigoAntigo)]);
      CDSTmp.Data := ExecuteReader(SQL, -1, False);
      if CDSTmp.RecordCount > 1 then
        Result := True;
    finally
      FreeAndNil(CDSTmp);
    end;
  end;

begin
  CDSTemp := TClientDataSet.Create(Self);
  try
    SQL :=
      'select distinct b.rdb$depended_on_name tabela,' + #13 +
      '                b.rdb$field_name       campo' + #13 +
      'from rdb$dependencies a, rdb$dependencies b' + #13 +
      'where a.rdb$depended_on_name = ' + QuotedStr(AnsiUpperCase(Tabela)) + #13 +
      'and   a.rdb$field_name = ' + QuotedStr(AnsiUpperCase(CampoChave)) + #13 +
      'and   a.rdb$dependent_type = 2' + #13 +
      'and   a.rdb$dependent_name like ' + QuotedStr('CHECK_%') + #13 +
      'and   a.rdb$dependent_name = b.rdb$dependent_name' + #13 +
      'and   b.rdb$field_name is not null' + #13 +
      'and   a.rdb$depended_on_name <> b.rdb$depended_on_name';
    CDSTemp.Data := ExecuteReader(SQL, -1, True);

    FPrincipal.IniciarTransacao(TD, FMeuSQLConnection);
    try
      if ExisteSaldoCTB then
        raise Exception.Create('Não será possível a troca de códigos! Existem saldos contábeis para os 2 participantes.');
      sDataHora := TFuncoesSQL.DataSQL(DataHora);
      with CDSTemp do
      begin
        IndexFieldNames := 'tabela;campo';
        First;
        while (not eof) do
        begin
          cTabela := AnsiUpperCase(Trim(FieldByName('TABELA').AsString));
          cCampo  := AnsiUpperCase(Trim(FieldByName('CAMPO').AsString));
          if (TFuncoesVetor.ContidoNoVetor(TabelasDeExcecao, cTabela) = -1) then
          begin
            Qtde := TrocaReferencia;
            if (Qtde > 0) then
              RegistraTroca;
          end;

          Next;
        end;
        Close;
      end;
      if MeuSQLConnection.HasTransaction(TD) then
        MeuSQLConnection.CommitFreeAndNil(TD);
    except
      on E: Exception do
      begin
        if MeuSQLConnection.HasTransaction(TD) then
          MeuSQLConnection.RollbackFreeAndNil(TD);
        raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'TrocarCodigo', E.Message));
      end;
    end;
  finally
    FreeAndNil(CDSTemp);
  end;
end;

procedure TSMConexao.AtualizarContadorSAC(const CodigoUsuario: Integer);
var
  i          : Integer;
  SQL        : String;
  Vetor      : TJSONArray;
  NomeUsuario: String;
begin
  NomeUsuario := SecaoAtual.Usuario.Nome;

  // Verifica o numero de SAC com situação "em andamento"
  SQL :=
    sOcultarDoMonitorDeSQL +
    'select count(*) QTDE ' + #13 +
    'from SGQ_SAC ' + #13 +
    'left join SGQ_ASSUNTOS_SAC on (SGQ_ASSUNTOS_SAC.CODIGO_ASSUNTOSAC = SGQ_SAC.ASSUNTO_SAC)' + #13 +
    'where SGQ_SAC.CODIGO_SAC > 0' + #13 +
    '  and SGQ_ASSUNTOS_SAC.USUARIODIRECIONAMENT_ASSUNTOSAC = ' + IntToStr(CodigoUsuario) + #13 +
    '  and SGQ_SAC.SITUACAO_SAC = 1';

  i := ExecuteScalar(SQL, True);

  if SecaoAtual.Usuario.Codigo <> CodigoUsuario then
  begin
    SQL := sOcultarDoMonitorDeSQL +
      'select USUARIO.DESCRICAO_USUARIO from SGQ_ASSUNTOS_SAC ' + #13 +
      '  left join USUARIO on USUARIO.CODIGO_USUARIO = SGQ_ASSUNTOS_SAC.USUARIODIRECIONAMENT_ASSUNTOSAC ' + #13 +
      'where SGQ_ASSUNTOS_SAC.USUARIODIRECIONAMENT_ASSUNTOSAC = ' + IntToStr(CodigoUsuario);

    NomeUsuario := ExecuteScalar(SQL, True);
  end;

  Vetor := TJSONArray.Create;
  try
    Vetor.Owned := False;
    Vetor.AddElement(TJSONString.Create(Self.ClassName));
    Vetor.AddElement(TJSONNumber.Create(i));
    FuncoesCallBack2.CallBack_Cliente(ServerContainer.DSServer, NomeUsuario, SecaoAtual.Guid, ConstantesCallBack.EvCallBack_SACAberto, Vetor);
  finally
    Vetor.Free;
  end;
end;

function TSMConexao.CarregaDefaults(Tabela: String): OleVariant;
var
  SQL: string;
begin
  SQL :=
    ' select ' + #13 +
    '   PADROES.TABELA_PADRAO "TABELA",' + #13 +
    '   PADROES.CAMPO_PADRAO  "CAMPO", ' + #13 +
    '   PADROES.PADRAO_PADRAO "DEFAULT"' + #13 +
    ' from PADROES ' + #13;

  if (Trim(Tabela) <> '') then
    SQL := SQL +
      ' where PADROES.TABELA_PADRAO = ' + QuotedStr(Tabela);

  Result := ExecuteReader(SQL, -1, True);
end;

procedure TSMConexao.CarregaFormulasCadastro;
begin
  FFormulasCadastro := ExecuteReader(
    'select ' + #13 +
    '  CONFIG_TABELA_PROCESSO.TABELA_CTP, ' + #13 +
    '  CONFIG_TABELA_PROCESSO.FORMULA_CTP ' + #13 +
    'from CONFIG_TABELA_PROCESSO ' + #13 +
    'where CONFIG_TABELA_PROCESSO.STATUS_CTP <> ' + IntToStr(SecaoAtual.Parametro.StatusInativo), -1, True);
end;

function TSMConexao.GetFormulasCadastro: OleVariant;
begin
  if VarIsEmpty(FFormulasCadastro) then
    CarregaFormulasCadastro;

  Result := FFormulasCadastro;
end;

procedure TSMConexao.RegistraAcao(Descricao: String; Inicio, Fim: TDateTime; Observacao: OleVariant);
var
  SQLDS: TSQLDataSet;
  DSP  : TDataSetProvider;
  CDS  : TClientDataSet;
begin
  try
    SQLDS := TSQLDataSet.Create(Self);
    DSP   := TDataSetProvider.Create(Self);
    CDS   := TClientDataSet.Create(Self);
    try
      SQLDS.SQLConnection := MeuSQLConnection;
      SQLDS.CommandText   := TClassAcoes.SQLBaseCadastro;

      DSP.Exported   := False;
      DSP.DataSet    := SQLDS;
      DSP.UpdateMode := upWhereKeyOnly;

      CDS.SetProvider(DSP);
      with CDS do
      begin
        Open;
        FieldByName('AUTOINC_ACAO').ProviderFlags := [pfinUpdate, pfInWhere, pfInKey];

        Insert;
        FieldByName('AUTOINC_ACAO').AsInteger      := ProximoCodigo('ACOES', 0);
        FieldByName('DATAHORA_ACAO').AsDateTime    := DataHora;
        FieldByName('DESCRICAO_ACAO').AsString     := AnsiUpperCase(Copy(Descricao, 1, 80));
        FieldByName('DATAINICIAL_ACAO').AsDateTime := Trunc(Inicio);
        FieldByName('DATAFINAL_ACAO').AsDateTime   := Trunc(Fim);
        FieldByName('USUARIO_ACAO').AsString       := SecaoAtual.Usuario.Nome;
        FieldByName('OBSERVACAO_ACAO').AsString    := Observacao;
        Post;

        ApplyUpdates(0);
      end;
    finally
      FreeAndNil(SQLDS);
      FreeAndNil(DSP);
      FreeAndNil(CDS);
    end;
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'RegistraAcao', E.Message));
  end;
end;

function TSMConexao.RegistrosEmEdicao: OleVariant;
var
  SQL: String;
begin
  try
    SQL :=
      ' select' + #13 +
      ' REGISTROS_BLOQUEADOS.AUTOINC_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.GUID_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.TABELA_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.QUEBRA_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.CODIGO_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.VINCULO_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.USUARIO_REGBLOQ,' + #13 +
      ' REGISTROS_BLOQUEADOS.DATAHORA_REGBLOQ ' + #13 +
      'from REGISTROS_BLOQUEADOS';
    Result := ExecuteReader(SQL, -1, True);
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'RegistrosEmEdicao', E.Message));
  end;
end;

function TSMConexao.IncluiRegistroEmEdicao(Tabela: String; Quebra: Integer; Codigo, Vinculo: String): OleVariant;
var
  SQLInsert, SQLSelect             : String;
  CodBloqueio                      : Int64;
  UsuarioBloqueio, DataHoraBloqueio: String;
  CDSTemp                          : TClientDataSet;
begin
  CDSTemp := TClientDataSet.Create(Self);
  try
    try
      SQLSelect :=
        ' select REGISTROS_BLOQUEADOS.AUTOINC_REGBLOQ, ' + #13 +
        '        REGISTROS_BLOQUEADOS.USUARIO_REGBLOQ, ' + #13 +
        '        REGISTROS_BLOQUEADOS.DATAHORA_REGBLOQ ' + #13 +
        ' from REGISTROS_BLOQUEADOS' + #13 +
        ' where (REGISTROS_BLOQUEADOS.TABELA_REGBLOQ = ' + QuotedStr(Tabela) + ')' + #13 +
        '   and (REGISTROS_BLOQUEADOS.QUEBRA_REGBLOQ = ' + IntToStr(Quebra) + ')' + #13 +
        '   and (REGISTROS_BLOQUEADOS.CODIGO_REGBLOQ = ' + Codigo + ')';
      CDSTemp.Data := ExecuteReader(SQLSelect, -1, True);
      with CDSTemp do
        if (IsEmpty) then
        begin
          CodBloqueio := ProximoCodigo('REGISTROS_BLOQUEADOS', 0);
          SQLInsert   :=
            ' insert into REGISTROS_BLOQUEADOS(' + #13 +
            ' AUTOINC_REGBLOQ, GUID_REGBLOQ, TABELA_REGBLOQ,' + #13 +
            ' QUEBRA_REGBLOQ, CODIGO_REGBLOQ, VINCULO_REGBLOQ, ' + #13 +
            ' USUARIO_REGBLOQ, DATAHORA_REGBLOQ)' + #13 +
            ' values (' + #13 +
            IntToStr(CodBloqueio) + ',' +
            QuotedStr(SecaoAtual.Guid) + ',' +
            QuotedStr(Tabela) + ',' +
            IntToStr(Quebra) + ',' +
            Codigo + ',' +
            Vinculo + ',' +
            QuotedStr(SecaoAtual.Usuario.Nome) + ',' +
            '(' + ParticularidadesBDD.VariavelDataHora + '))';
          try
            ExecuteCommand(SQLInsert, True);
          except
            on E: Exception do
              raise Exception.Create(E.Message + #13 + 'SQL: ' + SQLInsert);
          end;
        end
        else
        begin
          CodBloqueio      := FieldByName('AUTOINC_REGBLOQ').AsInteger;
          UsuarioBloqueio  := FieldByName('USUARIO_REGBLOQ').AsString;
          DataHoraBloqueio := FieldByName('DATAHORA_REGBLOQ').AsString;
        end;

      Result := VarArrayOf([CodBloqueio, UsuarioBloqueio, DataHoraBloqueio]);
    except
      on E: Exception do
        raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'IncluiRegistroEmEdicao', E.Message));
    end;
  finally
    FreeAndNil(CDSTemp);
  end;
end;

procedure TSMConexao.RetiraRegistroDeEdicao(AutoInc: Int64; Registrar, ApenasVinculados: Boolean);
var
  SQL, Tabela, Codigo, Secao: String;
  Quebra                    : Integer;
  CDSTemp                   : TClientDataSet;
begin
  // Desbloqueia o registro e todas as dependências do mesmo
  CDSTemp := TClientDataSet.Create(Self);
  try
    try
      // Busque os dados
      if AutoInc >= 0 then
      begin
        SQL :=
          ' select' + #13 +
          '   REGISTROS_BLOQUEADOS.TABELA_REGBLOQ,' + #13 +
          '   REGISTROS_BLOQUEADOS.QUEBRA_REGBLOQ,' + #13 +
          '   REGISTROS_BLOQUEADOS.CODIGO_REGBLOQ,' + #13 +
          '   REGISTROS_BLOQUEADOS.GUID_REGBLOQ' + #13 +
          ' from REGISTROS_BLOQUEADOS' + #13 +
          ' where (REGISTROS_BLOQUEADOS.AUTOINC_REGBLOQ = ' + IntToStr(AutoInc) + ')';
        CDSTemp.Data := ExecuteReader(SQL, -1, True);
        with CDSTemp do
          if IsEmpty then
            Exit
          else
          begin
            Tabela := FieldByName('TABELA_REGBLOQ').AsString;
            Quebra := FieldByName('QUEBRA_REGBLOQ').AsInteger;
            Codigo := FieldByName('CODIGO_REGBLOQ').AsString;
            Secao  := FieldByName('GUID_REGBLOQ').AsString;
            Close;
          end;
      end
      else
      begin
        Quebra := 0;
        Secao  := SecaoAtual.Guid;
      end;

      // Verifica dependências, caso existam, exclui-las primeiro
      SQL :=
        ' select ' + #13 +
        '   REGISTROS_BLOQUEADOS.AUTOINC_REGBLOQ' + #13 +
        ' from REGISTROS_BLOQUEADOS' + #13 +
        ' where (REGISTROS_BLOQUEADOS.VINCULO_REGBLOQ = ' + IntToStr(AutoInc) + ')' + #13 +
        '   and (REGISTROS_BLOQUEADOS.GUID_REGBLOQ    = ' + QuotedStr(Secao) + ')';
      CDSTemp.Data := ExecuteReader(SQL, -1, True);
      with CDSTemp do
        if (not IsEmpty) then
        begin
          First;
          while (not eof) do
          begin
            RetiraRegistroDeEdicao(FieldByName('AUTOINC_REGBLOQ').AsInteger, Registrar, False);
            Next;
          end;
          Close;
        end;

      // Exclui o registro, liberando o bloqueio
      if (not ApenasVinculados) then
      begin
        SQL :=
          ' delete from REGISTROS_BLOQUEADOS' + #13 +
          ' where REGISTROS_BLOQUEADOS.AUTOINC_REGBLOQ = ' + IntToStr(AutoInc);
        try
          ExecuteCommand(SQL, True);
        except
          on E: Exception do
            raise Exception.Create(E.Message + #13 + 'SQL: ' + SQL);
        end;
      end;

      // Registra a acao do desbloqueio, se necessário
      if (Registrar) then
        RegistraAcao(
          'DESBLOQUEIO MANUAL DE EDICAO DE REGISTRO', Date, Date,
          'Tabela: ' + Tabela + #13 +
          'Quebra: ' + IntToStr(Quebra) + #13 +
          'Codigo: ' + Codigo);

    except
      on E: Exception do
        raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'RetiraRegistroDeEdicao', E.Message));
    end;
  finally
    FreeAndNil(CDSTemp);
  end;
end;

procedure TSMConexao.RetiraRegistrosDeEdicao;
var
  SQL: String;
begin
  // Exclui todos os registros bloqueados pela secao atual
  // Chamado na destruicao do SMConexao

  if not Assigned(SecaoAtual) then
    Exit;

  try
    SQL :=
      ' delete from REGISTROS_BLOQUEADOS' + #13 +
      ' where REGISTROS_BLOQUEADOS.GUID_REGBLOQ = ' + QuotedStr(SecaoAtual.Guid);
    ExecuteCommand(SQL, True);
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'RetiraRegistrosDeEdicao', E.Message));
  end;
end;

procedure TSMConexao.RetiraRegistrosVinculadosDeEdicao(Vinculo: String);
var
  SQL: String;
begin
  try
    SQL :=
      ' delete from REGISTROS_BLOQUEADOS' + #13 +
      ' where (REGISTROS_BLOQUEADOS.GUID_REGBLOQ = ' + QuotedStr(SecaoAtual.Guid) + ')' + #13 +
      '   and (REGISTROS_BLOQUEADOS.VINCULO_REGBLOQ = ' + Vinculo + ')';
    ExecuteCommand(SQL, True);
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'RetiraRegistrosVinculadosDeEdicao', E.Message));
  end;
end;

procedure TSMConexao.RegistraLogAcesso(const DataHora: TDateTime);
var
  SQL: string;
begin
  if FCodigoAcesso > 0 then
    raise Exception.Create('Acesso já registrado');

  FCodigoAcesso := ProximoCodigo('LOG_ACESSO', 0);

  SQL :=
    'insert into LOG_ACESSO (AUTOINC_LOGACE, MODULO_LOGACE, USUARIO_LOGACE, HOST_LOGACE, IP_LOGACE, GUID_LOGACE, DATAHORAENTRADA_LOGACE) values (' +
    IntToStr(FCodigoAcesso) + ', ' +
    IntToStr(SecaoAtual.Sistema) + ', ' +
    QuotedStr(SecaoAtual.Usuario.Nome) + ', ' +
    QuotedStr(SecaoAtual.Host) + ', ' +
    QuotedStr(SecaoAtual.IP) + ', ' +
    QuotedStr(SecaoAtual.Guid) + ', ' +
    TFuncoesSQL.DataSQL(DataHora, 3) + ')';
  ExecuteCommand(SQL, True);

  SQL :=
    'update USUARIO set ' + #13 +
    '  USUARIO.ULTIMOACESSO_USUARIO = ' + TFuncoesSQL.DataSQL(DataHora, 3) + #13 +
    'where USUARIO.CODIGO_USUARIO = ' + IntToStr(SecaoAtual.Usuario.Codigo);
  try
    ExecuteCommand(SQL, True);
  except
    // pode ocorrer loock conflict quando acessando com mesmo usuário junto
  end;
end;

procedure TSMConexao.AtualizaLogAcesso(const DtHrSaida: TDateTime);
var
  SQL: string;
begin
  if FCodigoAcesso = 0 then
    Exit;

  SQL :=
    'update LOG_ACESSO set' + #13 +
    '  LOG_ACESSO.DATAHORASAIDA_LOGACE = ' + TFuncoesSQL.DataSQL(DtHrSaida, 3) + ',' + #13 +
    '  LOG_ACESSO.TEMPO_LOGACE = cast(''12/30/1899'' as timestamp) + (cast(' + TFuncoesSQL.DataSQL(DtHrSaida, 3) + ' as timestamp) - LOG_ACESSO.DATAHORAENTRADA_LOGACE)' + #13 +
    'where LOG_ACESSO.AUTOINC_LOGACE = ' + IntToStr(FCodigoAcesso);
  ExecuteCommand(SQL, True);
end;

procedure TSMConexao.RegistraLogTabela(Dados: OleVariant);
var
  Acao                    : Integer;
  Tabela, Usuario         : string;
  CodigoRegistro          : Largeint;
  CodigoRegistroSecundario: Largeint;
  Observacao              : string;

  SQL      : string;
  Codigo   : Integer;
  ObsGrande: Boolean;
begin
  // Registra ações executadas pelo usuário

  Acao                     := Dados[0];
  Tabela                   := Dados[1];
  Usuario                  := Dados[2];
  CodigoRegistro           := Dados[3];
  Observacao               := Dados[4];
  CodigoRegistroSecundario := Dados[5];

  Codigo    := ProximoCodigo('LOG_TABELAS', 0);
  ObsGrande := Length(Observacao) > 5000;

  SQL :=
    'insert into LOG_TABELAS (CODIGO_LOGTAB, DATAHORA_LOGTAB, ACAO_LOGTAB, TABELA_LOGTAB, REGISTRO_LOGTAB, USUARIO_LOGTAB, OBSERVACAO_LOGTAB, REGISTRO_SEC_LOGTAB) values (' + #13 +
    IntToStr(Codigo) + ',' +
    '(' + ParticularidadesBDD.SQLDataHora + '),' +
    IntToStr(Acao) + ',' +
    QuotedStr(AnsiUpperCase(Copy(Tabela, 1, 80))) + ',' +
    IntToStr(CodigoRegistro) + ',' +
    QuotedStr(Usuario) + ',' +
    IfThen(ObsGrande, 'null', QuotedStr(Observacao)) + ',' +
    IntToStr(CodigoRegistroSecundario) + ')';
  ExecuteCommand(SQL, True);

  if ObsGrande then
  begin
    SQL :=
      'select ' + #13 +
      '  LOG_TABELAS.CODIGO_LOGTAB, ' + #13 +
      '  LOG_TABELAS.OBSERVACAO_LOGTAB ' + #13 +
      'from LOG_TABELAS ' + #13 +
      'where LOG_TABELAS.CODIGO_LOGTAB = ' + IntToStr(Codigo);
    ExecuteCommand_Update(SQL, 'OBSERVACAO_LOGTAB', Observacao, True);
  end;
end;

function TSMConexao.RegistroLogTela(Sistema, Usuario: Integer; Formulario: String; DtHrEntrada: TDateTime): Int64;
var
  Codigo   : Int64;
  SQL, Form: string;
begin
  Codigo := ProximoCodigo('LOG_TELAS', 0);
  Form   := Copy(Formulario, 1, 50);

  SQL :=
    ' insert into LOG_TELAS(AUTOINC_LOGTELAS, MODULO_LOGTELAS, USUARIO_LOGTELAS, FORMULARIO_LOGTELAS, DATAHORAENTRADA_LOGTELAS)' +
    ' values (' +
    IntToStr(Codigo) + ', ' +
    IntToStr(Sistema) + ', ' +
    IntToStr(Usuario) + ', ' +
    QuotedStr(Form) + ', ' +
    TFuncoesSQL.DataSQL(DtHrEntrada, 3) + ')';

  ExecuteCommand(SQL, True);

  Result := Codigo;
end;

procedure TSMConexao.AtualizaLogTela(Codigo: Int64; DtHrSaida, Tempo: TDateTime);
var
  SQL: string;
begin
  SQL :=
    ' update LOG_TELAS set ' + #13 +
    '  LOG_TELAS.DATAHORASAIDA_LOGTELAS    = ' + TFuncoesSQL.DataSQL(DtHrSaida, 3) + ',' + #13 +
    '  LOG_TELAS.TEMPOPERMANENCIA_LOGTELAS = ' + TFuncoesSQL.DataSQL(Tempo, 3) + #13 +
    ' where LOG_TELAS.AUTOINC_LOGTELAS = ' + IntToStr(Codigo);
  ExecuteCommand(SQL, True);
end;

function TSMConexao.RegistraLogGR_Relatorio(Descricao: String; Conteudo: String; Relatorio, Tipo: Integer): Int64;
var
  Codigo: Int64;
  SQL   : string;
begin
  Codigo := ProximoCodigo('GR_LOG', 0);
  SQL    :=
    'insert into GR_LOG (AUTOINC_LOGREL, DESCRICAORELATORIO_LOGREL, RELATORIO_LOGREL, ' + #13 +
    '  TIPO_LOGREL, DATAHORA_LOGREL, USUARIO_LOGREL) values (' +
    IntToStr(Codigo) + ', ' +
    QuotedStr(Copy(Descricao, 1, 80)) + ', ' +
    IntToStr(Relatorio) + ', ' +
    IntToStr(Tipo) + ', ' +
    TFuncoesSQL.DataSQL(DataHora, 3) + ', ' +
    QuotedStr(SecaoAtual.Usuario.Nome) + ')';
  ExecuteCommand(SQL, True);

  if Conteudo <> '' then
  begin
    SQL :=
      'select ' + #13 +
      '  GR_LOG.AUTOINC_LOGREL, ' + #13 +
      '  GR_LOG.TEXTO_LOGREL ' + #13 +
      'from GR_LOG ' + #13 +
      'where GR_LOG.AUTOINC_LOGREL = ' + IntToStr(Codigo);
    ExecuteCommand_Update(SQL, 'TEXTO_LOGREL', Conteudo, True);
  end;

  Result := Codigo;
end;

procedure TSMConexao.AtualizaLogGR_Relatorio(Codigo: Int64; DtHrTermino, Tempo: TDateTime; Conteudo: String);
var
  SQL: string;
begin
  if DtHrTermino = 0 then
    DtHrTermino := DataHora;

  SQL :=
    ' update GR_LOG set ' + #13 +
    '  GR_LOG.DATAHORATERMINO_LOGREL = ' + TFuncoesSQL.DataSQL(DtHrTermino, 3) + ',' + #13 +
    '  GR_LOG.TEMPO_LOGREL = ' + TFuncoesSQL.DataSQL(Tempo, 3) + #13 +
    ' where GR_LOG.AUTOINC_LOGREL = ' + IntToStr(Codigo);
  ExecuteCommand(SQL, True);

  if Conteudo <> '' then
  begin
    SQL :=
      'select ' + #13 +
      '  GR_LOG.AUTOINC_LOGREL, ' + #13 +
      '  GR_LOG.TEXTO_LOGREL ' + #13 +
      'from GR_LOG ' + #13 +
      'where GR_LOG.AUTOINC_LOGREL = ' + IntToStr(Codigo);
    ExecuteCommand_Update(SQL, 'TEXTO_LOGREL', Conteudo, True);
  end;
end;

function TSMConexao.RegistroLogColetor(DtHrInicio: TDateTime; Entrada: string): Int64;
var
  Codigo: Int64;
  SQL   : string;
begin
  Codigo := ProximoCodigo('LOG_COLETOR', 0);

  SQL :=
    ' insert into LOG_COLETOR(CODIGO_LOGCOL, DATAHORAINICIO_LOGCOL)' +
    ' values (' +
    IntToStr(Codigo) + ', ' +
    TFuncoesSQL.DataSQL(DtHrInicio, 3) + ')';

  ExecuteCommand(SQL, True);

  Result := Codigo;

  if Entrada <> '' then
  begin
    SQL :=
      'select ' + #13 +
      '  LOG_COLETOR.CODIGO_LOGCOL, ' + #13 +
      '  LOG_COLETOR.ENTRADA_LOGCOL ' + #13 +
      'from LOG_COLETOR ' + #13 +
      'where LOG_COLETOR.CODIGO_LOGCOL = ' + IntToStr(Codigo);
    ExecuteCommand_Update(SQL, 'ENTRADA_LOGCOL', Entrada, True);
  end;
end;

procedure TSMConexao.AtualizaLogColetor(Codigo: Int64; DtHrTermino: TDateTime; Saida: string);
var
  SQL: string;
begin
  SQL :=
    ' update LOG_COLETOR set ' + #13 +
    '  LOG_COLETOR.DATAHORATERMINO_LOGCOL = ' + TFuncoesSQL.DataSQL(DtHrTermino, 3) + #13 +
    ' where LOG_COLETOR.CODIGO_LOGCOL = ' + IntToStr(Codigo);
  ExecuteCommand(SQL, True);

  if Saida <> '' then
  begin
    SQL :=
      'select ' + #13 +
      '  LOG_COLETOR.CODIGO_LOGCOL, ' + #13 +
      '  LOG_COLETOR.SAIDA_LOGCOL ' + #13 +
      'from LOG_COLETOR ' + #13 +
      'where LOG_COLETOR.CODIGO_LOGCOL = ' + IntToStr(Codigo);
    ExecuteCommand_Update(SQL, 'SAIDA_LOGCOL', Saida, True);
  end;
end;

function TSMConexao.MontaStringCodigos(CDS: TClientDataSet): String;
var
  s   : String;
  i, T: Integer;
begin
  // Retorna uma string para cláusula where de sql
  s := '( %S in (-1';
  T := Length(s);
  i := 0;
  with CDS do
  begin
    First;
    while (not eof) do
    begin
      Inc(i);
      if ((i mod 1400) = 0) then
        s := s + ') or %0:S in (' + Fields[0].AsString
      else
        s := s + ',' + Fields[0].AsString;
      Next;
    end;
    Close;
  end;
  if (Length(s) > T) then
    Delete(s, 10, 3);
  s      := s + ') )';
  Result := s;
end;

procedure TSMConexao.CarregaUsuario(sNome, sSenha: string);
var
  CDS   : TClientDataSet;
  SQL, s: string;

  procedure CarregaModulosDisponiveisUsuario;
  var
    CDS: TClientDataSet;
    X  : Integer;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      SetLength(SecaoAtual.Usuario.ModulosDisp, QtdeModulosExec + 1);
      for X                               := Low(SecaoAtual.Usuario.ModulosDisp) to High(SecaoAtual.Usuario.ModulosDisp) do
        SecaoAtual.Usuario.ModulosDisp[X] := False;

      with CDS do
      begin
        Data := ExecuteReader(
          ' select USUARIO_MODULOS.MODULO_USUMOD' + #13 +
          ' from USUARIO_MODULOS' + #13 +
          ' where USUARIO_MODULOS.USUARIO_USUMOD = ' + IntToStr(SecaoAtual.Usuario.Codigo), -1, True);
        IndexFieldNames := 'MODULO_USUMOD';
        First;
        while (not eof) do
        begin
          for X := 1 to QtdeModulosExec do
            if (X = FieldByName('MODULO_USUMOD').AsInteger) then
            begin
              SecaoAtual.Usuario.ModulosDisp[X] := True;
              Break;
            end;
          Next;
        end;
        Close;
      end;
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaEmpresasDisponiveisUsuario;
  var
    CDS: TClientDataSet;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select USUARIO_EMPRESAS.EMPRESA_USUEMP' + #13 +
        ' from USUARIO_EMPRESAS' + #13 +
        ' where (USUARIO_EMPRESAS.USUARIO_USUEMP = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')', -1, True);
      CDS.IndexFieldNames             := 'EMPRESA_USUEMP';
      SecaoAtual.Usuario.EmpresasDisp := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaEmpregadoresDisponiveisUsuario;
  var
    CDS: TClientDataSet;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select USUARIO_EMPREGADORES.EMPREGADOR_USUEMPREG' + #13 +
        ' from USUARIO_EMPREGADORES' + #13 +
        ' where (USUARIO_EMPREGADORES.USUARIO_USUEMPREG = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')', -1, True);
      CDS.IndexFieldNames                 := 'EMPREGADOR_USUEMPREG';
      SecaoAtual.Usuario.EmpregadoresDisp := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaEstabelecimentosDisponiveisUsuario;
  var
    CDS: TClientDataSet;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select USUARIO_ESTABELECIMENTOS.ESTABELECIMENTO_USUEST ' + #13 +
        ' from USUARIO_ESTABELECIMENTOS ' + #13 +
        ' where USUARIO_ESTABELECIMENTOS.USUARIO_USUEST = ' + IntToStr(SecaoAtual.Usuario.Codigo), -1, True);
      CDS.IndexFieldNames                     := 'ESTABELECIMENTO_USUEST';
      SecaoAtual.Usuario.EstabelecimentosDisp := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaQualificacoesDisponiveisUsuario;
  var
    CDS                                : TClientDataSet;
    PodeVerZero, PodeVerDiferenteDeZero: Boolean;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select USUARIO_QUALIFICACOES.QUALIFICACAO_USUQUALIF' + #13 +
        ' from USUARIO_QUALIFICACOES' + #13 +
        ' where USUARIO_QUALIFICACOES.USUARIO_USUQUALIF = ' + IntToStr(SecaoAtual.Usuario.Codigo), -1, True);
      CDS.IndexFieldNames := 'QUALIFICACAO_USUQUALIF';
      with CDS do
      begin
        First;
        PodeVerZero            := False;
        PodeVerDiferenteDeZero := False;
        while (not eof) do
        begin
          if (Fields[0].AsInteger = 0) then
            PodeVerZero := True
          else
            PodeVerDiferenteDeZero := True;
          if (PodeVerZero) and (PodeVerDiferenteDeZero) then
            Break;
          Next;
        end;
      end;
      if (PodeVerZero) and (PodeVerDiferenteDeZero) then
        SecaoAtual.Usuario.VisibilidadeQualificacoesBordero := 0
      else if (PodeVerZero) and (not PodeVerDiferenteDeZero) then
        SecaoAtual.Usuario.VisibilidadeQualificacoesBordero := 1
      else if (not PodeVerZero) and (PodeVerDiferenteDeZero) then
        SecaoAtual.Usuario.VisibilidadeQualificacoesBordero := 2;

      SecaoAtual.Usuario.QualificacoesDisp := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaClientesConsultorUsuario;
  var
    CDS : TClientDataSet;
    sSQL: string;
  begin
    if (SecaoAtual.Usuario.Consultor = 0) then
    begin
      SecaoAtual.Usuario.ClientesConsultorDisp := '';
      Exit;
    end;

    CDS := TClientDataSet.Create(Self);
    try
      sSQL := ' select PESSOA_CLIENTECONSULTOR.CLIENTE_PESSOA_CLICON' + #13 +
        ' from PESSOA_CLIENTECONSULTOR' + #13 +
        ' where (PESSOA_CLIENTECONSULTOR.CONSULTOR_PESSOA_CLICON = ' + IntToStr(SecaoAtual.Usuario.Consultor) + ')';
      CDS.Data            := ExecuteReader(sSQL, -1, True);
      CDS.IndexFieldNames := 'CLIENTE_PESSOA_CLICON';
      if CDS.RecordCount < 1400 then
        SecaoAtual.Usuario.ClientesConsultorDisp := MontaStringCodigos(CDS)
      else
        SecaoAtual.Usuario.ClientesConsultorDisp := '(%S in (' + sSQL + '))';
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaClientesSupervisor;
  var
    SQL: String;
    CDS: TClientDataSet;
  begin
    if (SecaoAtual.Usuario.Supervisor = 0) then
    begin
      SecaoAtual.Usuario.ClientesSupervisorDisp := '';
      Exit;
    end;

    CDS := TClientDataSet.Create(Self);
    try
      SQL := 'select PESSOA_CLIENTECONSULTOR.CLIENTE_PESSOA_CLICON' + #13 +
        'from PESSOA_CONSULTORSUPERVISOR' + #13 +
        'left join PESSOA_CLIENTECONSULTOR on (PESSOA_CLIENTECONSULTOR.CONSULTOR_PESSOA_CLICON = PESSOA_CONSULTORSUPERVISOR.CONSULTOR_PESSOA_CONSUP)' + #13 +
        'where ( (PESSOA_CONSULTORSUPERVISOR.SUPERVISOR_PESSOA_CONSUP = ' + IntToStr(SecaoAtual.Usuario.Supervisor) + ')' + #13 +
        '    or  (PESSOA_CLIENTECONSULTOR.SUPERVISOR_PESSOA_CLICON = ' + IntToStr(SecaoAtual.Usuario.Supervisor) + ')  )' + #13 +
        'and (PESSOA_CLIENTECONSULTOR.CLIENTE_PESSOA_CLICON is not null)' + #13;
      if (SecaoAtual.Usuario.Consultor <> 0) then
        SQL := SQL + #13 + ' union ' + #13 +
          'select PESSOA_CLIENTECONSULTOR.CLIENTE_PESSOA_CLICON' + #13 +
          'from PESSOA_CLIENTECONSULTOR' + #13 +
          'where (PESSOA_CLIENTECONSULTOR.CONSULTOR_PESSOA_CLICON = ' + IntToStr(SecaoAtual.Usuario.Consultor) + ')';
      CDS.Data            := ExecuteReader(SQL, -1, True);
      CDS.IndexFieldNames := 'CLIENTE_PESSOA_CLICON';
      if CDS.RecordCount < 1400 then
        SecaoAtual.Usuario.ClientesSupervisorDisp := MontaStringCodigos(CDS)
      else
        SecaoAtual.Usuario.ClientesSupervisorDisp := '(%S in (' + SQL + '))';
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaConsultoresSupervisorUsuario;
  var
    CDS: TClientDataSet;
  begin
    if (SecaoAtual.Usuario.Supervisor = 0) then
    begin
      SecaoAtual.Usuario.ConsultoresSupervisorDisp := '';
      Exit;
    end;

    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select PESSOA_CONSULTORSUPERVISOR.CONSULTOR_PESSOA_CONSUP' + #13 +
        ' from PESSOA_CONSULTORSUPERVISOR' + #13 +
        ' where (PESSOA_CONSULTORSUPERVISOR.SUPERVISOR_PESSOA_CONSUP = ' + IntToStr(SecaoAtual.Usuario.Supervisor) + ')', -1, True);
      CDS.IndexFieldNames                          := 'CONSULTOR_PESSOA_CONSUP';
      SecaoAtual.Usuario.ConsultoresSupervisorDisp := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaBloqueiosDisponiveisUsuario;
  var
    CDS: TClientDataSet;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select USUARIO_BLOQUEIO.BLOQUEIO_USUBLOQ' + #13 +
        ' from USUARIO_BLOQUEIO' + #13 +
        ' where USUARIO_BLOQUEIO.USUARIO_USUBLOQ = ' + IntToStr(SecaoAtual.Usuario.Codigo), -1, True);
      CDS.IndexFieldNames              := 'BLOQUEIO_USUBLOQ';
      SecaoAtual.Usuario.BloqueiosDisp := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaAutorizacaoEspecialUsuario;
  var
    CDS: TClientDataSet;
    X  : Integer;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      SetLength(SecaoAtual.Usuario.AutorizacaoEspecial, High(OpcoesEspeciais) + 2);
      for X                                       := Low(SecaoAtual.Usuario.AutorizacaoEspecial) to High(SecaoAtual.Usuario.AutorizacaoEspecial) do
        SecaoAtual.Usuario.AutorizacaoEspecial[X] := False;

      with CDS do
      begin
        Data := ExecuteReader(
          ' select USUARIO_ESPECIAIS.OPCAO_USUESP ' + #13 +
          ' from USUARIO_ESPECIAIS ' + #13 +
          ' where USUARIO_ESPECIAIS.USUARIO_USUESP  = ' + IntToStr(SecaoAtual.Usuario.Codigo), -1, True);
        IndexFieldNames := 'OPCAO_USUESP';
        First;
        while (not eof) do
        begin
          for X := 1 to High(OpcoesEspeciais) + 2 do
            if (X = FieldByName('OPCAO_USUESP').AsInteger) then
            begin
              SecaoAtual.Usuario.AutorizacaoEspecial[X] := True;
              Break;
            end;
          Next;
        end;
        Close;
      end;
    finally
      FreeAndNil(CDS);
    end;
  end;

  procedure CarregaAssuntosSacUsuario;
  var
    CDS: TClientDataSet;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      CDS.Data := ExecuteReader(
        ' select SGQ_ASSUNTOS_SAC.CODIGO_ASSUNTOSAC' + #13 +
        ' from SGQ_ASSUNTOS_SAC' + #13 +
        ' where (SGQ_ASSUNTOS_SAC.USUARIODIRECIONAMENT_ASSUNTOSAC = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')', -1, True);
      CDS.IndexFieldNames                     := 'CODIGO_ASSUNTOSAC';
      SecaoAtual.Usuario.AssuntosSacDoUsuario := MontaStringCodigos(CDS);
    finally
      FreeAndNil(CDS);
    end;
  end;

begin
  CDS := TClientDataSet.Create(Self);
  try
    SQL :=
      'select ' + #13 +
      '  USUARIO.CODIGO_USUARIO, USUARIO.SENHA_USUARIO, USUARIO.GUID_USUARIO, USUARIO.TOKEN_USUARIO, ' + #13 +
      '  USUARIO.MANIPULASENHA_USUARIO, USUARIO.PESSOASUPERVISOR_USUARIO, ' + #13 +
      '  USUARIO.PESSOAREPRESENTANTE_USUARIO, USUARIO.PESSOAFUNCIONARIO_USUARIO, USUARIO.PESSOATELEVENDAS_USUARIO ' + #13 +
      'from USUARIO' + #13 +
      'where USUARIO.DESCRICAO_USUARIO = ' + QuotedStr(sNome);
    CDS.Data := ExecuteReader(SQL, 1, True);
    with CDS do
    begin
      if (IsEmpty) or (sSenha <> TFuncoesCriptografia.DeCodifica(FieldByName('SENHA_USUARIO').AsString, sChaveCriptografia)) then
        raise Exception.Create(MensagemServidorApl + 'Usuário ou Senha incorretos. Favor verificar!');

      with SecaoAtual.Usuario do
      begin
        Nome          := sNome;
        Senha         := sSenha;
        Guid          := FieldByName('GUID_USUARIO').AsString;
        Token         := FieldByName('TOKEN_USUARIO').AsString;
        Codigo        := FieldByName('CODIGO_USUARIO').AsInteger;
        ManipulaSenha := FieldByName('MANIPULASENHA_USUARIO').AsString = 'S';
        Supervisor    := FieldByName('PESSOASUPERVISOR_USUARIO').AsInteger;
        Consultor     := FieldByName('PESSOAREPRESENTANTE_USUARIO').AsInteger;
        Funcionario   := FieldByName('PESSOAFUNCIONARIO_USUARIO').AsInteger;
        TeleVendas    := FieldByName('PESSOATELEVENDAS_USUARIO').AsInteger;

        // Define o nível do usuário (usado no site)
        if ((Consultor = 0) and (Supervisor = 0)) then
          Nivel := NIVEL_ADMINISTRADOR
        else if ((Consultor <> 0) and (Supervisor = 0)) then
          Nivel := NIVEL_CONSULTOR
        else if ((Consultor = 0) and (Supervisor <> 0)) then
          Nivel := NIVEL_SUPERVISOR
        else
          Nivel := NIVEL_INDEFINIDO;
      end;
    end;

    if (SecaoAtual.Sistema <= QtdeModulosExec) then
    begin
      // Verificando se o módulo está liberado para o usuário
      SQL :=
        'select USUARIO_MODULOS.AUTOINC_USUMOD ' + #13 +
        'from USUARIO_MODULOS ' + #13 +
        'where USUARIO_MODULOS.USUARIO_USUMOD = ' + IntToStr(SecaoAtual.Usuario.Codigo) + #13 +
        '  and USUARIO_MODULOS.MODULO_USUMOD  = ' + IntToStr(SecaoAtual.Sistema);
      CDS.Data := ExecuteReader(SQL, 1, True);
      if (CDS.IsEmpty) then
        raise Exception.Create(MensagemServidorApl + 'Módulo não liberado para esse usuário');
    end;

    // Verificando se pelo menos uma empresa ou conta está liberada para o usuário
    case SecaoAtual.Sistema of
      cSistemaCaixa:
        begin
          SQL :=
            'select count(USUARIO_CONTAS.AUTOINC_USUCNT)' + #13 +
            'from USUARIO_CONTAS' + #13 +
            'where (USUARIO_CONTAS.USUARIO_USUCNT = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')';
          s := 'Contas';
        end;

      cSistemaDepPessoal, cSistemaContabilidade:
        begin
          SQL :=
            'select count(USUARIO_ESTABELECIMENTOS.AUTOINC_USUEST) ' + #13 +
            'from USUARIO_ESTABELECIMENTOS ' + #13 +
            'where (USUARIO_ESTABELECIMENTOS.USUARIO_USUEST = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')';
          s := 'Estabelecimentos';
        end;

      cSistemaESocial:
        begin
          SQL :=
            'select count(USUARIO_EMPREGADORES.AUTOINC_USUEMPREG) ' + #13 +
            'from USUARIO_EMPREGADORES ' + #13 +
            'where (USUARIO_EMPREGADORES.USUARIO_USUEMPREG = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')';
          s := 'Empregadores';
        end;
    else
      begin
        SQL :=
          'select count(USUARIO_EMPRESAS.AUTOINC_USUEMP)' + #13 +
          'from USUARIO_EMPRESAS' + #13 +
          'where (USUARIO_EMPRESAS.USUARIO_USUEMP = ' + IntToStr(SecaoAtual.Usuario.Codigo) + ')';
        s := 'Empresas';
      end;
    end;

    if ExecuteScalar(SQL, True) = 0 then
      raise Exception.Create(MensagemServidorApl + 'Não há ' + s + ' liberadas para esse usuário');

    CarregaModulosDisponiveisUsuario;
    CarregaEmpresasDisponiveisUsuario;
    CarregaEmpregadoresDisponiveisUsuario;
    CarregaEstabelecimentosDisponiveisUsuario;
    CarregaContasDisponiveisUsuario;
    CarregaQualificacoesDisponiveisUsuario;
    CarregaClientesConsultorUsuario;
    CarregaConsultoresSupervisorUsuario;
    CarregaClientesSupervisor;
    CarregaBloqueiosDisponiveisUsuario;
    CarregaAutorizacaoEspecialUsuario;
    CarregaAssuntosSacUsuario;

    CarregaEmail(-1, SecaoAtual.Usuario.EmailPadrao);

    CarregaConfiguracoes;
  finally
    FreeAndNil(CDS);
  end;
end;

procedure TSMConexao.CarregaUsuarioPeloToken(sValue: string);
var
  SQL: string;
  CDS: TClientDataSet;
begin
  if Trim(sValue) = '' then
    raise Exception.Create('Token não informado');

  CDS := TClientDataSet.Create(Self);
  try
    SQL :=
      'select ' + #13 +
      '  USUARIO.DESCRICAO_USUARIO, USUARIO.SENHA_USUARIO ' + #13 +
      'from USUARIO' + #13 +
      'where USUARIO.TOKEN_USUARIO = ' + QuotedStr(sValue);
    CDS.Data := ExecuteReader(SQL, 1, True);
    with CDS do
    begin
      if (IsEmpty) then
        raise Exception.Create(MensagemServidorApl + 'Token inválido!');

      CarregaUsuario(FieldByName('DESCRICAO_USUARIO').AsString, TFuncoesCriptografia.DeCodifica(FieldByName('SENHA_USUARIO').AsString, sChaveCriptografia));
    end;
  finally
    CDS.Free;
  end;
end;

procedure TSMConexao.CarregaEmail(Codigo: Integer; var EMail: TConfigEMailNovo);
var
  SQL: string;
  CDS: TClientDataSet;
begin
  CDS := TClientDataSet.Create(Self);
  try
    SQL :=
      'select ' + #13 +
      TClassUsuario_CFG_Email.CamposCadastro + #13 +
      'from USUARIO_CFG_EMAIL' + #13;

    if Codigo > 0 then
      SQL := SQL +
        'where USUARIO_CFG_EMAIL.AUTOINC_CFGMAIL = ' + IntToStr(Codigo) + #13
    else
      SQL := SQL +
        'where USUARIO_CFG_EMAIL.USUARIO_CFGMAIL = ' + IntToStr(SecaoAtual.Usuario.Codigo) + #13 +
        '  and USUARIO_CFG_EMAIL.PADRAO_CFGMAIL = ''S''';

    CDS.Data := ExecuteReader(SQL, -1, True);

    if CDS.IsEmpty then
      Exit;

    with EMail do
    begin
      Codigo         := CDS.FieldByName('AUTOINC_CFGMAIL').AsInteger;
      Descricao      := CDS.FieldByName('DESCRICAO_CFGMAIL').AsString;
      NomeRemetente  := CDS.FieldByName('NOME_REMETENTE_CFGMAIL').AsString;
      EmailRemetente := AnsiLowerCase(CDS.FieldByName('EMAIL_REMETENTE_CFGMAIL').AsString);
      SmtpHost       := CDS.FieldByName('SMTP_CFGMAIL').AsString;
      SmtpPort       := CDS.FieldByName('SMTP_PORTA_CFGMAIL').AsInteger;
      User           := CDS.FieldByName('USER_NAME_CFGMAIL').AsString;
      Password       := TFuncoesCriptografia.DeCodifica(CDS.FieldByName('USER_PASS_CFGMAIL').AsString, sChaveCriptografia);
      SSL            := (CDS.FieldByName('SMTP_SSL_CFGMAIL').AsString = 'S');
      TLS            := (CDS.FieldByName('SMTP_TLS_CFGMAIL').AsString = 'S');
      Copia          := AnsiLowerCase(CDS.FieldByName('COPIA_CFGMAIL').AsString);
      TextoPadrao    := Trim(CDS.FieldByName('MENSAGEM_CFGMAIL').AsString);
      MetodoEnvio    := CDS.FieldByName('METODO_ENVIO_CFGMAIL').AsInteger;
    end;
  finally
    FreeAndNil(CDS);
  end;
end;

procedure TSMConexao.CarregaEmpresa(iQuebra: Integer);
// iQuebra pode ser empresa ou caixa ou estabelecimento conforme o modulo de acesso
var
  CDS : TClientDataSet;
  SQL : string;
  iCnt: Integer;

  procedure CarregaPerfilConfig(vPerfil: TPerfilConfigNovo; iCodPerfil: Integer);
  var
    CDS: TClientDataSet;
    SQL: string;
  begin
    CDS := TClientDataSet.Create(Self);
    try
      SQL :=
        ' select ' +
        ' CONFIG_SISTEMA_PERFIL.DESCRICAO_CFSPERFIL,        ' +
        ' CONFIG_SISTEMA_PERFIL.VARIACAO_CFSPERFIL,         ' +
        ' CONFIG_SISTEMA_PERFIL.COR_CFSPERFIL,              ' +
        ' CONFIG_SISTEMA_PERFIL.ACABAMENTO_CFSPERFIL,       ' +
        ' CONFIG_SISTEMA_PERFIL.GRADE_CFSPERFIL,            ' +
        ' CONFIG_SISTEMA_PERFIL.COMPRIMENTO_CFSPERFIL,      ' +
        ' CONFIG_SISTEMA_PERFIL.LARGURA_CFSPERFIL,          ' +
        ' CONFIG_SISTEMA_PERFIL.ESPESSURA_CFSPERFIL,        ' +
        ' CONFIG_SISTEMA_PERFIL.LAYOUTIMPRESSAO_CFSPERFIL,  ' +
        ' CONFIG_SISTEMA_PERFIL.STATUS_CFSPERFIL            ' +
        ' from CONFIG_SISTEMA_PERFIL' +
        ' where CONFIG_SISTEMA_PERFIL.CODIGO_CFSPERFIL = ' + IntToStr(iCodPerfil);

      CDS.Data := ExecuteReader(SQL, -1, True);
      with CDS, vPerfil do
      begin
        Codigo          := iCodPerfil;
        LayoutImpressao := FieldByName('LAYOUTIMPRESSAO_CFSPERFIL').AsInteger;
        Status          := FieldByName('STATUS_CFSPERFIL').AsInteger;
        Descricao       := FieldByName('DESCRICAO_CFSPERFIL').AsString;
        UsaVariacao     := (FieldByName('VARIACAO_CFSPERFIL').AsString = 'S');
        UsaCor          := (FieldByName('COR_CFSPERFIL').AsString = 'S');
        UsaAcabamento   := (FieldByName('ACABAMENTO_CFSPERFIL').AsString = 'S');
        UsaGrade        := (FieldByName('GRADE_CFSPERFIL').AsString = 'S');
        UsaComprimento  := (FieldByName('COMPRIMENTO_CFSPERFIL').AsString = 'S');
        UsaLargura      := (FieldByName('LARGURA_CFSPERFIL').AsString = 'S');
        UsaEspessura    := (FieldByName('ESPESSURA_CFSPERFIL').AsString = 'S');
      end;
    finally
      FreeAndNil(CDS);
    end;
  end;

begin
  SQL := '';
  if (SecaoAtual.Sistema = cSistemaCaixa) then
    SQL :=
      'select ' + #13 +
      '  USUARIO_CONTAS.CONTA_USUCNT CODIGO' + #13 +
      'from USUARIO_CONTAS' + #13 +
      'where USUARIO_CONTAS.USUARIO_USUCNT = ' + IntToStr(SecaoAtual.Usuario.Codigo)
  else if (SecaoAtual.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
    SQL :=
      'select ' + #13 +
      '  ESTABELECIMENTO.CODIGO_EST  CODIGO,' + #13 +
      '  ESTABELECIMENTO.EMPRESA_EST EMP    ' + #13 +
      'from USUARIO_ESTABELECIMENTOS ' + #13 +
      'inner join ESTABELECIMENTO  on (ESTABELECIMENTO.CODIGO_EST = USUARIO_ESTABELECIMENTOS.ESTABELECIMENTO_USUEST)' + #13 +
      'inner join USUARIO_EMPRESAS on (USUARIO_EMPRESAS.EMPRESA_USUEMP = ESTABELECIMENTO.EMPRESA_EST ' + #13 +
      '                            and USUARIO_EMPRESAS.USUARIO_USUEMP = USUARIO_ESTABELECIMENTOS.USUARIO_USUEST) ' + #13 +
      'where USUARIO_ESTABELECIMENTOS.USUARIO_USUEST = ' + IntToStr(SecaoAtual.Usuario.Codigo)
  else if (SecaoAtual.Sistema = cSistemaESocial) then
    SQL :=
      'select ' + #13 +
      '  USUARIO_EMPREGADORES.EMPREGADOR_USUEMPREG CODIGO, ' + #13 +
      '  ESTABELECIMENTO.CODIGO_EST   EST, ' + #13 +
      '  ESTABELECIMENTO.EMPRESA_EST  EMP ' + #13 +
      'from USUARIO_EMPREGADORES' + #13 +
      'left join ES_EMPREGADOR   on (ES_EMPREGADOR.CODIGO_EMPREGADOR = USUARIO_EMPREGADORES.EMPREGADOR_USUEMPREG) ' + #13 +
      'left join ESTABELECIMENTO on (ESTABELECIMENTO.CODIGO_EST      = ES_EMPREGADOR.ESTABELECIMENTO_EMPREGADOR) ' + #13 +
      'where USUARIO_EMPREGADORES.USUARIO_USUEMPREG = ' + IntToStr(SecaoAtual.Usuario.Codigo)
  else if (SecaoAtual.Sistema = cSistemaAgendadorRelatorio) then
    SQL :=
      'select ' + #13 +
      '  EMPRESA.CODIGO_EMP CODIGO' + #13 +
      'from EMPRESA ' + #13 +
      'where EMPRESA.CODIGO_EMP = ' + IntToStr(iQuebra)
  else
    SQL :=
      'select ' + #13 +
      '  USUARIO_EMPRESAS.EMPRESA_USUEMP CODIGO' + #13 +
      'from USUARIO_EMPRESAS ' + #13 +
      'where USUARIO_EMPRESAS.USUARIO_USUEMP = ' + IntToStr(SecaoAtual.Usuario.Codigo);

  CDS := TClientDataSet.Create(Self);
  try
    CDS.Data            := ExecuteReader(SQL, -1, True);
    CDS.IndexFieldNames := 'CODIGO';

    if (SecaoAtual.Sistema >= 1) and (SecaoAtual.Sistema <= Constantes.QtdeModulosExec) then
    begin
      // Se não encontrar a "empresa" passe para próxima, assim evitando a zero
      if (not CDS.FindKey([iQuebra])) or (iQuebra = 0) then
        CDS.Next;
    end
    else
      CDS.FindKey([iQuebra]);

    if (SecaoAtual.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
    begin
      SecaoAtual.Empresa.Codigo          := CDS.FieldByName('EMP').AsInteger;
      SecaoAtual.Empresa.Estabelecimento := CDS.FieldByName('CODIGO').AsInteger;
      SecaoAtual.Empresa.Empregador      := 0;
    end
    else if (SecaoAtual.Sistema in [cSistemaESocial]) then
    begin
      SecaoAtual.Empresa.Codigo          := CDS.FieldByName('EMP').AsInteger;
      SecaoAtual.Empresa.Estabelecimento := CDS.FieldByName('EST').AsInteger;
      SecaoAtual.Empresa.Empregador      := CDS.FieldByName('CODIGO').AsInteger;
    end
    else
    begin
      SecaoAtual.Empresa.Codigo          := CDS.FieldByName('CODIGO').AsInteger;
      SecaoAtual.Empresa.Estabelecimento := 0;
      SecaoAtual.Empresa.Empregador      := 0;
    end;
  finally
    FreeAndNil(CDS);
  end;

  CDS := TClientDataSet.Create(Self);
  try
    if (SecaoAtual.Sistema = cSistemaCaixa) then
      SQL :=
        'select ' + #13 +
        '  CONTA.CODIGO_CONTA,' + #13 +
        '  CONTA.DESCRICAO_CONTA,' + #13 +
        '  CONTA.CX_CIDADE_CONTA,' + #13 +
        '  CONTA.ACEITALANCAMENTOMANUAL_CONTA,' + #13 +
        '  CIDADE.DESCRICAO_CIDADE,' + #13 +
        '  CIDADE.CODMUNICIPIO_CIDADE,' + #13 +
        '  UF.CODIGO_UF,' + #13 +
        '  UF.SIGLA_UF' + #13 +
        'from CONTA' + #13 +
        'left join CIDADE on (CONTA.CX_CIDADE_CONTA = CIDADE.CODIGO_CIDADE)' + #13 +
        'left join UF     on (UF.CODIGO_UF = CIDADE.UF_CIDADE)' + #13 +
        'where CONTA.CODIGO_CONTA = ' + IntToStr(SecaoAtual.Empresa.Codigo)
    else if (SecaoAtual.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
      SQL :=
        'select ' + #13 +
        '  ESTABELECIMENTO.EMPRESA_EST, ' + #13 +
        '  ESTABELECIMENTO.CODIGO_EST, ' + #13 +
        '  ESTABELECIMENTO.QUALIFICACAO_EST, ' + #13 +
        '  ESTABELECIMENTO.NOME_EST, ' + #13 +
        '  ESTABELECIMENTO.TIPOINSC_EST, ' + #13 +
        '  ESTABELECIMENTO.CNPJCEICPF_EST, ' + #13 +
        '  ESTABELECIMENTO.INSCRICAO_ESTADUAL_EST, ' + #13 +
        '  ESTABELECIMENTO.INSCRICAO_MUNICIPAL_EST, ' + #13 +
        '  ESTABELECIMENTO.LOGRADOURO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.NUMERO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.COMPLEMENTO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.BAIRRO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.CEP_END_EST, ' + #13 +
        '  ESTABELECIMENTO.CIDADE_END_EST, ' + #13 +
        '  ESTABELECIMENTO.NIRE_EST, ' + #13 +
        '  ESTABELECIMENTO.DATA_ARQ_EST, ' + #13 +
        '  ESTABELECIMENTO.DATA_ARQ_CONV_EST, ' + #13 +
        '  CIDADE.DESCRICAO_CIDADE, ' + #13 +
        '  CIDADE.CODMUNICIPIO_CIDADE, ' + #13 +
        '  CIDADE.UF_CIDADE, ' + #13 +
        '  UF.SIGLA_UF, ' + #13 +
        '  ESTABELECIMENTO.CTB_USARCENTROCUSTO_EST, ' + #13 +
        '  ESTABELECIMENTO.CTB_ULTIMOLANC_EST, ' + #13 +
        '  ESTABELECIMENTO.CTB_ABR_CONS_PART_LCTO_EST, ' + #13 +
        '  ESTABELECIMENTO.CTB_DV_LANCAMENTO_EST, ' + #13 +
        '  EMPRESA.PESSOA_EMP ' + #13 +
        'from ESTABELECIMENTO ' + #13 +
        'left join EMPRESA on (EMPRESA.CODIGO_EMP = ESTABELECIMENTO.EMPRESA_EST) ' + #13 +
        'left join CIDADE  on (CIDADE.CODIGO_CIDADE = ESTABELECIMENTO.CIDADE_END_EST) ' + #13 +
        'left join UF      on (UF.CODIGO_UF = CIDADE.UF_CIDADE) ' + #13 +
        'where ESTABELECIMENTO.CODIGO_EST = ' + IntToStr(SecaoAtual.Empresa.Estabelecimento)
    else if (SecaoAtual.Sistema = cSistemaESocial) then
      SQL :=
        'select ' + #13 +
        '  ES_EMPREGADOR.CODIGO_EMPREGADOR, ' + #13 +
        '  ES_EMPREGADOR.TIPO_INSC_EMPREGADOR, ' + #13 +
        '  ES_EMPREGADOR.INSCRICAO_EMPREGADOR, ' + #13 +
        '  ES_EMPREGADOR.NOME_RS_EMPREGADOR, ' + #13 +
        '  ES_EMPREGADOR.ESTABELECIMENTO_EMPREGADOR, ' + #13 +
        '  ESTABELECIMENTO.EMPRESA_EST, ' + #13 +
        '  ESTABELECIMENTO.CODIGO_EST, ' + #13 +
        '  ESTABELECIMENTO.QUALIFICACAO_EST, ' + #13 +
        '  ESTABELECIMENTO.NOME_EST, ' + #13 +
        '  ESTABELECIMENTO.TIPOINSC_EST, ' + #13 +
        '  ESTABELECIMENTO.CNPJCEICPF_EST, ' + #13 +
        '  ESTABELECIMENTO.INSCRICAO_ESTADUAL_EST, ' + #13 +
        '  ESTABELECIMENTO.INSCRICAO_MUNICIPAL_EST, ' + #13 +
        '  ESTABELECIMENTO.LOGRADOURO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.NUMERO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.COMPLEMENTO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.BAIRRO_END_EST, ' + #13 +
        '  ESTABELECIMENTO.CEP_END_EST, ' + #13 +
        '  ESTABELECIMENTO.CIDADE_END_EST, ' + #13 +
        '  ESTABELECIMENTO.NIRE_EST, ' + #13 +
        '  ESTABELECIMENTO.DATA_ARQ_EST, ' + #13 +
        '  ESTABELECIMENTO.DATA_ARQ_CONV_EST, ' + #13 +
        '  CIDADE.DESCRICAO_CIDADE, ' + #13 +
        '  CIDADE.CODMUNICIPIO_CIDADE, ' + #13 +
        '  CIDADE.UF_CIDADE, ' + #13 +
        '  UF.SIGLA_UF, ' + #13 +
        '  ESTABELECIMENTO.CTB_USARCENTROCUSTO_EST, ' + #13 +
        '  ESTABELECIMENTO.CTB_ULTIMOLANC_EST, ' + #13 +
        '  ESTABELECIMENTO.CTB_ABR_CONS_PART_LCTO_EST, ' + #13 +
        '  ESTABELECIMENTO.CTB_DV_LANCAMENTO_EST, ' + #13 +
        '  EMPRESA.PESSOA_EMP ' + #13 +
        'from ES_EMPREGADOR ' + #13 +
        'left join ESTABELECIMENTO on (ESTABELECIMENTO.CODIGO_EST = ES_EMPREGADOR.ESTABELECIMENTO_EMPREGADOR) ' + #13 +
        'left join EMPRESA on (EMPRESA.CODIGO_EMP = ESTABELECIMENTO.EMPRESA_EST) ' + #13 +
        'left join CIDADE  on (CIDADE.CODIGO_CIDADE = ESTABELECIMENTO.CIDADE_END_EST) ' + #13 +
        'left join UF      on (UF.CODIGO_UF = CIDADE.UF_CIDADE) ' + #13 +
        'where ES_EMPREGADOR.CODIGO_EMPREGADOR = ' + IntToStr(SecaoAtual.Empresa.Empregador)
    else
      SQL :=
        'select ' + #13 +
        '  EMPRESA.CODIGO_EMP, EMPRESA.NOME_EMP, ' + #13 +
        '  EMPRESA.PESSOA_EMP, PESSOA_EMAIL.EMAIL_PESSOA_EMAIL, PESSOA.HOMEPAGE_PESSOA, ' + #13 +
        '  PESSOA_ENDERECO.CIDADE_PESSOA_END, PESSOA_ENDERECO.ENDERECO_PESSOA_END, ' + #13 +
        '  PESSOA_ENDERECO.NUMERO_PESSOA_END, PESSOA_ENDERECO.COMPLEMENTO_PESSOA_END, ' + #13 +
        '  PESSOA_ENDERECO.BAIRRO_PESSOA_END, PESSOA_ENDERECO.CEP_PESSOA_END, ' + #13 +
        '  CIDADE.DESCRICAO_CIDADE, CIDADE.CODMUNICIPIO_CIDADE, CIDADE.UF_CIDADE, UF.SIGLA_UF, ' + #13 +
        '  FONE.TELEFONE_PESSOA_TEL FONE, FAX.TELEFONE_PESSOA_TEL FAX, ' + #13 +
        '  EMPRESA.INDCOM_EMP,' + #13 +
        '  EMPRESA.ALQJURBOLETA_EMP,' + #13 +
        '  EMPRESA.ALQJURRECEBER_EMP,' + #13 +
        '  EMPRESA.ALQJURCHEQUE_EMP,' + #13 +
        '  EMPRESA.ALQJURBORDERO_EMP,' + #13 +
        '  EMPRESA.VLRMAXIMOCHQUE_EMP,' + #13 +
        '  EMPRESA.ALQISSQN_EMP,' + #13 +
        '  EMPRESA.ALQPIS_EMP,' + #13 +
        '  EMPRESA.ALQCOFINS_EMP,' + #13 +
        '  EMPRESA.ALQSIMPLES_EMP,' + #13 +
        '  EMPRESA.ALQIR_EMP,' + #13 +
        '  EMPRESA.ALQCTS_EMP,' + #13 +
        '  EMPRESA.ALQAPROVEITAMENTOICMS_EMP,' + #13 +
        '  EMPRESA.CRT_EMP,' + #13 +
        '  EMPRESA.REGIME_APURACAO_EMP,' + #13 +
        '  EMPRESA.FECHAMENTO_FISCAL_EMP, ' + #13 +
        '  EMPRESA.NIRE_EMP, ' + #13 +
        '  EMPRESA.DATA_ARQ_EMP, ' + #13 +
        '  EMPRESA.DATA_ARQ_CONV_EMP, ' + #13 +
        '  EMPRESA.REGIME_TRIBUTACAO_MUNICIPAL_EMP, ' + #13 +
        '  PESSOA.TIPO_PESSOA, ' + #13 +
        '  PESSOA_JURIDICA.CNPJCEI_PESSOA_JUR,' + #13 +
        '  PESSOA_JURIDICA.INSCRICAO_PESSOA_JUR, ' + #13 +
        '  PESSOA_JURIDICA.INSCRICAOMUNICIPAL_PESSOA_JUR, ' + #13 +
        '  PESSOA_FISICA.CPF_PESSOA_FIS ' + #13 +
        'from EMPRESA' + #13 +
        'left join PESSOA on (EMPRESA.PESSOA_EMP   = PESSOA.CODIGO_PESSOA) ' + #13 +
        'left join PESSOA_ENDERECO on (PESSOA_ENDERECO.AUTOINC_PESSOA_END = PESSOA.ENDERECO_PESSOA)' + #13 +
        'left join PESSOA_TELEFONE FONE on (FONE.AUTOINC_PESSOA_TEL = PESSOA_ENDERECO.TELEFONEPADRAO_PESSOA_END) ' + #13 +
        'left join PESSOA_TELEFONE FAX  on (FAX.PESSOA_PESSOA_TEL = EMPRESA.PESSOA_EMP) ' + #13 +
        '                              and (FAX.TIPOTELEFONE_PESSOA_TEL = ' + QuotedStr('F') + ')' + #13 +
        'left join CIDADE on (PESSOA_ENDERECO.CIDADE_PESSOA_END = CIDADE.CODIGO_CIDADE) ' + #13 +
        'left join UF     on (CIDADE.UF_CIDADE = UF.CODIGO_UF) ' + #13 +
        'left join PESSOA_JURIDICA on (PESSOA_JURIDICA.PESSOA_PESSOA_JUR = PESSOA.CODIGO_PESSOA) ' + #13 +
        'left join PESSOA_FISICA on (PESSOA_FISICA.PESSOA_PESSOA_FIS = PESSOA.CODIGO_PESSOA) ' + #13 +
        'left join PESSOA_EMAIL on (PESSOA_EMAIL.AUTOINC_PESSOA_EMAIL = PESSOA.EMAILPADRAO_PESSOA)' + #13 +
        'where EMPRESA.CODIGO_EMP = ' + IntToStr(SecaoAtual.Empresa.Codigo);

    CDS.Data := ExecuteReader(SQL, -1, True);
    with CDS do
    begin
      if (SecaoAtual.Sistema = cSistemaCaixa) then
      begin
        with SecaoAtual.Empresa do
        begin
          Codigo                      := FieldByName('CODIGO_CONTA').AsInteger;
          Estabelecimento             := 0;
          QualificacaoEstabelecimento := 0;
          Nome                        := FieldByName('DESCRICAO_CONTA').AsString;
          CidadeCod                   := FieldByName('CX_CIDADE_CONTA').AsInteger;
          CidadeNome                  := FieldByName('DESCRICAO_CIDADE').AsString;
          UFCod                       := FieldByName('CODIGO_UF').AsInteger;
          UF                          := FieldByName('SIGLA_UF').AsString;
          IndustriaComercioConfeccao  := 0; // Não sei o que vai passar. Por Antonio
          Cx_AceitaLancamentosManuais := FieldByName('ACEITALANCAMENTOMANUAL_CONTA').AsString = 'S';
          Pessoa                      := 0;
        end;
      end
      else if (SecaoAtual.Sistema = cSistemaESocial) then
      begin
        with SecaoAtual.Empresa do
        begin
          Codigo          := FieldByName('EMPRESA_EST').AsInteger;
          Estabelecimento := FieldByName('ESTABELECIMENTO_EMPREGADOR').AsInteger;
          Empregador      := FieldByName('CODIGO_EMPREGADOR').AsInteger;
          Nome            := FieldByName('NOME_RS_EMPREGADOR').AsString;
          CNPJ            := FieldByName('INSCRICAO_EMPREGADOR').AsString;

          Pessoa         := FieldByName('PESSOA_EMP').AsInteger;
          EndLogradouro  := FieldByName('LOGRADOURO_END_EST').AsString;
          EndNum         := FieldByName('NUMERO_END_EST').AsString;
          EndComplemento := FieldByName('COMPLEMENTO_END_EST').AsString;
          Endereco       := FieldByName('LOGRADOURO_END_EST').AsString +
            TrimRight(' ' + FieldByName('NUMERO_END_EST').AsString) +
            TrimRight(' ' + FieldByName('COMPLEMENTO_END_EST').AsString);
          CidadeCodMunicipio          := FieldByName('CODMUNICIPIO_CIDADE').AsInteger;
          CidadeCod                   := FieldByName('CIDADE_END_EST').AsInteger;
          CidadeNome                  := FieldByName('DESCRICAO_CIDADE').AsString;
          UFCod                       := FieldByName('UF_CIDADE').AsInteger;
          UF                          := FieldByName('SIGLA_UF').AsString;
          Bairro                      := FieldByName('BAIRRO_END_EST').AsString;
          Cep                         := FieldByName('CEP_END_EST').AsString;
          NIRE                        := FieldByName('NIRE_EST').AsString;
          DataNIRE                    := TFuncoesData.MaiorData(FieldByName('DATA_ARQ_EST').AsDateTime, FieldByName('DATA_ARQ_CONV_EST').AsDateTime);
          InscricaoEstadual           := FieldByName('INSCRICAO_ESTADUAL_EST').AsString;
          InscricaoMunicipal          := FieldByName('INSCRICAO_MUNICIPAL_EST').AsString;
          QualificacaoEstabelecimento := FieldByName('QUALIFICACAO_EST').AsInteger;
        end;
      end
      else if (SecaoAtual.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
      begin
        with SecaoAtual.Empresa do
        begin
          Codigo          := FieldByName('EMPRESA_EST').AsInteger;
          Pessoa          := FieldByName('PESSOA_EMP').AsInteger;
          Estabelecimento := FieldByName('CODIGO_EST').AsInteger;
          Nome            := FieldByName('NOME_EST').AsString;
          EndLogradouro   := FieldByName('LOGRADOURO_END_EST').AsString;
          EndNum          := FieldByName('NUMERO_END_EST').AsString;
          EndComplemento  := FieldByName('COMPLEMENTO_END_EST').AsString;
          Endereco        := FieldByName('LOGRADOURO_END_EST').AsString +
            TrimRight(' ' + FieldByName('NUMERO_END_EST').AsString) +
            TrimRight(' ' + FieldByName('COMPLEMENTO_END_EST').AsString);
          CidadeCodMunicipio          := FieldByName('CODMUNICIPIO_CIDADE').AsInteger;
          CidadeCod                   := FieldByName('CIDADE_END_EST').AsInteger;
          CidadeNome                  := FieldByName('DESCRICAO_CIDADE').AsString;
          UFCod                       := FieldByName('UF_CIDADE').AsInteger;
          UF                          := FieldByName('SIGLA_UF').AsString;
          Bairro                      := FieldByName('BAIRRO_END_EST').AsString;
          Cep                         := FieldByName('CEP_END_EST').AsString;
          NIRE                        := FieldByName('NIRE_EST').AsString;
          DataNIRE                    := TFuncoesData.MaiorData(FieldByName('DATA_ARQ_EST').AsDateTime, FieldByName('DATA_ARQ_CONV_EST').AsDateTime);
          CNPJ                        := FieldByName('CNPJCEICPF_EST').AsString;
          InscricaoEstadual           := FieldByName('INSCRICAO_ESTADUAL_EST').AsString;
          InscricaoMunicipal          := FieldByName('INSCRICAO_MUNICIPAL_EST').AsString;
          QualificacaoEstabelecimento := FieldByName('QUALIFICACAO_EST').AsInteger;
        end;

        with SecaoAtual.Parametro.CTB do
        begin
          UsarCentroDeCusto         := False; // (FieldByName('CTB_USARCENTROCUSTO_EST').AsString = 'S'); foi desabilitado temporariamente porque para utilizar o centro de custo será preciso preparar relatórios, importações, etc
          IrParaUltimoLancamento    := (FieldByName('CTB_ULTIMOLANC_EST').AsString = 'S');
          AbrirConsultaParticipante := (FieldByName('CTB_ABR_CONS_PART_LCTO_EST').AsString = 'S');
          UsarDVLancamento          := (FieldByName('CTB_DV_LANCAMENTO_EST').AsString = 'S');
        end;
      end
      else
      begin
        with SecaoAtual.Empresa do
        begin
          Codigo                      := FieldByName('CODIGO_EMP').AsInteger;
          Estabelecimento             := 0;
          QualificacaoEstabelecimento := 0;
          Nome                        := FieldByName('NOME_EMP').AsString;
          EndLogradouro               := FieldByName('ENDERECO_PESSOA_END').AsString;
          EndNum                      := FieldByName('NUMERO_PESSOA_END').AsString;
          EndComplemento              := FieldByName('COMPLEMENTO_PESSOA_END').AsString;
          Endereco                    := FieldByName('ENDERECO_PESSOA_END').AsString +
            TrimRight(' ' + FieldByName('NUMERO_PESSOA_END').AsString) +
            TrimRight(' ' + FieldByName('COMPLEMENTO_PESSOA_END').AsString);
          CidadeCodMunicipio            := FieldByName('CODMUNICIPIO_CIDADE').AsInteger;
          CidadeCod                     := FieldByName('CIDADE_PESSOA_END').AsInteger;
          CidadeNome                    := FieldByName('DESCRICAO_CIDADE').AsString;
          UF                            := FieldByName('SIGLA_UF').AsString;
          UFCod                         := FieldByName('UF_CIDADE').AsInteger;
          Bairro                        := FieldByName('BAIRRO_PESSOA_END').AsString;
          Cep                           := FieldByName('CEP_PESSOA_END').AsString;
          IndustriaComercioConfeccao    := FieldByName('INDCOM_EMP').AsInteger;
          TaxaJurosBordero              := FieldByName('ALQJURBORDERO_EMP').AsCurrency;
          TaxaJurosReceber              := FieldByName('ALQJURRECEBER_EMP').AsCurrency;
          TaxaJurosCheque               := FieldByName('ALQJURCHEQUE_EMP').AsCurrency;
          TaxaJurosBoleta               := FieldByName('ALQJURBOLETA_EMP').AsCurrency;
          ValorMaximoCheques            := FieldByName('VLRMAXIMOCHQUE_EMP').AsCurrency;
          AliquotaISSQN                 := FieldByName('ALQISSQN_EMP').AsCurrency;
          AliquotaPIS                   := FieldByName('ALQPIS_EMP').AsCurrency;
          AliquotaCOFINS                := FieldByName('ALQCOFINS_EMP').AsCurrency;
          AliquotaSIMPLES               := FieldByName('ALQSIMPLES_EMP').AsCurrency;
          AliquotaIR                    := FieldByName('ALQIR_EMP').AsCurrency;
          AliquotaCTR                   := FieldByName('ALQCTS_EMP').AsCurrency;
          AliquotaAproveitamentoCredito := FieldByName('ALQAPROVEITAMENTOICMS_EMP').AsCurrency;
          Natureza                      := FieldByName('TIPO_PESSOA').AsString;
          CNPJ                          := FieldByName('CNPJCEI_PESSOA_JUR').AsString;
          CPF                           := FieldByName('CPF_PESSOA_FIS').AsString;
          InscricaoEstadual             := FieldByName('INSCRICAO_PESSOA_JUR').AsString;
          InscricaoMunicipal            := FieldByName('INSCRICAOMUNICIPAL_PESSOA_JUR').AsString;
          EMail                         := FieldByName('EMAIL_PESSOA_EMAIL').AsString;
          CRT                           := FieldByName('CRT_EMP').AsInteger;
          RegimeApuracao                := FieldByName('REGIME_APURACAO_EMP').AsInteger;
          OptanteSimples                := FieldByName('CRT_EMP').AsInteger = 1;
          Pessoa                        := FieldByName('PESSOA_EMP').AsInteger;
          RegimeTributacaoMunicipal     := FieldByName('REGIME_TRIBUTACAO_MUNICIPAL_EMP').AsInteger;

          Site := FieldByName('HOMEPAGE_PESSOA').AsString;
          Fone := FieldByName('FONE').AsString;
          Fax  := FieldByName('FAX').AsString;

          DataFechamentoFiscal := FieldByName('FECHAMENTO_FISCAL_EMP').AsDateTime;
          NIRE                 := FieldByName('NIRE_EMP').AsString;
          DataNIRE             := TFuncoesData.MaiorData(FieldByName('DATA_ARQ_EMP').AsDateTime, FieldByName('DATA_ARQ_CONV_EMP').AsDateTime);
        end;
      end;
    end;

    if SecaoAtual.Sistema <> cSistemaCaixa then
    begin
{$REGION 'Parâmetro da Empresa'}
      SQL      := Trim(TClassConfigSistemaEmp.SQLBaseCadastro);
      SQL      := TFuncoesString.CorteAte(SQL, 'where', False);
      SQL      := SQL + 'where CONFIG_SISTEMA_EMPRESA.EMPRESA_CFSEMP = ' + IntToStr(SecaoAtual.Empresa.Codigo);
      CDS.Data := ExecuteReader(SQL, -1, True);

      with CDS, SecaoAtual.Parametro do
      begin
        LancaVariacaoDetalheEntrada    := False;
        LancaCorDetalheEntrada         := False;
        LancaAcabamentoDetalheEntrada  := False;
        LancaGradeDetalheEntrada       := False;
        LancaVariacaoDetalheSaida      := (Variacao) and (FieldByName('DIG_VARIACAOSAIDA_CFSEMP').AsInteger = 1);
        LancaCorDetalheSaida           := (Cor) and (FieldByName('DIG_CORSAIDA_CFSEMP').AsInteger = 1);
        LancaAcabamentoDetalheSaida    := (Acabamento) and (FieldByName('DIG_ACABAMENTOSAIDA_CFSEMP').AsInteger = 1);
        LancaGradeDetalheSaida         := (Grade) and (FieldByName('DIG_GRADESAIDA_CFSEMP').AsInteger = 1);
        TipoDescVariacao               := FieldByName('ITEM_DESC_VARIACAO_CFSEMP').AsInteger;
        TipoDescCor                    := FieldByName('ITEM_DESC_COR_CFSEMP').AsInteger;
        TipoDescAcabamento             := FieldByName('ITEM_DESC_ACABAMENTO_CFSEMP').AsInteger;
        CentavosNaPrimeiraParcelaIdeal := (FieldByName('CENTAVOSPARCELA1IDEAL_CFSEMP').AsString = 'S');
        CentavosNaPrimeiraParcelaAtual := (FieldByName('CENTAVOSPARCELA1ATUAL_CFSEMP').AsString = 'S');
        FormaCalculoDuplicataIPI       := FieldByName('RATEIODUPLICATAIPI_CFSEMP').AsInteger;
        FormaCalculoDuplicataDespesas  := FieldByName('RATEIODUPLICATADESP_CFSEMP').AsInteger;
        FormaCalculoDuplicataST        := FieldByName('RATEIODUPLICATAST_CFSEMP').AsInteger;
        CarregaPerfilConfig(PerfilEntrada, FieldByName('PERFILENTRADA_CFSEMP').AsInteger);
        CarregaPerfilConfig(PerfilSaida, FieldByName('PERFILSAIDA_CFSEMP').AsInteger);
        DetalhamentoEntrada                                          := False;
        DetalhamentoSaida                                            := (LancaVariacaoDetalheSaida or LancaCorDetalheSaida or LancaAcabamentoDetalheSaida or LancaGradeDetalheSaida);
        LancaPrecoDetalheEntrada                                     := False;
        LancaPrecoDetalheSaida                                       := (DetalhamentoSaida) and (FieldByName('DIG_PRECOSAIDA_CFSEMP').AsInteger = 1);
        FormulaPadraoCusto                                           := FieldByName('FORMULAPADRAOCUSTO_CFSEMP').AsInteger;
        TipoCalculoCustoMedio                                        := FieldByName('TIPO_CALC_CUSTOMEDIO_CFSEMP').AsInteger;
        AgruparTemposDeProcessosEmRegistroDeSetoresNaApuracaoDeCusto := FieldByName('AGRTEMPROCREGSETORAPCUST_CFSEMP').AsString = 'S';

        FormulaFormatoDuplicata       := FieldByName('FORMULAFORMATODUP_CFSEMP').AsString;
        BloqueioAutomaticoPedido      := (FieldByName('BLOQ_PEDIDO_CFSEMP').AsString = 'S');
        BloqueioAutomaticoAssistencia := (FieldByName('BLOQ_ASSISTENCIA_CFSEMP').AsString = 'S');
        PercCalculoICMSFreteAutonomo  := FieldByName('PERCCALCULOICMSFRETE_CFSEMP').AsCurrency;
        DataIniIsencaoICMSFrete       := FieldByName('DTINIISENCAOFRETEMG_CFSEMP').AsDateTime;
        DataFimIsencaoICMSFrete       := FieldByName('DTFIMISENCAOFRETEMG_CFSEMP').AsDateTime;
        DataIniIsencaoICMSIntFrete    := FieldByName('DTINIISENCAOFRETEINTER_CFSEMP').AsDateTime;
        DataFimIsencaoICMSIntFrete    := FieldByName('DTFIMISENCAOFRETEINTER_CFSEMP').AsDateTime;

        TransacaoVenda       := FieldByName('TRANSACAOPADRAO_VENDA_CFSEMP').AsInteger;
        TransacaoAssistencia := FieldByName('TRANSACAOPADRAO_ASSIST_CFSEMP').AsInteger;
        TransacaoConsignacao := FieldByName('TRANSACAOPADRAO_CONSIG_CFSEMP').AsInteger;

        TransacaoDevolucaoVendas      := FieldByName('TRANSACAOPADRAO_DEVOLUC_CFSEMP').AsInteger;
        TransacaoDevolucaoAssistencia := FieldByName('TRANSACAOPADRAO_DEVASS_CFSEMP').AsInteger;
        TransacaoDevolucaoConsignacao := FieldByName('TRANSACAOPADRAO_DEVCON_CFSEMP').AsInteger;
        TransacaoCoberturaConsignacao := FieldByName('TRANSACAOPADRAO_COBCON_CFSEMP').AsInteger;

        TransacaoTerceirizacaoEnvio          := FieldByName('TRANSACAOPADRAO_TERCENV_CFSEMP').AsInteger;
        TransacaoTerceirizacaoRetorno        := FieldByName('TRANSACAOPADRAO_TERCRET_CFSEMP').AsInteger;
        TransacaoEntradaTerceirizacaoEnvio   := FieldByName('TRANSACAOPADRAO_ETERENV_CFSEMP').AsInteger;
        TransacaoEntradaTerceirizacaoRetorno := FieldByName('TRANSACAOPADRAO_ETERRET_CFEMP').AsInteger;
        TransacaoDevolucaoCompra             := FieldByName('TRANSACAOPADRAO_DEVFOR_CFSEMP').AsInteger;
        TransacaoEntradaConhecTransporte     := FieldByName('TRANSACAOPADRAO_CTRC_ENT_CFSEMP').AsInteger;
        TransacaoVendaEntregaFutura          := FieldByName('TRANSACAOPADRAO_VENDAFUT_CFSEMP').AsInteger;
        TransacaoOrigVendaEntregaFutura      := FieldByName('TRANSACAOPADRAO_ENTRVFUT_CFSEMP').AsInteger;
        TransacaoTransferenciaOrigem         := FieldByName('TRANSACAOPADRAO_TRORIG_CFSEMP').AsInteger;
        TransacaoTransferenciaDestino        := FieldByName('TRANSACAOPADRAO_TRDEST_CFSEMP').AsInteger;
        TransacaoPDVECF                      := FieldByName('TRANSACAOPADRAO_PDVECF_CFSEMP').AsInteger;

        TransacaoCTRCFreteCIF := FieldByName('TRANSACAOCTRCFRETECIF_CFSEMP').AsInteger;
        TransacaoCTRCFreteFOB := FieldByName('TRANSACAOCTRCFRETEFOB_CFSEMP').AsInteger;

        TransacaoPadraoServico := FieldByName('TRANSACAOPADRAO_SERVICO_CFSEMP').AsInteger;

        MsgmOptanteSimples            := FieldByName('MSG_OPTANTESIMPLES_CFEMP').AsInteger;
        MsgmAprovCredito              := FieldByName('MSG_APROVCREDITO_CFEMP').AsInteger;
        MsgmICMSST                    := FieldByName('MSG_ICMSST_CFEMP').AsInteger;
        MsgmAliquotaReduzida          := FieldByName('MSG_ALIQREDUZIDA_CFEMP').AsInteger;
        MsgmBaseCalcReduzida          := FieldByName('MSG_BASECALCREDUZIDA_CFEMP').AsInteger;
        MsgmTranspPropria             := FieldByName('MSG_TRANSPPROPRIA_CFEMP').AsInteger;
        MsgmTomador                   := FieldByName('MSG_TOMADOR_CFEMP').AsInteger;
        MsgmFreteCIF                  := FieldByName('MSG_FRETECIF_CFEMP').AsInteger;
        MsgmTranspAutonomo            := FieldByName('MSG_TRANSPAUTONOMO_CFEMP').AsInteger;
        MsgmVlrICMSFrete              := FieldByName('MSG_VLRFRETEICMS_CFEMP').AsInteger;
        MsgmIsencaoFrete              := FieldByName('MSG_ISENCAOFRETE_CFEMP').AsInteger;
        MsgmIsencaoFreteInterestadual := FieldByName('MSG_ISENCAOFRETEINT_CFEMP').AsInteger;
        MsgmVlrTotTributos            := FieldByName('MSG_VLRTOTALTRIBUTOS_CFEMP').AsInteger;
        MsgmInfSuframa                := FieldByName('MSG_INFSUFRAMA_CFEMP').AsInteger;
        MsgmNfComplementar            := FieldByName('MSG_NFCOMPLEMENTAR_CFEMP').AsInteger;
        MsgmNfDevolucao               := FieldByName('MSG_NFDEVOLUCAO_CFEMP').AsInteger;
        MsgmNfCobConsignacao          := FieldByName('MSG_NFCOBCONSIGNACAO_CFEMP').AsInteger;
        MsgmNfEstorno                 := FieldByName('MSG_NFESTORNO_CFEMP').AsInteger;
        MsgmNfReferenciada            := FieldByName('MSG_NFREFERENCIADA_CFEEMP').AsInteger;
        MsgmSimplesFaturamento        := FieldByName('MSG_SIMPLESFATURAMENTO_CFEMP').AsInteger;
        MsgmICMSPartilha              := FieldByName('MSG_ICMSPARTILHA_CFSEMP').AsInteger;

        CalculoVolumeNF             := FieldByName('CALCULOVOLUMENF_CFSEMP').AsInteger;
        CalculoPesoNF               := FieldByName('CALCULOPESONF_CFSEMP').AsInteger;
        CalculoVolumePelaComposicao := FieldByName('VOL_PORCOMPOSICAO_CFSEMP').AsInteger;
        VolsComFixaAssist_MP_MC_PC  := (FieldByName('VOL_ASS_QTDE_FIXA_CFSEMP').AsString = 'S');
        QtdeVolsFixaAssistencia     := FieldByName('QTDE_FIXA_VOLUMES_CFSEMP').AsInteger;
        VolumeSempreDigitado        := (FieldByName('VOL_SEMPREDIGITADO_CFSEMP').AsString = 'S');

        MarcaVolumes            := FieldByName('MARCA_CFSEMP').AsString;
        EspecieVolumes          := FieldByName('ESPECIE_CFSEMP').AsString;
        OrigemManual            := FieldByName('ORIGEMPADRAO_MANUAL_CFSEMP').AsInteger;
        OrigemSite              := FieldByName('ORIGEMPADRAO_SITE_CFSEMP').AsInteger;
        OrigemIntegracao        := FieldByName('ORIGEMPADRAO_INTEGRACAO_CFSEMP').AsInteger;
        OrigemMobile            := FieldByName('ORIGEMPADRAO_MOBILE_CFSEMP').AsInteger;
        ClassificacaoPadrao_Ped := FieldByName('CLASSIFICACAOPADRAO_PED_CFSEMP').AsInteger;
        ClassificacaoPadrao_Ass := FieldByName('CLASSIFICACAOPADRAO_ASS_CFSEMP').AsInteger;
        ClassificacaoPadrao_Con := FieldByName('CLASSIFICACAOPADRAO_CON_CFSEMP').AsInteger;

        CodFormulaFreteEmbutido := FieldByName('FORMULA_FRETE_EMB_CFSEMP').AsInteger;
        CodFormulaFreteIdeal    := FieldByName('FORMULA_FRETE_IDEAL_CFSEMP').AsInteger;
        CodFormulaFreteAtual    := FieldByName('FORMULA_FRETE_ATUAL_CFSEMP').AsInteger;

        BloqueiaCargaNaoReservada        := (FieldByName('BLOQ_CARGA_SEMRESERVA_CFSEMP').AsString = 'S');
        BloqueiaFaturamentoCargaSemRCPE  := (FieldByName('BLOQ_FAT_CARGA_SEMRCPE_CFSEMP').AsString = 'S');
        BloqCargasNaoConferidas          := (FieldByName('FAT_BLOQCARGANAOCONF_CFSEMP').AsString = 'S');
        BloqDocumentosNaoConferidos      := (FieldByName('FAT_BLOQDOCNAOCONF_CFSEMP').AsString = 'S');
        MovEstDataEmissao                := (FieldByName('FAT_MOVESTDATAEMISSAO_CFSEMP').AsString = 'S');
        MovFinDataEmissao                := (FieldByName('FAT_MOVFINDATAEMISSAO_CFSEMP').AsString = 'S');
        DeduzIPIReceber                  := (FieldByName('FAT_DEDUZIPIRECEBER_CFSEMP').AsString = 'S');
        SempreLancarIPIcomoDesconto      := (FieldByName('FAT_LANCARIPIDESCONTO_CFSEMP').AsString = 'S');
        DtInicialCalculoICMSPartilha     := FieldByName('FAT_DTINI_ICMSPARTILHA_CFSEMP').AsDateTime;
        DtInicialCalculoICMSPartilhaCTE  := FieldByName('FAT_DTINI_ICMSPART_CTE_CFSEMP').AsDateTime;
        DespesasIntegramIPI              := (FieldByName('DESP_COMPOEBASEIPI_CFSEMP').AsString = 'S');
        IPIIntegraST                     := (FieldByName('IPI_INTEGRA_ST_CFSEMP').AsString = 'S');
        DescontoIntegraST                := (FieldByName('DESCONTO_INTEGRA_ST_CFSEMP').AsString = 'S');
        GravarOutrasIsentoIPI            := FieldByName('ISENTO_OUTRAS_IPI_CFSEMP').AsInteger;
        GravarOutrasIsentoICMS           := FieldByName('ISENTO_OUTRAS_ICMS_CFSEMP').AsInteger;
        GravarValorIPIIsentoOutrasICMS   := FieldByName('IPI_ISENTO_OUTRAS_ICMS_CFSEMP').AsInteger;
        TipoCalculoTotalImpostoNF        := FieldByName('TIPOCALCTOTALTRIBUTOS_CFSEMP').AsInteger;
        FazMovContrapartida              := (FieldByName('FAT_MOVCONTRAPARTIDA_CFSEMP').AsString = 'S');
        GerarDuplicFreteNoFaturamento    := (FieldByName('FATURA_GERA_DUPLIC_FRETE_CFSEMP').AsString = 'S');
        ConsideraDiasParaEntregaDupFrete := (FieldByName('CONS_DIASENT_DUP_FRETE_CFSEMP').AsString = 'S');
        PercValorMovContrapartida        := FieldByName('FAT_CUSTOMOVCPARTIDA_CFSEMP').AsCurrency;
        OrdemImpressaoItemNF             := FieldByName('FAT_ORDEMIMPRESSAONF_CFSEMP').AsInteger;
        AtribuicaoEmpCarga               := FieldByName('FAT_ATRIBUICAOEMPFAT_CFSEMP').AsInteger;
        UtilizaRCPE                      := (FieldByName('RCPE_UTILIZARCPE_CFSEMP').AsString = 'S');
        RCPE_GeraOPEntradaProducao       := (FieldByName('RCPE_GERAOP_ENTPROD_CFSEMP').AsString = 'S');
        RCPE_SaidaMPporRequisicao        := (FieldByName('RCPE_SAIDA_MP_REQ_CFSEMP').AsString = 'S');
        RCPE_DataGerarSaidaMP            := FieldByName('RCPE_DTSAIDAMP_CFSEMP').AsInteger;
        RCPE_GerarOPFechamentoCarga      := (FieldByName('RCPE_GERAOP_FCARGA_CFSEMP').AsString = 'S');
        RCPE_ComponentesItemCarga        := FieldByName('RCPE_COMP_ITENS_CARGA_CFSEMP').AsInteger;
        RCPE_TrocaItemFamiliaCarga       := FieldByName('RCPE_FAMILIA_CARGA_CFSEMP').AsInteger;
        RCPE_DataConclusaoOP             := FieldByName('RCPE_CONCLUSAOOP_CFSEMP').AsInteger;

        UnidFabrilPadrao_Compra   := FieldByName('UNIDFABRILPADRAO_COMPRA_CFSEMP').AsInteger;
        UnidFabrilPadrao_Venda    := FieldByName('UNIDFABRILPADRAO_VENDA_CFSEMP').AsInteger;
        PrazoPadraoDuplicataFrete := FieldByName('PRAZO_PADRAO_FRETE_CFSEMP').AsInteger;
        OpcaoFrete                := FieldByName('OPCAOFRETE_CFSEMP').AsInteger;
        DeduzICMSBasePISCOFINS    := (FieldByName('FAT_DEDUZICMSBASEPISCOF_CFSEMP').AsString = 'S');

        // Comissao
        Comissao_Separa1_12Avos             := (FieldByName('COM_SEPARA1_12AVOS_CFSEMP').AsString = 'S');
        Comissao_Paga1_12Avos               := (FieldByName('COM_PAGA1_12AVOS_CFSEMP').AsString = 'S');
        Comissao_PercProporcional_11_12Avos := (FieldByName('COM_PERC_PROPORCIONAL_CFSEMP').AsString = 'S');
        Comissao_CalculaIRRF                := (FieldByName('COM_CALCULA_IRRF_CFSEMP').AsString = 'S');
        Comissao_DeduzIRRF_ValorReceber     := (FieldByName('COM_DEDUZ_IRRF_CFSEMP').AsString = 'S');
        Comissao_IRRF_Comissao              := FieldByName('COM_IRRF_COMISSAO_CFSEMP').AsCurrency;
        Comissao_IRRF1_12Avos               := FieldByName('COM_IRRF1_12AVOS_CFSEMP').AsCurrency;
        Comissao_IRRF_ValorMinimo           := FieldByName('COM_IRRF_VALORMINIMO_CFSEMP').AsCurrency;
        Comissao_IRRF1_12AvosValorMinimo    := FieldByName('COM_IRRF1_12AVOSMINIMO_CFSEMP').AsCurrency;
        Comissao_Adiciona1_12Avos           := (FieldByName('COM_ADICIONA1_12AVOS_CFEMP').AsString = 'S');
        Comissao_GeraDup_12Avos             := (FieldByName('COM_GERADUP_12AVOS_CFEMP').AsString = 'S');

        Comissao_PisCofinsCsll_Comissao := FieldByName('COM_PISCOFINS_COMISSAO_CFSEMP').AsCurrency;
        Comissao_PisCofinsCsll1_12Avos  := FieldByName('COM_PISCOFINS1_12AVOS_CFSEMP').AsCurrency;

        // Contabilidade
        CTB.TabPlanoContaPadrao := FieldByName('CTB_TABELA_PLANO_CFSEMP').AsInteger;
        SQL                     :=
          'select CTB_TAB_PLANOCONTAS.MASCARA_TABPLACTA ' + #13 +
          '  from CTB_TAB_PLANOCONTAS ' + #13 +
          ' where CTB_TAB_PLANOCONTAS.CODIGO_TABPLACTA = ' + IntToStr(CTB.TabPlanoContaPadrao);
        CTB.MascaraPlanoContaPadrao := ExecuteScalar(SQL, True);

        // Pedido de Compra
        BloqueioAutomaticoPedidoCompra := (FieldByName('PDC_BLOQ_PEDIDOCOMPRA_CFSEMP').AsString = 'S');

        DFe_SSLLib             := FieldByName('DFE_WS_SSLLIB_CFSEMP').AsInteger;
        DFe_Http               := FieldByName('DFE_WS_HTTPLIB_CFSEMP').AsInteger;
        DFe_Crypt              := FieldByName('DFE_WS_CRYPTLIB_CFSEMP').AsInteger;
        DFe_XMLSign            := FieldByName('DFE_WS_XMLSIGNLIB_CFSEMP').AsInteger;
        DFe_CertificadoArquivo := FieldByName('NFE_ARQ_CERTIFICADO_CFSEMP').AsString;

        // NF-e
        NFe_Ambiente     := FieldByName('NFE_AMBIENTE_CFSEMP').AsInteger;
        CTe_Ambiente     := FieldByName('CTE_AMBIENTE_CFSEMP').AsInteger;
        MDFe_Ambiente    := FieldByName('MDFE_AMBIENTE_CFSEMP').AsInteger;
        AbrirDANFEGerado := (FieldByName('NFE_ABRIRDANFEGERADO_CFSEMP').AsString = 'S');
        if (FieldByName('NFE_AMBIENTE_CFSEMP').AsInteger = 1) then // Produção
          OrgaoConsultaDisponibilidadeNFe := FieldByName('NFE_ORGAOCONSULT_PRODUC_CFSEMP').AsInteger
        else if (FieldByName('NFE_AMBIENTE_CFSEMP').AsInteger = 2) then // Homologação
          OrgaoConsultaDisponibilidadeNFe := FieldByName('NFE_ORGAOCONSULT_HOMOLOG_CFSEMP').AsInteger
        else
          OrgaoConsultaDisponibilidadeNFe := 0;

        // CT-e
        if (FieldByName('CTE_AMBIENTE_CFSEMP').AsInteger = 1) then // Produção
          OrgaoConsultaDisponibilidadeCTe := FieldByName('CTE_ORGAOCONSULT_PRODUC_CFSEMP').AsInteger
        else if (FieldByName('CTE_AMBIENTE_CFSEMP').AsInteger = 2) then // Homologação
          OrgaoConsultaDisponibilidadeCTe := FieldByName('CTE_ORGAOCONSULT_HOMOLOG_CFSEMP').AsInteger
        else
          OrgaoConsultaDisponibilidadeCTe := 0;

        if (FieldByName('MDFE_AMBIENTE_CFSEMP').AsInteger = 1) then // Produção
          OrgaoConsultaDisponibilidadeMDFe := FieldByName('MDFE_ORGAOCONS_PRODUC_CFSEMP').AsInteger
        else if (FieldByName('MDFE_AMBIENTE_CFSEMP').AsInteger = 2) then // Homologação
          OrgaoConsultaDisponibilidadeMDFe := FieldByName('MDFE_ORGAOCONS_HOMOLOG_CFSEMP').AsInteger
        else
          OrgaoConsultaDisponibilidadeMDFe := 0;

        NFe_TipoImpressaoDANFE        := FieldByName('NFE_DANFE_MODOIMPRESSAO_CFSEMP').AsInteger;
        NFe_CompartilhamentoViaEmail  := FieldByName('NFE_COMPARTILHAVIA_EMAIL_CFSEMP').AsInteger;
        NFe_CompartilharDanfeViaEmail := (FieldByName('NFE_DANFE_ENVIARVIAEMAIL_CFSEMP').AsString = 'S');
        NFe_EnviaEmailConsultor       := (FieldByName('NFE_ENVIAEMAIL_CONSULTOR_CFSEMP').AsString = 'S');
        NFe_NumeroSerieCertificado    := FieldByName('NFE_CERTIFICADO_CFSEMP').AsString;
        NFe_SenhaCertificado          := FieldByName('NFE_SENHACERTIFICADO_CFSEMP').AsString;
        NFe_FusoHorario               := FieldByName('NFE_FUSOHORARIO_CFEMP').AsInteger;

        // Estampa fiscal no formulário de seguranca
        NFe_FSDS_EstampaFiscal         := (FieldByName('NFE_FSDA_ESPAMPAFISCAL_CFSEMP').AsString = 'S');
        NFe_FSDS_EstampaFiscalAlturaCM := FieldByName('NFE_FSDA_ESTAMPAFISC_ALT_CFSEMP').AsCurrency;

        // Picote serrilhado - se tiver, vai imprimir o local em branco
        NFe_FSDS_PicoteDestacar         := (FieldByName('NFE_FSDA_PICOTEDESTACAR_CFSEMP').AsString = 'S');
        NFe_FSDS_PicoteDestacarAlturaCM := FieldByName('NFE_FSDA_PICOTE_ALT_CFSEMP').AsCurrency;

        NFe_DANFE_AbrirComProgPadrao      := FieldByName('NFE_DANFE_ABREPROGPADRAO_CFSEMP').AsString = 'S';
        NFe_DANFE_ManterPDFGerado         := FieldByName('NFE_DANFE_MANTERPDF_CFSEMP').AsString = 'S';
        NFe_XML_SalvarPeloMesDeEmissao    := FieldByName('NFE_XML_SALVARMESEMISSAO_CFSEMP').AsString = 'S';
        NFe_CompartSiteAutomatico         := FieldByName('NFE_XML_ENVIARSITE_CFSEMP').AsString = 'S';
        NFe_SiteCompartHomologacao        := FieldByName('NFE_XML_SITEHOMOLOGACAO_CFSEMP').AsString;
        NFe_SiteCompartProducao           := FieldByName('NFE_XML_SITEPRODUCAO_CFSEMP').AsString;
        CTe_SiteCompartHomologacao        := FieldByName('CTE_XML_SITEHOMOLOGACAO_CFSEMP').AsString;
        CTe_SiteCompartProducao           := FieldByName('CTE_XML_SITEPRODUCAO_CFSEMP').AsString;
        Nfe_TempoLimiteCancelamento       := FieldByName('NFETEMPOMAXIMOCANCELA_CFSEMP').AsInteger;
        DiasBuscaRegistrosInsconsistentes := FieldByName('NFE_DIASLIMITEBUSCA_CFSEMP').AsInteger;
        NFe_SegundosAguardar              := FieldByName('NFE_SEGUNDOS_AGUARDAR_CFSEMP').AsInteger * 1000;
        // NF
        NF_ModeloPadrao := FieldByName('NF_MODELOPADRAO_CFSEMP').AsInteger;

        // MANIFESTO
        MDF_ModeloPadrao := FieldByName('MDF_MODELOPADRAO_CFSEMP').AsInteger;
        // CTRC
        CTRC_ModeloPadrao              := FieldByName('CTRC_MODELOPADRAO_CFSEMP').AsInteger;
        CTRC_GeraPagarCIF              := (FieldByName('CTRC_GERA_PAGARCIF_CFSEMP').AsString = 'S');
        CTRC_CondicaoPadrao            := FieldByName('CTRC_CONDICAOPADRAO_CFSEMP').AsInteger;
        CTRC_FormulaFreteValor         := FieldByName('CTRC_FORM_FRETEVALOR_CFEMP').AsInteger;
        CTRC_FormulaFretePeso          := FieldByName('CTRC_FORM_FRETEPESO_CFEMP').AsInteger;
        CTRC_ItemDeServicoDeTransporte := FieldByName('CTRC_ITEM_SERVICO_CFEMP').AsInteger;
        CTRC_ProdutoPredominante       := FieldByName('CTRC_PRODPREDOMINANTE_CFSEMP').AsString;
        CTRC_OutrasCaracteristicas     := FieldByName('CTRC_OUTCARAC_CFSEMP').AsString;
        CTRC_ExcluiDuplicataFR         := (FieldByName('CTRC_EXCLUI_DUPLICATA_FR_CFEMP').AsString = 'S');

        // SERVICO: 8641
        Fat_MovimentaCX_NF_AVista                := (FieldByName('FAT_MOVCX_VISTA_CFSEMP').AsString = 'S');
        Fat_CC_MovimentoCX_NF_AVistaApresentacao := (FieldByName('FAT_CC_MOVCX_VP_CFSEMP').AsInteger);
        Fat_ImprimeTelefoneNaNotaFiscal          := (FieldByName('FAT_IMP_TEL_NF_CFSEMP').AsString = 'S');

        BloqueioAlteracaoLivroFiscal   := FieldByName('LF_BLOQUEIO_ALTERACAO_CFSEMP').AsInteger;
        BloqueioAlteracaoContabilidade := FieldByName('CTB_BLOQUEIO_ALTERACAO_CFSEMP').AsInteger;
        UtilizaExclusividadeDeProdutos := (FieldByName('UTILIZACONTROLEEXCLUSIV_CFSEMP').AsString = 'S');

        EmpresaMovEstoque := FieldByName('EMP_MOVESTOQUE_QUAEXTRA_CFSEMP').AsInteger;
        if (EmpresaMovEstoque = 0) then
          EmpresaMovEstoque := SecaoAtual.Empresa.Codigo;

        // e-mail
        if FieldByName('CONFIG_EMAIL_NFE_CFSEMP').AsInteger > 0 then
          CarregaEmail(FieldByName('CONFIG_EMAIL_NFE_CFSEMP').AsInteger, EmailNFe)
        else if EmailGeral.Codigo > 0 then
        begin
          EmailNFe               := EmailGeral;
          EmailNFe.NomeRemetente := SecaoAtual.Empresa.Nome;
        end
        else
        begin
          with EmailNFe do
          begin
            Codigo         := 9999999;
            Descricao      := 'TEK-SYSTEM';
            NomeRemetente  := SecaoAtual.Empresa.Nome;
            EmailRemetente := 'nfe@teksystem.com.br'; // conta remetente -==>> CONTA DA TEK SYSTEM, MESMO USUARIO, MESMO REMETENTE ??
            SmtpHost       := 'mail.teksystem.com.br';
            SmtpPort       := 25;
            User           := 'nfe@teksystem.com.br';
            Password       := 'nfe5787';
            SSL            := False;
            TLS            := False;

            { * } // MARLON: trecho abaixo será removido quando os clientes fizerem adequação ao novo formato de configuração
            EmailRemetente := FieldByName('NFE_REMETENTE_CONTA_CFSEMP').AsString;
            Copia          := FieldByName('NFE_REMETENTE_COPIA_CFSEMP').AsString;
            if FieldByName('NFE_REMETENTE_PROPRIO_CFSEMP').AsString = 'S' then
            begin
              SmtpHost := FieldByName('NFE_REMETENTE_HOST_CFSEMP').AsString;
              SmtpPort := FieldByName('NFE_REMETENTE_PORT_CFSEMP').AsInteger;
              User     := FieldByName('NFE_REMETENTE_USERNAME_CFSEMP').AsString;
              Password := FieldByName('NFE_REMETENTE_PASSWORD_CFSEMP').AsString;
              TLS      := (FieldByName('NFE_REMETENTE_REQAUT_CFSEMP').AsString = 'S');
              SSL      := (FieldByName('NFE_REMETENTE_SEGURO_CFSEMP').AsString = 'S');
            end;
            // -- \\
          end;
        end;
        ContaCopiaEmailNFE := FieldByName('CONTACOPIAEMAILNFE_CFSEMP').AsString;

        if FieldByName('CONFIG_EMAIL_SITE_CFSEMP').AsInteger > 0 then
          CarregaEmail(FieldByName('CONFIG_EMAIL_SITE_CFSEMP').AsInteger, EmailSite)
        else
          EmailSite         := EmailGeral;
        ContaCopiaEmailSite := FieldByName('CONTACOPIAEMAILSITE_CFSEMP').AsString;

        if FieldByName('CONFIG_EMAIL_SAC_CFSEMP').AsInteger > 0 then
          CarregaEmail(FieldByName('CONFIG_EMAIL_SAC_CFSEMP').AsInteger, EmailSac)
        else
          EmailSac         := EmailGeral;
        ContaCopiaEmailSac := FieldByName('CONTACOPIAEMAILSAC_CFSEMP').AsString;

        ContaCopiaEmailBI   := FieldByName('CONTACOPIAEMAILBI_CFSEMP').AsString;
        ContaCopiaEmailProc := FieldByName('CONTACOPIAEMAILPROC_CFSEMP').AsString;

        // Coletor
        Coletor_TipoDoc             := FieldByName('COLETOR_TIPODOC_CFSEMP').AsInteger;
        Coletor_UsaProprioItem      := (FieldByName('COLETOR_USARPROPRIOITEM_CFSEMP').AsString = 'S');
        Coletor_AssistenciaEmbalada := (FieldByName('COLETOR_ASSISTEMBALADA_CFSEMP').AsString = 'S');
        Coletor_Sum_FiltraEmp       := (FieldByName('COLETOR_SUM_FILTRAEMP_CFSEMP').AsString = 'S');
        Coletor_Sum_FiltraUnd       := (FieldByName('COLETOR_SUM_FILTRAUND_CFSEMP').AsString = 'S');
        Coletor_Sinc_SepParcial     := (FieldByName('COLETOR_SINCSEPPARCIAL_CFSEMP').AsString = 'S');

        Coletor_Forma_Emabalagem    := FieldByName('COLETOR_FORMA_EMBALAGEM_CFSEMP').AsInteger;
        Coletor_Forma_ReqTransf     := FieldByName('COLETOR_FORMA_REQTRANSF_CFSEMP').AsInteger;
        Coletor_Forma_ConfTransf    := FieldByName('COLETOR_FORMA_CONFTRANSF_CFSEMP').AsInteger;
        Coletor_Forma_Inventario    := FieldByName('COLETOR_FORMA_INVENTARIO_CFSEMP').AsInteger;
        Coletor_Forma_RealocItem    := FieldByName('COLETOR_FORMA_REALOCITEM_CFSEMP').AsInteger;
        Coletor_Forma_RealocEnd     := FieldByName('COLETOR_FORMA_REALOCEND_CFSEMP').AsInteger;
        Coletor_Forma_EstDefeituoso := FieldByName('COLETOR_FORMA_DEFEITO_CFSEMP').AsInteger;
        Coletor_Forma_Separacao     := FieldByName('COLETOR_FORMA_SEPARACAO_CFSEMP').AsInteger;
        Coletor_Forma_Carregamento  := FieldByName('COLETOR_FORMA_CARREG_CFSEMP').AsInteger;
        Coletor_Forma_Tarefa        := FieldByName('COLETOR_FORMA_TAREFA_CFSEMP').AsInteger;

        Coletor_Emb_Na_Req   := (FieldByName('COLETOR_EMB_NA_REQ_CFSEMP').AsString = 'S');
        Coletor_Conf_Parcial := (FieldByName('COLETOR_CONF_PARCIAL_CFSEMP').AsString = 'S');
        Coletor_Bloq_Carga   := (FieldByName('COLETOR_BLOQ_CARGA_CFSEMP').AsString = 'S');
        Coletor_Carrega_Seq  := (FieldByName('COLETOR_CARREGA_SEQ_CFSEMP').AsString = 'S');

        Coletor_Carrega_Desc           := (FieldByName('COLETOR_CARREGA_DESC_CFSEMP').AsString = 'S');
        Coletor_Tar_Leitura_End        := (FieldByName('COLETOR_TAR_LEITURA_END_CFSEMP').AsString = 'S');
        Coletor_Tar_Leitura_Pal        := (FieldByName('COLETOR_TAR_LEITURA_PAL_CFSEMP').AsString = 'S');
        Coletor_Tar_Oculta_Informacoes := (FieldByName('COLETOR_TAR_OCULTA_INFOR_CFSEMP').AsString = 'S');

        Coletor_Usa_EtiquetAgrup    := (FieldByName('COLETOR_USA_ETIQTAGRUP_CFSEMP').AsString = 'S');
        Agrup_Aceita_Comp_OutrasOps := (FieldByName('AGRUP_ACEIT_OUTRASOPS_CFSEMP').AsString = 'S');
        Agrup_Emissao_Estoca        := (FieldByName('AGRUP_ESTQ_EMIS_CFSEMP').AsString = 'S');
        Agrup_Obriga_Inf_Doc        := (FieldByName('AGRUP_OBRG_INFDC_CFSEMP').AsString = 'S');

        Coletor_Tempo_Aplicacao   := FieldByName('COLETOR_TEMPO_APLICACAO_CFSEMP').AsInteger;
        Coletor_Momento_Aplicacao := FieldByName('COLETOR_MOMENTOAPLICACAO_CFSEMP').AsInteger;

        SecaoAtual.Empresa.UsaModuloFaturamento := (FieldByName('USA_MODULO_FATURAMENTO_CFSEMP').AsString = 'S');
        DFe_CertificadoDados                    := ExecuteScalar('select e.DFE_CERTIFICADO_CFSEMP from CONFIG_SISTEMA_EMPRESA e  where e.EMPRESA_CFSEMP = ' + IntToStr(SecaoAtual.Empresa.Codigo), True);

        // NFS-e
        NFSe_ModeloPadrao        := FieldByName('NFS_MODELOPADRAO_CFSEMP').AsInteger;
        NFSe_RPS_ModeloPadrao    := FieldByName('NFS_MODELOPADRAO_RPS_CFSEMP').AsInteger;
        NFSe_Ambiente            := FieldByName('NFS_AMBIENTE_CFSEMP').AsInteger;
        NFSe_Provedor            := FieldByName('NFS_PROVEDOR_CFSEMP').AsInteger;
        NFSe_DescricaoPrefeitura := FieldByName('NFS_DESCRICAOPREFEITURA_CFSEMP').AsString;

      end;

{$ENDREGION}
{$REGION 'Quanto a Bloqueio'}
      SQL :=
        'select min(BLOQUEIO.VALORMINIMOPARCELA_BLOQUEIO) VALORMINIMOPARCELA_BLOQUEIO ' + #13 +
        'from CONFIG_SISTEMA_BLOQUEIO ' + #13 +
        'left join BLOQUEIO on (BLOQUEIO.CODIGO_BLOQUEIO = CONFIG_SISTEMA_BLOQUEIO.BLOQUEIO_CFSBLOQ) ' + #13 +
        'where (CONFIG_SISTEMA_BLOQUEIO.EMPRESA_CFSBLOQ = ' + IntToStr(SecaoAtual.Empresa.Codigo) + ') ' + #13 +
        '  and (BLOQUEIO.VALORMINIMOPARCELA_BLOQUEIO > 0)';
      CDS.Data := ExecuteReader(SQL, -1, True);
      with CDS, SecaoAtual.Parametro do
        ValorMinimoParaGeracaoDeDuplicatas := FieldByName('VALORMINIMOPARCELA_BLOQUEIO').AsCurrency;
{$ENDREGION}
{$REGION 'Níveis de Composição'}
      SQL                 := TClassConfigSistemaBuscaComposicao.SQLBaseCadastro;
      CDS.Data            := ExecuteReader(SQL, -1, True);
      CDS.IndexFieldNames := 'ARQUIVO_CSP';
      with CDS, SecaoAtual.Parametro do
      begin
        SetLength(MatrizNivelBuscaComp, Length(ClassItem.DescricaoTipoArquivo));
        for iCnt                     := Low(MatrizNivelBuscaComp) to High(MatrizNivelBuscaComp) do
          MatrizNivelBuscaComp[iCnt] := -1;

        NivelMaximoBuscaComp := 0;
        First;
        while (not eof) do
        begin
          MatrizNivelBuscaComp[FieldByName('ARQUIVO_CSP').AsInteger] := FieldByName('NIVELMAXINO_CSP').AsInteger;

          if FieldByName('NIVELMAXINO_CSP').AsInteger > NivelMaximoBuscaComp then
            NivelMaximoBuscaComp := FieldByName('NIVELMAXINO_CSP').AsInteger;

          Next;
        end;
        IndexFieldNames := '';
      end;
{$ENDREGION}
{$REGION 'Produção'}
      SQL      := Trim(TClassPCP_Config.SQLBaseCadastro);
      SQL      := TFuncoesString.CorteAte(SQL, 'where', False);
      SQL      := SQL + 'where PCP_CONFIG.CODIGO_CONFIG = ' + IntToStr(SecaoAtual.Empresa.Codigo);
      CDS.Data := ExecuteReader(SQL, -1, True);
      with CDS, SecaoAtual.ConfigPCP do
      begin
        DiasPreparacao := FieldByName('DIASPREPARACAO_CONFIG').AsInteger;
        DiasProducao   := FieldByName('DIASPRODUCAO_CONFIG').AsInteger;
        HorasPorMes    := FieldByName('HORASPORMES_CONFIG').AsInteger;

        TabelaDePreparacao := FieldByName('PREPARACAO_CONFIG').AsString = 'S';

        AvisarApontamentoIncompativel      := FieldByName('AVISARAPONTAMENTOINCOMP_CONFIG').AsString = 'S';
        ApontamentoApenasPorCicloProdutivo := FieldByName('APONTAMENTO_POR_CICLO_CONFIG').AsString = 'S';

        ReaproveitaRestoBlocoEspuma                 := FieldByName('REAPROV_RESTO_BLOCO_CONFIG').AsString = 'S';
        ConsideraEstoquePecaAntesCalculoBlocoEspuma := FieldByName('CEST_PECA_CORTE_ESP_CONFIG').AsString = 'S';
        Importacao_Documento_Por                    := FieldByName('IMPORTACAO_DOCUMENTO_POR_CONFIG').AsInteger;

        ProducaoMovimentaElaboracaoVolume         := FieldByName('MOVIMENTA_ELAB_VOL_CONFIG').AsString = 'S';
        ProducaoMovimentaElaboracaoPeca           := FieldByName('MOVIMENTA_ELAB_PEC_CONFIG').AsString = 'S';
        MovimentaPecaNaOrdemDeProducao            := FieldByName('MOVIMENTA_PECA_OP_CONFIG').AsString = 'S';
        ImpedirIniciarOPSemReservaMatPrima        := FieldByName('IMPEDIRINIOPSEMRESERVAMP_CONFIG').AsString = 'S';
        EmpenharAutomaticamenteAoGerarNecessidade := FieldByName('EMPENHOAUT_NEC_CONS_CONFIG').AsString = 'S';

        ControlaMovimentoPecaOPemSetor := FieldByName('CTRLMOVPECA_OP_SETOR_CONFIG').AsString = 'S';
        ControlaEstoqueSemiAcabado     := FieldByName('CTRL_EST_SEMIACAB_CONFIG').AsString = 'S';
        CalcularNecessidadeDeInsumos   := FieldByName('CALCNECESSIDADEINSUMO_CONFIG').AsString = 'S';
        LimitarQtdeNaImportacaoPedidos := FieldByName('LIMITARQTDEIMPORTPED_CONFIG').AsString = 'S';

        KambamProcessaMatPrima := FieldByName('KAMBAM_PROCESSA_MATPRIMA_CONFIG').AsString = 'S';

        UsaItensPorVolume                   := FieldByName('USAITENSPORVOLUME_CONFIG').AsString = 'S';
        BloqueiaEntradaNoEstoqueSemInspecao := FieldByName('BLOQ_ENT_EST_LAUDO_CONFIG').AsString = 'S';

        TempoDeTrabalhoDiario := FieldByName('TEMPOTRABALHODIARIO_CONFIG').AsDateTime;

        TipoDeDivisaoDaOrdemDeProducao   := FieldByName('TIPO_ORDEM_PRODUCAO_CONFIG').AsInteger;
        FormaAnaliseEstoqueIntermediario := FieldByName('TIPOANALISEESTOQINTER_CONFIG').AsInteger;
      end;
{$ENDREGION}
    end;

    CarregaContasDisponiveisUsuario;

    SecaoAtual.Parametro.QtdEmpresasQueNaoUsamFaturamento := ExecuteScalar('select count(*) from CONFIG_SISTEMA_EMPRESA where (EMPRESA_CFSEMP > 0) and (USA_MODULO_FATURAMENTO_CFSEMP = ' + QuotedStr('N') + ')', True);

  finally
    FreeAndNil(CDS);
  end;
end;

procedure TSMConexao.CarregaConfiguracoes;
var
  CDS  : TClientDataSet;
  CDSGR: TClientDataSet;
  SQL  : string;

  procedure CarregaHistoricoESimbolo(GR: Integer; var Historico: Integer; var Simbolo: String);
  begin
    with CDSGR do
      if FindKey([GR]) then
      begin
        Historico := FieldByName('HISTORICO_GRUPORES').AsInteger;
        Simbolo   := FieldByName('SIMBOLO_GRUPORES').AsString;
      end
      else // Não pode gerar raise pois pode ser na entrada do sistema
      begin
        Historico := 0;
        Simbolo   := '+';
      end;
  end;

  function RetornaVersaoDocumento(TipoDoc: Integer): Integer;
  begin
    SQL :=
      'select first 1 V.VERSAO_CFSVIG from CONFIG_SISTEMA_VIGENCIA V' + #13 +
      'where V.TIPODOC_CFSVIG = ' + IntToStr(TipoDoc) + #13 +
      '      and V.INICIOVIGENCIA_CFSVIG <= ' + ParticularidadesBDD.VariavelDataHora + #13 +
      '      and V.FINALVIGENCIA_CFSVIG >= ' + ParticularidadesBDD.VariavelDataHora + #13 +
      'order by V.INICIOVIGENCIA_CFSVIG desc';

    Result := ExecuteScalar(SQL, True);
  end;

begin
  CDS   := TClientDataSet.Create(Self);
  CDSGR := TClientDataSet.Create(Self);
  try
    SQL      := Trim(TClassConfigSistema.SQLBaseCadastro);
    CDS.Data := ExecuteReader(SQL, -1, True);

    // Carregando todos os Grupos de Resultados
    SQL :=
      ' select' + #13 +
      '   GRUPORESULTADO.CODIGO_GRUPORES,' + #13 +
      '   GRUPORESULTADO.HISTORICO_GRUPORES,' + #13 +
      '   GRUPORESULTADO.SIMBOLO_GRUPORES' + #13 +
      ' from GRUPORESULTADO';
    CDSGR.Data            := ExecuteReader(SQL, -1, True);
    CDSGR.IndexFieldNames := 'CODIGO_GRUPORES';

    with CDS, SecaoAtual.Parametro do
    begin
      Variacao     := (FieldByName('VARIACAO_CFS').AsString = 'S');
      Cor          := (FieldByName('COR_CFS').AsString = 'S');
      Grade        := (FieldByName('GRADE_CFS').AsString = 'S');
      Almoxarifado := (FieldByName('ALMOXARIFADO_CFS').AsString = 'S');
      Lote         := (FieldByName('LOTE_CFS').AsString = 'S');
      NumeroSerie  := (FieldByName('NUMERO_SERIE_CFS').AsString = 'S');
      Fornecedor   := (FieldByName('FORNECEDOR_CFS').AsString = 'S');
      Acabamento   := (FieldByName('ACABAMENTO_CFS').AsString = 'S');

      QualificacaoExtra := FieldByName('QUALIFICACAOEXTRA_CFS').AsInteger;

      StatusInativo               := FieldByName('STATUS_INATIVO_CFS').AsInteger;
      StatusListaNegra            := FieldByName('STATUS_LISTANEGRA_CFS').AsInteger;
      StatusClienteEncerrado      := FieldByName('STATUS_ENCERRADO_CFS').AsInteger;
      StatusRecepcao              := FieldByName('STATUS_RECEPCAO_CFS').AsInteger;
      StatusDocPendente           := FieldByName('STATUS_PENDENTE_CFS').AsInteger;
      StatusDocCancelado          := FieldByName('STATUS_CANCELADO_CFS').AsInteger;
      StatusDocCanceladoParcial   := FieldByName('STATUS_CANCELADO_PARCIAL_CFS').AsInteger;
      StatusLiberado              := FieldByName('STATUS_LIBERADOBLOQUEIO_CFS').AsInteger;
      StatusEmCarga               := FieldByName('STATUS_EMCARGA_CFS').AsInteger;
      StatusFaturamentoSolicitado := FieldByName('STATUS_FATURAM_SOLICITADO_CFS').AsInteger;
      StatusFaturamentoPendente   := FieldByName('STATUS_FATURAM_PENDENTE_CFS').AsInteger;

      StatusFaturadoParcial := FieldByName('STATUS_FATURADO_PARCIAL_CFS').AsInteger;
      StatusFaturado        := FieldByName('STATUS_FATURADO_CFS').AsInteger;
      StatusNfeCompartOrgao := FieldByName('STATUS_NFE_COMP_ORGAO_CFS').AsInteger;
      StatusEmTransporte    := FieldByName('STATUS_LIB_TRANSPORTE_CFS').AsInteger;
      StatusEntregue        := FieldByName('STATUS_ENTREGUE_CFS').AsInteger;
      StatusEncProducao     := FieldByName('STATUS_ENC_PRODUCAO_CFS').AsInteger;

      ExibeNoSiteApenasObservacaoMarcadaParaEsteFim := (FieldByName('EXIBIROBSDUPLICATASITE_CFS').AsInteger = 1);

      Cx_GrupoTransfSaida   := FieldByName('CX_GRUPOTRANSFSAIDA_CFS').AsInteger;
      Cx_GrupoTransfEntrada := FieldByName('CX_GRUPOTRANSFENTRADA_CFS').AsInteger;
      Cx_GrupoOrdemPagto    := FieldByName('CX_GRUPOORDEMPAGTO_CFS').AsInteger;

      GR_ValorNominalReceber   := FieldByName('GR_VALORNOMINALRECEBER_CFS').AsInteger;
      GR_ValorNominalPagar     := FieldByName('GR_VALORNOMINALPAGAR_CFS').AsInteger;
      GR_JurosPagos            := FieldByName('GR_JUROSPAGOS_CFS').AsInteger;
      GR_JurosRecebidos        := FieldByName('GR_JUROSRECEBIDOS_CFS').AsInteger;
      GR_DescontosConcedidos   := FieldByName('GR_DESCONTOCONCEDIDO_CFS').AsInteger;
      GR_DescontosObtidos      := FieldByName('GR_DESCONTOOBTIDO_CFS').AsInteger;
      GR_NotaCredito           := FieldByName('GR_NOTACREDITO_CFS').AsInteger;
      GR_NotaDebito            := FieldByName('GR_NOTADEBITO_CFS').AsInteger;
      GR_CreditoDesconsiderado := FieldByName('GR_CREDITODESCONSIDERADO_CFS').AsInteger;
      GR_DebitoDesconsiderado  := FieldByName('GR_DEBITODESCONSIDERADO_CFS').AsInteger;
      GR_ComplementoBord_Ent   := FieldByName('GR_COMPLEMENTOBORDEROREC_CFS').AsInteger;
      GR_ComplementoBord_Sai   := FieldByName('GR_COMPLEMENTOBORDEROPAG_CFS').AsInteger;
      GR_TrocoDevolvido        := FieldByName('GR_TROCODEVOLVIDO_CFS').AsInteger;
      GR_TrocoRecebido         := FieldByName('GR_TROCORECEBIDO_CFS').AsInteger;
      GR_ProrrogacoesReceb     := FieldByName('GR_PRORROGRECEB_CFS').AsInteger;
      GR_ProrrogacoesPagas     := FieldByName('GR_PRORROGPAGA_CFS').AsInteger;
      GR_UsoDepositoCheque     := FieldByName('GR_USOOUDEPOSITOCHEQUE_CFS').AsInteger;

      GR_EmissaoCheque := FieldByName('GR_EMISSAOCHEQUE_CFS').AsInteger;

      GR_PgtoChequeDevolvido          := FieldByName('GR_PGTOCHEQDEVOLVIDO_CFS').AsInteger;
      GR_RecebtoChequeDevolvido       := FieldByName('GR_RECEBTOCHEQDEVOLVIDO_CFS').AsInteger;
      GR_OperacaoDescontoCheque       := FieldByName('GR_DESCONTOCHEQUE_CFS').AsInteger;
      GR_OperacaoDescontoDupl         := FieldByName('GR_DESCONTODUPL_CFS').AsInteger;
      GR_TarifaDoc_Desconto           := FieldByName('GR_DESCONTO_TARIFADOC_CFS').AsInteger;
      GR_TarifaOperacao_Desconto      := FieldByName('GR_DESCONTO_TARIFAOPER_CFS').AsInteger;
      GR_AbatimentoConcedido          := FieldByName('GR_ABATIMENTOCONCEDIDO_CFS').AsInteger;
      GR_AbatimentoRecebido           := FieldByName('GR_ABATIMENTORECEBIDO_CFS').AsInteger;
      GR_AcrescimoRecebido            := FieldByName('GR_ACRESCIMORECEBIDO_CFS').AsInteger;
      GR_AcrescimoPago                := FieldByName('GR_ACRESCIMOPAGO_CFS').AsInteger;
      GR_DespesaCobranca              := FieldByName('GR_DESPCOBRANCAPAGA_CFS').AsInteger;
      GR_IOFPago                      := FieldByName('GR_IOFPAGO_CFS').AsInteger;
      GR_OutrasDespesasEmCobranca     := FieldByName('GR_OUTRASDESPESASRECEB_CFS').AsInteger;
      GR_OutrasDespesasEmPagamento    := FieldByName('GR_OUTRASDESPESASPAGAS_CFS').AsInteger;
      GR_OutrosCreditosEmCobranca     := FieldByName('GR_OUTROSCREDITOSRECEB_CFS').AsInteger;
      GR_OutrasCreditosEmPagamento    := FieldByName('GR_OUTROSCREDITOSPAGOS_CFS').AsInteger;
      GR_TarifasCustasPagas           := FieldByName('GR_TARIFASCUSTASPAGAS_CFS').AsInteger;
      GR_OutrosVencimentosDP          := FieldByName('GR_OUTROSVENCIMENTOSDP_CFS').AsInteger;
      GR_OutrosDescontosDP            := FieldByName('GR_OUTROSDESCONTOSDP_CFS').AsInteger;
      GR_OutrosDescontosDP            := FieldByName('GR_OUTROSDESCONTOSDP_CFS').AsInteger;
      GR_OutrosDescontosDP            := FieldByName('GR_OUTROSDESCONTOSDP_CFS').AsInteger;
      GR_VendaAVista                  := FieldByName('GR_VENDAAVISTA_CFS').AsInteger;
      GR_VendaAPrazo                  := FieldByName('GR_VENDAAPRAZO_CFS').AsInteger;
      GR_DevolucaoVenda               := FieldByName('GR_DEVOLUCAOVENDA_CFS').AsInteger;
      GR_DevolucaoCompra              := FieldByName('GR_DEVOLUCAOCOMPRA_CFS').AsInteger;
      GR_CTRCReceberAVista            := FieldByName('GR_CTRCRECEBERAVISTA_CFS').AsInteger;
      GR_CTRCReceberAPrazo            := FieldByName('GR_CTRCRECEBERAPRAZO_CFS').AsInteger;
      GR_CTRCPagarAVista              := FieldByName('GR_CTRCPAGARAVISTA_CFS').AsInteger;
      GR_CTRCPagarAPrazo              := FieldByName('GR_CTRCPAGARAPRAZO_CFS').AsInteger;
      GR_ComissaoPagar                := FieldByName('GR_COMISSAOPAGAR_GPS').AsInteger;
      GR_Comissao1_12avosPagar        := FieldByName('GR_COMISSAOPAGAR112AVOS_CFS').AsInteger;
      GR_FreteReceber                 := FieldByName('GR_FRETERECEBER_CFS').AsInteger;
      GR_ManutencaoVeiculos_Servico   := FieldByName('GR_SERVICOVEICULO_CFS').AsInteger;
      GR_ManutencaoVeiculos_Materiais := FieldByName('GR_MATERIAISVEICULO_CFS').AsInteger;
      GR_AbastecimentoVeiculos        := FieldByName('GR_COMBUSTIVELVEICULO_CFS').AsInteger;
      GR_AdiantamentoViagem           := FieldByName('GR_ADIANTAMENTOVIAGEM_CFS').AsInteger;
      GR_ManutencaoMaquinas_Servico   := FieldByName('GR_SERVICOMAQUINA_CFS').AsInteger;
      GR_ManutencaoMaquinas_Peca      := FieldByName('GR_PECAMAQUINA_CFS').AsInteger;
      GR_PagtoDeFrete                 := FieldByName('GR_PGTOFRETE_CFS').AsInteger;
      GR_ReceitaAlienadaEmViagem      := FieldByName('GR_RECEITAALIENADAVIAGEM_CFS').AsInteger;
      GR_FreteDestinatario            := FieldByName('GR_FRETEDEST_CFS').AsInteger;
      GR_FreteEmitente                := FieldByName('GR_FRETEEMIT_CFS').AsInteger;
      GR_OutrosFretes                 := FieldByName('GR_OUTROSFRETES_CFS').AsInteger;
      GR_MultaTransito                := FieldByName('GR_MULTATRANSITO_CFS').AsInteger;
      GR_ReformaPneus                 := FieldByName('GR_REFORMAPNEUS_CFS').AsInteger;
      GR_BonuesFuturosViagens         := FieldByName('GR_BONUSFUTUROSEMVIAGEM_CFS').AsInteger;
      GR_ContratoRodoviario_IRRF      := FieldByName('GR_IRRFCONTRATRODOV_CFS').AsInteger;
      GR_ContratoRodoviario_SESTSENAT := FieldByName('GR_SESTSENATCONTRATRODOV_CFS').AsInteger;
      GR_ContratoRodoviario_INSS      := FieldByName('GR_INSSCONTRATRODOV_CFS').AsInteger;

      CarregaHistoricoESimbolo(GR_ValorNominalPagar, HistoricoValorNominalPagar, SimboloGR_ValorNominalPagar);
      CarregaHistoricoESimbolo(GR_ValorNominalReceber, HistoricoValorNominalReceber, SimboloGR_ValorNominalReceber);
      CarregaHistoricoESimbolo(GR_JurosPagos, HistoricoJurosPagos, SimboloGR_JurosPagos);
      CarregaHistoricoESimbolo(GR_JurosRecebidos, HistoricoJurosRecebidos, SimboloGR_JurosRecebidos);
      CarregaHistoricoESimbolo(GR_DescontosConcedidos, HistoricoDescontoConcedido, SimboloGR_DescontoConcedido);
      CarregaHistoricoESimbolo(GR_DescontosObtidos, HistoricoDescontoObtido, SimboloGR_DescontoObtido);
      CarregaHistoricoESimbolo(GR_NotaCredito, HistoricoNotaCredito, SimboloGR_NotaCredito);
      CarregaHistoricoESimbolo(GR_NotaDebito, HistoricoNotaDebito, SimboloGR_NotaDebito);
      CarregaHistoricoESimbolo(GR_ComplementoBord_Ent, HistoricoComplementoBord_Ent, SimboloGR_ComplementoBord_Ent);
      CarregaHistoricoESimbolo(GR_ComplementoBord_Sai, HistoricoComplementoBord_Sai, SimboloGR_ComplementoBord_Sai);
      CarregaHistoricoESimbolo(GR_TrocoDevolvido, HistoricoTrocoDevolvido, SimboloGR_TrocoDevolvido);
      CarregaHistoricoESimbolo(GR_TrocoRecebido, HistoricoTrocoRecebido, SimboloGR_TrocoRecebido);
      CarregaHistoricoESimbolo(GR_UsoDepositoCheque, HistoricoUsoDepositoCheque, SimboloGR_UsoDepositoCheque);
      CarregaHistoricoESimbolo(GR_EmissaoCheque, HistoricoEmissaoCheque, SimboloGR_EmissaoCheque);
      CarregaHistoricoESimbolo(GR_PgtoChequeDevolvido, HistoricoPgtoCheqDevolvido, SimboloGR_PgtoCheqDevolvido);
      CarregaHistoricoESimbolo(GR_ProrrogacoesReceb, HistoricoProrrogacoesReceb, SimboloGR_ProrrogacoesReceb);
      CarregaHistoricoESimbolo(GR_ProrrogacoesPagas, HistoricoProrrogacoesPagas, SimboloGR_ProrrogacoesPagas);
      CarregaHistoricoESimbolo(GR_RecebtoChequeDevolvido, HistoricoRecebtoChqDevolvido, SimboloGR_RecebtoChqDevolvido);
      CarregaHistoricoESimbolo(GR_CreditoDesconsiderado, HistoricoCreditoDesconsiderado, SimboloGR_CreditoDesconsiderado);
      CarregaHistoricoESimbolo(GR_DebitoDesconsiderado, HistoricoDebitoDesconsiderado, SimboloGR_DebitoDesconsiderado);
      CarregaHistoricoESimbolo(GR_OperacaoDescontoCheque, HistoricoDescontoCheque, SimboloGR_DescontoCheque);
      CarregaHistoricoESimbolo(GR_OperacaoDescontoDupl, HistoricoDescontoDupl, SimboloGR_DescontoDupl);
      CarregaHistoricoESimbolo(GR_TarifaDoc_Desconto, HistoricoDesconto_TarifaDoc, SimboloGR_Desconto_TarifaDoc);
      CarregaHistoricoESimbolo(GR_TarifaOperacao_Desconto, HistoricoDesconto_TarifaOperacao, SimboloGR_Desconto_TarifaOperacao);

      HistoricoTarifasBancarias := FieldByName('CX_HISTORICOTARIFABANC_CFS').AsInteger;
      HistoricoPagamentoSalario := FieldByName('CX_HISTORICOPGTOSALARIO_CFS').AsInteger;

      CDC_Vendas              := FieldByName('CDC_VENDAS_CFS').AsInteger;
      CDC_DevolucaoVendas     := FieldByName('CDC_DEVOLUCAOVENDAS_CFS').AsInteger;
      CDC_DevolucaoCompras    := FieldByName('CDC_DEVOLUCAOCOMPRAS_CFS').AsInteger;
      CDC_CTRC                := FieldByName('CDC_CTRC_CFS').AsInteger;
      CDC_Comissao            := FieldByName('CDC_COMISSAO_CFS').AsInteger;
      CDC_OutrasDespesas      := FieldByName('CDC_OUTRASDESPESAS_CFS').AsInteger;
      CDC_MultaTransito       := FieldByName('CDC_MULTATRANSITO_CFS').AsInteger;
      CDC_ManutencaoVeiculo   := FieldByName('CDC_MANUTENCAOVEICULO_CFS').AsInteger;
      CDC_ManutencaoMaquina   := FieldByName('CDC_MANUTENCAOMAQUINA_CFS').AsInteger;
      CDC_Exportacao          := FieldByName('CDC_EXPORTACAO_CFS').AsInteger;
      CDC_Financeiro          := FieldByName('CDC_FINANCEIRO_CFS').AsInteger;
      CDC_DepartamentoPessoal := FieldByName('CDC_DEPPESSOAL_CFS').AsInteger;
      CDC_AcertoFrete         := FieldByName('CDC_ACERTOFRETE_CFS').AsInteger;

      PreProduto                         := (FieldByName('PREPRODUTO_CFS').AsString = 'S');
      ValidarSaldoAtual                  := (FieldByName('VALIDASALDOMOVESTOQUEATUAL_CFS').AsString = 'S');
      ValidarSaldoIdeal                  := (FieldByName('VALIDASALDOMOVESTOQUEIDEAL_CFS').AsString = 'S');
      ValidarSaldoTerceiro               := (FieldByName('VALIDAESTOQUETERCEIRO_CFS').AsString = 'S');
      ControlaEstoqueDeVolumesDeProdutos := (FieldByName('CTRLESTOQPRODEMVOLUME_CFS').AsString = 'S');
      NecessarioAutorizarPagamentos      := (FieldByName('NECESSARIOAUTORIZARPAGTO_CFS').AsString = 'S');
      NecessarioAutorizarAdiantamentos   := (FieldByName('NECESSARIOAUTORIZARADIANT_CFS').AsString = 'S');

      AgruparTarifasBancarias                             := (FieldByName('CX_AGRUPARTARIFASBANC_CFS').AsString = 'S');
      ObrigatorioGrupoResultadoDiferenteDeZeroNaDuplicata := (FieldByName('GR_OBRIGATORIO_DUPL_CFS').AsString = 'S');
      BuscarProdutoBaseDeVolumeEmEtiquetaProducao         := (FieldByName('USAPRODUTOBASEEMVOLUME_CFS').AsString = 'S');
      OcultarDuplicataPagarSalario                        :=
        (FieldByName('OCULTARDUPLSALARIO_CFS').AsString = 'S') and
        (High(SecaoAtual.Usuario.ModulosDisp) >= cSistemaDepPessoal) and
        (not SecaoAtual.Usuario.ModulosDisp[cSistemaDepPessoal]);

      SituacaoChequeDuvidoso             := FieldByName('SITUACAOCHEQUEDUVIDOSO_CFS').AsInteger;
      AtrasoMinimoDesconsiderarDuplicata := FieldByName('ATRASOMINIMODESCONSIDDUPL_CFS').AsInteger;
      ValorMininoNotaCredito             := FieldByName('VALORMINIMONOTACREDITO_CFS').AsCurrency;
      SituacaoBloqueadoPagamento         := FieldByName('SITUACAO_BLOQUEADO_PAGTO_CFS').AsInteger;
      SituacaoBloqueadoCobranca          := FieldByName('SITUACAO_BLOQUEADO_COBR_CFS').AsInteger;

      Prorrog_MaximoDesconsiderar := FieldByName('PRORROG_MAXIMODESCONSID_CFS').AsCurrency;
      Prorrog_NominalMinimo       := FieldByName('PRORROG_NOMINALMINIMO_CFS').AsInteger;
      Prorrog_QtdMaxima           := FieldByName('PRORROG_MAXIMOQTD_CFS').AsInteger;
      Prorrog_QtdMaximaGeral      := FieldByName('PRORROG_MAXIMOQTDGERAL_CFS').AsInteger;
      Prorrog_DiasMaximo          := FieldByName('PRORROG_MAXIMODIAS_CFS').AsInteger;

      PrecoVendaPadrao       := (FieldByName('USAPRECOVENDAPADRAO_CFS').AsString = 'S');
      TabelaPorItemPedido    := (FieldByName('USATABELAPORITEM_CFS').AsString = 'S');
      UtilizaPreposto        := (FieldByName('USAPREPOSTO_CFS').AsString = 'S');
      ImprimeLogoEmpresa     := (FieldByName('IMPRIMELOGORELATORIOS_CFS').AsString = 'S');
      ExibirLogTelaPrincipal := (FieldByName('EXIBIRLOGOTELAPRINCIPAL_CFS').AsString = 'S');

      CotacaoCompraMeses    := FieldByName('COTACAOCOMPRA_MESES_CFS').AsInteger;
      CotacaoCompraQtdForn  := FieldByName('COTACAOCOMPRA_QTDFORN_CFS').AsInteger;
      BuscaDePrecoPedCompra := FieldByName('BUSCAPRECOPEDCOMPRA_CFS').AsInteger;

      ComissaoDifEmpresa     := (FieldByName('COMISSAODIFEMPRESA_CFS').AsString = 'S');
      ComissaoDifCliente     := (FieldByName('COMISSAODIFCLIENTE_CFS').AsString = 'S');
      ComissaoDifTipoProduto := (FieldByName('COMISSAODIFTIPOPRODUTO_CFS').AsString = 'S');
      ComissaoDifLinha       := (FieldByName('COMISSAODIFLINHA_CFS').AsString = 'S');
      UsaTabelaNegociacao    := (FieldByName('USATABELANEGOCIACAO_CFS').AsString = 'S');

      MascaraGrupoDeResultado := FieldByName('MASCARAGRUPORESULTADO_CFS').AsString;
      MascaraEnderecamento    := FieldByName('MASCARAENDERECO_CFS').AsString;
      MascaraNivelDocumentos  := FieldByName('MASCARADOCUMENTOS_CFS').AsString;

      WMS_Utiliza                 := FieldByName('WMS_UTILIZA_CFS').AsString = 'S';
      WMS_UtilizaPalete           := FieldByName('WMS_UTILIZAPALETE_CFS').AsString = 'S';
      WMS_PaleteMisto             := FieldByName('WMS_PALETEMISTO_CFS').AsString = 'S';
      WMS_Priorizacao_Alocacao    := FieldByName('WMS_PRIORIZACAO_ALOCACAO_CFS').AsString;
      WMS_Priorizacao_Recuperacao := FieldByName('WMS_PRIORIZACAO_RECUPERACAO_CFS').AsString;
      WMS_Priorizacao_Tarefa      := FieldByName('WMS_PRIORIZACAO_TAREFA_CFS').AsString;
      WMS_Alocacao_Fracionavel    := FieldByName('WMS_ALOCACAO_FRACIONAVEL_CFS').AsString = 'S';
      WMS_Alocacao_Enderecamento  := FieldByName('WMS_ALOCACAO_ENDERECAMENTO_CFS').AsInteger;
      WMS_Recup_Enderecamento     := FieldByName('WMS_RECUPER_ENDERECAMENTO_CFS').AsInteger;
      WMS_Suprimento_Fracionavel  := FieldByName('WMS_SUPRIMENTO_FRACIONAVEL_CFS').AsString = 'S';
      WMS_Sequencia_Tarefa        := FieldByName('WMS_SEQ_TAREFA_CFS').AsInteger;
      WMS_Aloc_Incons_Direc       := FieldByName('WMS_ALOC_INCONS_DIREC_CFS').AsString = 'S';
      WMS_Rec_Faltosa_Direc       := FieldByName('WMS_REC_FALTOSA_DIREC_CFS').AsString = 'S';
      WMS_Tar_RQ_Gera_RC          := FieldByName('WMS_TAR_RQ_GERA_RC_CFS').AsString = 'S';
      WMS_Tar_RQ_Gera_RC_Prior    := FieldByName('WMS_TAR_RQ_GERA_RC_PRIOR_CFS').AsInteger;
      WMS_Tar_RC_Gera_RA          := FieldByName('WMS_TAR_RC_GERA_RA_CFS').AsString = 'S';
      WMS_Tar_RC_Gera_RA_Prior    := FieldByName('WMS_TAR_RC_GERA_RA_PRIOR_CFS').AsInteger;
      WMS_Tar_CR_Gera_CC          := FieldByName('WMS_TAR_CR_GERA_CC_CFS').AsString = 'S';
      WMS_Tar_CR_Gera_CC_Prior    := FieldByName('WMS_TAR_CR_GERA_CC_PRIOR_CFS').AsInteger;
      WMS_Tar_CR_Abate_Aloc       := FieldByName('WMS_TAR_CR_ABATE_ALOC_CFS').AsString = 'S';
      WMS_Tar_CC_Gera_AL          := FieldByName('WMS_TAR_CC_GERA_AL_CFS').AsString = 'S';
      WMS_Tar_CC_Gera_AL_Prior    := FieldByName('WMS_TAR_CC_GERA_AL_PRIOR_CFS').AsInteger;
      WMS_Tar_RC_Por_Palete       := FieldByName('WMS_TAR_RC_POR_PALETE_CFS').AsString = 'S';
      WMS_Tar_RA_Por_Palete       := FieldByName('WMS_TAR_RA_POR_PALETE_CFS').AsString = 'S';
      WMS_Tar_CR_Por              := FieldByName('WMS_TAR_CR_POR_CFS').AsInteger;
      WMS_Tar_CA_Por_Palete       := FieldByName('WMS_TAR_CA_POR_PALETE_CFS').AsString = 'S';
      WMS_Tar_Valida_Loc_Etiqueta := FieldByName('WMS_TAR_VALIDA_LOC_ETIQUETA_CFS').AsString = 'S'; // Marlon: futuramente remover
      WMS_Tar_Bloqueio_Loc        := FieldByName('WMS_TAR_BLOQUEIO_LOC_CFS').AsInteger;
      WMS_Inv_GeraConfPalete      := FieldByName('WMS_INV_GERACONFPALETE_CFS').AsString = 'S';
      WMS_Inv_GeraConfPalete_Prio := FieldByName('WMS_INV_GERACONFPALETE_PRIO_CFS').AsInteger;
      WMS_Alocacao_ObrigaPrior    := FieldByName('WMS_ALOCACAO_OBRIGAPRIOR_CFS').AsString = 'S';
      WMS_Rec_TipoEnderecoDoca    := FieldByName('WMS_REC_TIPOENDERECODOCA_CFS').AsInteger;
      WMS_Rec_CapacidadeEm        := FieldByName('WMS_REC_CAPACIDADEEM_CFS').AsInteger;
      WMS_Rec_PorMinuto           := FieldByName('WMS_REC_PORMINUTO_CFS').AsCurrency;
      WMS_Rec_Intervalo           := FieldByName('WMS_REC_INTERVALO_CFS').AsDateTime;
      WMS_Exp_TipoEnderecoDoca    := FieldByName('WMS_EXP_TIPOENDERECODOCA_CFS').AsInteger;
      WMS_Exp_CapacidadeEm        := FieldByName('WMS_EXP_CAPACIDADEEM_CFS').AsInteger;
      WMS_Exp_PorMinuto           := FieldByName('WMS_EXP_PORMINUTO_CFS').AsCurrency;
      WMS_Exp_Intervalo           := FieldByName('WMS_EXP_INTERVALO_CFS').AsDateTime;
      WMS_Def_TipoEndereco        := FieldByName('WMS_DEF_TIPOENDERECO_CFS').AsInteger;
      WMS_Org_Perc_Analise        := FieldByName('WMS_ORG_PERC_ANALISE_CFS').AsCurrency;
      WMS_SepCar_Detalhado        := FieldByName('WMS_SEPCAR_DETALHADO_CFS').AsString = 'S';

      TipoLaudoInspecaoQualidade := FieldByName('LAUDOINSPECAOQUALIDADE_CFS').AsInteger;

      UtilizaSolicitacaoConsumo := (FieldByName('UTILIZASOLICITACAOCONSUMO_CFS').AsString = 'S');
      AtendeItensSemEmpenho     := (FieldByName('ATENDE_ITENS_SEM_EMPENHO_CFS').AsString = 'S');

      OrigemNaoConformItensProd         := FieldByName('SGQ_ORIGNCONFORINSPITEMPROD_CFS').AsInteger;
      OrigemNaoConformItensAdq          := FieldByName('SGQ_ORIGNCONFORINSPITEMADQU_CFS').AsInteger;
      OrigemNaoConformItensOutro        := FieldByName('SGQ_ORIGNCONFORINPITEMOUTRO_CFS').AsInteger;
      SGQ_DataHoraAberturaSACAutomatica := FieldByName('SGQ_DHABERT_ATEND_AUTOM_SAC_CFS').AsString = 'S';

      DP.FeriasNaoProporcionais  := (FieldByName('DP_FERIASNAOPROPORCIONAIS_CFS').AsString = 'S');
      DP.RescisaoNaoProporcional := (FieldByName('DP_RESCISAONAOPROPORCIONAL_CFS').AsString = 'S');

      DP.ModoCalculoFerias   := FieldByName('DP_MODOCALCULOFERIAS_CFS').AsInteger;
      DP.ModoCalculoRescisao := FieldByName('DP_MODOCALCULORESCISAO_CFS').AsInteger;
      DP.ModoCalculoSalario  := FieldByName('DP_MODOCALCULOSALARIO_CFS').AsInteger;

      DP.FaltasAtrasosAcumulados                       := (FieldByName('DP_FALTASACUMULADAS_CFS').AsString = 'S');
      DP.HoraFormatoSexagesimalRecibo                  := (FieldByName('DP_HORASEXAGESIMALRECIBO_CFS').AsString = 'S');
      DP.SalarioFamiliaFerias                          := (FieldByName('DP_SALARIOFAMILIAFERIAS_CFS').AsString = 'S');
      DP.ImprimirEventoFeriasReciboMensal              := (FieldByName('DP_IMPRIME_FERIAS_CFS').AsString = 'S');
      DP.ImprimirBaseIRRFComDeducoes                   := (FieldByName('DP_IMPRIMIR_IRRFCOMDEDUCOES_CFS').AsString = 'S');
      DP.CalculoDiretoDiasFeriasProporcionais          := (FieldByName('DP_CALCDIR_FERIAS_PROP_CFS').AsString = 'S');
      DP.ProrrogarPeriodoConcessivoSeExisteAfastamento := (FieldByName('DP_PRORROGA_PCF_CFS').AsString = 'S');

      ESocial.AmbienteTransmissao := FieldByName('AMBIENTE_ESOCIAL_CFS').AsInteger;

      Formato_Reserva_Automatica         := FieldByName('FORMATO_RESERVA_CFS').AsInteger;
      AlmoxarifadoPadraoPedVenda         := FieldByName('ALMOXARIFADO_PADRAO_PED_CFS').AsInteger;
      AlmoxarifadoPadraoAssisTec         := FieldByName('ALMOXARIFADO_PADRAO_ASSIST_CFS').AsInteger;
      AlmoxarifadoPadraoNecConsumo       := FieldByName('ALMOXARIFADO_PADRAO_NC_CFS').AsInteger;
      AlmoxarifadoPadraoReqTransfOrigem  := FieldByName('ALMOXARIFADO_PADRAO_REQ_ORI_CFS').AsInteger;
      AlmoxarifadoPadraoReqTransfDestino := FieldByName('ALMOXARIFADO_PADRAO_REQ_DES_CFS').AsInteger;
      DiasPrevistoParaFaturamento        := FieldByName('DIASPREVISTOFATURA_CFS').AsInteger;
      DiasPrevistoParaFaturamentoAssist  := FieldByName('DIASPREVISTOFATURA_ASSIST_CFS').AsInteger;
      AtualizaPrevFaturaNaCarga          := (FieldByName('CARGAATUALIZAPREVFATURA_CFS').AsString = 'S');

      Fat_PorUnidadeFabril := (FieldByName('FAT_PORUNIDADEFABRIL_CFS').AsString = 'S');

      RCPE_CustoItemProduzido     := FieldByName('RCPE_CUSTOITEMPROD_CFS').AsInteger;
      RCPE_CustoItemConsumido     := FieldByName('RCPE_CUSTOITEMCONS_CFS').AsInteger;
      RCPE_CustoOutros            := FieldByName('RCPE_CUSTOOUTROS_CFS').AsInteger;
      RCPE_BuscaCompItemPrincipal := (FieldByName('RCPE_COMPOSICAOITEMAJUSTE_CSF').AsString = 'S');

      NFe_InicioHorarioVerao := FieldByName('INICIOHORARIOVERAO_CFS').AsDateTime;
      NFe_FimHorarioVerao    := FieldByName('FIMHORARIOVERAO_CFS').AsDateTime;

      NFe_Versao  := RetornaVersaoDocumento(tpDocNFe);
      CTe_Versao  := RetornaVersaoDocumento(tpDocCTe);
      MDFe_Versao := RetornaVersaoDocumento(tpDocMDFe);

      OrgaoConsultaNFeAN := FieldByName('ORGAO_CONSULTANFEAN_CFS').AsInteger;
      OrgaoConsultaCTeAN := FieldByName('ORGAO_CONSULTACTEAN_CFS').AsInteger;
      OrgaoConsultaNFeUF := FieldByName('ORGAO_CONSULTANFEUF_CFS').AsInteger;
      OrgaoConsultaCTeUF := FieldByName('ORGAO_CONSULTACTEUF_CFS').AsInteger;

      DiasDeGarantiaParaAceitarAssistencia         := FieldByName('DIASGARANTIAASSIST_CFS').AsInteger;
      ValidaItemConformeItemRelacionadoAssistencia := (FieldByName('VALIDAITEMCONFORMEITEMREL_CFS').AsString = 'S');
      NumeroMaximoRegistroItensAssistencia         := FieldByName('NUMREGISTROS_ASSISTENCIA_CFS').AsInteger;

      EditarReciboDIRF := FieldByName('EDITARRECIBODIRF').AsString = 'S';

      BloquearExpiracaoGarantiaItemAssistencia    := (FieldByName('BLOQEXPIRACAOGARANTIA_CFS').AsString = 'S');
      UsaEsquemaMontagemAssistencia               := (FieldByName('USAESQUEMAMONTAGEMASS_CFS').AsString = 'S');
      ObrigatorioPreencherLoteItemAssistencia     := (FieldByName('OBRIGLOTEITEMASSIST_CFS').AsString = 'S');
      ObrigatorioPreencherEtiquetaItemAssistencia := (FieldByName('OBRIGETIQUETAITEMASSIT_CFS').AsString = 'S');
      ObrigatorioPreencherProdutoItemAssistencia  := (FieldByName('OBRIGPRODUTOITEMASSIST_CFS').AsString = 'S');
      ObrigatorioPreencherMotivoItemAssistencia   := (FieldByName('OBRIGMOTIVOITEMASSIST_CFS').AsString = 'S');
      BloquearItemDeAssistenciaDeOutroCliente     := (FieldByName('BLOQETIQOUTCLIITEMASSIST_CFS').AsString = 'S');
      ValidarAssistenciaRepetida                  := (FieldByName('VALIDARASSISTREPETIDA_CFS').AsString = 'S');

      Formula_EncargoFunc      := FieldByName('FORMULA_ENCARGOFUNC_CFS').AsString;
      Formula_EncargoFuncIdeal := FieldByName('FORMULA_ENCARGOFUNCIDEAL_CFS').AsString;

      Terc_CustoReqSaida  := FieldByName('TERC_CUSTOREQSAIDA_CFS').AsInteger;
      Terc_VlrUnitRetorno := FieldByName('TERC_VLRUNITRETORNO_CFS').AsInteger;

      Emprestimo_CustoItem := FieldByName('EMPREST_CUSTOITEM_CFS').AsInteger;

      Req_UsaAutorizacaoSaida := (FieldByName('REQ_USAAUTORIZACAOSAIDA_CFS').AsString = 'S');
      Req_CustoReqSaida       := FieldByName('REQ_CUSTOREQSAIDA_CFS').AsInteger;

      ItensPorEmpresa                   := (FieldByName('ITENSPOREMPRESA_CFS').AsString = 'S');
      EscritorioContabil                := (FieldByName('ESCRITORIO_CONTABIL_CFG').AsString = 'S');
      ConsultaItemPorReferenciaPrimeiro := (FieldByName('CONSULTA_ITEM_POR_REF_CFS').AsString = 'S');

      NumeroCaracteresNome            := FieldByName('NUMEROCARACTERESNOME_CFS').AsInteger;
      NumeroCaracteresNomeFuncionario := FieldByName('NUMEROCARACTERESNOMEFUNC_CFS').AsInteger;
      NumeroCaracteresEndereco        := FieldByName('NUMEROCARACTERESEND_CFS').AsInteger;

      Etiq_Tam_Seq          := FieldByName('ETIQ_TAM_SEQ_CFS').AsInteger;
      Etiq_Tam_Item         := FieldByName('ETIQ_TAM_ITEM_CFS').AsInteger;
      Etiq_Tam_Variacao     := FieldByName('ETIQ_TAM_VARIACAO_CFS').AsInteger;
      Etiq_Tam_Cor          := FieldByName('ETIQ_TAM_COR_CFS').AsInteger;
      Etiq_Tam_Acabamento   := FieldByName('ETIQ_TAM_ACABAMENTO_CFS').AsInteger;
      Etiq_Tam_Grade        := FieldByName('ETIQ_TAM_GRADE_CFS').AsInteger;
      Etiq_Tam_DV           := FieldByName('ETIQ_TAM_DV_CFS').AsInteger;
      Etiq_Composicao_Barra := FieldByName('ETIQ_COMPOSICAO_BARRA_CFS').AsString;

      EtiqCompra_Tam_Seq          := FieldByName('ETIQCOMPRA_TAM_SEQ_CFS').AsInteger;
      EtiqCompra_Tam_Item         := FieldByName('ETIQCOMPRA_TAM_ITEM_CFS').AsInteger;
      EtiqCompra_Tam_Variacao     := FieldByName('ETIQCOMPRA_TAM_VARIACAO_CFS').AsInteger;
      EtiqCompra_Tam_Cor          := FieldByName('ETIQCOMPRA_TAM_COR_CFS').AsInteger;
      EtiqCompra_Tam_Acabamento   := FieldByName('ETIQCOMPRA_TAM_ACABAMENTO_CFS').AsInteger;
      EtiqCompra_Tam_Grade        := FieldByName('ETIQCOMPRA_TAM_GRADE_CFS').AsInteger;
      EtiqCompra_Tam_Lote         := FieldByName('ETIQCOMPRA_TAM_LOTE_CFS').AsInteger;
      EtiqCompra_Composicao_Barra := FieldByName('ETIQCOMPRA_COMPOSICAO_BARRA_CFS').AsString;

      DiasRetroCalcEmissaoDisponib := FieldByName('DIASRETROAGIR_DISPONPEDIDO_CFS').AsInteger;

      NFe_DiretorioXML := FieldByName('DIRETORIOXML_CFS').AsString;

      Transp_PrazoPadraoVencimento_DuplAcertoViagem := FieldByName('TRANSP_DIASVENC_ACERTVIAG_CFS').AsInteger;
      Transp_AtualizaModeloPneuRetornoReforma       := FieldByName('TRANSP_ATUALMODELPNEURETREF_CFS').AsString = 'S';
      Transp_DefinePadraoAcertoViagem_CTRB          := FieldByName('TRANSP_PADRAOACERTVIAG_CTRB_CFS').AsString = 'S';
      Transp_HabilitaEmissaoRPA                     := FieldByName('TRANSP_HABILITAEMISSAORPA_CFS').AsString = 'S';
      Transp_AcertoViagemPermiteGerar1DuplPorGR     := FieldByName('TRANSP_AVPERMITE1DUPLPORGR_CFS').AsString = 'S';
      Transp_EventoHoraExtra                        := FieldByName('TRANSP_EVENTOHORAEXTRA_CFS').AsString;
      Transp_EventoRSR                              := FieldByName('TRANSP_EVENTORSR_CFS').AsString;

      RegistraLog_Tela            := FieldByName('REGISTRALOG_TELA_CFS').AsString = 'S';
      RegistraLog_Tabela          := FieldByName('REGISTRALOG_TABELA_CFS').AsString = 'S';
      RegistraLog_Relatorio       := FieldByName('REGISTRALOG_RELATORIO_CFS').AsString = 'S';
      RegistraLog_ProcClasse      := FieldByName('REGISTRALOG_PROCCLASSE_CFS').AsString = 'S';
      RegistraLog_Rel_TempoMinimo := FieldByName('REGISTRALOG_REL_TEMPOMINIMO_CFS').AsDateTime;
      RegistraLog_Coletor         := FieldByName('REGISTRALOG_COLETOR_CFS').AsString = 'S';

      NumDiasAproveitaRel_DataBase := FieldByName('NUMDIASAPROVEITAREL_DTBASE_CFS').AsInteger;
      NumDiasAproveitaRel_Comum    := FieldByName('NUMDIASAPROVEITAREL_COMUM_CFS').AsInteger;

      MetasPorEmpresa      := FieldByName('METASPOREMPRESA_CFS').AsString = 'S';
      TributacaoPorEmpresa := FieldByName('TRIBUTACAOPOREMPRESA_CFS').AsString = 'S';
      RelSistemaAntigo     := FieldByName('RELSISTEMAANTIGO_CFS').AsString = 'S';

      BloquearLancamentoBorderoQualificacao0Todas       := FieldByName('BLOQLANCQUALIFTODAS_CFS').AsString = 'S';
      BorderoDataExigirPreenchimentoOperacao            := FieldByName('DT_EXIGIROPERACAO_CFS').AsDateTime;
      BorderoExigirPreenchimentoRegraIntegracaoContabil := FieldByName('EXIGIRREGRAINTEGRACAOCTB_CFS').AsString = 'S';

      Cache_Composicao                    := FieldByName('CACHE_COMPOSICAO_CFS').AsString = 'S';
      ComposicaoDinamicaAtravesDeFormulas := FieldByName('COMPOSICAO_DINAMICA_CFS').AsString = 'S';

      UrlSite                 := FieldByName('URLSITE_CFS').AsString;
      ChaveAPIGoogleMaps      := FieldByName('CHAVEAPIGOOGLEMAPS_CFS').AsString;
      KBMaxAnexoEmailAgendRel := FieldByName('KBMAXANEXOEMAILAGENDREL_CFS').AsInteger;

      UtilizaControleTarefas := False; // (FieldByName('UTILIZA_CONTROLE_TAREFAS_CFS').AsString = 'S');   Iniciado mas não finalizado, liberado indevidamente no sistema

      OcultarIntegracaoCTBVelha := (FieldByName('OCULTARINTEGRACAOVELHA_CFS').AsString = 'S');

      Seg_ComplexidadeSenhas := FieldByName('SEG_COMPLEXIDADESENHA_CFS').AsInteger;
      Seg_DiasTrocaSenhas    := FieldByName('SEG_DIASTROCASENHA_CFS').AsInteger;

      Carga_TranspProDoc := (FieldByName('CARGA_TRANSPPORDOC_CFS').AsString = 'S');

      // -- e-mail -- \\
      CarregaEmail(FieldByName('CONFIG_EMAIL_CFS').AsInteger, EmailGeral);
      ContaCopiaEmail := FieldByName('CONTACOPIAEMAIL_CFS').AsString;
      // -- \\

      CDS.Data := ExecuteReader(
        'select CONFIG_SISTEMA_STATUS.STATUS_CFSSTATUS ' + #13 +
        'from CONFIG_SISTEMA_STATUS ' + #13 +
        'where CONFIG_SISTEMA_STATUS.BLOQUEIO_SISTEMA_CFSSTATUS = ' + QuotedStr('S'), -1, True);

      IndexFieldNames := 'STATUS_CFSSTATUS';
      SetLength(StatusBloqueios, RecordCount);
      First;
      while not eof do
      begin
        StatusBloqueios[RecNo - 1] := FieldByName('STATUS_CFSSTATUS').AsInteger;
        Next;
      end;

      CDS.Data := ExecuteReader(
        'select CONFIG_SISTEMA_STATUS.STATUS_CFSSTATUS ' + #13 +
        'from CONFIG_SISTEMA_STATUS ' + #13 +
        'where CONFIG_SISTEMA_STATUS.BLOQUEIO_SITE_CFSSTATUS = ' + QuotedStr('S'), -1, True);

      IndexFieldNames := 'STATUS_CFSSTATUS';
      SetLength(StatusBloqueiosSite, RecordCount);
      First;
      while not eof do
      begin
        StatusBloqueiosSite[RecNo - 1] := FieldByName('STATUS_CFSSTATUS').AsInteger;
        Next;
      end;
    end;
  finally
    FreeAndNil(CDS);
    FreeAndNil(CDSGR);
  end;
end;

procedure TSMConexao.CarregaContasDisponiveisUsuario;
var
  CDS: TClientDataSet;
  SQL: string;
begin
  CDS := TClientDataSet.Create(Self);
  try
    SQL :=
      'select USUARIO_CONTAS.CONTA_USUCNT' + #13 +
      'from USUARIO_CONTAS' + #13;

    if (SecaoAtual.Sistema <> 4 { cSistemaCaixa } ) then
      SQL := SQL +
        'inner join EMPRESA_CONTAS on (EMPRESA_CONTAS.CONTA_EMPCNT = USUARIO_CONTAS.CONTA_USUCNT)' + #13;

    SQL := SQL +
      'where USUARIO_CONTAS.USUARIO_USUCNT = ' + IntToStr(SecaoAtual.Usuario.Codigo) + #13;

    if (SecaoAtual.Sistema <> 4 { cSistemaCaixa } ) then
      SQL := SQL + '  and EMPRESA_CONTAS.EMPRESA_EMPCNT = ' + IntToStr(SecaoAtual.Empresa.Codigo);

    CDS.Data                      := ExecuteReader(SQL, -1, True);
    CDS.IndexFieldNames           := 'CONTA_USUCNT';
    SecaoAtual.Usuario.ContasDisp := MontaStringCodigos(CDS);
  finally
    FreeAndNil(CDS);
  end;
end;

function TSMConexao.SecaoAtualSerializada: TJsonValue;
var
  xMarshal       : TJSONMarshal;
  tpSecaoAtualAnt: TClassSecao;
begin
  if Assigned(SecaoAtual) then
  begin
    tpSecaoAtualAnt := TClassSecao.Create;
    try
      tpSecaoAtualAnt.Guid       := SecaoAtual.Guid;
      tpSecaoAtualAnt.Host       := SecaoAtual.Host;
      tpSecaoAtualAnt.IP         := SecaoAtual.IP;
      tpSecaoAtualAnt.Plataforma := SecaoAtual.Plataforma;
      tpSecaoAtualAnt.Sistema    := SecaoAtual.Sistema;

      tpSecaoAtualAnt.Usuario.Codigo := SecaoAtual.Usuario.Codigo;
      tpSecaoAtualAnt.Usuario.Nome   := SecaoAtual.Usuario.Nome;
      tpSecaoAtualAnt.Usuario.Senha  := SecaoAtual.Usuario.Senha;
      tpSecaoAtualAnt.Usuario.Guid   := SecaoAtual.Usuario.Guid;

      xMarshal := TJSONMarshal.Create(TJSONConverter.Create);
      try
        Result := xMarshal.Marshal(tpSecaoAtualAnt);
      finally
        xMarshal.Free;
      end;
    finally
      tpSecaoAtualAnt.Free;
    end;
  end
  else
    Result := TJSONNull.Create;
end;

function TSMConexao.SecaoAtualSerializadaNovo(const prVersaoSistema: string): TJsonValue;
var
  xMarshal: TJSONMarshal;
begin
  if Assigned(SecaoAtual) then
  begin
    xMarshal := TJSONMarshal.Create(TJSONConverter.Create);
    try
      Result := xMarshal.Marshal(SecaoAtual);
    finally
      xMarshal.Free;
    end;
  end
  else
    Result := TJSONNull.Create;
end;

procedure TSMConexao.VerificaProcAtualizacao(cCodigoClienteTek: string);
var
  ArquivoRealiz         : string;
  CDS                   : TClientDataSet;
  NecessarioProcedimento: Boolean;
  LogErros              : WideString;
begin
  FCodigoClienteTek := cCodigoClienteTek;

  CDS := TClientDataSet.Create(Self);
  try
    CDS.Data               := ExecuteReader('select ATUALIZACAO.PROCPOSTERIOR_ATU from ATUALIZACAO', -1, True);
    NecessarioProcedimento := (not CDS.IsEmpty) and (CDS.FieldByName('PROCPOSTERIOR_ATU').AsString = 'N');
    CDS.Close;
  finally
    FreeAndNil(CDS);
  end;

  if (not NecessarioProcedimento) and
    (not(SecaoAtual.Sistema in [ConstanteSistema.cSistemaDepPessoal, ConstanteSistema.cSistemaESocial, ConstanteSistema.cSistemaLivrosFiscais])) then
  begin
    Exit;
  end;

  LogErros                         := '';
  FPrincipal.ProcExclusivoServidor := True;
  try
    if NecessarioProcedimento then
    begin
      try
        ExecuteMethods('TSMRelatorio.AtualizaRelatorios', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Relatórios: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadGR_Indicadores.AtualizarIndicadoresTekSystem', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Indicadores: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadTI_Processamentos.AtualizarModelosProcessamentosTekSystem', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Processamentos: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadConfigRemessaRetorno.AtualizarConfiguracoesRemessaRetornoBancTekSystem', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Configurações de Remessa/Retorno: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadConfigExportacaoTitulos.AtualizarConfiguracoesImportaExportaTekSystem', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Configurações de Importação/Exportação de Títulos: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadDW_Temas.AtualizarModelosDataWarehouse', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Modelos de DW: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadGR_Relatorio.AtualizarModelosRelatorios', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar Relatórios do Gerador: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadGR_Unidades_Codificacao.AtualizarModelosUnidadesCodificacao', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função VerificaProcAtualizacao ao Atualizar MOdelos de Unidades de Codificação: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMRotinasEspeciais.AtualizarXMLStringParaCompactado', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função AtualizarXMLStringParaCompactado ao Converter XML de Notas Fiscais: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadVariaveis.InicializaVariaveis', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função InicializaVariaveis ao Inicializar Variáveis de Desconto e Negociação: ' + E.Message;
      end;

      try
        ExecuteMethods('TSMCadBorderoRetornoBancario.ConverterTitulosBorderosEmTabelas', []);
      except
        on E: Exception do
          LogErros := LogErros + #10 + E.Message;
      end;

      try
        ArquivoRealiz := ExtractFilePath(ParamStr(0)) + 'realizacoes_dadosmc.cds';
        if FileExists(ArquivoRealiz) then
        begin
          CDS := TClientDataSet.Create(Self);
          try
            CDS.LoadFromFile(ArquivoRealiz);
            SincronizarRealizacoes(CDS.Data, 'ATUALIZADOR AUTOMÁTICO');
          finally
            FreeAndNil(CDS);
          end;
        end;
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função SincronizarRealizacoes: ' + E.Message;
      end;

      if (LogErros = '') then
        ExecuteCommand('update ATUALIZACAO set ATUALIZACAO.PROCPOSTERIOR_ATU = ''S''', True);
    end;

    if (SecaoAtual.Sistema = ConstanteSistema.cSistemaDepPessoal) then
      try
        // Atualizar a tabelas do departamento pessoal
        ExecuteMethods('TSMDepPessoal.EP_InicializarTabelas', [1])
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função EP_InicializarTabelas: ' + E.Message;
      end;

    if (SecaoAtual.Sistema = ConstanteSistema.cSistemaESocial) then
      try
        // Atualizar a tabelas do esocial
        ExecuteMethods('TSMDepPessoal.EP_InicializarTabelasESocial', [1])
      except
        on E: Exception do
          LogErros := LogErros + #10 + 'Erro na função EP_InicializarTabelasESocial: ' + E.Message;
      end;

    if (SecaoAtual.Sistema = ConstanteSistema.cSistemaLivrosFiscais) then
      ExecuteMethods('TSMLivroFiscal.ExecProcedimento', [LF_Constantes.LF_Proc_InicializarTabelas, 1]);

  finally
    FPrincipal.ProcExclusivoServidor := False;

    if (LogErros <> '') then
      raise Exception.Create(LogErros);
  end;
end;

function TSMConexao.LimpezaBDD(Ativa: Boolean): OleVariant;
var
  i         : Integer;
  FileBDD   : string;
  TekAg_Host: string;
  TekAg_Port: Integer;
  ModoDesenv: Boolean;
  Lista     : TList<string>;
  Vetor     : TJSONArray;
begin
  if FPrincipal.ProcExclusivoServidor then
    raise Exception.Create(sProcessoExclusivoServ);

  if Ativa and (ConexaoBDD_Tipo = Funcoes_TekConnects.cTipoBDD_Limpo) then
    raise Exception.Create('Processo de limpeza já solicitado/executado.');

  if (not Ativa) and (ConexaoBDD_Tipo <> Funcoes_TekConnects.cTipoBDD_Limpo) then
    raise Exception.Create('Processo de retroagir reorganização já solicitado/executado.');

  Result := '';
  try
    FPrincipal.ProcExclusivoServidor := True;

    if Ativa then
    begin
      CallBack_AbreTela(Self.ClassName, 'Execução da Reorganização');
    end
    else
    begin
      CallBack_AbreTela(Self.ClassName, 'Retroagindo a base de dados');
    end;

    // Mandar fechar os clientes com exceção o de execução
    Lista := ServerContainer.DSServer.GetAllChannelCallbackId(cCanal);
    if Lista.Count > 0 then
    begin
      Vetor := TJSONArray.Create;
      try
        Vetor.Owned := False;
        Vetor.AddElement(TJSONString.Create(Self.ClassName));
        Vetor.AddElement(TJSONString.Create(SecaoAtual.Usuario.Nome));

        for i := 0 to Lista.Count - 1 do
          if Lista[i] <> SecaoAtual.Usuario.Nome then
            FuncoesCallBack2.CallBack_CallBack(ServerContainer.DSServer, cCanal, Lista[i], ConstantesCallBack.EvCallBack_ShutDown, Vetor);
      finally
        Vetor.Free;
      end;
    end;

    try
      TArquivoINI.Abrir;
      try
        TekAg_Host := TArquivoINI.Ler('TekAgendador', 'Host', 'localhost');
        TekAg_Port := TArquivoINI.Ler_Integer('TekAgendador', 'Port', TekAgendadorPorta);
      finally
        TArquivoINI.Fechar;
      end;

      with MeuSQLConnection do
      begin
        ModoDesenv := AnsiUpperCase(Params.Values['MODO']) = 'DESENVOLVEDOR';

        if ModoDesenv then
          raise Exception.Create('Sistema em modo "desenvolvedor" não é permitido a execução do processo de reorganização da base de dados.');

        FileBDD := ExtractFileName(Params.Values['Id' + DATABASENAME_KEY]);

        Close;
        if Ativa then
          TFuncoes_TekConnects.Limpeza_Ativa(TekAg_Host, TekAg_Port, 86, FileBDD, SecaoAtual.Usuario.Nome)
        else
          TFuncoes_TekConnects.Limpeza_Desativa(TekAg_Host, TekAg_Port, 86, FileBDD, SecaoAtual.Usuario.Nome);
      end;
    except
      on E: Exception do
        Result := E.Message;
    end;

    ControlaConexaoBDD.LerParametrosDoArquivoDeConfiguracao;
  finally
    FPrincipal.ProcExclusivoServidor := False;
    CallBack_FechaTela(Self.ClassName);
  end;
end;

procedure TSMConexao.SincronizarRealizacoes(Realizacoes: OleVariant; Atualizador: String);
const
  SQLExiste =
    ' select count(1)' + #13 +
    ' from REALIZACOES' + #13 +
    ' where (REALIZACOES.AUTOINC_REAL = %s)';
  SQLInsere =
    ' insert into REALIZACOES (' + #13 +
    ' AUTOINC_REAL, DATAHORAREALIZACAO_REAL, RESPONSAVELREALIZACAO_REAL, ' + #13 +
    ' DATAHORATESTE_REAL, RESPONSAVELTESTE_REAL,' + #13 +
    ' DATAHORAATUALIZACAO_REAL, RESPONSAVELATUALIZACAO_REAL, ' + #13 +
    ' MODULO_REAL, AREA_REAL, TIPO_REAL, TEXTO_REAL) values (' + #13 +
    ' %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)';
  SQLAltera =
    ' update REALIZACOES R set' + #13 +
    '   R.DATAHORAREALIZACAO_REAL     = %s,' + #13 +
    '   R.DATAHORATESTE_REAL          = %s,' + #13 +
    '   R.RESPONSAVELREALIZACAO_REAL  = %s,' + #13 +
    '   R.RESPONSAVELTESTE_REAL       = %s,' + #13 +
    '   R.MODULO_REAL                 = %s,' + #13 +
    '   R.AREA_REAL                   = %s,' + #13 +
    '   R.TIPO_REAL                   = %s,' + #13 +
    '   R.TEXTO_REAL                  = %s' + #13 +
    ' where (R.AUTOINC_REAL = %s)';
var
  CDS : TClientDataSet;
  SQL : String;
  Qtde: Integer;

  function MapeaModulos(ModuloSistemaAtendimento: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i  := Low(Modulos) to High(Modulos) do
      if (Modulos[i, 4] = IntToStr(ModuloSistemaAtendimento)) then
      begin
        Result := i;
        Break;
      end;
  end;

  function MapeaTipos(TipoServicoAtendimento: Integer): Integer;
  begin
    case TipoServicoAtendimento of
      1:
        Result := ClassRealizacoes.cTipoServico_Alteracao;
      2:
        Result := ClassRealizacoes.cTipoServico_Correcao;
      3:
        Result := ClassRealizacoes.cTipoServico_Inovacao;
    else
      Result := ClassRealizacoes.cTipoServico_Informacao;
    end;
  end;

begin
  CDS := TClientDataSet.Create(Self);
  try
    CallBack_AbreTela(Self.ClassName, 'Atualizando Realizações');
    try
      CDS.Data := Realizacoes;
      with CDS do
      begin
        IndexFieldNames := 'CODIGO_REAL';
        First;
        while (not eof) do
        begin
          CallBack_Incremento(Self.ClassName, RecNo, RecordCount, FieldByName('CODIGO_REAL').AsString);

          if (CDS.FindField('VISIVEL_REAL') = nil) or (CDS.FieldByName('VISIVEL_REAL').AsString <> 'S') then
          begin
            CDS.Next;
            Continue;
          end;

          SQL  := Format(SQLExiste, [IntToStr(FieldByName('CODIGO_REAL').AsInteger)]);
          Qtde := ExecuteScalar(SQL, True);
          if (Qtde = 0) then
          begin
            SQL := Format(SQLInsere, [
              { 01 } IntToStr(FieldByName('CODIGO_REAL').AsInteger),
              { 02 } TFuncoesSQL.DataSQL(FieldByName('DATAREALIZACAO_REAL').AsDateTime + FieldByName('HORAREALIZACAO_REAL').AsDateTime, 3),
              { 03 } QuotedStr(FieldByName('RESPONSAVELREALIZACAO_REAL').AsString),
              { 04 } TFuncoesSQL.DataSQL(FieldByName('DATATESTE_REAL').AsDateTime),
              { 05 } QuotedStr(FieldByName('RESPONSAVELTESTE_REAL').AsString),
              { 06 } 'current_timestamp',
              { 07 } QuotedStr(Atualizador),
              { 08 } IntToStr(MapeaModulos(FieldByName('MODULO_REAL').AsInteger)),
              { 09 } QuotedStr(FieldByName('AREA_REAL').AsString),
              { 10 } IntToStr(MapeaTipos(FieldByName('TIPO_REAL').AsInteger)),
              { 11 } QuotedStr(FieldByName('TEXTO_REAL').AsString)]);
          end
          else
          begin
            SQL := Format(SQLAltera, [
              { 01 } TFuncoesSQL.DataSQL(FieldByName('DATAREALIZACAO_REAL').AsDateTime + FieldByName('HORAREALIZACAO_REAL').AsDateTime, 3),
              { 02 } TFuncoesSQL.DataSQL(FieldByName('DATATESTE_REAL').AsDateTime),
              { 03 } QuotedStr(FieldByName('RESPONSAVELREALIZACAO_REAL').AsString),
              { 04 } QuotedStr(FieldByName('RESPONSAVELTESTE_REAL').AsString),
              { 05 } IntToStr(MapeaModulos(FieldByName('MODULO_REAL').AsInteger)),
              { 06 } QuotedStr(FieldByName('AREA_REAL').AsString),
              { 07 } IntToStr(MapeaTipos(FieldByName('TIPO_REAL').AsInteger)),
              { 08 } QuotedStr(FieldByName('TEXTO_REAL').AsString),
              { 09 } IntToStr(FieldByName('CODIGO_REAL').AsInteger)]);
          end;
          ExecuteCommand(SQL, True);
          Next;
        end;
        CallBack_Mensagem(Self.ClassName, 'Atualização Concluída');
      end;
    finally
      FreeAndNil(CDS);
      CallBack_FechaTela(Self.ClassName);
    end;
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'SincronizarRealizacoes', E.Message));
  end;
end;

function TSMConexao.ClassesDeCadastro(const iTipo: Integer; const sNomeClasse: string): OleVariant;
var
  X                        : Integer;
  SubDiretorio, NomeArquivo: string;
  NomeClasse               : string;
  Lista                    : TStrings;
  CDSClasses, CDSClone     : TClientDataSet;
  CDSCampos                : TClientDataSet;
  Classe                   : TFClassPaiCadastro;

  procedure AdicionaCampos(NomeClasse: string; Seq: Integer);
  var
    i      : Integer;
    SQL    : string;
    CDSTemp: TClientDataSet;
    Classe : TFClassPaiCadastro;
  begin
    Classe := TFClassPaiCadastro(FindClass(NomeClasse));

    CDSTemp := TClientDataSet.Create(Self);
    try
      try
        if Trim(Classe.CamposCadastro) = '' then
        begin
          SQL := Trim(Classe.SQLBaseCadastro);
          SQL := TFuncoesString.CorteAte(SQL, 'where');
        end
        else
          SQL := 'select ' + Classe.CamposCadastro + ' from ' + Classe.TabelaPrincipal;

        if Trim(Classe.CampoChave) = '' then
          SQL := SQL + ' where 0 = 1'
        else
          SQL := SQL + ' where ' + Classe.CampoChave + ' = -1';

        try
          CDSTemp.Data := ExecuteReader(SQL, -1, True);
        except
          Exit;
        end;

        Classe.ConfigurarPropriedadesDosCampos(CDSTemp);

        for i := 0 to CDSTemp.Fields.Count - 1 do
          if (CDSTemp.FieldDefs.Items[i].Name <> Classe.CampoChave) and
            (CDSTemp.FieldDefs.Items[i].Name <> Classe.UsuarioInc) and
            (CDSTemp.FieldDefs.Items[i].Name <> Classe.UsuarioAlt) and
            (CDSTemp.FieldDefs.Items[i].Name <> Classe.DataHoraInc) and
            (CDSTemp.FieldDefs.Items[i].Name <> Classe.DataHoraAlt) then
          begin
            CDSCampos.Insert;
            CDSCampos.FieldByName('SEQ').AsInteger      := Seq;
            CDSCampos.FieldByName('CLASSE').AsString    := Classe.ClassName;
            CDSCampos.FieldByName('NOME').AsString      := CDSTemp.FieldDefs.Items[i].Name;
            CDSCampos.FieldByName('DESCRICAO').AsString := CDSTemp.Fields[i].DisplayLabel;
            CDSCampos.FieldByName('TIPO').AsInteger     := Integer(CDSTemp.Fields[i].DataType);
            CDSCampos.FieldByName('DEFAULT').AsString   := CDSTemp.Fields[i].DefaultExpression;
            CDSCampos.FieldByName('VALIDACAO').AsString := CDSTemp.Fields[i].CustomConstraint;
            CDSCampos.Post;
          end;
      except
        // on E: Exception do   ** não fazer nada mesmo, passar pro proximo **
        // raise Exception.Create('Classe ' + NomeDaClasse + ' não encontrada. ' +#13 + E.Message);
      end;
    finally
      FreeAndNil(CDSTemp);
    end;
  end;

begin
  try
    CDSClasses := TClientDataSet.Create(Self);
    CDSCampos  := TClientDataSet.Create(Self);
    try
{$REGION 'Trata classes'}
      SubDiretorio := TFuncoesSistemaOperacional.DiretorioComBarra(ExtractFilePath(ParamStr(0)) + 'EstruturaDeClasse');
      if (not DirectoryExists(SubDiretorio)) then
        CreateDir(SubDiretorio);

      NomeArquivo := SubDiretorio + 'Classes-Versao-' + VersaoBDD + '.cds';

      if FileExists(NomeArquivo) then
      begin
        CDSClasses.LoadFromFile(NomeArquivo);
        CDSClasses.IndexFieldNames := 'NOME';
      end
      else
      begin
        Lista    := TStringList.Create;
        CDSClone := TClientDataSet.Create(Self);
        CallBack_AbreTela(Self.ClassName, 'Carregando classes de cadastro');
        try
          with CDSClasses do
          begin
            Close;
            with FieldDefs do
            begin
              Clear;
              Add('SEQ', ftInteger);

              Add('NOME', ftString, 50);
              Add('DESCRICAO', ftString, 80);
              Add('TABELA', ftString, 50);

              Add('ORIGINAL', ftString, 50);
              Add('RELACIONAL', ftString, 50);

              Add('CLASSEPAI', ftInteger);
              Add('CLASSEORIGINAL', ftInteger);
              Add('CLASSERELACIONAL', ftInteger);

              Add('VISIVEL', ftString, 1);
              Add('CONFIG_ACESSO', ftString, 1);
            end;
            CreateDataSet;
            LogChanges      := False;
            ReadOnly        := False;
            IndexFieldNames := 'NOME';
            Open;

            CallBack_Mensagem(Self.ClassName, 'Carregando lista');
            EnumClasses(Lista, TClassPaiCadastro);
            for X := 0 to Lista.Count - 1 do
            begin
              NomeClasse := Lista[X];
              Classe     := TFClassPaiCadastro(FindClass(NomeClasse));

              Insert;
              FieldByName('SEQ').AsInteger      := X + 1;
              FieldByName('NOME').AsString      := Classe.ClassName;
              FieldByName('DESCRICAO').AsString := Classe.Descricao;
              FieldByName('TABELA').AsString    := Classe.TabelaPrincipal;

              if Classe.ClassOriginal <> '' then
                FieldByName('ORIGINAL').AsString := 'T' + Classe.ClassOriginal;
              if Classe.ClassRelacional <> '' then
                FieldByName('RELACIONAL').AsString := 'T' + Classe.ClassRelacional;

              FieldByName('VISIVEL').AsString       := 'S';
              FieldByName('CONFIG_ACESSO').AsString := IfThen(Classe.PermiteConfigurarAcessos, 'S', 'N');

              Post;
            end;
          end;

          CallBack_Mensagem(Self.ClassName, 'Carregando vinculos');
          CDSClone.Clonar(CDSClasses);

          CDSClone.First;
          while not CDSClone.eof do
          begin
            if (CDSClone.FieldByName('ORIGINAL').AsString <> '') and
              (CDSClasses.FindKey([CDSClone.FieldByName('ORIGINAL').AsString])) then
            begin
              X := CDSClasses.FieldByName('SEQ').AsInteger;

              CDSClasses.Edit;
              CDSClasses.FieldByName('VISIVEL').AsString := 'N';
              CDSClasses.Post;

              if CDSClasses.FindKey([CDSClone.FieldByName('NOME').AsString]) then
              begin
                CDSClasses.Edit;
                CDSClasses.FieldByName('CLASSEPAI').AsInteger      := X;
                CDSClasses.FieldByName('CLASSEORIGINAL').AsInteger := X;
                CDSClasses.Post;
              end;
            end;

            if (CDSClone.FieldByName('RELACIONAL').AsString <> '') and
              (CDSClasses.FindKey([CDSClone.FieldByName('RELACIONAL').AsString])) then
            begin
              X := CDSClasses.FieldByName('SEQ').AsInteger;
              CDSClasses.Edit;
              CDSClasses.FieldByName('VISIVEL').AsString := 'N';
              CDSClasses.Post;

              if CDSClasses.FindKey([CDSClone.FieldByName('NOME').AsString]) then
              begin
                CDSClasses.Edit;
                CDSClasses.FieldByName('CLASSEPAI').AsInteger        := X;
                CDSClasses.FieldByName('CLASSERELACIONAL').AsInteger := X;
                CDSClasses.Post;
              end;
            end;

            CDSClone.Next;
          end;

          CallBack_Mensagem(Self.ClassName, 'Salvando');
          CDSClasses.SaveToFile(NomeArquivo);
        finally
          FreeAndNil(Lista);
          FreeAndNil(CDSClone);
          CallBack_FechaTela(Self.ClassName);
        end;
      end;
{$ENDREGION}
      case iTipo of
        1: CDSClasses.LimparRegistros(True, 'ORIGINAL <> ' + QuotedStr(''));
        2: CDSClasses.LimparRegistros(True, 'CONFIG_ACESSO = ' + QuotedStr('N'));
      end;

      if sNomeClasse <> '' then
      begin
        if CDSClasses.FindKey([sNomeClasse]) and (CDSClasses.FieldByName('ORIGINAL').AsString <> '') then
          NomeClasse := CDSClasses.FieldByName('ORIGINAL').AsString
        else
          NomeClasse := sNomeClasse;

        CDSClasses.LimparRegistros(True, 'NOME <> ' + QuotedStr(sNomeClasse) + ' and NOME <> ' + QuotedStr(NomeClasse) + ' and RELACIONAL <> ' + QuotedStr(NomeClasse));
      end;

      if iTipo = 3 then
      begin
{$REGION 'Trata campos'}
        SubDiretorio := TFuncoesSistemaOperacional.DiretorioComBarra(ExtractFilePath(ParamStr(0)) + 'EstruturaDeClasse');
        if (not DirectoryExists(SubDiretorio)) then
          CreateDir(SubDiretorio);

        NomeArquivo := SubDiretorio + 'Campos-Versao-' + VersaoBDD + '.cds';

        if FileExists(NomeArquivo) then
          CDSCampos.LoadFromFile(NomeArquivo)
        else
        begin
          CallBack_AbreTela(Self.ClassName, 'Carregando campos da classe');
          try
            with CDSCampos do
            begin
              Close;
              with FieldDefs do
              begin
                Clear;
                Add('SEQ', ftInteger);
                Add('CLASSE', ftString, 50);

                Add('NOME', ftString, 50);
                Add('DESCRICAO', ftString, 80);
                Add('TIPO', ftInteger);

                Add('DEFAULT', ftString, 255);
                Add('VALIDACAO', ftString, 255);
              end;
              CreateDataSet;
              LogChanges      := False;
              ReadOnly        := False;
              IndexFieldNames := 'NOME';
              Open;
            end;

            CDSClasses.First;
            while not CDSClasses.eof do
            begin
              CallBack_Incremento(Self.ClassName, CDSClasses.RecNo, CDSClasses.RecordCount);

              AdicionaCampos(CDSClasses.FieldByName('NOME').AsString, CDSClasses.FieldByName('SEQ').AsInteger);
              CDSClasses.Next;
            end;

            if (not(iTipo in [1, 2])) and (sNomeClasse = '') then
            begin
              CallBack_Mensagem(Self.ClassName, 'Salvando');
              CDSCampos.SaveToFile(NomeArquivo);
            end;
          finally
            CallBack_FechaTela(Self.ClassName);
          end;
        end;
{$ENDREGION}
      end;

      Result := VarArrayOf([CDSClasses.Data, CDSCampos.Data]);
    finally
      FreeAndNil(CDSClasses);
      FreeAndNil(CDSCampos);
    end;
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(ClassName, 'ClassesDeCadastro', 'Classe: ' + NomeClasse + #13 + E.Message));
  end;
end;

procedure TSMConexao.RequisitarDesconexao(Guid: string);
var
  Delay            : Boolean;
  Vetor            : TJSONArray;
  Conexao          : TConexao;
  HandleThread     : THandle;
  ConnectionHandler: TDSServerConnectionHandler;
begin
  if Guid = SecaoAtual.Guid then
    raise Exception.Create('A própria conexão não pode ser finalizada.');

  Conexao := ControlaConexao.RetornaConexao(Guid);
  if not Assigned(Conexao) then
    raise Exception.Create('Conexão "' + Guid + '" não disponível.');

  // registra a ação
  RegistraAcao('REQUISIÇÃO DE DESCONEXÃO', 0, 0,
    'O usuário "' + SecaoAtual.Usuario.Nome + '" solicitou fechamento conexão: ' + #13 +
    '  Guid: ' + Guid + #13 +
    '  Usuário: ' + Conexao.SecaoAtual.Usuario.Nome + #13 +
    '  Host: ' + Conexao.SecaoAtual.Host + #13 +
    '  IP: ' + Conexao.SecaoAtual.IP + #13 +
    '  Plataforma: ' + Conexao.SecaoAtual.Plataforma + #13 +
    '  Dt/Hr.Criação: ' + DateTimeToStr(Conexao.DtHrCriacao) + #13 +
    '  Status: ' + Conexao.Status);

  HandleThread      := Conexao.Handle;
  ConnectionHandler := Conexao.ConnectionHandler;
  Delay             := False;

  // Mandar fechar do cliente para o servidor (via callback), é mais elegante pois
  // apresenta mensagem para o usuario informando que foi solicitado a desconexão
  Vetor := TJSONArray.Create;
  try
    Vetor.Owned := False;
    Vetor.AddElement(TJSONString.Create(Self.ClassName));
    Vetor.AddElement(TJSONString.Create(SecaoAtual.Usuario.Nome));

    if FuncoesCallBack2.CallBack_Cliente(ServerContainer.DSServer, Conexao.SecaoAtual.Usuario.Nome, Conexao.SecaoAtual.Guid, ConstantesCallBack.EvCallBack_ShutDown, Vetor) then
    begin
      // Da um tempo para que o cliente processe a mensagem recebida e tente finalizar
      // segura o retorno da função para que o solicitante tenha mais possibilidade de ser atualizado corretamente
      Sleep(1000);
      Delay := True;
    end;
  finally
    Vetor.Free;
  end;

  TThread.CreateAnonymousThread(
    procedure()
    begin
      // Dar mais um tempo para que seja desconectado pelo lado cliente, sem que o solicitante fique aguardando
      if Delay then
        Sleep(1000 * 4);

      try
        ControlaConexao.DestroiConexao(Guid);
      except
        // se tiver processando algo pode ocorrer alguns erros
      end;

      if Delay then
        Sleep(1000 * 6);

      // Solicita finalização da thread, caso de em processamento ainda esteja sendo realizado
      // * ATENÇÃO: Trexo abaixo está gerando problemas para finalizar o TekServer, faz com trave
      // não tive tempo ainda de resolver, não é prioridade para Tek...
      TerminateThread(HandleThread, 0);

      // Destroi elementos (ex: SM) que ficaram sem destroir quando finalizado a thread com o comando assima
      // * ATENÇÃO: Trexo abaixo está gerando erro quando conseguir finalizar a conexão sem problemas, ex:
      // quando não está em processamento algo.
      if Assigned(ConnectionHandler) then
        ConnectionHandler.Destroy;
    end
    ).Start;
end;

procedure TSMConexao.RequisitarHalt;
var
  i    : Integer;
  Lista: TList<string>;
  Vetor: TJSONArray;
begin
  try
    // registra a ação
    RegistraAcao('REQUISIÇÃO DE HALT (SHUTDOWN) NO TEKSERVER', 0, 0, '');

    // Mandar fechar os clientes
    Lista := ServerContainer.DSServer.GetAllChannelCallbackId(cCanal);
    if Lista.Count > 0 then
    begin
      Vetor := TJSONArray.Create;
      try
        Vetor.Owned := False;
        Vetor.AddElement(TJSONString.Create(Self.ClassName));
        Vetor.AddElement(TJSONString.Create(SecaoAtual.Usuario.Nome));

        for i := 0 to Lista.Count - 1 do
          FuncoesCallBack2.CallBack_CallBack(ServerContainer.DSServer, cCanal, Lista[i], ConstantesCallBack.EvCallBack_ShutDown, Vetor);
      finally
        Vetor.Free;
      end;

      // Da um tempo para todos receber a mensagem
      Sleep(1000);
    end;

    ServerContainer.PararServidor;
  finally
    // Fechar o servidor de aplicação
    ExitProcess(0);
    Halt;
  end;
end;

function TSMConexao.InternetAtiva: Boolean;
begin
  Result := TFuncoesRede.ExisteConexaoComInternet;
end;

procedure TSMConexao.AtualizarMascaraGrupoResultado(MskGrupoResultado: string);
begin
  FSecaoAtual.Parametro.MascaraGrupoDeResultado := MskGrupoResultado;
end;

procedure TSMConexao.AtualizarMascaraNivelDeDocumento(MskNivelDocumento: string);
begin
  FSecaoAtual.Parametro.MascaraNivelDocumentos := MskNivelDocumento;
end;

function TSMConexao.EstruturaDoBancoDeDadosEmXML: String;
var
  Provedor: TacQBdbExMetadataProvider;
  QB      : TacQueryBuilder;
  Sintaxe : TacFirebirdSyntaxProvider;
  Filtro  : TacMetadataFilter;
  // NomeTabelaUnica: string;
  SubDiretorio, NomeArqXML: String;
  Lista                   : TStrings;
begin
  try
    SubDiretorio := TFuncoesSistemaOperacional.DiretorioComBarra(ExtractFilePath(ParamStr(0)) + 'EstruturaDoBancoDeDados');
    NomeArqXML   := SubDiretorio + 'Versao-' + ControlaConexaoBDD.VersaoBD + '.xml';

    Lista := TStringList.Create;
    try
      // Se já existe um XML com a estrutura do banco de dados na versão atual, carregue-o
      if FileExists(NomeArqXML) then
        Lista.LoadFromFile(NomeArqXML)
      else // Se não existir, vai carregar a estrutura do banco de dados e salvar o XML
      begin
        // Busca o MetaData do banco de dados e retorna como XML
        Provedor := TacQBdbExMetadataProvider.Create(Self);
        QB       := TacQueryBuilder.Create(Self);
        Sintaxe  := TacFirebirdSyntaxProvider.Create(Self);
        Filtro   := TacMetadataFilter.Create(Self);
        try
          Provedor.Connection := MeuSQLConnection;

          Sintaxe.ServerVersion := svFirebird2;

          Filtro.Clear;

          // Vai ler todas as tabelas do banco, com exceção das de sistema e algumas procedures
          // if (NomeTabelaUnica = '') then
          begin
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'RDB$%';
            end;
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'MON$%';
            end;
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'TESTE';
            end;
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'DEFAULTS';
            end;
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'DESFAZ_ALMOXARIFADO';
            end;
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'DEFAULTS';
            end;
            with Filtro.Add do
            begin
              Exclude    := True;
              ObjectMask := 'INICIALIZA%';
            end;
          end
          { else // Lerá apenas os campos de uma tabela
            with Filtro.Add do
            begin
            Exclude    := False;
            ObjectMask := NomeTabelaUnica;
            end };

          QB.MetadataProvider := Provedor;
          QB.SyntaxProvider   := Sintaxe;
          QB.MetadataFilter   := Filtro;
          QB.LoadMetadata();
          QB.RefreshMetadata;

          if (not DirectoryExists(SubDiretorio)) then
            CreateDir(SubDiretorio);

          Lista.Text := QB.MetadataContainer.XML;
          Lista.SaveToFile(NomeArqXML);
        finally
          FreeAndNil(QB);
          FreeAndNil(Sintaxe);
          FreeAndNil(Provedor);
          FreeAndNil(Filtro);
        end;
      end;

      Result := Lista.Text;
    finally
      FreeAndNil(Lista);
    end;
  except
    on E: Exception do
      raise Exception.Create(FuncoesGeraisServidor.FormataErroNoServidor(Self.ClassName, 'EstruturaDoBancoDeDadosEmXML', E.Message));
  end;
end;

function TSMConexao.CallBack_AbreTela(ID: string; Mensagem: string = ''): Boolean;
var
  Vetor: TJSONArray;
begin
  Vetor := TJSONArray.Create;
  try
    Vetor.Owned := False;
    Vetor.AddElement(TJSONString.Create(ID));
    Vetor.AddElement(TJSONString.Create(Mensagem));

    Result := FuncoesCallBack2.CallBack_Cliente(ServerContainer.DSServer, SecaoAtual.Usuario.Nome, SecaoAtual.Guid, ConstantesCallBack.EvCallBack_AbreTelaMensagem, Vetor);
  finally
    Vetor.Free;
  end;
end;

function TSMConexao.CallBack_FechaTela(ID: string): Boolean;
var
  Vetor: TJSONArray;
begin
  Vetor := TJSONArray.Create;
  try
    Vetor.Owned := False;
    Vetor.AddElement(TJSONString.Create(ID));

    Result := FuncoesCallBack2.CallBack_Cliente(ServerContainer.DSServer, SecaoAtual.Usuario.Nome, SecaoAtual.Guid, ConstantesCallBack.EvCallBack_FechaTelaMensagem, Vetor);
  finally
    Vetor.Free;
  end;
end;

function TSMConexao.CallBack_Mensagem(ID, Mensagem: string): Boolean;
var
  Vetor: TJSONArray;
begin
  Vetor := TJSONArray.Create;
  try
    Vetor.Owned := False;
    Vetor.AddElement(TJSONString.Create(ID));
    Vetor.AddElement(TJSONString.Create(Mensagem));

    Result := FuncoesCallBack2.CallBack_Cliente(ServerContainer.DSServer, SecaoAtual.Usuario.Nome, SecaoAtual.Guid, ConstantesCallBack.EvCallBack_Status, Vetor);
  finally
    Vetor.Free;
  end;
  Application.ProcessMessages;

  InformaAtividadeSecao;
end;

function TSMConexao.CallBack_Incremento(ID: string; Atual, Total: Integer; Mensagem: string = ''): Boolean;
var
  Vetor: TJSONArray;
begin
  // Evitar excesso de call back seguidos para o cliente, extressando muito o canal ocorre problemas e desconecta
  // fazendo com que a janela FAguarde do cliente permancessa aberta
  if (Total > TotalMaximoDoContador) and (Atual mod (Total div TotalMaximoDoContador) > 0) then
  begin
    Result := False;
    Exit;
  end;

  Vetor := TJSONArray.Create;
  try
    Vetor.Owned := False;
    Vetor.AddElement(TJSONString.Create(ID));
    Vetor.AddElement(TJSONNumber.Create(Atual));
    Vetor.AddElement(TJSONNumber.Create(Total));
    Vetor.AddElement(TJSONString.Create(Mensagem));

    Result := FuncoesCallBack2.CallBack_Cliente(ServerContainer.DSServer, SecaoAtual.Usuario.Nome, SecaoAtual.Guid, ConstantesCallBack.EvCallBack_IncrementaProgresso, Vetor);
  finally
    Vetor.Free;
  end;

  InformaAtividadeSecao;
end;

function TSMConexao.GetTableNames(ApenasTabelasDeSistema: Boolean): string;
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    MeuSQLConnection.GetTableNames(Lista, ApenasTabelasDeSistema);
    Lista.Sort;
    Result := Lista.Text;
  finally
    Lista.Free;
  end;
end;

function TSMConexao.GetProcedureNames: string;
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    MeuSQLConnection.GetProcedureNames(Lista);
    Lista.Sort;
    Result := Lista.Text;
  finally
    Lista.Free;
  end;
end;

function TSMConexao.GetSetorDesenvolvimentoTekSystem: Boolean;
begin
  Result :=
    (Pos('-' + CodigoClienteTek + '-', '-1000-501-502-') > 0) and
    (Pos(AnsiUpperCase('C:\MultiCamadas2006\Exec\Servidor\'), AnsiUpperCase(ExtractFilePath(ParamStr(0)))) > 0);
end;

function TSMConexao.Funcao_AcbrExecuteCommand(s: string): Int64;
begin
  Result := ExecuteCommand(s, True);
end;

function TSMConexao.Funcao_AcbrExecuteReader(s: string): OleVariant;
begin
  Result := ExecuteReader(s, -1, True);
end;

function TSMConexao.Funcao_AcbrExecuteScalar(s: string): OleVariant;
begin
  Result := ExecuteScalar(s, True);
end;

function TSMConexao.Funcao_AcbrProximoCodigo(s: string): OleVariant;
begin
  Result := ProximoCodigo(s, 0);
end;

function TSMConexao.FuncionalidadeLiberada(LabelFuncionalidade: String): Boolean;
var
  ServidorProtecao, sRetorno: String;
  PortaProtecao             : Integer;
  TekProtClient             : TTekProtClient;
  Lista                     : TStringList;
begin
  if (not FCDSFuncionalidadesLiberadas.Active) then
  begin
{$REGION 'Buscando servidor/porta Tekprot'}
    TFuncoes_TekConnects.Config_Protecao(ControlaConexaoBDD.TekAg_Host, ControlaConexaoBDD.TekAg_Port, ServidorProtecao, PortaProtecao);
{$ENDREGION}
{$REGION 'Carregando a lista de funcionalidades liberadas'}
    TekProtClient := TTekProtClient.Create(Self);
    try
      TekProtClient.Server := ServidorProtecao;
      TekProtClient.Port   := PortaProtecao;

      // A função abaixo retorna erros no result, assim uma pequena gambia
      // para saber se o retorno que está chegando é um erro ou o valor esperado
      sRetorno := TekProtClient.GetLicenseInfo(liClientInfo);
      if Pos('Ocorreram falhas', sRetorno) > 0 then
        raise Exception.Create(sRetorno);

      Lista := TStringList.Create;
      try
        TFuncoesString.DividirParaStringList(Lista, sRetorno, '|');
        with Lista do
        begin
          // FCodigoClienteTek                  := Strings[0];
          // FCNPJClienteTek                    := Strings[1];
          // FNomeClienteTek                    := Strings[2];
          // FEmpresasDisponiveis               := Strings[3];
          FCDSFuncionalidadesLiberadas.XMLData := Strings[4];
        end;
      finally
        Lista.Free;
      end;
    finally
      TekProtClient.Free;
    end;
{$ENDREGION}
    FCDSFuncionalidadesLiberadas.IndexFieldNames := 'ALIAS';
    FCDSFuncionalidadesLiberadas.First;
  end;

  Result := FCDSFuncionalidadesLiberadas.FindKey([AnsiUpperCase(LabelFuncionalidade)]);
end;

procedure TSMConexao.CarregarUnitsProtegidas;
var
  X  : Integer;
  MS : TMemoryStream;
  CDS: TClientDataSet;
begin
  if (CDSUnitsProtegidas.Active) then
    Exit;

  with CDSUnitsProtegidas do
  begin
    with FieldDefs do
    begin
      Clear;
      Add('NOME', ftString, 60);
      Add('CODIFICACAO', ftMemo);
    end;
    CreateDataSet;
    LogChanges := False;

    MS  := TMemoryStream.Create;
    CDS := TClientDataSet.Create(nil);
    try
      for X := Low(mModelosUnits) to High(mModelosUnits) do
        if (Trim(mModelosUnits[X, 3]) <> '') then
        begin
          MS.Clear;
          TFuncoesSistemaOperacional.LerRecursoDLL(mModelosUnits[X, 1], NomeDLLModelosUnits, MS);
          CDS.LoadFromStream(MS);

          Append;
          FieldByName('NOME').AsString        := AnsiUpperCase(mModelosUnits[X, 1]);
          FieldByName('CODIFICACAO').AsString := CDS.FieldByName('CODIFICACAO_UNIT').AsString;
          Post;
        end;
    finally
      CDS.Free;
      MS.Free;
    end;

    IndexFieldNames := 'NOME';
  end;
end;

procedure TSMConexao.CarregarProcessamentosProtegidos;
var
  X  : Integer;
  MS : TMemoryStream;
  CDS: TClientDataSet;
begin
  if (CDSProcessamentosProtegidos.Active) then
    Exit;

  with CDSProcessamentosProtegidos do
  begin
    with FieldDefs do
    begin
      Clear;
      Add('CODIGOTEKSYSTEM', ftString, 60);
      Add('CODIFICACAO', ftMemo);
    end;
    CreateDataSet;
    LogChanges := False;

    MS  := TMemoryStream.Create;
    CDS := TClientDataSet.Create(nil);
    try
      for X := Low(mModelosProcessamentos) to High(mModelosProcessamentos) do
        if (Trim(mModelosProcessamentos[X, 4]) <> '') then
        begin
          MS.Clear;
          TFuncoesSistemaOperacional.LerRecursoDLL(mModelosProcessamentos[X, 1], NomeDLLModelosProcessamentos, MS);
          CDS.LoadFromStream(MS);

          Append;
          FieldByName('CODIGOTEKSYSTEM').AsString := AnsiUpperCase(mModelosProcessamentos[X, 1]);
          FieldByName('CODIFICACAO').AsString     := CDS.FieldByName('CODIFICACAO_PROC').AsString;
          Post;
        end;
    finally
      CDS.Free;
      MS.Free;
    end;

    IndexFieldNames := 'CODIGOTEKSYSTEM';
  end;
end;

function TSMConexao.UnitsProtegidas: OleVariant;
var
  CDSTemp: TClientDataSet;
begin
  CarregarUnitsProtegidas;

  CDSTemp := TClientDataSet.Create(nil);
  try
    CDSTemp.Data := CDSUnitsProtegidas.Data;

    with CDSTemp do
    begin
      LogChanges := False;
      First;
      while (not eof) do
      begin
        Edit;
        FieldByName('CODIFICACAO').AsString := TrimRight(TFuncoesCriptografia.Codifica(FieldByName('CODIFICACAO').AsString, sChaveCriptografia));
        Post;

        Next;
      end;
    end;

    Result := CDSTemp.Data;
  finally
    CDSTemp.Free;
  end;
end;

function TSMConexao.ProcessamentosProtegidos: OleVariant;
var
  CDSTemp: TClientDataSet;
begin
  CarregarProcessamentosProtegidos;

  CDSTemp := TClientDataSet.Create(nil);
  try
    CDSTemp.Data := CDSProcessamentosProtegidos.Data;

    with CDSTemp do
    begin
      LogChanges := False;
      First;
      while (not eof) do
      begin
        Edit;
        FieldByName('CODIFICACAO').AsString := TrimRight(TFuncoesCriptografia.Codifica(FieldByName('CODIFICACAO').AsString, sChaveCriptografia));
        Post;

        Next;
      end;
    end;

    Result := CDSTemp.Data;
  finally
    CDSTemp.Free;
  end;
end;

procedure TSMConexao.VerificarUsoUnidadeCodificaoLiberado(CodigoTekSystemDaUnidadeCodifica: string);
var
  i: Integer;
begin
  if (Pos('TEK_', AnsiUpperCase(CodigoTekSystemDaUnidadeCodifica)) = 1) then
    for i := Low(mModelosUnits) to High(mModelosUnits) do
      if (AnsiUpperCase(mModelosUnits[i, 1]) = AnsiUpperCase(CodigoTekSystemDaUnidadeCodifica)) then
      begin
        if (Trim(mModelosUnits[i, 3]) <> '') and
          (not FuncionalidadeLiberada(mModelosUnits[i, 3])) then
        begin
          raise EFuncionalidadeNaoLiberada.Create(MensagemPersonalizadaServidorApl +
            'Para executar/usar a unidade de codificação ' + CodigoTekSystemDaUnidadeCodifica + ' é necessário que a Tek-System faça a liberação.' + #13#13 +
            'Favor entrar em contato, informando o nome da funcionalidade: ' + mModelosUnits[i, 3]);
        end;
        Break;
      end;
end;

end.
