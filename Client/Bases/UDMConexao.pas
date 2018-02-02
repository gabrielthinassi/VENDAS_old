unit UDMConexao;

interface

uses
  SysUtils, Classes, FMTBcd, Vcl.Graphics, Controls, Forms, Menus, Dialogs, AppEvnts, Registry, Variants, ExtCtrls, ShellApi, ComCtrls, ActiveX,
  Windows, Messages, IniFiles, StdCtrls, IdStack, DB, DBClient, SqlExpr, Provider, System.Math, System.StrUtils, DateUtils, IndyPeerImpl, Datasnap.DSHTTPCommon,
  Data.DBXCommon, Data.DBXDataSnap, Datasnap.DSConnect, DBXJSONReflect, DSProxy, System.Json, IPPeerClient, System.ImageList, DSHTTPLayer,
  ImgList, DBGrids, JvDBGrid,  Rdprint, ComponentesDPR, NewBtn, KeyNav, JvDesktopAlert, SynEditHighlighter, SynHighlighterPas, SynHighlighterSQL,
  frxClass, frxDsgnIntf, frxNetUtils, frxRes, frxExportCSV, frxExportImage, frxExportText, frxExportXML, frxExportODF, frxExportXLS,
  frxExportHTML, frxExportMail, frxExportPDF, frxDMPExport, frxDCtrl, frxADOComponents, frxDBXComponents, fcxExportCSV, fcxExportDBF, fcxExportHTML, fcxExportBIFF,
  fcxExportODF, fcxCustomExport, fcxExportXML,
  TekPesquisaGrid, TekProtClient, UTekProtTypes, UTekProtConsts,
  {$IF DEFINED(FATURAMENTO) OR DEFINED(ESTOQUE) OR DEFINED(LIVROSFISCAIS) OR DEFINED(ANEXO)} ClassConfigACBr, ClassConfigCTe, ClassConfigMDFe, {$ENDIF}
  LF_Constantes, ClassEnviarEmail, ClassUsuario_CFG_Email, ClassSecaoAtualNovo, FuncoesCallBack2;

function HtmlHelp(hwndCaller: THandle; pszFile: PAnsiChar; uCommand: cardinal; dwData: longint): THandle; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';

type
  EFuncionalidadeNaoLiberada = class(Exception);

  TDMConexao = class(TDataModule)
    KeyNavigator1: TKeyNavigator;
    CDSServidores: TClientDataSet;
    CDSServidoresOrdem: TIntegerField;
    CDSServidoresServidor: TStringField;
    CDSServidoresPorta: TIntegerField;
    PopupMenuGrid: TPopupMenu;
    OcultarColuna1: TMenuItem;
    ReexibirColunas1: TMenuItem;
    N1: TMenuItem;
    PesquisaIncremental1: TMenuItem;
    Exportar1: TMenuItem;
    GridParaHTML1: TGridParaHTML;
    DataSetParaCSV1: TDataSetParaCSV;
    SaveDialogGrid: TSaveDialog;
    CDSDefaults: TClientDataSet;
    RDprint1: TRDprint;
    ApplicationEvents1: TApplicationEvents;
    SaveDialogReg: TSaveDialog;
    OpenDialogReg: TOpenDialog;
    ImageList1: TImageList;
    CopiarRegistrosparareadeTransferncia1: TMenuItem;
    SeparadorFuncaoAgregacao: TMenuItem;
    FuncoesdeAgregacao1: TMenuItem;
    SomarColuna1: TMenuItem;
    ContarRegistros1: TMenuItem;
    MediaColuna1: TMenuItem;
    CDSServidoresDescricao: TStringField;
    frxExportaPDF: TfrxPDFExport;
    frxExportaMail: TfrxMailExport;
    frxExportaHTML: TfrxHTMLExport;
    frxExportaXLS: TfrxXLSExport;
    frxExportaODS: TfrxODSExport;
    frxExportaODT: TfrxODTExport;
    frxExportaXML: TfrxXMLExport;
    frxExportaBMP: TfrxBMPExport;
    frxExportaSimpleText: TfrxSimpleTextExport;
    frxExportaJPEG: TfrxJPEGExport;
    frxExportCSV: TfrxCSVExport;
    frxDialogControls1: TfrxDialogControls;
    frxDotMatrixExport1: TfrxDotMatrixExport;
    Todaagrade1: TMenuItem;
    ApenasColunaAtual1: TMenuItem;
    ApenasLinhaAtual1: TMenuItem;
    CDSServidoresProxy_Host: TStringField;
    CDSServidoresProxy_Porta: TIntegerField;
    CDSServidoresProxy_Usuario: TStringField;
    CDSServidoresProxy_Senha: TStringField;
    CDSServidoresProtecao_Host: TStringField;
    CDSServidoresProtecao_Porta: TIntegerField;
    CDSServidoresSecundario_Host: TStringField;
    CDSServidoresSecundario_Porta: TIntegerField;
    SQLConexao: TSQLConnection;
    CDSPermissoes: TClientDataSet;
    CDSConfigCamposClasses: TClientDataSet;
    CDSAtalhos: TClientDataSet;
    DSPCCadAtalho: TDSProviderConnection;
    CDSConfigClasses: TClientDataSet;
    CDSIndicadores: TClientDataSet;
    FuncoesdeAtribuicao: TMenuItem;
    Formula: TMenuItem;
    Arredondarpara2casasdecimais: TMenuItem;
    Arredondarpara1casadecimal: TMenuItem;
    Arredondarparaunidade: TMenuItem;
    Arredondarparadezena: TMenuItem;
    Ajustarparaprximointeiro: TMenuItem;
    Ajustarparainteiroanterior: TMenuItem;
    Atribuirvalorfixo: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    FiltrarRegistros1: TMenuItem;
    frxADOComponents1: TfrxADOComponents;
    frxDBXComponents1: TfrxDBXComponents;
    AnalisaremCubodeDeciso1: TMenuItem;
    N5: TMenuItem;
    SynPasSynPadrao: TSynPasSyn;
    SynSQLSynPadrao: TSynSQLSyn;
    fcxXMLExport1: TfcxXMLExport;
    fcxODSExport1: TfcxODSExport;
    fcxBIFFExport1: TfcxBIFFExport;
    fcxHTMLExport1: TfcxHTMLExport;
    fcxDBFExport1: TfcxDBFExport;
    fcxCSVExport1: TfcxCSVExport;
    AutoAjusteColunas1: TMenuItem;
    TekPesquisaGrid1: TTekPesquisaGrid;
    CDSServidoresTipo: TSmallintField;
    CDSServidoresRede: TSmallintField;
    ApenasClulaatual1: TMenuItem;
    SeparadorOpcoesAgregacao: TMenuItem;
    ContarRegistrosMarcados1: TMenuItem;
    SomarColunaapenasdosRegistrosMarcados1: TMenuItem;
    MediaAritmeticadaColunaapenasdosRegistrosMarcados1: TMenuItem;
    procedure OcultarColuna1Click(Sender: TObject);
    procedure ReexibirColunas1Click(Sender: TObject);
    procedure PesquisaIncremental1Click(Sender: TObject);
    procedure Exportar1Click(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure PopupMenuGridPopup(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ContarRegistros1Click(Sender: TObject);
    procedure SomarOuMediaColuna1Click(Sender: TObject);
    procedure AtribuicaoClick(Sender: TObject);

    procedure MeuBotaoOkB_Click(Sender: TObject);
    procedure frxExportaMailBeginExport(Sender: TObject);

    procedure Todaagrade1Click(Sender: TObject);
    procedure ApenasColunaAtual1Click(Sender: TObject);
    procedure ApenasLinhaAtual1Click(Sender: TObject);
    procedure SQLConexaoAfterConnect(Sender: TObject);
    procedure SQLConexaoAfterDisconnect(Sender: TObject);
    procedure CDSIndicadoresNewRecord(DataSet: TDataSet);
    procedure CDSIndicadoresAfterInsert(DataSet: TDataSet);
    procedure FiltrarRegistros1Click(Sender: TObject);
    function frxExportaMailSendMail(const Server: string; const Port: Integer; const UserField, PasswordField: string; FromField, ToField, SubjectField,
      CompanyField, TextField: WideString; FileNames: TStringList; Timeout: Integer; ConfurmReading: Boolean; MailCc, MailBcc: WideString): string;
    procedure AnalisaremCubodeDeciso1Click(Sender: TObject);
    procedure AutoAjusteColunas1Click(Sender: TObject);
    procedure CDSServidoresRedeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure CDSServidoresTipoGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure CDSServidoresAfterOpen(DataSet: TDataSet);
    procedure CDSServidoresBeforePost(DataSet: TDataSet);
    procedure ApenasClulaatual1Click(Sender: TObject);
  private
    fSecaoAtual: TClassSecaoNovo;
    fConfig: TConfigNovo;

    ConexaoTratada: Boolean;

    FormMailExportDialog: TfrxMailExportDialog;

    FStatusDeMensagens, FStatusSAC: Integer;
    FContadorTransacoesTemporarias: Integer;
    LendoHelp: Boolean;

    {$region 'TekProt'}
    FCodigoClienteTek: string;
    FNomeClienteTek: string;
    FCNPJClienteTek: string;
    FEmpresasDisponiveis:string;
    FFuncionalidadesDisponiveis:string;
    procedure QuandoNaoAutorizado(Sender: TObject; prResult: TVlResult);
    procedure AposValidar(Sender: TObject; prResult: TVlResult);
    {$endregion}

    procedure TrataOciosidade(var Msg: tagMSG);
    procedure TrataHelp(var Msg: tagMSG);

    procedure SetStatusDeMensagens(const Value: Integer);
    procedure SetStatusSAC(const Value: Integer);
    procedure TrataMensagemDeFechamento(TemMensagem: Boolean);

    procedure ExtrairModeloRelPai;
    procedure VerificaTrocaDeSenha;

    function CallbackMethod(const Args: TJSONValue): TJSONValue;

    procedure CarregarListaDeTabelasEProceduresDoBDD;
    procedure CarregarUnitsProtegidas;
    procedure CarregarProcessamentosProtegidos;
  public
    TekProtClient: TTekProtClient;

    CDSUnitsProtegidas: TClientDataSet;
    CDSProcessamentosProtegidos: TClientDataSet;

    LogoEmpresa: TPicture;

    PrimeiraVezDoTimer: cardinal;
    cDataHoraServidorNaEntrada, cDataHoraServidor: TDateTime;
    ServidorBDD, VersaoBDD: string;
    ConexaoBDD_Tipo: Integer;

    DestinatarioPadraoEmailRelatorio, AssuntoPadraoEmailRelatorio: string;
    Flag_EnviaEmail_ServidorEmail_EmailSeguro, Flag_EnviaEmail_ServidorEmail_TLS: Boolean;
    Flag_EnviaEmail_Metodo: Integer;
    Flag_EnviandoRelatorioFastReport: Boolean;

    CallBack: TClienteCallback;

    procedure FecharSistema;

    procedure EntrarNoSistema(TrocaInterna: Boolean);
    function ConectaServidorAplicacao(cUsuario, cSenha: string; iQuebra: Integer): Boolean;
    procedure LerServidoresAplicacao;
    procedure AbrirHelp;

    /// <summary>
    ///   Verifica se uma funcionalidade protegida da sistema está liberada para a empresa.
    /// </summary>
    /// <param name="LabelFuncionalidade">
    ///   Código único de funcionalidade definido no Tekprot
    /// </param>
    function FuncionalidadeLiberada(LabelFuncionalidade: String): Boolean;

    /// <summary>
    ///   Verifica se o processamento é protegido e se está liberado para uso pela empresa.
    /// </summary>
    /// <param name="CodigoTekSystemDoProcessamento">
    ///   código único do processamento definido pela Tek-system
    /// </param>
    function ExecucaoDeProcessamentoLiberado(CodigoTekSystemDoProcessamento: string): Boolean;

    /// <summary>
    ///   Verifica se uma unidade de codificação é protegida e se está liberada
    ///   para uso pela empresa.
    /// </summary>
    /// <param name="CodigoTekSystemDaUnidadeCodifica">
    ///   Código único da unidade de codificação definido pela Tek-system
    /// </param>
    /// <exception cref="EFuncionalidadeNaoLiberada">
    ///   Caso a unidade de codificação seja protegida, mas não esteja liberada
    /// </exception>
    procedure VerificarUsoUnidadeCodificaoLiberado(CodigoTekSystemDaUnidadeCodifica: string);

    function ExecuteMethods(Metodo: string; Parametros_Valor: array of OleVariant): OleVariant;
    function ExecuteMethods_ComCallBack(Metodo: string; Parametros_Valor: array of OleVariant): OleVariant;
    function ExecuteMethods_SegundoPlano(Titulo, Metodo: string; Parametros_Valor: array of OleVariant): OleVariant;

    function ExecuteReader(sql: string; TamanhoPacote: Integer = 1000; MonitoraSQL: Boolean = True): OleVariant;
    function ExecuteScalar(sql: string; MonitoraSQL: Boolean = True): OleVariant;
    function ExecuteCommand(sql: WideString; MonitoraSQL: Boolean = True): int64;
    function ExecuteCommand_Update(sql: WideString; Campo: string; Valor: OleVariant; MonitoraSQL: Boolean = True): int64;

    function ProximoCodigo(Tabela: string; Quebra: Integer = 0): int64;
    function ProximoCodigoAcrescimo(Tabela: string; Quebra: Integer = 0; Acrescimo: Integer = 1): int64;

    function DataHora: TDateTime;
    function DataHoraServidor(ForcaHoraServidor: Boolean = false): TDateTime;

    procedure RegistraAcao(Descricao: string; Inicio, Fim: TDateTime; Observacao: string);

    procedure CarregaDefaults;
    procedure AtribuirOutrosDefault(DS: TDataSet; Tabela: string);

    procedure CarregaPermissoesDoCadastro;
    procedure CarregaConfigCamposClasses;
    procedure CarregaConfigClasses;
    procedure CarregaMensagem;
    procedure CarregaSecaoAtual;
    procedure CarregaModulosDisp(var CDS: TClientDataSet);

    function GetCDSConfigCamposClasses: OleVariant;
    function GetCDSConfigClasses: OleVariant;

    procedure ChamarConfig(ReLer: Boolean = True);

    procedure ExportarRegistrosCDS(Tabela, NomeDoArquivo: string; CDSOrigem: TClientDataSet);
    procedure ImportarRegistrosParaCDS(BotaoIncluir, BotaoGravar: TNewBtn;
      Tabela, NomeDoArquivo: string; CDSDestino: TClientDataSet;
      AntesDeGravar: TDataSetNotifyEvent = nil; AntesDeAceitar: TDataSetNotifyEvent = nil);

    function VerificaAutorizacao(cOpcao: Integer): Boolean; overload;
    function VerificaAutorizacao(sOpcao: string): Boolean; overload;
    function VerificaAutorizacao_ComOutroUsuario(cUsuario, cOpcao: Integer): Boolean;

    {$region 'Relacionados a dia não útil'}
    procedure CarregaDiasNaoUteis(Modulo: Integer);
    procedure ReCarregaDiasNaoUteis(Modulo: Integer);
    procedure DesCarregaDiasNaoUteis;
    function DiaUtil(cData: TDate; Modulo: Integer; Cidade: Integer = 0): Boolean;
    function ProximoDiaUtil(Data: TDate; Modulo: Integer; Cidade: Integer = 0): TDate;
    function DiaUtilAnterior(Data: TDate; Modulo: Integer; Cidade: Integer = 0): TDate;
    function DiasUteisEntre(dDataInicial, dDataFinal: TDateTime; Modulo: Integer; Cidade: Integer = 0): Integer;
    function DiasEntre(dDataInicial, dDataFinal: TDate; iSistema: Integer; bDiaUtil, bPermiteNegativo: Boolean): Integer;
    {$endregion}

    function GetContadorTransacoesTemporarias: Integer;
    property ContadorTransacoesTemporarias: Integer read GetContadorTransacoesTemporarias;

    function Ler(Campos, Tabela: string; Ordem: Integer; Where: string = ''): OleVariant;
    function Acha(Tabela, Campo: string; Valor: Variant; CampoEmpresa: string = ''; CodigoDaEmpresa: Integer = -1): Boolean;

    property StatusDeMensagens: Integer read FStatusDeMensagens write SetStatusDeMensagens;
    property StatusSAC: Integer read FStatusSAC write SetStatusSAC;

    {$region 'Relacionados a Atualização do Sistema'}
    procedure AtualizarModelosRelatorios(MostrarMensagem: Boolean);
    procedure AtualizarModelosIndicadores(MostrarMensagem: Boolean);
    procedure AtualizarConfigRemessaRetornoBanc(MostrarMensagem: Boolean);
    procedure AtualizarImportaExportaTitulos(MostrarMensagem: Boolean);
    procedure AtualizarModelosDataWarehouse(MostrarMensagem: Boolean);
    procedure AtualizarModelosRelatoriosEspecificos(MostrarMensagem: Boolean);
    procedure AtualizarDeptoPessoal(MostrarMensagem: Boolean);
    procedure AtualizarESocial(MostrarMensagem: Boolean);
    procedure AtualizarLivroFiscal(MostrarMensagem: Boolean);
    procedure AtualizarContabilidade(MostrarMensagem: Boolean);
    procedure AtualizarModelosUnidadesCodificacao(MostrarMensagem: Boolean);
    procedure AtualizarModelosProcessamentos(MostrarMensagem: Boolean);
    {$endregion}

    procedure ExecutaRelatorioGR(CodigoRel: Integer; Filtros: OleVariant; Formato: Integer; ProcessarLocal, EmSegundoPlano: Boolean);

    function PegaEmpresaDoMovimentoEstoque(iEmp: Integer): Integer;
    function PegaEmpresasFicticias(iEmp: Integer): String;

    procedure AbrirArquivoDoAlert(Sender: TObject);

    procedure DBGridToClipBoard(DBGrid: TDBGrid; ComCabecalho, ApenasLinhaAtual, ApenasColunaAtual: Boolean);
    procedure HabilitarOpcaoDeFiltrarGrade(Grade: TDBGrid);

    // Funcoes utilizadas como property nas Units de emissão de NFe/CTe/MDFe
    function Funcao_AcbrExecuteCommand(s: string): int64;
    function Funcao_AcbrExecuteReader(s: string): OleVariant;
    function Funcao_AcbrExecuteScalar(s: string): OleVariant;
    function Funcao_AcbrProximoCodigo(s: string): OleVariant;

    procedure CallBack_AbreTela(ID: string; Mensagem: string = '');
    procedure CallBack_FechaTela(ID: string);
    procedure CallBack_Mensagem(ID, Mensagem: string);
    procedure CallBack_Incremento(ID: string; Atual, Total: Integer; Mensagem: string = '');

    // -- \\
    procedure MostrarLog(TextoDoLog: string; MostrarNoRichEdit: Boolean = True; ExibirLandscape: Boolean = false); overload; deprecated 'Usar ULogSistema.Mostrar ...';
    procedure MostrarLog(TextoDoLog: TStrings; MostrarNoRichEdit: Boolean = True; ExibirLandscape: Boolean = false); overload; deprecated 'Usar ULogSistema.Mostrar ...';
    procedure MostrarLog(MostrarNoRichEdit: Boolean; NomeDoArquivoDeLog: WideString; ExibirLandscape: Boolean = false); overload; deprecated 'Usar ULogSistema.Mostrar ...';
    procedure MostrarLog(DataSet: TClientDataSet; NomeDoCampo: String; Titulo: string = ''; ExibirLandscape: Boolean = false); overload; deprecated 'Usar ULogSistema.Mostrar ...';
    procedure MostrarLog(TextoDoLog, Titulo: String; MostrarNoRichEdit: Boolean = True; ExibirLandscape: Boolean = false); overload; deprecated 'Usar ULogSistema.Mostrar ...';
    // -- \\

    property Config: TConfigNovo read fConfig write fConfig;
    property SecaoAtual: TClassSecaoNovo read fSecaoAtual;

    property CodigoClienteTek: string read FCodigoClienteTek;
    property CNPJClienteTek: string read FCNPJClienteTek;
    property NomeClienteTek: string read FNomeClienteTek;
    property EmpresasDisponiveis: string read FEmpresasDisponiveis;
  end;

var
  DMConexao: TDMConexao;

const
  cServTipo_SoftwareCenter = 0;
  cServTipo_TekServer = 1;

  cServRede_Intranet = 0;
  cServRede_Extranet = 1;

implementation

uses Constantes, ConstanteSistema, ConstantesRelatorios, ConstantesCallBack,
  FuncoesDataSnap, TrataErros, Debug, Encrypt_decrypt,
  ClassArquivoINI, ClassCaixasDeDialogos, ClassFuncoesNumero, ClassFuncoesString, ClassFuncoesSistemaOperacional, ClassFuncoesConversao,
  ClassFuncoesBaseDados, ClassHelperGrid, ClassHelperDataSet, ClassFuncoesCriptografia, ClassFuncoesData,
  ClassGerarRelatorioEspecifico, ClassMensagens, ClassCntrlDiasUteis, ClassPaiProcessamento,
  ConstantesModelosProcessamentos, ConstantesModelosUnidadesCodificacao, Funcoes_TekConnects, GetTexts
  {$IF DEFINED(FATURAMENTO) OR DEFINED(ESTOQUE) OR DEFINED(LIVROSFISCAIS) OR DEFINED(ANEXO)}
  , FuncoesConfigACBr, ClassConfigNFSe
  {$ELSEIF DEFINED(ESOCIAL)}
  , FuncoesConfigACBr, ClassConfigESocial, ClassConfigReInf
  {$ENDIF}
  , UConfigServApl, USplash, ULogin, URegresso, UDMDownload, UPrincipal, UAguarde, UAguarde2, UPainelBordo, UFechaTekProt,
  UDlgSelecionaContaEmail, UPainelBordo2, UDefineFormulaCampo, ULogSistema, UCuboDeDecisao, UTrocaSenha, ConstantesACBrDFe;
{$R *.dfm}

var
  CntrlDiasNaoUteis: TClassCntrlDiasUteis;

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  PrimeiraVezDoTimer := 0;
  FContadorTransacoesTemporarias := 0;
  FStatusDeMensagens := cStatusDeMensagens_SemMensagem;
  FStatusSAC := 0;
  LendoHelp := false;
  ConexaoTratada := false;

  ApplicationEvents1.OnMessage := nil; // Será recolocado quando a tela principal for exibida

  FSplash.Passo(15, 'Configurando e Testando Ambiente');
  TFuncoesSistemaOperacional.AcertarConfigRegional;
  if not TFuncoesSistemaOperacional.ImpressoraInstalada then
    begin
      TCaixasDeDialogo.Informacao('Não existem impressoras instaladas nesse computador. Instale uma e volte a executar o sistema');
      FecharSistema;
    end;

  ClassArquivoINI.TArquivoINI.NomeArquivoPadrao := Constantes.ArquivoIniClient;
  ClassArquivoINI.TArquivoINI.PathArquivoPadrao := ExtractFilePath(Application.ExeName);

  fConfig := TConfigNovo.Create;
  fSecaoAtual := TClassSecaoNovo.Create;

  CallBack := TClienteCallback.Create;
  CallBack.CallbackMethod := CallbackMethod;

  //TekPesquisaGrid1.ArquivoINI := ExtractFilePath(Application.ExeName) + ArquivoIniClient;

  Constantes.DMConexaoExistente := Self;

  with SQLConexao do
    begin
      Params.Values['Sistema']    := IntToStr(ConstanteSistema.Sistema);
      Params.Values['IP']         := SecaoAtual.IP;
      Params.Values['Host']       := SecaoAtual.Host;
      Params.Values['Plataforma'] := Constantes.sPlataformaAtual;
    end;

  CDSUnitsProtegidas          := TClientDataSet.Create(Self);
  CDSProcessamentosProtegidos := TClientDataSet.Create(Self);

  EntrarNoSistema(false);

  FSplash.Passo(70, 'Configurações Adicionais do DMConexão');

  if FileExists(TFuncoesSistemaOperacional.DiretorioComBarra(Config.DirExe) + ChangeFileExt(Modulos[Sistema, 1], '.CHM')) then
    Application.HelpFile := TFuncoesSistemaOperacional.DiretorioComBarra(Config.DirExe) + ChangeFileExt(Modulos[Sistema, 1], '.CHM')
  else
    if FileExists(TFuncoesSistemaOperacional.DiretorioComBarra(Config.DirExe) + ArquivoHelpGeral) then
    Application.HelpFile := TFuncoesSistemaOperacional.DiretorioComBarra(Config.DirExe) + ArquivoHelpGeral;

  ExtrairModeloRelPai;

  Debug.PopupMenuGradeDebugDataSet := PopupMenuGrid;

{$IF DEFINED(FATURAMENTO) OR DEFINED(ESTOQUE) OR DEFINED(LIVROSFISCAIS) OR DEFINED(ANEXO)}
  if not ClassFuncoesSistemaOperacional.IsDebuggerPresent() then
    begin
      TThread.CreateAnonymousThread(
        procedure()
        begin
          TClassConfigACBr.ExtraiSchemasXMLNFe(ConstantesACBrDFe.sisERP);
          TClassConfigCTe.ExtraiSchemasXMLCTe(ConstantesACBrDFe.sisERP);
          TClassConfigMDFe.ExtraiSchemasXMLMDFe(ConstantesACBrDFe.sisERP);
          TClassConfigNFSe.ExtraiSchemasXMLNFSe(ConstantesACBrDFe.sisERP, NomeSchemaProvedorNFSe(DMConexao.SecaoAtual.Parametro.NFSe_Provedor));
        end
        ).Start;
    end;
{$ELSEIF DEFINED(ESOCIAL)}
  if not ClassFuncoesSistemaOperacional.IsDebuggerPresent() then
    begin
      TThread.CreateAnonymousThread(
        procedure()
        begin
          TClassConfigESocial.ExtraiSchemasXMLESocial(ConstantesACBrDFe.sisERP, '');
          TClassConfigReInf.ExtraiSchemasXMLReInf(ConstantesACBrDFe.sisERP, '');
        end
        ).Start;
    end;
{$ENDIF}
  Flag_EnviandoRelatorioFastReport := false;
  DestinatarioPadraoEmailRelatorio := '';
  AssuntoPadraoEmailRelatorio := '';

  try
    PrimeiraVezDoTimer := 0;
    cDataHoraServidorNaEntrada := DataHoraServidor(True);
    cDataHoraServidor := cDataHoraServidorNaEntrada;
  except
    On E: Exception do
      raise Exception.Create('Erro em DataHoraServidor: ' + E.Message);
  end;

  CarregaDefaults;
  CarregaConfigClasses;
  CarregarUnitsProtegidas;
  CarregarProcessamentosProtegidos;

  with CDSAtalhos do
    begin
      RemoteServer := DSPCCadAtalho;
      FetchParams;
    end;

  CarregarListaDeTabelasEProceduresDoBDD;
end;

procedure TDMConexao.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(LogoEmpresa) then
    FreeAndNil(LogoEmpresa);

  if Assigned(CntrlDiasNaoUteis) then
    FreeAndNil(CntrlDiasNaoUteis);

  if Assigned(TekProtClient) then
  begin
    TekProtClient.OnAfterValidate := nil;
    TekProtClient.OnGetCloseApp := nil;
    FreeAndNil(TekProtClient);
  end;

  if Assigned(Config) then
    FreeAndNil(fConfig);

  if SQLConexao.Connected then
    SQLConexao.Close;

  if Assigned(SecaoAtual) then
    FreeAndNil(fSecaoAtual);

  if Assigned(CallBack) then
    FreeAndNil(CallBack);

  if Assigned(CDSUnitsProtegidas) then
    CDSUnitsProtegidas.Free;

  if Assigned(CDSProcessamentosProtegidos) then
    CDSProcessamentosProtegidos.Free;

  Constantes.DMConexaoExistente := nil;
end;

{$REGION 'TekProt'}
procedure TDMConexao.AposValidar(Sender: TObject; prResult: TVlResult);
begin
  if (prResult.ResultCod = 'VLTPSRV101') then
    TCaixasDeDialogo.Informacao('Estação habilitada com sucesso!')
  else if (prResult.ResultCod = 'VLTPSRV102') then
    begin
      ExecuteMethods('TSMConexao.AtribuirSistemaSomenteLeitura', []);
      CarregaSecaoAtual;
      TCaixasDeDialogo.Informacao('Sistema está operando em modo somente-leitura');
    end
  else if (prResult.ResultCod <> 'VLTPSRV100') and
          (prResult.ResultCod <> 'VLTPSRV101') then
  begin
    if TCaixasDeDialogo.Confirma(prResult.ResultMsg + #13 + 'Deseja configurar servidor de proteção?') then
      begin
        ChamarConfig(True);
        TekProtClient.validarLicenca;//(60 * 60 * 1000);
      end
    else
      FecharSistema;
  end;
end;

procedure TDMConexao.QuandoNaoAutorizado(Sender: TObject; prResult: TVlResult);
var tpDateTime: TDateTime;
begin
  TCaixasDeDialogo.Aviso(
    'Problemas ao efetuar validação da sua estação de trabalho.' + #13 +
    'Salve as informações não gravadas pois o sistema será finalizado. ' + #13#13 +
    'Mensagem retornada: ' + prResult.ResultMsg);

  fFechamentoTekProt := TfFechamentoTekProt.Create(Self);
  try
    fFechamentoTekProt.Show;
    tpDateTime := EncodeTime(0, 1, 0, 0);
    while FormatDateTime('nn:ss', tpDateTime) <> '00:00' do
      begin
        tpDateTime := IncSecond(tpDateTime, -1);
        fFechamentoTekProt.Label1.Caption := 'Estação não liberada para uso' + #13 +
                                             'Sistema será finalizado.' + #13#13 +
                                             'Tempo restante: ' + FormatDateTime('nn:ss', tpDateTime);
        Application.ProcessMessages;
        Sleep(1000);
      end;

    fFechamentoTekProt.Close;
  finally
    FreeAndNil(fFechamentoTekProt);
  end;

  FecharSistema;
end;

function TDMConexao.FuncionalidadeLiberada(LabelFuncionalidade: String): Boolean;
var
  tpClientDataSet:TClientDataSet;
begin
  tpClientDataSet := TClientDataSet.Create(Self);
  try
    with tpClientDataSet do
      begin
        XMLData := FFuncionalidadesDisponiveis;
        IndexFieldNames := 'ALIAS';
        First;
        Result := FindKey([AnsiUpperCase(LabelFuncionalidade)]);
        Close;
      end;
  finally
    if Assigned(tpClientDataSet) then
      FreeAndNil(tpClientDataSet);
  end;
end;

function TDMConexao.ExecucaoDeProcessamentoLiberado(CodigoTekSystemDoProcessamento: string): Boolean;
var I: Integer;
begin
  Result := True;

  if (Trim(CodigoTekSystemDoProcessamento) <> '') then
    for I := Low(mModelosProcessamentos) to High(mModelosProcessamentos) do
      if (AnsiUpperCase(mModelosProcessamentos[I, 1]) = AnsiUpperCase(CodigoTekSystemDoProcessamento)) then
        begin
          if (Trim(mModelosProcessamentos[I, 4]) <> '') and
             (not DMConexao.FuncionalidadeLiberada(mModelosProcessamentos[I, 4])) then
            begin
              TCaixasDeDialogo.Informacao(
                'Para executar este processamento (' + CodigoTekSystemDoProcessamento + ') é necessário que a Tek-System libere sua execução.' + #13#13 +
                'Favor entrar em contato, informando o nome da funcionalidade: ' + mModelosProcessamentos[I, 4]);
              Result := False;
            end;
          Break;
        end;
end;

procedure TDMConexao.VerificarUsoUnidadeCodificaoLiberado(CodigoTekSystemDaUnidadeCodifica: string);
var I: Integer;
begin
  if (Pos('TEK_', AnsiUpperCase(CodigoTekSystemDaUnidadeCodifica)) = 1) then
    for I := Low(mModelosUnits) to High(mModelosUnits) do
      if (AnsiUpperCase(mModelosUnits[I, 1]) = AnsiUpperCase(CodigoTekSystemDaUnidadeCodifica)) then
        begin
          if (Trim(mModelosUnits[I, 3]) <> '') and
             (not DMConexao.FuncionalidadeLiberada(mModelosUnits[I, 3])) then
            begin
              raise EFuncionalidadeNaoLiberada.Create(
                'Para executar/usar a unidade de codificação ' + CodigoTekSystemDaUnidadeCodifica + ' é necessário que a Tek-System faça a liberação.' + #13#13 +
                'Favor entrar em contato, informando o nome da funcionalidade: ' + mModelosUnits[I, 3]);
            end;
          Break;
        end;
end;
{$ENDREGION}

{$REGION 'Execução de Metodos'}

function TDMConexao.ExecuteMethods(Metodo: string; Parametros_Valor: array of OleVariant): OleVariant;
begin
  // FINALIDADE: Executa metodo no servidor de aplicação
  // No parametro "Metodo" deve passar o TNomeSM.NomeFuncao, ex: ExecuteMethods('TSMConexao.DataHora', [])

  // Para processamentos mais demorados de preferencia em utilizar o método ExecuteMethods_ComCallBack
  // ATENÇÃO: Ao executa essa função dependendo do que é executado no metodo no servidor os calls vão chegar tudo de uma
  // vez no termino processo, nessa situação utilize o método ExecuteMethods_ComCallBack

  Result := FuncoesDataSnap.ExecuteMethods_Sincrono(SQLConexao, Metodo, Parametros_Valor, false);
end;

function TDMConexao.ExecuteMethods_ComCallBack(Metodo: string; Parametros_Valor: array of OleVariant): OleVariant;
var
  CriouTela: Boolean;
  EmProcessoAnt: Boolean;
begin
  // Para processamentos mais rápidos de preferencia em utilizar o método ExecuteMethods.
  // ATENÇÃO: Esse método faz a chamada do metódo do servidor dentro de uma Thread, assim o sistema ficaria livre para o usuário
  // manipular o sistema durante o processamento, assim, a função irá criar "película" para evitar o uso durante o processamento.

  EmProcessoAnt := EmProcesso;
  CriouTela := TFAguarde2.Ativar;
  try
    EmProcesso := True;
    Result := FuncoesDataSnap.ExecuteMethods_Assincrono(SQLConexao, Metodo, Parametros_Valor, false);
  finally
    EmProcesso := EmProcessoAnt;
    if CriouTela then
      TFAguarde2.Desativar;
  end;
end;

function TDMConexao.ExecuteMethods_SegundoPlano(Titulo, Metodo: string; Parametros_Valor: array of OleVariant): OleVariant;
var
  i: Integer;
  ParamConexao: TStrings;
  sParamConexao: string;
begin
  // ATENÇÃO: A execução desse metodo cria outra conexão, que é autenticada e executa uma serie de processamento,
  // assim deve ver ser utilizada com cautela para não sobrecarrega o servidor

  ParamConexao := TStringList.Create;
  try
    ParamConexao.Text := SQLConexao.Params.Text;
    ParamConexao.Values['Guid'] := '';
    ParamConexao.Values['OmitirAcesso'] := 'S';

    if (DMConexao.Config.ServidorRelatorio <> '') then
    begin
      ParamConexao.Values[TDBXPropertyNames.HostName] := DMConexao.Config.ServidorRelatorio;
      ParamConexao.Values[TDBXPropertyNames.Port] := IntToStr(DMConexao.Config.PortaRelatorio);
    end;
    sParamConexao := ParamConexao.Text;
  finally
    FreeAndNil(ParamConexao);
  end;

  i := FPrincipal.Processamento_Add(Titulo);
  try
    Result := FuncoesDataSnap.ExecuteMethods_Assincrono(sParamConexao, Metodo, Parametros_Valor, false);
  finally
    FPrincipal.Processamento_Del(i);
  end;
end;

function TDMConexao.ExecuteScalar(sql: string; MonitoraSQL: Boolean = True): OleVariant;
var
  Tempo: TTime;
begin
  // Executa a função ExecuteScalar do Servidor de Aplicação, que tem o objetivo de
  // executar um comando no BDD e retornar o primeiro campo do primeiro registro
  // Exemplo: Informacao('Total de Clientes: ' + IntToStr(ExecuteScalar('select count(*) from cliente')));

  Tempo := Time;
  if (FPrincipal <> nil) and (MonitoraSQL) then
    FPrincipal.AdicionaRich('ExecuteScalar', sql);

  Result := ExecuteMethods('TSMConexao.ExecuteScalar', [Trim(sql), True]);

  if (FPrincipal <> nil) and (MonitoraSQL) then
  begin
    Tempo := Time - Tempo;
    FPrincipal.AdicionaLinhaRich('Tempo Gasto em ExecuteScalar ==> ' + FormatDateTime(' hh:mm:ss.zzz', Tempo), clGreen, [fsBold]);
  end;
end;

function TDMConexao.ExecuteReader(sql: string; TamanhoPacote: Integer = 1000; MonitoraSQL: Boolean = True): OleVariant;
var
  Tempo: TTime;
begin
  // Executa a função ExecuteReader do Servidor de Aplicação, que tem o objetivo de
  // executar um comando no BDD e retornar todos os dados
  // Exemplo: ClientDataSet1.Data := ExecuteReader('select CODIGO_CLI, NOME_CLI from CLIENTE order by NOME_CLI');

  Tempo := Time;
  if (FPrincipal <> nil) and (MonitoraSQL) then
    FPrincipal.AdicionaRich('ExecuteReader', sql);

  Result := ExecuteMethods('TSMConexao.ExecuteReader', [Trim(sql), TamanhoPacote, True]);

  if (FPrincipal <> nil) and (MonitoraSQL) then
  begin
    Tempo := Time - Tempo;
    FPrincipal.AdicionaLinhaRich('Tempo Gasto em ExecuteReader ==> ' + FormatDateTime(' hh:mm:ss.zzz', Tempo), clGreen, [fsBold]);
  end;
end;

function TDMConexao.ExecuteCommand(sql: WideString; MonitoraSQL: Boolean = True): int64;
var
  Tempo: TTime;
begin
  // Executa a função ExecuteCommand do Servidor de Aplicação, que tem o objetivo de
  // executar comandos que não possuem resultado. Do tipo INSERT, DELETE, UPDATE.
  // Retornando o número de registros afetados
  // Exemplo: Informacao('Registros Atualizados:' + IntToStr(ExecuteCommand('update PRODUTO set SALDOFISICO_PRODUTO = SALDOFISICO_PRODUTO + 1 where EMPRESA_PRODUTO = 1 and CODIGO_PRODUTO = ''XXX''')));

  Tempo := Time;
  if (FPrincipal <> nil) and (MonitoraSQL) then
    FPrincipal.AdicionaRich('ExecuteCommand', sql);

  Result := TFuncoesConversao.VariantParaInt64(ExecuteMethods('TSMConexao.ExecuteCommand', [Trim(sql), True]));

  if (FPrincipal <> nil) and (MonitoraSQL) then
  begin
    Tempo := Time - Tempo;
    FPrincipal.AdicionaLinhaRich('Tempo Gasto em ExecuteCommand ==> ' + FormatDateTime(' hh:mm:ss.zzz', Tempo), clGreen, [fsBold]);
  end;
end;

function TDMConexao.ExecuteCommand_Update(sql: WideString; Campo: string; Valor: OleVariant; MonitoraSQL: Boolean = True): int64;
var
  Tempo: TTime;
begin
  // Executa a função ExecuteCommand_Update do Servidor de Aplicação, que tem o objetivo de
  // executar comandos tipo update de campos binários e memos, na sql passa o comando sql e
  // apos o campo afetado e o novo valor;
  // Retornando o número de registros afetados

  Tempo := Time;
  if (FPrincipal <> nil) and (MonitoraSQL) then
    FPrincipal.AdicionaRich('ExecuteCommand_Update', sql);

  Result := TFuncoesConversao.VariantParaInt64(ExecuteMethods('TSMConexao.ExecuteCommand_Update', [Trim(sql), Campo, Valor, True]));

  if (FPrincipal <> nil) and (MonitoraSQL) then
  begin
    Tempo := Time - Tempo;
    FPrincipal.AdicionaLinhaRich('Tempo Gasto em ExecuteCommand_Update ==> ' + FormatDateTime(' hh:mm:ss.zzz', Tempo), clGreen, [fsBold]);
  end;
end;

function TDMConexao.CallbackMethod(const Args: TJSONValue): TJSONValue;
var
  LJSONObject: TJSONObject;
  LJSONPair: TJSONPair;
  allValues: TJSONArray;
  TipoDeMensagem, Atual, Total: Integer;
  ID, AMessage, NomeRemetente: string;
begin
  LJSONObject := TJSONObject(Args);
  LJSONPair := LJSONObject. {$IFDEF VER230} Get(0) {$ELSE} Pairs[0] {$ENDIF};

  TipoDeMensagem := TJSONNumber(LJSONPair.JsonString).AsInt;

  try
    allValues := TJSONArray(LJSONPair.JsonValue);
    ID := allValues. {$IFDEF VER230} Get(0) {$ELSE} Items[0] {$ENDIF} .ToString;

    if (TipoDeMensagem = EvCallBack_IncrementaProgresso) then
    begin
      Atual := StrToInt(allValues. {$IFDEF VER230} Get(1) {$ELSE} Items[1] {$ENDIF} .Value);
      Total := StrToInt(allValues. {$IFDEF VER230} Get(2) {$ELSE} Items[2] {$ENDIF} .Value);
      AMessage := allValues. {$IFDEF VER230} Get(3) {$ELSE} Items[3] {$ENDIF} .ToString;
    end
    else if (TipoDeMensagem = EvCallBack_NovaMensagem) then
    begin
      Atual := StrToInt(allValues. {$IFDEF VER230} Get(1) {$ELSE} Items[1] {$ENDIF} .Value);
      NomeRemetente := allValues. {$IFDEF VER230} Get(2) {$ELSE} Items[2] {$ENDIF} .ToString;
      AMessage := allValues. {$IFDEF VER230} Get(3) {$ELSE} Items[3] {$ENDIF} .ToString;

    end
    else if (TipoDeMensagem <> EvCallBack_FechaTelaMensagem) then
      AMessage := allValues. {$IFDEF VER230} Get(1) {$ELSE} Items[1] {$ENDIF} .ToString
  except
    //
  end;

  TThread.Queue(nil,
    procedure
    begin

      case TipoDeMensagem of
        EvCallBack_AbreTelaMensagem:
          begin
            TFAguarde.Ativar(ID, AMessage);
          end;
        EvCallBack_FechaTelaMensagem:
          begin
            TFAguarde.Desativar(ID);
          end;
        EvCallBack_Status:
          begin
            TFAguarde.Mensagem(ID, AMessage);
          end;
        EvCallBack_IncrementaProgresso:
          begin
            TFAguarde.IncrementaProgresso(ID, Atual, Total);
            if (AMessage <> '') and (AMessage <> '""') then
              TFAguarde.Mensagem(ID, AMessage);
          end;
        EvCallBack_NovaMensagem:
          begin
            if (StrToInt(ID) >= 0) and (StatusDeMensagens >= 0) then
              StatusDeMensagens := FStatusDeMensagens + 1
            else
              StatusDeMensagens := StrToInt(ID);
          end;
        EvCallBack_MensagemLida:
          begin
            if FStatusDeMensagens > 0 then
              StatusDeMensagens := FStatusDeMensagens - 1
            else
              CarregaMensagem;
          end;
        EvCallBack_ShutDown:
          begin
            TrataMensagemDeFechamento(false);
          end;
        EvCallBack_SACAberto:
          begin
            StatusSAC := StrToInt(AMessage);
          end;
      end;
    end);

  Result := TJSONTrue.Create;
end;

procedure TDMConexao.CallBack_AbreTela(ID, Mensagem: string);
begin
  TFAguarde.Ativar(ID, Mensagem);
end;

procedure TDMConexao.CallBack_FechaTela(ID: string);
begin
  TFAguarde.Desativar(ID);
end;

procedure TDMConexao.CallBack_Mensagem(ID, Mensagem: string);
begin
  TFAguarde.Mensagem(ID, Mensagem);
end;

procedure TDMConexao.CallBack_Incremento(ID: string; Atual, Total: Integer; Mensagem: string);
begin
  TFAguarde.IncrementaProgresso(ID, Atual, Total);
  if Mensagem <> '' then
    TFAguarde.Mensagem(ID, Mensagem);
end;
{$ENDREGION}

{$REGION 'Componentes do DM'}

procedure TDMConexao.SQLConexaoAfterConnect(Sender: TObject);
var
  Ret: OleVariant;
begin
  if (not ConexaoTratada) then
  begin
    TCaixasDeDialogo.Erro(sErroNaRede + 'Tentativa de Conexão não tratada.');
    FecharSistema;
  end;

  if Assigned(FSplash) then
  begin
    FSplash.Show;
    FSplash.Passo(45, 'Tratando Conexão');
  end;

  Ret := ExecuteMethods('TSMConexao.InformacoesDaConexaoBDD', []);
  ServidorBDD := Ret[0]; // ExecuteMethods('TSMConexao.ConexaoBDD', []);
  VersaoBDD := Ret[1]; // ExecuteMethods('TSMConexao.VersaoBDD', []);
  ConexaoBDD_Tipo := Ret[2]; // ExecuteMethods('TSMConexao.ConexaoBDD_Tipo', []);
  DriverBDDAtual := Ret[3];
end;

procedure TDMConexao.SQLConexaoAfterDisconnect(Sender: TObject);
begin
  CallBack.DesRegistraCallBack(SecaoAtual.Usuario.Nome);
end;

procedure TDMConexao.CDSIndicadoresAfterInsert(DataSet: TDataSet);
begin
  FPrincipal.PainelSalvo := false;
end;

procedure TDMConexao.CDSIndicadoresNewRecord(DataSet: TDataSet);
begin
  DataSet.AcertarDefaultDinamico(DMConexao.SecaoAtual.Usuario.Nome, DMConexao.cDataHoraServidor);
end;

procedure TDMConexao.CDSServidoresAfterOpen(DataSet: TDataSet);
begin
  CDSServidoresRede.OnSetText := TGetTexts.SetText_Campo1Digito;
  CDSServidoresTipo.OnSetText := TGetTexts.SetText_Campo1Digito;
end;

procedure TDMConexao.CDSServidoresBeforePost(DataSet: TDataSet);
begin
  if (DataSet.FieldByName('Tipo').AsInteger = cServTipo_SoftwareCenter) and
     (DataSet.FieldByName('Rede').AsInteger = cServRede_Extranet) then
  begin
    TCaixasDeDialogo.Aviso('O tipo de servidor informado "SoftwareCenter" atualmente não oferece suporte para o tipo de rede "Extranet".');
    Abort;
  end;
  if (DataSet.FieldByName('Tipo').AsInteger <> cServTipo_SoftwareCenter) and
     (DataSet.FieldByName('Porta').AsInteger = Constantes.TekAgendadorPorta) then
  begin
    TCaixasDeDialogo.Aviso('Verifique a porta informada, pois, pertence à SoftwareCenter.');
    Abort;
  end;
end;

procedure TDMConexao.CDSServidoresRedeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if (Sender.DataSet.IsEmpty) then
  begin
    Text := '';
    Exit;
  end;

  case Sender.AsInteger of
    cServRede_Intranet:
      Text := 'Intranet';
    cServRede_Extranet:
      Text := 'Extranet';
    else
      Text := Sender.AsString;
  end;
end;

procedure TDMConexao.CDSServidoresTipoGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if (Sender.DataSet.IsEmpty) then
  begin
    Text := '';
    Exit;
  end;

  case Sender.AsInteger of
    cServTipo_SoftwareCenter:
      Text := 'SoftwareCenter';
    cServTipo_TekServer:
      Text := 'TekServer';
    else
      Text := Sender.AsString;
  end;
end;

procedure TDMConexao.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  TrataErro(E);
end;

procedure TDMConexao.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
begin
  if not Debugando then
  begin
    TrataOciosidade(Msg);
    TrataHelp(Msg);
  end;
end;

procedure TDMConexao.OcultarColuna1Click(Sender: TObject);
var
  Grade: TDBGrid;
begin
  // Oculta a coluna selecionada da grade
  if not(Screen.ActiveControl is TDBGrid) then
    Exit;

  Grade := (Screen.ActiveControl as TDBGrid);

  Grade.OcultarColuna(Grade.SelectedField.FieldName);
end;

procedure TDMConexao.ReexibirColunas1Click(Sender: TObject);
begin
  // Torna visível todas as colunas da grade
  if not(Screen.ActiveControl is TDBGrid) then
    Exit;

  TDBGrid(Screen.ActiveControl).ReexibirColunas;
end;

procedure TDMConexao.AutoAjusteColunas1Click(Sender: TObject);
begin
  if not(Screen.ActiveControl is TDBGrid) then
    Exit;

  TDBGrid(Screen.ActiveControl).AutoAjustarTamanhoDeColunas;
end;

procedure TDMConexao.PesquisaIncremental1Click(Sender: TObject);
begin
  // Permite fazer uma pesquisa incremental na grade
  if not(Screen.ActiveControl is TDBGrid) then
    Exit;

  TekPesquisaGrid1.Grid := TDBGrid(Screen.ActiveControl);

  KeyNavigator1.Active := false;
  try
    TekPesquisaGrid1.Pesquisar;
  finally
    KeyNavigator1.Active := True;
  end;
end;

procedure TDMConexao.PopupMenuGridPopup(Sender: TObject);
var
  i, J: Integer;
  CampoNumerico, CampoDataHora, Bloqueado, PossuiColunaMarcacao: Boolean;
  MenuItemPai, MenuItem: TMenuItem;

  function RetiraEComercial(s: string): string;
  begin
    Result := TFuncoesString.Trocar(s, '&', '');
  end;

begin
  if (not (Screen.ActiveControl is TDBGrid)) or
     ((EmProcesso) and (not InteracaoRequerida)) then
    Abort;

  if (Screen.ActiveControl is TJvDBGrid) then
  begin
    OcultarColuna1.Enabled   := (Screen.ActiveControl as TJvDBGrid).TitleArrow;
    ReexibirColunas1.Enabled := (Screen.ActiveControl as TJvDBGrid).TitleArrow;
  end;

  CampoNumerico        := False;
  CampoDataHora        := False;
  Bloqueado            := True;
  PossuiColunaMarcacao := False;

  if (Screen.ActiveControl is TDBGrid) then
    with (Screen.ActiveControl as TDBGrid) do
      if (SelectedField <> nil) then // Se a grid está sem colunas dá erro na linha abaixo
        begin
          CampoNumerico        := SelectedField.CampoTipoNumerico;
          CampoDataHora        := SelectedField.CampoTipoData;
          PossuiColunaMarcacao := Assigned(TDBGrid(Screen.ActiveControl).ProcurarColunaPeloNome('MARQUE'));

          Bloqueado :=
            ReadOnly or (not Enabled) or
            (SelectedField.ReadOnly) or
            (TDBGrid(Screen.ActiveControl).ColunaPeloNome(SelectedField.FieldName).ReadOnly) or
            (TClientDataSet(DataSource.DataSet).ReadOnly) or
            (TClientDataSet(DataSource.DataSet).FindField(SelectedField.FieldName).ReadOnly);
        end;

  if Sender = PopupMenuGrid then
  begin
    SomarColuna1.Visible := CampoNumerico or CampoDataHora;
    MediaColuna1.Visible := CampoNumerico or CampoDataHora;

    ContarRegistrosMarcados1.Visible                           := PossuiColunaMarcacao;
    SeparadorOpcoesAgregacao.Visible                           := PossuiColunaMarcacao;
    SomarColunaapenasdosRegistrosMarcados1.Visible             := SomarColuna1.Visible and (PossuiColunaMarcacao);
    MediaAritmeticadaColunaapenasdosRegistrosMarcados1.Visible := MediaColuna1.Visible and (PossuiColunaMarcacao);

    FuncoesdeAtribuicao.Visible := not Bloqueado;
    Arredondarpara2casasdecimais.Visible := CampoNumerico and (not Bloqueado);
    Arredondarpara1casadecimal.Visible := CampoNumerico and (not Bloqueado);
    Arredondarparaunidade.Visible := CampoNumerico and (not Bloqueado);
    Arredondarparadezena.Visible := CampoNumerico and (not Bloqueado);
    Ajustarparaprximointeiro.Visible := CampoNumerico and (not Bloqueado);
    Ajustarparainteiroanterior.Visible := CampoNumerico and (not Bloqueado);
  end
  else if Sender is TPopupMenu then
    for i := 0 to TPopupMenu(Sender).Items.Count - 1 do
    begin
      MenuItem := TPopupMenu(Sender).Items[i];
      if (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(FuncoesdeAtribuicao.Caption)) then
      begin
        MenuItem.Visible := not Bloqueado;
        MenuItemPai := MenuItem;
        for J := MenuItemPai.Count - 1 downto 0 do
        begin
          MenuItem := MenuItemPai.Items[J];
          if (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(Arredondarpara2casasdecimais.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(Arredondarpara1casadecimal.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(Arredondarparaunidade.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(Arredondarparadezena.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(Ajustarparaprximointeiro.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(Ajustarparainteiroanterior.Caption)) then
            MenuItem.Visible := CampoNumerico and (not Bloqueado);
        end;
      end
      else if (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(FuncoesdeAgregacao1.Caption)) then
      begin
        MenuItemPai := MenuItem;
        for J := MenuItemPai.Count - 1 downto 0 do
        begin
          MenuItem := MenuItemPai.Items[J];

          if (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(SomarColuna1.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(MediaColuna1.Caption)) then
            MenuItem.Visible := CampoNumerico or CampoDataHora;

          if (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(SomarColunaapenasdosRegistrosMarcados1.Caption)) or
             (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(MediaAritmeticadaColunaapenasdosRegistrosMarcados1.Caption)) then
            MenuItem.Visible := (CampoNumerico or CampoDataHora) and (PossuiColunaMarcacao);

          if (RetiraEComercial(MenuItem.Caption) = RetiraEComercial(ContarRegistrosMarcados1.Caption)) then
            MenuItem.Visible := PossuiColunaMarcacao;
        end;
      end;
    end;
end;

procedure TDMConexao.Exportar1Click(Sender: TObject);
var
  NomeArquivo: string;
  Grade: TDBGrid;
  CDS, Clone: TClientDataSet;
begin
  // Permite exportar o conteúdo da grade para diversos tipos diferentes de arquivos
  if not(Screen.ActiveControl is TDBGrid) then
    Exit;

  SaveDialogGrid.InitialDir := Config.DirTemp;

  if SaveDialogGrid.Execute then
  begin
    Grade := (Screen.ActiveControl as TDBGrid);
    NomeArquivo := SaveDialogGrid.Filename;
    // HTML é o único formato que despreza as colunas invisíveis
    // pois é feito pela grid e não pelo dataset.
    // Justificativa - é o único que não será manipulado porteriormente
    case SaveDialogGrid.FilterIndex of
      1: // CSV
        with DataSetParaCSV1 do
        begin
          Extensao := '.CSV';
          NomeArquivo := ChangeFileExt(NomeArquivo, Extensao);
          ArquivoBase := NomeArquivo;
          DataSet := Grade.DataSource.DataSet;
          MaximoRegistrosPorArquivo := 31999;
          Separador := ',';
          Delimitador := '"';
          Executar;
          TCaixasDeDialogo.Informacao(NomeArquivo + ' gerado com sucesso');
        end;
      2: // HTML
        with GridParaHTML1 do
        begin
          NomeArquivo := ChangeFileExt(NomeArquivo, '.HTML');
          Arquivo := NomeArquivo;
          CabecalhoFontePadrao := True;
          CorpoFontePadrao := True;
          DBGrid := Grade;
          Titulo := Modulos[Sistema, 2] + ' - ' + Screen.FocusedForm.Caption;
          Rodape := SecaoAtual.Empresa.Nome + ' - ' + SecaoAtual.Usuario.Nome;
          Executar;
        end;
      3: // XML
        if (Grade.DataSource.DataSet is TClientDataSet) then
        begin
          NomeArquivo := ChangeFileExt(NomeArquivo, '.XML');
          CDS := (Grade.DataSource.DataSet as TClientDataSet);
          with CDS do
          begin
            if (DataSetField = nil) then
              SaveToFile(NomeArquivo, dfXMLUTF8)
            else
            begin
              Clone := TClientDataSet.Create(nil);
              try
                Clone.Clonar(CDS);
                Clone.SaveToFile(NomeArquivo, dfXMLUTF8);
              finally
                FreeAndNil(Clone);
              end;
            end;
          end;
          TCaixasDeDialogo.Informacao(NomeArquivo + ' gerado com sucesso');
        end
        else
          TCaixasDeDialogo.Informacao('Essa grade não pode ser exportada para esse formato, tente outro');
      4: // CDS
        if (Grade.DataSource.DataSet is TClientDataSet) then
        begin
          NomeArquivo := ChangeFileExt(NomeArquivo, '.CDS');
          CDS := (Grade.DataSource.DataSet as TClientDataSet);
          with CDS do
          begin
            if (DataSetField = nil) then
              SaveToFile(NomeArquivo, dfBinary)
            else
              try
                Clone := TClientDataSet.Create(nil);
                Clone.Clonar(CDS);
                Clone.SaveToFile(NomeArquivo, dfBinary);
              finally
                Clone.Free;
              end;
          end;
          TCaixasDeDialogo.Informacao(NomeArquivo + ' gerado com sucesso');
        end
        else
          TCaixasDeDialogo.Informacao('Essa grade não pode ser exportada para esse formato, tente outro');
      5: // TXT
        with DataSetParaCSV1 do
        begin
          Extensao := '.TXT';
          NomeArquivo := ChangeFileExt(NomeArquivo, Extensao);
          ArquivoBase := NomeArquivo;
          DataSet := Grade.DataSource.DataSet;
          MaximoRegistrosPorArquivo := 0;
          Separador := #9;
          Delimitador := '';
          Executar;
          TCaixasDeDialogo.Informacao(NomeArquivo + ' gerado com sucesso');
        end;
    end;
    Grade.SetFocus;
  end;
end;

procedure TDMConexao.Todaagrade1Click(Sender: TObject);
begin
  if (Screen.ActiveControl is TDBGrid) then
    DBGridToClipBoard((Screen.ActiveControl as TDBGrid), True, false, false);
end;

procedure TDMConexao.ApenasClulaatual1Click(Sender: TObject);
begin
  if (Screen.ActiveControl is TDBGrid) then
    (Screen.ActiveControl as TDBGrid).CopiarCelulaParaClipBoard;
end;

procedure TDMConexao.ApenasColunaAtual1Click(Sender: TObject);
begin
  if (Screen.ActiveControl is TDBGrid) then
    DBGridToClipBoard((Screen.ActiveControl as TDBGrid), True, false, True);
end;

procedure TDMConexao.ApenasLinhaAtual1Click(Sender: TObject);
begin
  if (Screen.ActiveControl is TDBGrid) then
    DBGridToClipBoard((Screen.ActiveControl as TDBGrid), True, True, false);
end;

procedure TDMConexao.ContarRegistros1Click(Sender: TObject);
const
  ContarTodos          = 0;
  ContarApenasMarcados = 1;
var
  Registros, Opcao: Integer;
begin
  if not (Screen.ActiveControl is TDBGrid) then
    Exit;

  if not (Sender is TMenuItem) then
    Exit;

  Opcao := TMenuItem(Sender).Tag;

  Registros := (Screen.ActiveControl as TDBGrid).ContarRegistros(Opcao = ContarApenasMarcados);

  if (Registros = -1) then
    TCaixasDeDialogo.Informacao('Não é possível contar os registros dessa grade nesse momento.')
  else
    TCaixasDeDialogo.Informacao('Essa grade contém ' + IntToStr(Registros) + ' registro(s)' + ifThen(Opcao = ContarTodos, '', ' marcado(s)'));
end;

procedure TDMConexao.SomarOuMediaColuna1Click(Sender: TObject);
const
  OperacaoSomar         = 1;
  OperacaoMedia         = 2;
  OperacaoSomarMarcados = 3;
  OperacaoMediaMarcados = 4;
var
  Grade: TDBGrid;
  Operacao: Integer;
  OperacaoPermitida, MascaraDeData: Boolean;
  Resultado: Double;
  Mensagem: string;
begin
  if (Screen.ActiveControl is TDBGrid) then
    Grade := (Screen.ActiveControl as TDBGrid)
  else
    Exit;

  Operacao := (Sender as TMenuItem).Tag;

  OperacaoPermitida := Grade.SelectedField.CampoTipoNumerico or
                       Grade.SelectedField.CampoTipoData;

  MascaraDeData := (Pos('/', Grade.SelectedField.EditMask) > 0);

  if (not OperacaoPermitida) then
    begin
      TCaixasDeDialogo.Informacao('Operação não permitida para o campo posicionado na grade.');
      Exit;
    end;

  Resultado := 0;
  Mensagem  := '';
  case Operacao of
    OperacaoSomar:
      begin
        if MascaraDeData then
          begin
            TCaixasDeDialogo.Informacao('A soma de datas não tem significado.');
            Exit;
          end;
        Mensagem  := 'A soma';
        Resultado := Grade.SomarColuna(Grade.SelectedField.FieldName, False);
      end;
    OperacaoMedia:
      begin
        Mensagem  := 'A média aritmética';
        Resultado := Grade.MediaColuna(Grade.SelectedField.FieldName, False);
      end;
    OperacaoSomarMarcados:
      begin
        if MascaraDeData then
          begin
            TCaixasDeDialogo.Informacao('A soma de datas não tem significado.');
            Exit;
          end;
        Mensagem  := 'A soma';
        Resultado := Grade.SomarColuna(Grade.SelectedField.FieldName, True);
      end;
    OperacaoMediaMarcados:
      begin
        Mensagem  := 'A média aritmética';
        Resultado := Grade.MediaColuna(Grade.SelectedField.FieldName, True);
      end;
  end;

  Mensagem := Mensagem + ' do campo "' + Grade.SelectedField.DisplayName + '" é ';

  if Grade.SelectedField.CampoTipoNumerico then
    Mensagem := Mensagem + FormatFloat('#,##0.00####', Resultado)
  else
    begin
      if (Pos('/', Grade.SelectedField.EditMask) > 0) then
        Mensagem := Mensagem + FormatDateTime(sDisplayFormatDataHora_HoraMinSeg, Resultado)
      else
        Mensagem := Mensagem + TFuncoesData.DateTimeParaHMS(Resultado, True);
    end;

  TCaixasDeDialogo.Informacao(Mensagem);
end;

procedure TDMConexao.AtribuicaoClick(Sender: TObject);
var
  Funcao: Integer;
  Mens, NovoValor: string;
  Grade: TDBGrid;
  CDS: TClientDataSet;
  Campo: TField;
  Coluna: TColumn;

  procedure ProcessaRegistro;
  begin
    if (Coluna.ReadOnly) or (Grade.SelectedField.ReadOnly) or (Campo.ReadOnly) then
      Exit;

    case Funcao of
      1: // formula
        NovoValor := FDefineFormulaCampo.Executa;
      2: // arredondamento para 2 casas decimais
        NovoValor := FloatToStr(TFuncoesNumero.Arredondar(Campo.AsExtended, 2));
      3: // arredondamento para 1 casas decimais
        NovoValor := FloatToStr(TFuncoesNumero.Arredondar(Campo.AsExtended, 1));
      4: // arredondar para unidade
        NovoValor := FloatToStr(TFuncoesNumero.Arredondar(Campo.AsExtended, 0));
      5: // arredondar para dezena
        NovoValor := FloatToStr(TFuncoesNumero.Arredondar(Campo.AsExtended, -1));
      6: // ajuste para o próximo inteiro
        NovoValor := FloatToStr(Ceil(Campo.AsExtended));
      7: // ajuste para o inteiro anterior
        NovoValor := FloatToStr(Trunc(Campo.AsExtended));
    end;

    if (NovoValor = Campo.AsString) then
      Exit;

    CDS.Edit;
    Campo.Value := NovoValor;
    CDS.Post;
  end;

  procedure ProcessaRegistros;
  var
    BM: TBookMark;
  begin
    if not TCaixasDeDialogo.Confirma('Executar para todos?') then
    begin
      ProcessaRegistro;
      Exit;
    end;

    with CDS do
    begin
      BM := GetBookmark;
      DisableControls;
      try
        FPrincipal.IniciaLoop(RecordCount);
        First;
        while (not eof) do
        begin
          FPrincipal.AtualizaLoop(RecNo);
          ProcessaRegistro;
          Next;
        end;
        if BookmarkValid(BM) then
          GotoBookmark(BM);
        if Assigned(Grade.DataSource.OnStateChange) then
          Grade.DataSource.OnStateChange(CDS);
      finally
        EnableControls;
        FPrincipal.FinalizaLoop;
      end;
    end;
  end;

begin
  if (Screen.ActiveControl is TDBGrid) then
    Grade := (Screen.ActiveControl as TDBGrid)
  else
    Exit;

  if (not Assigned(Grade.DataSource)) or (not Assigned(Grade.DataSource.DataSet)) or (not Grade.DataSource.DataSet.Active) then
    begin
      TCaixasDeDialogo.Informacao('Fonte de dados não preperada');
      Exit;
    end;

  if Grade.DataSource.DataSet.IsEmpty then
    begin
      TCaixasDeDialogo.Informacao('Não existem registros nesta grade.');
      Exit;
    end;

  Funcao := (Sender as TMenuItem).Tag;

  if (not(Funcao in [1,8])) and (not(Grade.SelectedField.CampoTipoNumerico)) then
  begin
    TCaixasDeDialogo.Aviso('Esse cálculo só é válido quando um campo numérico está posicionado na grade');
    Exit;
  end;

  CDS := TClientDataSet(Grade.DataSource.DataSet);
  Campo := CDS.FindField(Grade.SelectedField.FieldName);
  Coluna := Grade.ColunaPeloNome(Grade.SelectedField.FieldName);

  if (Grade.ReadOnly) or (Coluna.ReadOnly) or (Grade.SelectedField.ReadOnly) or (CDS.ReadOnly) or (Campo.ReadOnly) then
  begin
    TCaixasDeDialogo.Aviso('Campo bloqueado para alteração');
    Exit;
  end;

  if (Funcao = 1) then
  begin
    FDefineFormulaCampo := TFDefineFormulaCampo.Create(Self);
    try
      FDefineFormulaCampo.NomeFonte := Screen.ActiveForm.ClassName + '.' + Grade.Name;
      FDefineFormulaCampo.CDS := CDS;
      FDefineFormulaCampo.Campo := Grade.SelectedField.FieldName;
      FDefineFormulaCampo.ShowModal;
    finally
      if (FDefineFormulaCampo.ModalREsult = mrOK) then
        ProcessaRegistros;
      FreeAndNil(FDefineFormulaCampo);
    end;
  end
  else
  begin
    if Funcao = 8 then
    begin
      Mens := '';
      if not TCaixasDeDialogo.Responda_2('Informe o valor fixo', 'Valor', Mens) then
        Exit;

      if (Grade.SelectedField.CampoTipoNumerico) then
        NovoValor := FloatToStr(StrToFloatDef(Mens, 0))
      else
        NovoValor := Mens;

      if (NovoValor = Campo.AsString) then
        Exit;
    end;

    case Funcao of
      2:
        Mens := 'Confirma o arredondamento para 2 casas decimais?';
      3:
        Mens := 'Confirma o arredondamento para 1 casa decimal?';
      4:
        Mens := 'Confirma o arredondamento para a unidade?';
      5:
        Mens := 'Confirma o arredondamento para a dezena?';
      6:
        Mens := 'Confirma o ajuste para o próximo inteiro?';
      7:
        Mens := 'Confirma o ajuste para o inteiro anterior?';
      8:
        Mens := 'Confirma atribuir o valor "' + NovoValor + '"?';
    end;

    if (not TCaixasDeDialogo.Confirma(Mens)) then
      Exit;

    ProcessaRegistros;
  end;
end;

procedure TDMConexao.FiltrarRegistros1Click(Sender: TObject);
var
  Grade: TDBGrid;
  CDS: TClientDataSet;
  NovoFiltro: String;
begin
  if not(Screen.ActiveControl is TDBGrid) then
    Exit;

  Grade := (Screen.ActiveControl as TDBGrid);

  if (Assigned(Grade.DataSource)) and
    (Assigned(Grade.DataSource.DataSet)) then
    if (Grade.DataSource.DataSet is TClientDataSet) then
    begin
      CDS := (Grade.DataSource.DataSet as TClientDataSet);
      NovoFiltro := CDS.Filter;

      if TCaixasDeDialogo.Responda_2('Filtrar os Dados', 'Novo filtro:', NovoFiltro) then
      begin
        CDS.Filter := NovoFiltro;
        CDS.Filtered := (Trim(NovoFiltro) <> '');
      end;
    end;
end;

procedure TDMConexao.MeuBotaoOkB_Click(Sender: TObject);
var
  i: Integer;
begin
  with FormMailExportDialog do
  begin
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TLabel then
        (Components[i] as TLabel).Font.Style := [];
    if AddressE.Text = '' then
    begin
      ExportSheet.Show;
      AddressLB.Font.Style := [fsBold];
      ModalREsult := mrNone;
    end;
    if SubjectE.Text = '' then
    begin
      ExportSheet.Show;
      SubjectLB.Font.Style := [fsBold];
      ModalREsult := mrNone;
    end;
    if FromAddrE.Text = '' then
    begin
      AccountSheet.Show;
      FromAddrLB.Font.Style := [fsBold];
      ModalREsult := mrNone;
    end;

    // nao validar o servidor: Caso necessite implementar o endereco de servidor do cliente, colocar isso de volta

    { if HostE.Text = '' then
      begin
     AccountSheet.Show;
     HostLB.Font.Style := [fsBold];
     ModalREsult := mrNone;
     end;
     if PortE.Text = '' then
     begin
     AccountSheet.Show;
     PortLB.Font.Style := [fsBold];
     ModalREsult := mrNone;
     end; }

    ReqLB.Visible := ModalREsult = mrNone;
  end;
end;

procedure TDMConexao.frxExportaMailBeginExport(Sender: TObject);
const
  EMAIL_EXPORT_SECTION = 'Tek_EmailExport';
var
  i: Integer;
  INI: TCustomIniFile;
  s, Section: string;
  UseIniFile_Remetente, UseIniFile_EMail: boolean;
  AddressCCl: TLabel;
  AddressCCe: TComboBox;
  ST: TStream;
begin
  frxExportaMail.FromName := SecaoAtual.Usuario.Nome;
  frxExportaMail.FromMail := SecaoAtual.Usuario.EmailPadrao.EmailRemetente;
  frxExportaMail.FromCompany := SecaoAtual.Empresa.Nome;
  frxExportaMail.Address := DestinatarioPadraoEmailRelatorio;
  frxExportaMail.Subject := AssuntoPadraoEmailRelatorio;
  frxExportaMail.MailCC  := '';
  frxExportaMail.Lines.Clear;
  frxExportaMail.Signature.Clear;
  frxExportaMail.SmtpHost := '';
  frxExportaMail.SmtpPort := 25;
  frxExportaMail.Login := '';
  frxExportaMail.Password := '';

  UseIniFile_Remetente := frxExportaMail.UseIniFile;
  UseIniFile_EMail := frxExportaMail.UseIniFile;

  with TFDlgSelecionaContaEmail.SelecionaEmail(Self) do
  begin
    if Codigo > 0 then
    begin
      frxExportaMail.FromName := NomeRemetente;
      frxExportaMail.FromMail := EmailRemetente;

      frxExportaMail.SmtpHost := SmtpHost;
      frxExportaMail.SmtpPort := SmtpPort;
      frxExportaMail.Login    := User;
      frxExportaMail.Password := Password;
      frxExportaMail.MailCC   := Copia;
      frxExportaMail.Lines.Text := TextoPadrao;

      Flag_EnviaEmail_ServidorEmail_EmailSeguro := SSL;
      Flag_EnviaEmail_ServidorEmail_TLS         := TLS;
      Flag_EnviaEmail_Metodo := MetodoEnvio;

      UseIniFile_Remetente := False;
    end
    else
    if SecaoAtual.Parametro.EmailGeral.Codigo > 0 then
    begin
      frxExportaMail.FromName := SecaoAtual.Parametro.EmailGeral.NomeRemetente;
      frxExportaMail.FromMail := SecaoAtual.Parametro.EmailGeral.EmailRemetente;

      frxExportaMail.SmtpHost := SecaoAtual.Parametro.EmailGeral.SmtpHost;
      frxExportaMail.SmtpPort := SecaoAtual.Parametro.EmailGeral.SmtpPort;
      frxExportaMail.Login    := SecaoAtual.Parametro.EmailGeral.User;
      frxExportaMail.Password := SecaoAtual.Parametro.EmailGeral.Password;

      Flag_EnviaEmail_ServidorEmail_EmailSeguro := SecaoAtual.Parametro.EmailGeral.SSL;
      Flag_EnviaEmail_ServidorEmail_TLS         := SecaoAtual.Parametro.EmailGeral.TLS;

      Flag_EnviaEmail_Metodo := SecaoAtual.Parametro.EmailGeral.MetodoEnvio;

      UseIniFile_Remetente := False;
    end;
  end;

  Section := EMAIL_EXPORT_SECTION + '.Properties';

  FormMailExportDialog := TfrxMailExportDialog.Create(nil);
  try
    with FormMailExportDialog do
    begin
      MessageM.Height := MessageM.Height - AddressE.Height -3;

      AddressCCe := TComboBox.Create(FormMailExportDialog);
      AddressCCe.Parent := MessageGroup;
      AddressCCe.Top := MessageM.Top + MessageM.Height + 3;
      AddressCCe.Left := AddressE.Left;
      AddressCCe.Height := AddressE.Height;
      AddressCCe.Width := AddressE.Width;
      AddressCCe.TabOrder := MessageM.TabOrder +1;

      AddressCCl := TLabel.Create(FormMailExportDialog);
      AddressCCl.Parent := MessageGroup;
      AddressCCl.Top := AddressCCe.Top + 4;
      AddressCCl.Left := AddressLB.Left;
      AddressCCl.Height := AddressLB.Height;
      AddressCCl.Width := AddressLB.Width;
      AddressCCl.Caption := 'CC';

      SendMessage(GetWindow(ExportsCombo.Handle, GW_CHILD), EM_SETREADONLY, 1, 0);
      ExportsCombo.Items.Clear;
      ExportsCombo.Style := csDropDownList;
      for i := 0 to frxExportFilters.Count - 1 do
      begin
        if (TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName <> 'TfrxDotMatrixExport')
          and (TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName <> 'TfrxMailExport') then
        begin
          s := TfrxCustomExportFilter(frxExportFilters[i].Filter).GetDescription;
          if ExportsCombo.Items.IndexOf(s) < 0 then
            ExportsCombo.Items.AddObject(s, TfrxCustomExportFilter(frxExportFilters[i].Filter));
        end;
      end;
      ExportsCombo.Items.AddObject(frxResources.Get('FastReportFile'), nil);
      SettingCB.Checked := DMConexao.frxExportaMail.ShowExportDialog;

      if not DMConexao.frxExportaMail.UseIniFile then
        RememberCB.Visible := false;

      if DMConexao.frxExportaMail.UseIniFile then
        INI := IniFiles.TIniFile.Create(ExtractFilePath(Application.ExeName) + ArquivoIniClient)
      else
        INI := TRegistryIniFile.Create('\Software\Tek System Informática Ltda.');
      try
        if UseIniFile_Remetente then
        begin
          FromNameE.Text := INI.ReadString(Section, 'FromName', frxExportaMail.FromName);
          FromAddrE.Text := INI.ReadString(Section, 'FromAddress', frxExportaMail.FromMail);
          OrgE.Text := INI.ReadString(Section, 'Organization', frxExportaMail.FromCompany);
          ST := TMemoryStream.Create;
          try
            INI.ReadBinaryStream(Section, 'SignatureM', ST);
            ST.Position := 0;
            SignatureM.Lines.LoadFromStream(ST);
          finally
            FreeAndNil(ST);
          end;
          ReadingCB.Checked := INI.ReadString(Section, 'ConfurmReading', '') = 'S';
          SettingCB.Checked := INI.ReadString(Section, 'ShowExportDialog', '') = 'S';

          HostE.Text := INI.ReadString(Section, 'SmtpHost', '');
          PortE.Text := INI.ReadString(Section, 'SmtpPort', '25');
          LoginE.Text := string(Base64Decode(AnsiString(INI.ReadString(Section, 'Login', ''))));
          PasswordE.Text := string(Base64Decode(AnsiString(INI.ReadString(Section, 'Password', ''))));
          TimeoutE.Text := INI.ReadString(Section, 'Timeout', '60');
        end else begin
          FromNameE.Text := frxExportaMail.FromName;
          FromAddrE.Text := frxExportaMail.FromMail;
          OrgE.Text := frxExportaMail.FromCompany;
          SignatureM.Lines.Text := frxExportaMail.Signature.Text;
          ReadingCB.Checked := frxExportaMail.ConfurmReading;
          SettingCB.Checked := frxExportaMail.ShowExportDialog;

          // Dados do servidor, sem uso para envio pelo servidor de email da tek system
          HostE.Text := frxExportaMail.SmtpHost;
          PortE.Text := IntToStr(frxExportaMail.SmtpPort);
          LoginE.Text := frxExportaMail.Login;
          PasswordE.Text := frxExportaMail.Password;
          TimeoutE.Text := IntToStr(frxExportaMail.Timeout);
        end;

        if UseIniFile_EMail then
        begin
          INI.ReadSection(EMAIL_EXPORT_SECTION + '.RecentAddresses', AddressE.Items);
          INI.ReadSection(EMAIL_EXPORT_SECTION + '.RecentSubjects', SubjectE.Items);
          INI.ReadSection(EMAIL_EXPORT_SECTION + '.RecentAddressCCs', AddressCCe.Items);
          AddressCCe.ItemIndex := INI.ReadInteger(Section, 'LastUsedAddressCC', -1);
          ExportsCombo.ItemIndex := INI.ReadInteger(Section, 'LastUsedExport', 0);
        end else begin
          if not Assigned(frxExportaMail.ExportFilter) then
            ExportsCombo.ItemIndex := 0
          else
            ExportsCombo.ItemIndex := ExportsCombo.Items.IndexOfObject(frxExportaMail.ExportFilter);
        end;
      finally
        FreeAndNil(INI);
      end;

      if DestinatarioPadraoEmailRelatorio <> '' then
        frxExportaMail.Address := DestinatarioPadraoEmailRelatorio;
      if AssuntoPadraoEmailRelatorio <> '' then
        frxExportaMail.Subject := AssuntoPadraoEmailRelatorio;

      AddressE.Text := frxExportaMail.Address;
      SubjectE.Text := frxExportaMail.Subject;
      MessageM.Text := frxExportaMail.Lines.Text;
      if frxExportaMail.MailCC <> '' then
        AddressCCe.Text := frxExportaMail.MailCC;

      AccountGroup.Visible := false;
      ReadingCB.Caption := 'Solicitar Confirmação de Leitura'; // A tradução do FastReport estava errada
      ReadingCB.Width := 200;

      // trocar ovento de click do botao
      OkB.OnClick := MeuBotaoOkB_Click;

      if ShowModal <> mrOK then
        Abort;

      if DMConexao.frxExportaMail.UseIniFile then
        INI := IniFiles.TIniFile.Create(ExtractFilePath(Application.ExeName) + ArquivoIniClient)
      else
        INI := TRegistryIniFile.Create('\Software\Tek System Informática Ltda.');
      try
        frxExportaMail.Address := AddressE.Text;
        frxExportaMail.FromName := FromNameE.Text;
        frxExportaMail.FromMail := FromAddrE.Text;
        frxExportaMail.MailCC := AddressCCe.Text;
        frxExportaMail.FromCompany := OrgE.Text;
        frxExportaMail.Signature.Assign(SignatureM.Lines);
        frxExportaMail.SmtpHost := HostE.Text;
        frxExportaMail.SmtpPort := StrToInt(PortE.Text);
        frxExportaMail.Login := LoginE.Text;
        frxExportaMail.Password := PasswordE.Text;
        frxExportaMail.Subject := SubjectE.Text;
        frxExportaMail.Lines.Text := MessageM.Lines.Text;
        frxExportaMail.Timeout := StrToInt(TimeoutE.Text);
        frxExportaMail.ConfurmReading := ReadingCB.Checked;
        frxExportaMail.ShowExportDialog := SettingCB.Checked;

        if Radio_Smtp.Checked then
          frxExportaMail.UseMAPI := SMTP
        else if Radio_MAPI.Checked then
          frxExportaMail.UseMAPI := MAPI
        else if Radio_Outlook.Checked then
          frxExportaMail.UseMAPI := MSOutlook;

        if RememberCB.Checked and UseIniFile_Remetente then
        begin
          INI.WriteString(Section, 'FromName', FromNameE.Text);
          INI.WriteString(Section, 'FromAddress', FromAddrE.Text);
          INI.WriteString(Section, 'Organization', OrgE.Text);

          ST := TMemoryStream.Create;
          try
            SignatureM.Lines.SaveToStream(ST);
            ST.Position := 0;
            INI.WriteBinaryStream(Section, 'SignatureM', ST);
          finally
            FreeAndNil(ST);
          end;

          INI.WriteBool(Section, 'ConfurmReading', ReadingCB.Checked);
          INI.WriteBool(Section, 'ShowExportDialog', SettingCB.Checked);

          // ini.WriteString(Section, 'Signature', SignatureM.Lines.Text);
          INI.WriteString(Section, 'SmtpHost', HostE.Text);
          INI.WriteString(Section, 'SmtpPort', PortE.Text);
          INI.WriteString(Section, 'Login', string(Base64Encode(AnsiString(LoginE.Text))));
          INI.WriteString(Section, 'Password', string(Base64Encode(AnsiString(PasswordE.Text))));
          INI.WriteString(Section, 'Timeout', string(TimeoutE.Text));
        end;

        if UseIniFile_EMail then
        begin
          INI.WriteString(EMAIL_EXPORT_SECTION + '.RecentAddresses', AddressE.Text, AddressE.Text);
          INI.WriteString(EMAIL_EXPORT_SECTION + '.RecentSubjects', SubjectE.Text, SubjectE.Text);
          INI.WriteString(EMAIL_EXPORT_SECTION + '.RecentAddressCCs', AddressCCe.Text, AddressCCe.Text);
          INI.WriteInteger(Section, 'LastUsedAddressCC', AddressCCe.ItemIndex);
          INI.WriteInteger(Section, 'LastUsedExport', ExportsCombo.ItemIndex);
        end;
      finally
        FreeAndNil(INI);
      end;

      frxExportaMail.ShowExportDialog := SettingCB.Checked;
      frxExportaMail.ExportFilter := TfrxCustomExportFilter(ExportsCombo.Items.Objects[ExportsCombo.ItemIndex]);

      if Assigned(frxExportaMail.ExportFilter) then
        frxExportaMail.ExportFilter.SlaveExport := True;
    end;
  finally
    FreeAndNil(FormMailExportDialog);
  end;
  Flag_EnviandoRelatorioFastReport := True;
end;

function TDMConexao.frxExportaMailSendMail(const Server: string; const Port: Integer; const UserField, PasswordField: string;
  FromField, ToField, SubjectField,
  CompanyField, TextField: WideString;
  FileNames: TStringList; Timeout: Integer; ConfurmReading: Boolean; MailCc, MailBcc: WideString): string;
var
  i, P: Integer;
  s, NomeArquivo, Identificacao: string;
  MSGSimples, MSGHtml: string;
  EnviaEmail: TEnviarEmail;
begin
  TFAguarde.Ativar(Self.Name, 'Enviando e-mail');
  try
    Identificacao := '';
    for i := 0 to FileNames.Count - 1 do
    begin
      NomeArquivo := ExtractFileName(FileNames[i]);
      NomeArquivo := ChangeFileExt(NomeArquivo, '');

      if Identificacao <> '' then // Concatenar a identificacao, geralmente irá um arquivo apenas
        Identificacao := Identificacao + ', ';
      Identificacao := NomeArquivo;
    end;

    if DMConexao.frxExportaMail.Lines.Count = 0 then
    begin
      MSGSimples :=
        'E-mail/Relatório Exportado pelo Sistema da Tek-System ' + #13 +
        SecaoAtual.Empresa.Nome + #13#13 +
        'Informações sobre o Relatório: ' + #13 +
        'Descrição: ' + Identificacao + #13 +
        'Autor: ' + DMConexao.frxExportaMail.FromName + #13 +
        'Empresa: ' + DMConexao.frxExportaMail.FromCompany + #13#13 +
        DMConexao.frxExportaMail.Lines.Text + #13#13#13;

      MSGHtml :=
        '<html><body>' + #13 +
        '<p align="center"><b> E-mail/Relatório Exportado pelo Sistema da Tek-System </b></p>' + #13 +
        '<p align="center">' + SecaoAtual.Empresa.Nome + '</p>'#13 +
        '<p align="center"><u>Informações sobre o Relatório:</u></p>' + #13 +
        '<font face="Courier New"><UL>' +
        '<LI> Descrição...: ' + Identificacao + '</LI>'#13 +
        '<LI> Autor.......: ' + DMConexao.frxExportaMail.FromName + '</LI>'#13 +
        '<LI> Empresa.....: ' + DMConexao.frxExportaMail.FromCompany + '</LI>'#13 +
        '</UL></font><p>' + DMConexao.frxExportaMail.Lines.Text + '</p>'#13#13#13;

      MSGHtml := MSGHtml + '<font face="Tahoma" size=2><UL>';
      MSGHtml := MSGHtml + '<p align="left">';

      for i := 0 to DMConexao.frxExportaMail.Signature.Count - 1 do
      begin
        MSGHtml := MSGHtml + '<br>' + DMConexao.frxExportaMail.Signature[i] + '</br>';
        MSGSimples := MSGSimples + DMConexao.frxExportaMail.Signature[i];
      end;

      MSGHtml := MSGHtml + '</p>';
      MSGHtml := MSGHtml + '</UL></font>';
      MSGHtml := MSGHtml + '</body></html>';

      TextField := MSGSimples;
    end
    else
    begin
      MSGSimples := DMConexao.frxExportaMail.Lines.Text;
      MSGHtml := '';
    end;

    EnviaEmail := TEnviarEmail.Create(Self);
    try
      if (frxExportaMail.SmtpHost <> '') then
      begin
        EnviaEmail.ServidorEmail_Host := DMConexao.frxExportaMail.SmtpHost;
        EnviaEmail.ServidorEmail_Port := DMConexao.frxExportaMail.SmtpPort;
        EnviaEmail.ServidorEmail_Username := DMConexao.frxExportaMail.Login;
        EnviaEmail.ServidorEmail_Password := DMConexao.frxExportaMail.Password;

        EnviaEmail.ServidorEmail_EmailSeguro := Flag_EnviaEmail_ServidorEmail_EmailSeguro;
        EnviaEmail.ServidorEmail_TLS := Flag_EnviaEmail_ServidorEmail_TLS;
      end;

      EnviaEmail.Remetente_Nome := DMConexao.frxExportaMail.FromName;
      EnviaEmail.Remetente_Email := DMConexao.frxExportaMail.FromMail;

      EnviaEmail.Assunto := DMConexao.frxExportaMail.Subject;
      EnviaEmail.MensagemHTML := MSGHtml;
      EnviaEmail.Mensagem := MSGSimples;

      for i := 0 to FileNames.Count - 1 do
      begin
        s := FileNames[i];
        P := Pos('=', s);
        if P > 0 then
          NomeArquivo := Trim(Copy(s, 1, P - 1))
        else
          NomeArquivo := s;
        EnviaEmail.ArquivosAnexados.Add(NomeArquivo);
      end;

      EnviaEmail.Destinatario_Email := DMConexao.frxExportaMail.Address;
      EnviaEmail.Destinatario_EmailCC := DMConexao.frxExportaMail.MailCc;
      EnviaEmail.Destinatario_EmailCCO := DMConexao.frxExportaMail.MailBcc;

      if SecaoAtual.Parametro.ContaCopiaEmail <> '' then
        EnviaEmail.Destinatario_EmailCCO := IfThen(EnviaEmail.Destinatario_EmailCCO <> '', EnviaEmail.Destinatario_EmailCCO + ';', '') + SecaoAtual.Parametro.ContaCopiaEmail;

      if DMConexao.SecaoAtual.Parametro.ContaCopiaEmailProc <> '' then
        EnviaEmail.Destinatario_EmailCCO := IfThen(EnviaEmail.Destinatario_EmailCCO <> '', EnviaEmail.Destinatario_EmailCCO + ';', '') + SecaoAtual.Parametro.ContaCopiaEmailProc;

      if SecaoAtual.Usuario.EmailPadrao.Copia <> '' then
        EnviaEmail.Destinatario_EmailCCO := IfThen(EnviaEmail.Destinatario_EmailCCO <> '', EnviaEmail.Destinatario_EmailCCO + ';', '') + SecaoAtual.Usuario.EmailPadrao.Copia;

      EnviaEmail.UsaRemetenteEmailNoFrom := True;
      EnviaEmail.SolicitarConfirmacaoDeLeitura := DMConexao.frxExportaMail.ConfurmReading;

      case frxExportaMail.UseMAPI of
        TMailTransport.SMTP:
          EnviaEmail.FormaEnvio := ClassEnviarEmail.TFormaEnvioEmail(Flag_EnviaEmail_Metodo);
        TMailTransport.MAPI:
          EnviaEmail.FormaEnvio := ClassEnviarEmail.envioEmailMapi;
        TMailTransport.MSOutlook:
          EnviaEmail.FormaEnvio := EnviaEmail.getDefaultMailer;
      end;

      EnviaEmail.Enviar;
    finally
      FreeAndNil(EnviaEmail);

      Flag_EnviandoRelatorioFastReport := false;
      DestinatarioPadraoEmailRelatorio := '';
      AssuntoPadraoEmailRelatorio := '';
    end;
  finally
    TFAguarde.Desativar(Self.Name);
  end;

  Result := '';
end;

procedure TDMConexao.CarregarListaDeTabelasEProceduresDoBDD;
begin
  SynSQLSynPadrao.FunctionNames.Text := ExecuteMethods('TSMConexao.GetProcedureNames', []);
  SynSQLSynPadrao.TableNames.Text    := ExecuteMethods('TSMConexao.GetTableNames',     [False]);
  SynSQLSynPadrao.TableNames.Add(ExecuteMethods('TSMConexao.GetTableNames', [True]));
end;

procedure TDMConexao.CarregarUnitsProtegidas;
begin
  if (CDSUnitsProtegidas.Active) then
    Exit;

  CDSUnitsProtegidas.Data := ExecuteMethods('TSMConexao.UnitsProtegidas', []);
  with CDSUnitsProtegidas do
    begin
      LogChanges := False;
      First;
      while (not Eof) do
        begin
          Edit;
          FieldByName('CODIFICACAO').AsString := TrimRight(TFuncoesCriptografia.Decodifica(FieldByName('CODIFICACAO').AsString, sChaveCriptografia));
          Post;

          Next;
        end;

      IndexFieldNames := 'NOME';
    end;
end;

procedure TDMConexao.CarregarProcessamentosProtegidos;
begin
  if (CDSProcessamentosProtegidos.Active) then
    Exit;

  CDSProcessamentosProtegidos.Data := ExecuteMethods('TSMConexao.ProcessamentosProtegidos', []);
  with CDSProcessamentosProtegidos do
    begin
      LogChanges := False;
      First;
      while (not Eof) do
        begin
          Edit;
          FieldByName('CODIFICACAO').AsString := TrimRight(TFuncoesCriptografia.Decodifica(FieldByName('CODIFICACAO').AsString, sChaveCriptografia));
          Post;

          Next;
        end;

      IndexFieldNames := 'CODIGOTEKSYSTEM';
    end;
end;

{$ENDREGION}

{$REGION 'Carga de Cache'}
procedure TDMConexao.CarregaDefaults;
begin
  CDSDefaults.Data := ExecuteMethods('TSMConexao.CarregaDefaults', ['']);
  CDSDefaults.IndexFieldNames := 'TABELA';
end;

procedure TDMConexao.AtribuirOutrosDefault(DS: TDataSet; Tabela: string);
begin
  DS.AtribuirOutrosDefault(CDSDefaults, Tabela);
end;

procedure TDMConexao.CarregaPermissoesDoCadastro;
var sql: string;
begin
  sql :=
    'select ' + #13 +
    '  USUARIO_CLASSES.CLASSE_USUCLASS, ' + #13 +
    '  USUARIO_CLASSES.INCLUI_USUCLASS, ' + #13 +
    '  USUARIO_CLASSES.ALTERA_USUCLASS, ' + #13 +
    '  USUARIO_CLASSES.EXCLUI_USUCLASS' + #13 +
    'from USUARIO_CLASSES' + #13 +
    'where USUARIO_CLASSES.USUARIO_USUCLASS = ' + IntToStr(SecaoAtual.Usuario.Codigo);

  CDSPermissoes.Data := DMConexao.ExecuteReader(sql, -1);
  CDSPermissoes.IndexFieldNames := 'CLASSE_USUCLASS';
end;

procedure TDMConexao.CarregaConfigClasses;
var sql: string;
begin
  sql :=
    'select ' + #13 +
    '  CONFIG_CLASSES.CLASSEPAI_CFGC, ' + #13 +
    '  CONFIG_CLASSES.CLASSE_CFGC, ' + #13 +
    '  CONFIG_CLASSES.CONDICAO_CFGC, ' + #13 +
    '  CONFIG_CLASSES.MENSAGEM_CFGC ' + #13 +
    'from CONFIG_CLASSES ';

  CDSConfigClasses.Data := DMConexao.ExecuteReader(sql, -1);
  CDSConfigClasses.IndexFieldNames := 'CLASSEPAI_CFGC;CLASSE_CFGC';
end;

procedure TDMConexao.CarregaConfigCamposClasses;
var sql: string;
begin
  sql :=
    'select ' + #13 +
    '  USUARIO_CLASSES.CLASSE_USUCLASS,   ' + #13 +
    '  USUARIO_CLASSES_CAMPOS.CLASSE_UCC, ' + #13 +
    '  USUARIO_CLASSES_CAMPOS.CAMPO_UCC,  ' + #13 +
    '  ''S'' BLOQUEAR_UCC, ' + #13 +
    '  ''N'' OMITIR_UCC,   ' + #13 +
    '  ''''  CONDICAO_UCC, ' + #13 +
    '  ''''  MENSAGEM_UCC  ' + #13 +
    'from USUARIO_CLASSES_CAMPOS ' + #13 +
    'inner join USUARIO_CLASSES on (USUARIO_CLASSES.AUTOINC_USUCLASS = USUARIO_CLASSES_CAMPOS.CODIGOCLASSE_UCC) ' + #13 +
    'where USUARIO_CLASSES.USUARIO_USUCLASS  = ' + IntToStr(SecaoAtual.Usuario.Codigo) + #13 +
    'union all' + #13 +
    'select ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.CLASSEPAI_CCC, ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.CLASSE_CCC,    ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.CAMPO_CCC,     ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.BLOQUEAR_CCC,  ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.OMITIR_CCC,    ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.CONDICAO_CCC,  ' + #13 +
    '  CONFIG_CLASSES_CAMPOS.MENSAGEM_CCC   ' + #13 +
    'from CONFIG_CLASSES_CAMPOS ';

  CDSConfigCamposClasses.Data := DMConexao.ExecuteReader(sql, -1);
  CDSConfigCamposClasses.IndexFieldNames := 'CLASSE_USUCLASS;CLASSE_UCC;CAMPO_UCC';
end;

procedure TDMConexao.CarregaMensagem;
begin
  StatusDeMensagens := ExecuteMethods('TSMMensagem.MensagemNaoLida', []);
end;

procedure TDMConexao.CarregaSecaoAtual;
var
  vJson: TJSONValue;
  xUnMarshal: TJSONUnMArshal;
  FCommand: TDBXCommand;
  sSQL: string;
  CDSTemp: TClientDataSet;
begin
  FCommand := SQLConexao.DBXConnection.CreateCommand;
  try
    FCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FCommand.Text := 'TSMConexao.SecaoAtualSerializadaNovo';
    FCommand.Prepare;
    FCommand.Parameters[0].Value.AsString := '1';
    FCommand.ExecuteUpdate;
    vJson := TJSONValue(FCommand.Parameters[1].Value.GetJSONValue);
  finally
    FreeAndNil(FCommand);
  end;

  if Assigned(vJson) then
  begin
    if Assigned(fSecaoAtual) then
      FreeAndNil(fSecaoAtual);

    xUnMarshal := TJSONUnMArshal.Create;
    try
      fSecaoAtual := (xUnMarshal.UnMarshal(vJson) as TClassSecaoNovo);
    finally
      FreeAndNil(xUnMarshal);
    end;
    FreeAndNil(vJson);
  end;

  CarregaPermissoesDoCadastro;
  CarregaConfigCamposClasses;

  CDSTemp := TClientDataSet.Create(nil);
  try
    sSQL :=
      'select EMPRESA.LOGOMARCA_EMP from EMPRESA' + #13 +
      'where EMPRESA.CODIGO_EMP = ' + IntToStr(SecaoAtual.Empresa.Codigo);
    CDSTemp.Data := ExecuteReader(sSQL, -1, True);

    if not Assigned(LogoEmpresa) then
      LogoEmpresa := TPicture.Create;

    CDSTemp.FieldByName('LOGOMARCA_EMP').Recuperar(LogoEmpresa);
  finally
    FreeAndNil(CDSTemp);
  end;

  if (FPrincipal <> nil) then
    FPrincipal.ConfigurarAmbienteSistema;

{$IF DEFINED(QUALIDADE)}
  DMConexao.ExecuteMethods('TSMConexao.AtualizarContadorSAC', [DMConexao.SecaoAtual.Usuario.Codigo]);
{$IFEND}

{$Region 'Extração Schemas NFS-e - Provedor pode variar de acordo com município da empresa'}
{$IF DEFINED(FATURAMENTO) OR DEFINED(ESTOQUE) OR DEFINED(LIVROSFISCAIS) OR DEFINED(ANEXO)}
  if not ClassFuncoesSistemaOperacional.IsDebuggerPresent() then
  begin
    TThread.CreateAnonymousThread(
      procedure()
      begin
        TClassConfigNFSe.ExtraiSchemasXMLNFSe(sisERP, NomeSchemaProvedorNFSe(DMConexao.SecaoAtual.Parametro.NFSe_Provedor));
      end
      ).Start;
  end;
{$IFEND}
{$EndRegion}

end;

procedure TDMConexao.CarregaModulosDisp(var CDS: TClientDataSet);
var
  X: Integer;
begin
  with CDS do
  begin
    Close;
    with FieldDefs do
    begin
      Clear;
      Add('Codigo', ftInteger);
      Add('Descricao', ftString, 40);
    end;
    CreateDataSet;
    LogChanges := false;
    IndexFieldNames := 'Descricao';

    // É necessário a inclusão do registro zero para passar na validação do new record
    Insert;
    FieldByName('Codigo').AsInteger := 0;
    FieldByName('Descricao').AsString := 'Indefinido';
    Post;

    for X := Low(Modulos) to High(Modulos) do
    begin
      Insert;
      FieldByName('Codigo').AsInteger := X;
      FieldByName('Descricao').AsString := Copy(Modulos[X, 2], 1, 40);
      Post;
    end;
  end;
end;

function TDMConexao.GetCDSConfigCamposClasses: OleVariant;
begin
  Result := CDSConfigCamposClasses.Data;
end;

function TDMConexao.GetCDSConfigClasses: OleVariant;
begin
  Result := CDSConfigClasses.Data;
end;

{$ENDREGION}

{$REGION 'Atualizar registro pala DLL / Consumir DLL'}


procedure TDMConexao.AtualizarDeptoPessoal(MostrarMensagem: Boolean);
var
  Parametros: OleVariant;
begin
  ExecuteMethods_ComCallBack('TSMDepPessoal.EP_InicializarTabelas', [Parametros]);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao(sSucessoEmProcesso);
end;

procedure TDMConexao.AtualizarESocial(MostrarMensagem: Boolean);
var
  Parametros: OleVariant;
begin
  ExecuteMethods_ComCallBack('TSMDepPessoal.EP_InicializarTabelasESocial', [Parametros]);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao(sSucessoEmProcesso);
end;

procedure TDMConexao.AtualizarImportaExportaTitulos(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadConfigExportacaoTitulos.AtualizarConfiguracoesImportaExportaTekSystem', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Configurações de Importação/Exportação de Títulos atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarLivroFiscal(MostrarMensagem: Boolean);
var
  Parametros: OleVariant;
begin
  ExecuteMethods_ComCallBack('TSMLivroFiscal.ExecProcedimento', [LF_Constantes.LF_Proc_InicializarTabelas, Parametros]);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao(sSucessoEmProcesso);
end;

procedure TDMConexao.AtualizarModelosDataWarehouse(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadDW_Temas.AtualizarModelosDataWarehouse', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Temas de Armazéns de Dados (Data Warehouse) Atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarModelosRelatoriosEspecificos(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadGR_Relatorio.AtualizarModelosRelatorios', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Relatórios Específicos (Gerador) atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarModelosUnidadesCodificacao(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadGR_Unidades_Codificacao.AtualizarModelosUnidadesCodificacao', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Modelos de Unidades de Codificação Atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarModelosProcessamentos(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadTI_Processamentos.AtualizarModelosProcessamentosTekSystem', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Processamentos Específicos foram atualizados com sucesso!');
end;

procedure TDMConexao.AtualizarModelosIndicadores(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadGR_Indicadores.AtualizarIndicadoresTekSystem', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Modelos de Indicadores Atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarConfigRemessaRetornoBanc(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMCadConfigRemessaRetorno.AtualizarConfiguracoesRemessaRetornoBancTekSystem', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Configurações de Remessa/Retorno Bancários Atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarContabilidade(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMContabilidade.InicializarDadosContabilidade', []);
  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Tabelas do Módulo Contabilidade Atualizados com Sucesso!');
end;

procedure TDMConexao.AtualizarModelosRelatorios(MostrarMensagem: Boolean);
begin
  ExecuteMethods_ComCallBack('TSMRelatorio.AtualizaRelatorios', []);

  if MostrarMensagem then
    TCaixasDeDialogo.Informacao('Modelos de relatórios atualizados com sucesso!');
end;

procedure TDMConexao.ExtrairModeloRelPai;
const
  MaxTentativas = 5;
var
  Tentativa: Integer;
  ST: TMemoryStream;
begin
  // No caso da abertura de diversos módulos simultâneos,
  // por exemplo com terminal server
  Tentativa := 1;
  while (Tentativa <= MaxTentativas) do
  begin
    try
      ST := TMemoryStream.Create;
      try
        TFuncoesSistemaOperacional.LerRecursoDLL(sPaiRelatorioGrafico, sNomeDll, ST);
        ST.SaveToFile(Config.DirExe + sPaiRelatorioGrafico + '.fr3');
        Break;
      Finally
        FreeAndNil(ST);
      end;
    except
      on E: Exception do
      begin
        if (Tentativa = MaxTentativas) then
        begin
          if TCaixasDeDialogo.Confirma(
            'Foram feitas ' + IntToStr(MaxTentativas) + ' tentativas de extração do arquivo que contém o modelo pai de relatórios.' +
            'No entanto, não foi possível sua extração, devido o erro:' + #13 + E.Message + #13 +
            'Gostaria de tentar novamente agora?') then
            Tentativa := 1
          else
            Halt;
        end
        else
        begin
          Inc(Tentativa);
          Application.ProcessMessages;
        end;
      end;
    end;
  end;
end;

{$ENDREGION}

{$REGION 'Metodos Comuns com SMConexao'}


function TDMConexao.ProximoCodigo(Tabela: string; Quebra: Integer = 0): int64;
begin
  // Executa a função Proximo do Servidor de Aplicação, que tem o objetivo de
  // retornar o próximo código para a tabela em questão
  Tabela := AnsiUpperCase(Tabela);
  Result := ExecuteMethods('TSMConexao.ProximoCodigo', [Tabela, Quebra]);
end;

function TDMConexao.ProximoCodigoAcrescimo(Tabela: string; Quebra, Acrescimo: Integer): int64;
begin
  // Executa a função Proximo do Servidor de Aplicação, que tem o objetivo de
  // retornar o próximo código para a tabela em questão, com incremento de acordo com o terceiro parametro
  Tabela := AnsiUpperCase(Tabela);
  Result := ExecuteMethods('TSMConexao.ProximoCodigoAcrescimo', [Tabela, Quebra, Acrescimo]);
end;

function TDMConexao.DataHora: TDateTime;
begin
  // Posteriormente substituir a função DataHoraServidor por essa;
  Result := DataHoraServidor;
end;

function TDMConexao.DataHoraServidor(ForcaHoraServidor: Boolean = false): TDateTime;
begin
  // Executa a função DataHora do Servidor de Aplicação, que tem o objetivo de
  // Retornar a data e hora do servidor de banco de dados
  // ATENÇÃO: Só é chamada uma vez no sistema, para evitar fluxo ao Servidor de Aplicação.
  // Use a variável cDataHoraServidor que é sempre atualizada
  if (ForcaHoraServidor) or (cDataHoraServidor = 0) then
    Result := ExecuteMethods('TSMConexao.DataHora', [])
  else
    Result := cDataHoraServidor;
end;

procedure TDMConexao.RegistraAcao(Descricao: string; Inicio, Fim: TDateTime; Observacao: string);
begin
  // Executa a função RegistraAcao do Servidor de Aplicação, que tem o objetivo de
  // Registrar ações monitoradas/perigosas executadas pelo usuário
  ExecuteMethods('TSMConexao.RegistraAcao', [Descricao, Inicio, Fim, Observacao]);
end;

{$ENDREGION}

{$REGION 'Dias Não Uteis'}


procedure TDMConexao.CarregaDiasNaoUteis(Modulo: Integer);
begin
  if Assigned(CntrlDiasNaoUteis) then
    CntrlDiasNaoUteis.QtdeReferencias := CntrlDiasNaoUteis.QtdeReferencias + 1
  else
    CntrlDiasNaoUteis := TClassCntrlDiasUteis.Create(Self, Modulo, SecaoAtual.Empresa.CidadeCod);
end;

procedure TDMConexao.ReCarregaDiasNaoUteis(Modulo: Integer);
begin
  if Assigned(CntrlDiasNaoUteis) then
    CntrlDiasNaoUteis.CarregaDiasNaoUteis;
end;

procedure TDMConexao.DesCarregaDiasNaoUteis;
begin
  if (CntrlDiasNaoUteis.QtdeReferencias = 1) then
    FreeAndNil(CntrlDiasNaoUteis)
  else
    CntrlDiasNaoUteis.QtdeReferencias := CntrlDiasNaoUteis.QtdeReferencias - 1;
end;

function TDMConexao.DiasEntre(dDataInicial, dDataFinal: TDate; iSistema: Integer; bDiaUtil, bPermiteNegativo: Boolean): Integer;
begin
  CarregaDiasNaoUteis(iSistema);
  try
    Result := CntrlDiasNaoUteis.DiasEntre(dDataInicial, dDataFinal, bDiaUtil, bPermiteNegativo, iSistema);
  finally
    DesCarregaDiasNaoUteis;
  end;
end;

function TDMConexao.DiaUtil(cData: TDate; Modulo: Integer; Cidade: Integer = 0): Boolean;
var
  ClasseCriadaAgora: Boolean;
begin
  ClasseCriadaAgora := not Assigned(CntrlDiasNaoUteis);
  if (ClasseCriadaAgora) then
    CntrlDiasNaoUteis := TClassCntrlDiasUteis.Create(Self, Modulo, Cidade);

  try
    Result := CntrlDiasNaoUteis.DiaUtil(cData);
  finally
    if (ClasseCriadaAgora) then
      FreeAndNil(CntrlDiasNaoUteis);
  end;
end;

function TDMConexao.DiaUtilAnterior(Data: TDate; Modulo, Cidade: Integer): TDate;
var
  ClasseCriadaAgora: Boolean;
begin
  ClasseCriadaAgora := not Assigned(CntrlDiasNaoUteis);
  if (ClasseCriadaAgora) then
    CntrlDiasNaoUteis := TClassCntrlDiasUteis.Create(Self, Modulo, Cidade);

  try
    Result := CntrlDiasNaoUteis.DiaUtilAnterior(Data);
  finally
    if (ClasseCriadaAgora) then
      FreeAndNil(CntrlDiasNaoUteis);
  end;
end;

function TDMConexao.DiasUteisEntre(dDataInicial, dDataFinal: TDateTime; Modulo: Integer; Cidade: Integer = 0): Integer;
var
  ClasseCriadaAgora: Boolean;
begin
  ClasseCriadaAgora := not Assigned(CntrlDiasNaoUteis);
  if (ClasseCriadaAgora) then
    CntrlDiasNaoUteis := TClassCntrlDiasUteis.Create(Self, Modulo, Cidade);

  try
    Result := CntrlDiasNaoUteis.DiasUteisEntre(Trunc(dDataInicial), Trunc(dDataFinal));
  finally
    if (ClasseCriadaAgora) then
      FreeAndNil(CntrlDiasNaoUteis);
  end;
end;

function TDMConexao.ProximoDiaUtil(Data: TDate; Modulo: Integer; Cidade: Integer = 0): TDate;
var
  ClasseCriadaAgora: Boolean;
begin
  ClasseCriadaAgora := not Assigned(CntrlDiasNaoUteis);
  if (ClasseCriadaAgora) then
    CntrlDiasNaoUteis := TClassCntrlDiasUteis.Create(Self, Modulo, Cidade);

  try
    Result := CntrlDiasNaoUteis.ProximoDiaUtil(Data);
  finally
    if (ClasseCriadaAgora) then
      FreeAndNil(CntrlDiasNaoUteis);
  end;
end;

{$ENDREGION}

{$REGION 'Autorização'}


function TDMConexao.VerificaAutorizacao(cOpcao: Integer): Boolean;
begin
  Result := SecaoAtual.Usuario.AutorizacaoEspecial[cOpcao];
end;

function TDMConexao.VerificaAutorizacao(sOpcao: string): Boolean;
begin
  Result := VerificaAutorizacao(StrToInt(sOpcao));
end;

function TDMConexao.VerificaAutorizacao_ComOutroUsuario(cUsuario, cOpcao: Integer): Boolean;
var
  CDSTemp: TClientDataSet;
begin
  CDSTemp := TClientDataSet.Create(nil);
  try
    with ListaDeStrings do
    begin
      Clear;
      Add('select USUARIO_ESPECIAIS.AUTOINC_USUESP');
      Add('from USUARIO_ESPECIAIS');
      Add('where USUARIO_ESPECIAIS.USUARIO_USUESP = ' + IntToStr(cUsuario));
      Add('  and USUARIO_ESPECIAIS.OPCAO_USUESP   = ' + IntToStr(cOpcao));
    end;
    CDSTemp.Data := ExecuteReader(ListaDeStrings.Text, 1);
    Result := not CDSTemp.eof;
  finally
    FreeAndNil(CDSTemp);
  end;
end;

{$ENDREGION}

{$REGION 'Metodos Diversos'}

procedure TDMConexao.EntrarNoSistema(TrocaInterna: Boolean);
var
  sUsuario, sSenha, sRetorno: string;
  iQuebra: Integer;
  tpStrListTekProt: TStringList;
begin
  // if not (TrocaInterna) then
  LerServidoresAplicacao;

  if (TrocaInterna) then
  begin
    if ConstanteSistema.Sistema = cSistemaCaixa then
      iQuebra := SecaoAtual.Empresa.Codigo
    else if (ConstanteSistema.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
      iQuebra := SecaoAtual.Empresa.Estabelecimento
    else
      iQuebra := SecaoAtual.Empresa.Codigo;
  end
  else
  begin
    if ConstanteSistema.Sistema = cSistemaCaixa then
      iQuebra := StrToIntDef(TArquivoINI.Ler('MenuPrincipal', 'CaixaAtual', '1'), 0)
    else if (ConstanteSistema.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
      iQuebra := StrToIntDef(TArquivoINI.Ler('MenuPrincipal', 'EstabelecimentoAtual', '1'), 0)
    else if (ConstanteSistema.Sistema = cSistemaESocial) then
      iQuebra := StrToIntDef(TArquivoINI.Ler('MenuPrincipal', 'EmpregadorAtual', '1'), 0)
    else
      iQuebra := StrToIntDef(TArquivoINI.Ler('MenuPrincipal', 'EmpresaAtual', '1'), 0);
  end;

  if Assigned(FSplash) then
    FSplash.Passo(25, 'Login...');

  if (ParamCount > 0) or (TrocaInterna) then
  begin
    if (TrocaInterna) then
    begin
      sUsuario := SecaoAtual.Usuario.Nome;
      sSenha := SecaoAtual.Usuario.Senha;
    end
    else // (ParamCount > 0)
    begin
      sUsuario := ParamStr(1);
      sSenha := ParamStr(2);
      if FindCmdLineSwitch('CRIPT', ['/'], True) then
        sSenha := TFuncoesCriptografia.Decodifica(sSenha, sChaveCriptografia);

        //Trim(Decode(sSenha));
    end;

    if (not ConectaServidorAplicacao(sUsuario, sSenha, iQuebra)) then
      FecharSistema;
  end
  else
  begin
    Application.CreateForm(TFLogin, FLogin);
    FSplash.Hide;
    try
      FLogin.Quebra := iQuebra;

      if (FLogin.ShowModal <> mrOK) then
        FecharSistema;
    finally
      FreeAndNil(FLogin);
    end;
  end;

  if ServidorBDD = '' then
    FecharSistema;

  TFuncoesBaseDados.AcertarParticularidades(DriverBDDAtual, Constantes.ParticularidadesBDD);

  Application.CreateForm(TDMDownload, DMDownload);
  try
    DMDownload.VerificaArquivosNecessarios;
  finally
    DMDownload.Free;
  end;

  CarregaSecaoAtual;

  CallBack.Configura(
    DMConexao.SQLConexao.Params.Values[TDBXPropertyNames.HostName],
    DMConexao.SQLConexao.Params.Values[TDBXPropertyNames.Port],
    SecaoAtual.Usuario.Nome,
    SecaoAtual.Usuario.Senha,
    Config.ServidorProxy,
    Config.PortaProxy,
    Config.UsuarioProxy,
    Config.SenhaProxy,
    FuncoesCallBack2.cCanal,
    SecaoAtual.Guid);
  CallBack.RegistraCallBack(SecaoAtual.Usuario.Nome);

  VerificaTrocaDeSenha;

  {$region 'Tekprot'}
  if (not Assigned(TekProtClient)) or ((Assigned(TekProtClient)) and ((TekProtClient.Server <> Config.ServidorTekProt) or (TekProtClient.Port <> Config.PortaTekProt))) then
    begin
      if Assigned(FSplash) then
        FSplash.Passo(60, 'Validando a Cópia do Sistema');
      try
        if Assigned(TekProtClient) then
          begin
            TekProtClient.OnAfterValidate := nil;
            TekProtClient.OnGetCloseApp   := nil;
            FreeAndNil(TekProtClient);
          end;

        TekProtClient := TTekProtClient.Create(Self);
        with TekProtClient do
          begin
            ExecName  := Modulos[Sistema, 1];
            ModuleCod := StrToInt(Modulos[Sistema, 3]);

            if (SecaoAtual.Empresa.Codigo = 0) or (SecaoAtual.Sistema in [cSistemaCaixa, cSistemaDepPessoal, cSistemaContabilidade, cSistemaESocial]) then
              EmpID := EmptyStr
            else
              EmpID := TFuncoesString.SoNumero(IfThen(SecaoAtual.Empresa.Natureza = 'J', SecaoAtual.Empresa.CNPJ, SecaoAtual.Empresa.CPF));

            Server := Config.ServidorTekProt;
            Port   := Config.PortaTekProt;

            OnAfterValidate := AposValidar;
            OnGetCloseApp   := QuandoNaoAutorizado;

            validarLicenca;

            // A função abaixo retorna erros no result, assim uma pequena gambia
            // para saber se o retorno que está chegando é um erro ou o valor esperado
            sRetorno := GetLicenseInfo(liClientInfo);
            if Pos('Ocorreram falhas', sRetorno) > 0 then
              raise Exception.Create(sRetorno);

            tpStrListTekProt := TStringList.Create;
            try
              TFuncoesString.DividirParaStringList(tpStrListTekProt, sRetorno, '|');
              with tpStrListTekProt do
                begin
                  FCodigoClienteTek           := Strings[0];
                  FCNPJClienteTek             := Strings[1];
                  FNomeClienteTek             := Strings[2];
                  FEmpresasDisponiveis        := Strings[3];
                  FFuncionalidadesDisponiveis := Strings[4];
                end;
            finally
              if Assigned(tpStrListTekProt) then
                 FreeAndNil(tpStrListTekProt);
            end;
          end;
      except
        on E: Exception do
          begin
            TCaixasDeDialogo.Erro('Ocorreu o seguinte erro ao tentar validar a sua cópia do sistema: ' + #13 +
                                  E.Message + #13 +
                                  'Servidor: ' + TekProtClient.Server + ', porta: ' +
              IntToStr(TekProtClient.Port));

            if TCaixasDeDialogo.Confirma('Deseja configurar servidor de proteção?') then
              ChamarConfig;

            TCaixasDeDialogo.Erro('Sistema será finalizado, acesse novamente se desejar.');

            FecharSistema;
          end;
      end;
    end;
  {$endregion}
end;

function TDMConexao.ConectaServidorAplicacao(cUsuario, cSenha: string; iQuebra: Integer): Boolean;
var
  Primeira: Boolean;
  Servidor, ServidorTP, S: string;
  Porta, PortaTP: Integer;
  SL: TStrings;
begin
  Result := false;

  if Assigned(FSplash) then
  begin
    FSplash.Show;
    FSplash.Passo(30, 'Preparando Conexão...');
  end;

  Porta := 0;
  PortaTP := 0;

  CDSServidores.First;

  Primeira := True;
  while True do
    try
      if Primeira then
      begin
        if Assigned(FSplash) then
          FSplash.Passo(35, 'Conectando ao Servidor de Aplicação Principal');

        SQLConexao.Connected := false;

        with SQLConexao.Params do
        begin
          Values[TDBXPropertyNames.DSAuthenticationUser] := cUsuario;
          Values[TDBXPropertyNames.DSAuthenticationPassword] := TFuncoesCriptografia.Codifica(cSenha, sChaveCriptografia);

          Values['Quebra'] := IntToStr(iQuebra);
        end;
      end
      else
      begin
        if Assigned(FSplash) then
          FSplash.Passo(40, 'Tentando Servidores de Aplicação Secundários');
      end;

      ConexaoTratada := True;
      try
        if CDSServidores.FieldByName('Tipo').AsInteger = cServTipo_SoftwareCenter then
        begin
          SL := TStringList.Create;
          try
            SL.Values[cConfig_Sistema] := IntToStr(86);
            SL.Values[cConfig_Ambiente] := IntToStr(cTipoBDD_Producao);
            S := SQLConexao.Params.Text;
            S := TFuncoesString.Trocar(S, #13#10, '|');
            SL.Values[cConfig_Paramametros] := S;

            try
              SL.Text := TFuncoes_TekConnects.Configuracoes(
                CDSServidores.FieldByName('Servidor').AsString,
                CDSServidores.FieldByName('Porta').AsInteger,
                SL.Text);
            except
              on E: Exception do
              begin
                if not CDSServidores.eof then
                begin
                  CDSServidores.Next;
                  Continue;
                end;
                raise;
              end;
            end;

            Servidor := SL.Values[cConfig_ServAplicHost];
            Porta := StrToIntDef(SL.Values[cConfig_ServAplicPorta], 0);

            ServidorTP := SL.Values[cConfig_ProtecaoHost];
            PortaTP := StrToIntDef(SL.Values[cConfig_ProtecaoPorta], 0);
          finally
            SL.Free;
          end;
        end else begin
          Servidor := CDSServidores.FieldByName('Servidor').AsString;
          Porta := CDSServidores.FieldByName('Porta').AsInteger;
        end;

        SQLConexao.Connected := false;

        with SQLConexao.Params do
        begin
          Values[TDBXPropertyNames.HostName] := Servidor;
          Values[TDBXPropertyNames.Port] := IntToStr(Porta);

          // if Proxy_Utiliza then
          begin
            Values[TDBXPropertyNames.DSProxyHost] := CDSServidores.FieldByName('Proxy_Host').AsString;
            Values[TDBXPropertyNames.DSProxyPort] := CDSServidores.FieldByName('Proxy_Porta').AsString;
            Values[TDBXPropertyNames.DSProxyUsername] := CDSServidores.FieldByName('Proxy_Usuario').AsString;
            Values[TDBXPropertyNames.DSProxyPassword] := CDSServidores.FieldByName('Proxy_Senha').AsString;
          end;
        end;

        SQLConexao.Connected := True;

        if CDSServidores.FieldByName('Tipo').AsInteger = cServTipo_SoftwareCenter then
        begin
          Config.ServidorRelatorio := '';
          Config.PortaRelatorio    := 0;

          Config.ServidorTekProt   := ServidorTP;
          Config.PortaTekProt      := PortaTP;
        end else begin
          Config.ServidorRelatorio := CDSServidores.FieldByName('Secundario_Host').AsString;
          Config.PortaRelatorio    := CDSServidores.FieldByName('Secundario_Porta').AsInteger;

          Config.ServidorTekProt   := CDSServidores.FieldByName('Protecao_Host').AsString;
          Config.PortaTekProt      := CDSServidores.FieldByName('Protecao_Porta').AsInteger;
        end;

        Config.ServidorProxy     := CDSServidores.FieldByName('Proxy_Host').AsString;
        Config.PortaProxy        := CDSServidores.FieldByName('Proxy_Porta').AsInteger;
        Config.UsuarioProxy      := CDSServidores.FieldByName('Proxy_Usuario').AsString;
        Config.SenhaProxy        := CDSServidores.FieldByName('Proxy_Senha').AsString;

        Config.AcessoPelaInternet := CDSServidores.FieldByName('Rede').AsInteger = cServRede_Extranet;

        Result := True;
        Exit;
      finally
        ConexaoTratada := false;
        Primeira := false;
      end;

      Break;
    except
      on E: EIdSocketError do
      begin
        if not CDSServidores.eof then
        begin
          CDSServidores.Next;
          Continue;
        end;

        if TCaixasDeDialogo.Confirma('Servidor de Aplicação não está rodando em ' +
          Servidor + '/' + IntToStr(Porta) + '.' + #13 +
          'Tentar entrar novamente?' + #13#13 +
          'Mensagem Original: ' + E.Message) then
        begin
          LerServidoresAplicacao;
          Primeira := True;
        end
        else
        begin
          if TCaixasDeDialogo.Confirma('Deseja configurar para outros servidores?') then
          begin
            ChamarConfig;
            Primeira := True;
          end
          else
            Exit;
        end;
      end;

      on E: Exception do
      begin
        TCaixasDeDialogo.Erro(E.Message);
        Break;
      end;
    end;
end;

procedure TDMConexao.LerServidoresAplicacao;
const
  MaxTentativas = 5;
var
  Arq: string;
  Count, Tentativa: Integer;
  CDS: TClientDataSet;
begin
  if Assigned(FSplash) then
    FSplash.Passo(20, 'Lendo Servidores de Aplicação');

  // Configurações Padrões
  with Config do
  begin
    RelRemalina := false;
    RelRodapes := True;
    RelZebrado := True;
    RelSalvar := false;
    RelImpressoraEspecial := false;
    RelImpressaoGrafica := false;

    DirExe := ExtractShortPathName(ExtractFilePath(Application.ExeName));
    DirRoot := Copy(DirExe, 1, Length(DirExe) - 1);
    DirRoot := Copy(DirRoot, 1, TFuncoesString.PosDireita('\', DirRoot));

    DirTemp := DirRoot + 'TEMP';
    DirTempCDS := DirRoot + 'TEMP\CDS';
    DirTempDANFe := DirRoot + 'TEMP\NFE\DANF';
    // DirTempRetornoNFe := DirRoot + 'TEMP\NFE\RETORNO';

    AcessoPelaInternet := false;
    MinutosOciosidade := 5;
  end;

  Arq := ExtractFilePath(ParamStr(0)) + '\' + ArquivoServidoresAplicacao;
  CDS := TClientDataSet.Create(nil);
  try
    with CDSServidores do
    begin
      IndexName := '';
      Count := 0;
      while True do
      begin
        Close;
        CreateDataSet;
        LogChanges := false;

        if FileExists(Arq) then
        begin
          // No caso da abertura de diversos módulos simultâneos,
          // por exemplo com terminal server
          Tentativa := 1;
          while (Tentativa <= MaxTentativas) do
            try
              CDS.LoadFromFile(Arq);
              Break;
            except
              on E: Exception do
              begin
                if (Tentativa = MaxTentativas) then
                begin
                  if TCaixasDeDialogo.Confirma(
                    'Foram feitas ' + IntToStr(MaxTentativas) + ' tentativas de leitura do arquivo que contém a lista de servidores de aplicação.' +
                    'No entanto. não foi possível sua abertura, devido o erro:' + #13 + E.Message + #13 +
                    'Gostaria de tentar novamente agora?') then
                    Tentativa := 1
                  else
                    FecharSistema;
                end
                else
                begin
                  Inc(Tentativa);
                  Application.ProcessMessages;
                end;
              end;
            end;

          CDSServidores.DisableConstraints;
          CDSServidores.CopiarRegistros(CDS, True);
          CDSServidores.EnableConstraints;
          Count := RecordCount;

          // Ler Configurações
          with Config do
          begin
            RelRemalina := CDS.GetOptionalParam('Relatorios->Remalina');
            RelRodapes := CDS.GetOptionalParam('Relatorios->Rodapes');
            RelZebrado := CDS.GetOptionalParam('Relatorios->Zebrada');
            RelSalvar := CDS.GetOptionalParam('Relatorios->Salvar');
            RelImpressoraEspecial := CDS.GetOptionalParam('Relatorios->ImpressoraEspecial');
            RelImpressaoGrafica := CDS.GetOptionalParam('Relatorios->ImpressaoGrafica');

            DirTemp := CDS.GetOptionalParam('Diretorios->Temporario');
            DirTempCDS := DirTemp + '\CDS';

            DirTempDANFe := CDS.GetOptionalParam('Diretorios->DANFe');
            if Trim(DirTempDANFe) = '' then
              DirTempDANFe := DirTemp + '\NFE\DANF';

            MinutosOciosidade := CDS.GetOptionalParam('Ociosidade->Minutos');
          end;

        end;
        if (Count = 0) and (TCaixasDeDialogo.Confirma('Servidores de Aplicação não estão configurados, deseja configurá-los agora?')) then
          ChamarConfig(false)
        else
          Break;
      end;
      if (Count = 0) then
        FecharSistema;

      // Adiciona o primeiro servidor como principal
      IndexFieldNames := 'Ordem';
    end;
  finally
    FreeAndNil(CDS);
  end;

  with Config do
  begin
    if not DirectoryExists(DirTemp) then
      ForceDirectories(DirTemp);
    if not DirectoryExists(DirTempCDS) then
      ForceDirectories(DirTempCDS);
    if not DirectoryExists(DirTempDANFe) then
      ForceDirectories(DirTempDANFe);
    // if not DirectoryExists(DirTempRetornoNFe) then
    // ForceDirectories(DirTempRetornoNFe);
  end;
end;

procedure TDMConexao.ChamarConfig(ReLer: Boolean = True);
var
  Xml_Ant, Xml_Dep: WideString;
  ST_Ant, ST_Dep: TStream;
begin
  Application.CreateForm(TFConfigServApl, FConfigServApl); // No Create lê ou cria o CDSServidores
  ST_Ant := TMemoryStream.Create;
  ST_Dep := TMemoryStream.Create;
  try
    CDSServidores.First;
    CDSServidores.SaveToStream(ST_Ant, dfXML); // dfBinary, dfXML, dfXMLUTF8
    CDSServidores.Last;
    if (FConfigServApl.ShowModal = Controls.mrOK) and (ReLer) then
    begin
      CDSServidores.First;
      CDSServidores.SaveToStream(ST_Dep, dfXML);

      ST_Ant.Position := 0;
      ListaDeStrings.LoadFromStream(ST_Ant);
      Xml_Ant := ListaDeStrings.Text;

      ST_Dep.Position := 0;
      ListaDeStrings.LoadFromStream(ST_Dep);
      Xml_Dep := ListaDeStrings.Text;

      if (CompareText(Xml_Ant, Xml_Dep) <> 0){ and Assigned(FPrincipal)} then
        EntrarNoSistema(True);
    end;
  finally
    FConfigServApl.Free;
    FreeAndNil(ST_Ant);
    FreeAndNil(ST_Dep);
  end;
end;

procedure TDMConexao.ExecutaRelatorioGR(CodigoRel: Integer; Filtros: OleVariant; Formato: Integer; ProcessarLocal, EmSegundoPlano: Boolean);
var
  Rel_MS: TMemoryStream;
  Rel_Ole: OleVariant;
  FR: TfrxReport;
  Titulo, ArqTemp: String;
  Parametros: TParametros;
  LocalProcessamento: TLocalProcessamento;
begin
  Rel_MS := TMemoryStream.Create;
  FR := TfrxReport.Create(Self);

  // Até o momento não poderá ser processando no cliente pois há possibilidade de processamento
  // de class de relatório que pode não está disponível no módulo de execução
  ProcessarLocal := false;

  EmSegundoPlano := EmSegundoPlano or (DMConexao.Config.ServidorRelatorio <> '');

  if not EmSegundoPlano then
  begin
    DMConexao.CallBack_AbreTela(Self.ClassName, 'Execução de Relatório');
    EmProcesso := True;
  end;

  try
    Titulo := 'Rel. GR:' + IntToStr(CodigoRel);

    if EmSegundoPlano then
      LocalProcessamento := ClassPaiProcessamento.fLocal_SegundoPlano
    else if ProcessarLocal then
      LocalProcessamento := ClassPaiProcessamento.fLocal_Atual
    else
      LocalProcessamento := ClassPaiProcessamento.fLocal_Servidor;

    if not EmSegundoPlano then
      DMConexao.CallBack_Mensagem(Self.ClassName, 'Gerando Relatório: ' + IntToStr(CodigoRel));

    TGeradorRelatorioEspecifico.GravarParametro(Parametros, 'CodigoRelatorio', CodigoRel);
    TGeradorRelatorioEspecifico.GravarParametro(Parametros, 'Formato', Formato);
    TGeradorRelatorioEspecifico.GravarParametro(Parametros, 'Filtros', Filtros);

    Rel_Ole := TGeradorRelatorioEspecifico.ProcessarClasse(DMConexao, Parametros, Self, False, LocalProcessamento);

    if not EmSegundoPlano then
      DMConexao.CallBack_Mensagem(Self.ClassName, 'Recebendo dados');

    TFuncoesConversao.OleVariantParaStream(Rel_Ole, Rel_MS);

    ArqTemp := TFuncoesSistemaOperacional.DiretorioComBarra(DMConexao.Config.DirTemp) + 'RelatorioGerado-' + IntToStr(CodigoRel) + '.TMP';
    case Formato of
      1: // frArquivoFR:
        begin
          FR.PreviewPages.LoadFromStream(Rel_MS);
          FR.ShowPreparedReport;
        end;
      0: // frArquivoPDF:
        ArqTemp := ChangeFileExt(ArqTemp, '.PDF');
      2: // frArquivoTXT:
        ArqTemp := ChangeFileExt(ArqTemp, '.TXT');
      3: // frArquivoHTML:
        ArqTemp := ChangeFileExt(ArqTemp, '.HTML');
      4: // frArquivoJPEG:
        ArqTemp := ChangeFileExt(ArqTemp, '.JPEG');
      5: // frArquivoCSV:
        ArqTemp := ChangeFileExt(ArqTemp, '.CSV');
    end;

    if (Formato <> 1) then
    begin
      if not EmSegundoPlano then
        DMConexao.CallBack_Mensagem(Self.ClassName, 'Salvando');

      Rel_MS.SaveToFile(ArqTemp);

      // if EmSegundoPlano then
      // begin
      // FPrincipal.Alerta('Disponível: ' + Titulo, ArqTemp, AbrirArquivoDoAlert);
      // end else begin
      if (ShellExecute(0, nil, PWideChar(ArqTemp), nil, nil, SW_SHOWNORMAL) < 32) then
        TCaixasDeDialogo.Informacao('O arquivo está disponível em ' + ArqTemp + ', mas não foi possível abri-lo diretamente');
      // end;
    end;
  finally
    Rel_MS.Free;
    FR.Free;
    if not EmSegundoPlano then
    begin
      DMConexao.CallBack_FechaTela('');
      EmProcesso := false;
    end;
  end;
end;

function TDMConexao.PegaEmpresaDoMovimentoEstoque(iEmp: Integer): Integer;
begin
  Result := ExecuteScalar(
    ' select ' +
    ' CONFIG_SISTEMA_EMPRESA.EMP_MOVESTOQUE_QUAEXTRA_CFSEMP ' +
    ' from CONFIG_SISTEMA_EMPRESA where CONFIG_SISTEMA_EMPRESA.EMPRESA_CFSEMP = ' + IntToStr(iEmp));
  if (Result = 0) then
    Result := iEmp;
end;

function TDMConexao.PegaEmpresasFicticias(iEmp: Integer): string;
var
  CDSTemp: TClientDataSet;
begin
  CDSTemp := TClientDataSet.Create(nil);
  try
    CDSTemp.Data := ExecuteReader(
      'select ' + #13 +
      '  CONFIG_SISTEMA_EMPRESA.EMPRESA_CFSEMP ' + #13 +
      'from CONFIG_SISTEMA_EMPRESA ' + #13 +
      'where CONFIG_SISTEMA_EMPRESA.EMP_MOVESTOQUE_QUAEXTRA_CFSEMP = ' + IntToStr(SecaoAtual.Empresa.Codigo));

    Result := '';
    CDSTemp.First;
    while (not CDSTemp.eof) do
    begin
      Result := Result + CDSTemp.Fields[0].AsString + ',';
      CDSTemp.Next;
    end;

    if (Result <> '') then
      Result := Copy(Result, 1, Length(Result) - 1);
  finally
    FreeAndNil(CDSTemp);
  end;
end;

procedure TDMConexao.TrataOciosidade(var Msg: tagMSG);
var
  X: Integer;
begin
  if ((Msg.Message = WM_MOUSEMOVE) or // qualquer movimento do mouse.
    (Msg.Message = WM_KEYDOWN) or // qualquer tecla pressionada.
    (Msg.Message = WM_LBUTTONDOWN) or // botão esquerdo do mouse
    (Msg.Message = WM_RBUTTONDOWN) or // botão direito do mouse
    (Msg.Message = WM_MOUSEWHEEL) or // Roda do Mouse
    (Msg.Message = WM_SYSKEYDOWN)) and // tecla de sistema
    (not(Assigned(FRegresso))) then
    TempoOcio := GetTickCount
  else if (not EmProcesso) and
    (not Debugando) and
    (not Assigned(FRegresso)) and
    (not(Screen.ActiveForm is TFPainelBordo)) and
    (not(Screen.ActiveForm is TFPainelBordo2)) and
  // (not RelatorioRD.RDAberto) and
  // (not FastAberto) and
  // (not QuickAberto) and
    ((GetTickCount - TempoOcio) > DWORD(Config.MinutosOciosidade * 60 * 1000) - (15 * 1000)) then
  begin
    Application.Restore;
    FRegresso := TFRegresso.Create(Application);
    try
      if (FRegresso.ShowModal = mrOK) then
      begin
        with Screen do
          for X := 0 to ComponentCount - 1 do
            if (Components[X] is TClientDataSet) then
              (Components[X] as TClientDataSet).Close;
        FecharSistema;
      end
      else
        TempoOcio := GetTickCount;
    finally
      FRegresso.Free;
    end;
  end;
end;

procedure TDMConexao.AbrirArquivoDoAlert(Sender: TObject);
var
  ArqTemp: string;
begin
  if not(Sender is TJVDesktopAlert) then
    Exit;

  ArqTemp := TJVDesktopAlert(Sender).MessageText;
  if (ShellExecute(0, nil, PWideChar(ArqTemp), nil, nil, SW_SHOWNORMAL) < 32) then
    TCaixasDeDialogo.Informacao('O arquivo está disponível em ' + ArqTemp + ', mas não foi possível abri-lo diretamente.');
end;

function TDMConexao.GetContadorTransacoesTemporarias: Integer;
begin
  Dec(FContadorTransacoesTemporarias);
  Result := FContadorTransacoesTemporarias;
end;

procedure TDMConexao.ImportarRegistrosParaCDS(BotaoIncluir, BotaoGravar: TNewBtn;
Tabela, NomeDoArquivo: string; CDSDestino: TClientDataSet;
AntesDeGravar: TDataSetNotifyEvent = nil; AntesDeAceitar: TDataSetNotifyEvent = nil);
var
  CDS: TClientDataSet;
begin
  if CDSDestino.State in [dsEdit, dsInsert] then
  begin
    TCaixasDeDialogo.Aviso('Termine a edição do registro atual antes de solicitar importação de registros');
    Exit;
  end;

  with OpenDialogReg do
  begin
    InitialDir := Config.DirTemp;
    Filename := TFuncoesSistemaOperacional.NomeArquivoValido(NomeDoArquivo) + '.CDS';

    if Execute then
    begin
      CDS := TClientDataSet.Create(nil);
      try
        with CDS do
        begin
          LoadFromFile(OpenDialogReg.Filename);

          if (Tabela <> GetOptionalParam('Tabela')) then
          begin
            TCaixasDeDialogo.Aviso('Arquivo incompatível com o cadastro em questão');
            Exit;
          end;

          if Assigned(AntesDeAceitar) then
            AntesDeAceitar(CDS);

          First;
          while not eof do
          begin
            BotaoIncluir.Click;
            CDSDestino.DisableControls;
            try
              CDSDestino.CopiarRegistros(CDS, false, AntesDeGravar);
            finally
              CDSDestino.EnableControls;
            end;
            BotaoGravar.Click;

            Next;
          end;
        end;
      finally
        FreeAndNil(CDS);
      end;
    end;
  end;
end;

procedure TDMConexao.ExportarRegistrosCDS(Tabela, NomeDoArquivo: string; CDSOrigem: TClientDataSet);
begin
  if (not CDSOrigem.Active) or (CDSOrigem.IsEmpty) then
  begin
    TCaixasDeDialogo.Aviso('Tabela deve estar aberta e não deve estar vazia para fazer exportação de registros');
    Exit;
  end;

  if (CDSOrigem.State in [dsEdit, dsInsert]) then
  begin
    TCaixasDeDialogo.Aviso('Salve o registro antes de fazer a exportação do mesmo');
    Exit;
  end;

  with SaveDialogReg do
  begin
    InitialDir := Config.DirTemp;
    Filename := TFuncoesSistemaOperacional.NomeArquivoValido(NomeDoArquivo) + '.CDS';

    if Execute then
    begin
      NomeDoArquivo := Filename;
      case FilterIndex of
        1:
          begin
            NomeDoArquivo := ChangeFileExt(NomeDoArquivo, '.XML');
            CDSOrigem.SaveToFile(NomeDoArquivo, dfXMLUTF8);
          end;
        2:
          begin
            CDSOrigem.SetOptionalParam('Tabela', Tabela);
            NomeDoArquivo := ChangeFileExt(NomeDoArquivo, '.CDS');
            CDSOrigem.SaveToFile(NomeDoArquivo, dfBinary);
          end;
      end;
      TCaixasDeDialogo.Informacao(NomeDoArquivo + ' gerado com sucesso');
    end;
  end;
end;

function TDMConexao.Ler(Campos, Tabela: string; Ordem: Integer; Where: string = ''): OleVariant;
begin
  with ListaDeStrings do
  begin
    Clear;
    Add('select ' + Campos);
    Add(' from ' + Tabela);
    if Length(Trim(Where)) > 0 then
      Add(Where);
    if Ordem >= 0 then
      Add(' order by ' + IntToStr(Ordem));
    Result := DMConexao.ExecuteReader(Text);
  end;
end;

function TDMConexao.Acha(Tabela, Campo: string; Valor: Variant; CampoEmpresa: string = ''; CodigoDaEmpresa: Integer = -1): Boolean;
var
  CDSAcha: TClientDataSet;
  E: Integer;
begin
  if (Tabela = '') or (Campo = '') then
    raise Exception.Create('Função Acha: Nome da tabela e campo deve ser informado.');

  with ListaDeStrings do
  begin
    Clear;
    Add('select ' + Tabela + '.' + Campo);
    Add('from ' + Tabela);
    Add('where');
    if CampoEmpresa <> '' then
    begin
      if CodigoDaEmpresa <> -1 then
        E := CodigoDaEmpresa
      else if (ConstanteSistema.Sistema in [cSistemaDepPessoal, cSistemaContabilidade]) then
        E := SecaoAtual.Empresa.Estabelecimento
      else
        E := SecaoAtual.Empresa.Codigo;
      Add(Tabela + '.' + CampoEmpresa + ' = ' + IntToStr(E));
      Add(' and ');
    end;
    Add(Tabela + '.' + Campo + ' = ' + QuotedStr(Valor));
  end;

  CDSAcha := TClientDataSet.Create(nil);
  try
    CDSAcha.Data := DMConexao.ExecuteReader(ListaDeStrings.Text, 1);
    Result := not CDSAcha.IsEmpty;
  finally
    FreeAndNil(CDSAcha);
  end;
end;

procedure TDMConexao.AnalisaremCubodeDeciso1Click(Sender: TObject);
var
  Grade: TDBGrid;
  CDS: TClientDataSet;
  Descricao: String;
begin
  if not (Screen.ActiveControl is TDBGrid) then
    Exit;

  Grade := (Screen.ActiveControl as TDBGrid);

  if not Assigned(Grade.DataSource) then
    Exit;

  if not (Grade.DataSource.DataSet is TClientDataSet) then
    Exit;

  CDS := (Grade.DataSource.DataSet as TClientDataSet);

  if not CDS.Active then
    Exit;

  Descricao := '';
  if (Grade.Parent is TGroupBox) and
     ((Grade.Parent as TGroupBox).Caption <> '') then
    Descricao := (Grade.Parent as TGroupBox).Caption
  else if (Grade.Parent is TTabSheet) and
          ((Grade.Parent as TTabSheet).TabVisible) and
          ((Grade.Parent as TTabSheet).Caption <> '') then
    Descricao := (Grade.Parent as TTabSheet).Caption
  else if (Grade.Owner is TForm) then
    Descricao := (Grade.Owner as TForm).Caption;

  TFCuboDeDecisao.Abrir(0, Descricao, CDS.Data, False);
end;

procedure TDMConexao.FecharSistema;
begin
  if Assigned(FSplash) then
  begin
    FSplash.Free;
    FSplash := nil;
  end;

  if SQLConexao.Connected then
    SQLConexao.Close;

  Application.Terminate;
  ExitProcess(0);
end;

procedure TDMConexao.SetStatusDeMensagens(const Value: Integer);
begin
  if (FStatusDeMensagens = Value) then
    Exit;

  if (Value < 0) then
  begin
    Windows.Beep(700, 150);
    Windows.Beep(900, 150);
    Windows.Beep(1100, 150);
  end;

  FStatusDeMensagens := Value;
  if (FStatusDeMensagens = 0) then
  begin
    FPrincipal.BotaoMensagem.Images.ActiveIndex := 1;
    FPrincipal.StatusIndicator_Msg.Visible := false;
  end
  else if (FStatusDeMensagens > 0) then
  begin
    FPrincipal.BotaoMensagem.Images.ActiveIndex := 0;
    FPrincipal.StatusIndicator_Msg.Visible := True;
    if Value <= 99 then
      FPrincipal.StatusIndicator_Msg.Caption := IntToStr(Value)
    else
      FPrincipal.StatusIndicator_Msg.Caption := '..';
  end
  else
  begin
    FPrincipal.BotaoMensagem.Images.ActiveIndex := 0;
    FPrincipal.StatusIndicator_Msg.Visible := false;
  end;

  case FStatusDeMensagens of
    cStatusDeMensagens_FechaSistema:
      begin
        FPrincipal.PanelMensagem.Hint := 'Foi solicitado o fechamento do sistema';
        FPrincipal.JvBalloonHint1.ActivateHint(FPrincipal.BotaoMensagem, FPrincipal.PanelMensagem.Hint, 'Mensagem');
        // FPrincipal.StatusIndicator_Msg.Cor := clRed;
        TrataMensagemDeFechamento(True);
      end;
    cStatusDeMensagens_PedidoAutorizacao:
      begin
        FPrincipal.PanelMensagem.Hint := 'Há processos aguardando a sua autorização';
        FPrincipal.JvBalloonHint1.ActivateHint(FPrincipal.BotaoMensagem, 'Novo processo aguardando a sua autorização', 'Mensagem');
        // FPrincipal.StatusIndicator_Msg.Cor := $000080FF;
      end;
    cStatusDeMensagens_Autorizacao:
      begin
        FPrincipal.PanelMensagem.Hint := 'Foi concedida a autorização para execução de algum processo solicitado';
        FPrincipal.JvBalloonHint1.ActivateHint(FPrincipal.BotaoMensagem, FPrincipal.PanelMensagem.Hint, 'Mensagem');
        // FPrincipal.StatusIndicator_Msg.Cor := clLime;
      end;
    cStatusDeMensagens_NegacaoAutorizacao:
      begin
        FPrincipal.PanelMensagem.Hint := 'Foi negada a autorização para execução de algum processo solicitado';
        // FPrincipal.JvBalloonHint1.ActivateHint(FPrincipal.BotaoMensagem, FPrincipal.PanelMensagem.Hint, 'Mensagem');
        // FPrincipal.StatusIndicator_Msg.Cor := clBlack;
      end;
    cStatusDeMensagens_SemMensagem:
      begin
        FPrincipal.PanelMensagem.Hint := 'Não há novas mensagens';
        // FPrincipal.StatusIndicator_Msg.Cor := clBtnFace;
      end;
    cStatusDeMensagens_ExisteMensagem:
      begin
        FPrincipal.PanelMensagem.Hint := Format('Há %d mensagem(ns) não lida(s)', [Value]);
        // FPrincipal.JvBalloonHint1.ActivateHint(FPrincipal.BotaoMensagem, 'Há Nova(s) mensagem(ns)', 'Mensagem');
        // FPrincipal.StatusIndicator_Msg.Cor := clBlue;
      end;
  else
    FPrincipal.PanelMensagem.Hint := '';
  end
end;

procedure TDMConexao.SetStatusSAC(const Value: Integer);
begin
  if FStatusSAC = Value then
    Exit;

  if (Value < 0) then
  begin
    Windows.Beep(700, 150);
    Windows.Beep(900, 150);
    Windows.Beep(1100, 150);
  end;

  FStatusSAC := Value;
  if (FStatusSAC < 0) then
    Exit;

{$IF Defined(QUALIDADE)}
  with FPrincipal do
  begin
    if FStatusSAC > 0 then
    begin
      BotaoSAC.Images.ActiveIndex := 4;
      BotaoSAC.Hint := Format('Há %d atendimento(s) em andamento', [FStatusSAC]);
      StatusIndicator_SAC.Visible := True;
      if FStatusSAC <= 99 then
        StatusIndicator_SAC.Caption := IntToStr(Value)
      else
        StatusIndicator_SAC.Caption := '..';

      // JvBalloonHint1.ActivateHint(BotaoSAC, 'Existem Atendimentos em Andamento', 'SAC');
    end
    else
    begin
      BotaoSAC.Images.ActiveIndex := 3;
      StatusIndicator_SAC.Visible := false;
      BotaoSAC.Hint := 'SAC';
    end;
  end;
{$IFEND}
end;

procedure TDMConexao.TrataHelp(var Msg: tagMSG);
begin
  if ((Screen.ActiveForm <> nil) and (Screen.ActiveForm.ClassName <> 'TMessageForm') and
    (Msg.Message = WM_KEYDOWN) and (Msg.wParam = VK_F1) and
    (GetKeyState(VK_SHIFT) < 0)) then
  begin
    AbrirHelp
  end;
end;

procedure TDMConexao.AbrirHelp;
var
  CDSTemp: TClientDataSet;
  ArquivoHelp, NomeForm, HelpContextoForm, HelpContextoComponente, ComandoHelp: string;
  AbriuHelp: Boolean;
  ST: TMemoryStream;
begin
  if (LendoHelp) then
    Exit;

  LendoHelp := True;
  try
    AbriuHelp := false;
    ArquivoHelp := TFuncoesSistemaOperacional.DiretorioComBarra(Config.DirExe) + ChangeFileExt(Modulos[Sistema, 1], '.CHM');
    NomeForm := Screen.ActiveForm.Name;
    HelpContextoForm := IfThen(Screen.ActiveForm.HelpKeyword = '', '-', Screen.ActiveForm.HelpKeyword);
    HelpContextoComponente := IfThen(Screen.ActiveControl.HelpKeyword = '', '-', Screen.ActiveControl.HelpKeyword);

    ST := TMemoryStream.Create;
    CDSTemp := TClientDataSet.Create(Self);
    try
      TFuncoesSistemaOperacional.LerRecursoDLL('MAPEAMENTOHELP', sNomeDll, ST);
      CDSTemp.LoadFromStream(ST);
      CDSTemp.IndexFieldNames := 'Formulario;HelpKeyword_Form;HelpKeyword_Componente';
      CDSTemp.First;
      if CDSTemp.FindKey([NomeForm, HelpContextoForm, HelpContextoComponente]) then
      begin
        ComandoHelp := ArquivoHelp + '::/' + StringReplace(CDSTemp.FieldByName('Caminho').AsString, '\', '/', [rfReplaceAll]);
        AbriuHelp := HtmlHelp(0, PAnsiChar(AnsiString(ComandoHelp)), HH_DISPLAY_TOPIC, 0) <> 0;
      end;
      CDSTemp.Close;
    finally
      FreeAndNil(ST);
      FreeAndNil(CDSTemp);
    end;

    if (not AbriuHelp) then
      AbriuHelp := HtmlHelp(0, PAnsiChar(AnsiString(ArquivoHelp)), HH_DISPLAY_TOPIC, 0) <> 0;

    if (not AbriuHelp) then
      HtmlHelp(Application.Handle, PAnsiChar(AnsiString(ArquivoHelpGeral)), HH_DISPLAY_TOPIC, 0);
  finally
    LendoHelp := false;
  end;
end;

procedure TDMConexao.TrataMensagemDeFechamento(TemMensagem: Boolean);
var
  CDSTemp: TClientDataSet;
  AutoInc, Mens: string;
  DataHoraEnvio: TDateTime;
begin
  if TemMensagem then
  begin
    CDSTemp := TClientDataSet.Create(Self);
    try
      // 1 - Ler a mensagem de fechamento
      CDSTemp.Data := ExecuteMethods('TSMMensagem.BuscaCabecalhosMensagens', [1, cStatusDeMensagens_FechaSistema, 'S']);
      CDSTemp.Data := ExecuteMethods('TSMMensagem.BuscaDetalhesMensagem', [CDSTemp.FieldByName('AUTOINC_MENSAGEM').AsString]);
      with CDSTemp do
      begin
        AutoInc := FieldByName('AUTOINC_MENSAGEM').AsString;
        DataHoraEnvio := FieldByName('DATAHORAENVIO_MENSAGEM').AsDateTime;
        Mens :=
          ' O usuário ' + FieldByName('REMETENTE').AsString +
          ' solicitou o fechamento do sistema em ' + FieldByName('DATAHORAENVIO_MENSAGEM').AsString + #13 +
          ' Assunto: ' + TFuncoesCriptografia.DeCodifica(FieldByName('ASSUNTO_MENSAGEM').AsString, sChaveCriptografia);
        if (Trim(FieldByName('TEXTO_MENSAGEM').AsString) <> '') then
          Mens := Mens + #13#13 + Trim(TFuncoesCriptografia.DeCodifica(FieldByName('TEXTO_MENSAGEM').AsString, sChaveCriptografia));
        Close;
      end;
    finally
      FreeAndNil(CDSTemp);
    end;

    // 2 - Marcar como lida
    ExecuteMethods('TSMMensagem.MarcaMensagemComoLida', [AutoInc]);
  end
  else
  begin
    DataHoraEnvio := DataHoraServidor;
    Mens := 'Foi solicitado o fechamento do sistema (ShutDown)';
  end;

  // Se o usuário receber a mensagem com mais de 3 minutos de atraso
  // é porque ele estava desconectado. Então não tem valia para ele
  if (DataHoraServidor - DataHoraEnvio) < (1 / 24 / 60) * 3 then
  begin
    Application.ProcessMessages;

    try
      FAguarde.Desativar('');
    except
    end;

    try
      FAguarde2.Desativar;
    except
    end;

    // 3 - Desconectar do servidor
    SQLConexao.Connected := false;

    // 4 - Exibir a mensagem
    TCaixasDeDialogo.Aviso(Mens);

    // 5 - Finalizar o sistema
    FecharSistema;
  end;
end;

procedure TDMConexao.HabilitarOpcaoDeFiltrarGrade(Grade: TDBGrid);
var
  MenuItem: TMenuItem;
begin
  MenuItem := Grade.PopupMenu.Items.Find(FiltrarRegistros1.Caption);

  if Assigned(MenuItem) then
    MenuItem.Visible := True;
end;

procedure TDMConexao.DBGridToClipBoard(DBGrid: TDBGrid; ComCabecalho, ApenasLinhaAtual, ApenasColunaAtual: Boolean);
begin
  if ApenasColunaAtual then
    DBGrid.GridParaClipBoard(ComCabecalho, ApenasLinhaAtual, DBGrid.SelectedField.FieldName)
  else
    DBGrid.GridParaClipBoard(ComCabecalho, ApenasLinhaAtual);

  TCaixasDeDialogo.Informacao('Informações transferidas para a área de transferência. Agora você pode colá-las em outros programas.');
end;

procedure TDMConexao.VerificaTrocaDeSenha;
var
  DtUltModificacao: TDateTime;
begin
  if SecaoAtual.Parametro.Seg_DiasTrocaSenhas <= 0 then
    Exit;

  DtUltModificacao := ExecuteScalar('select ULTIMATROCASENHA_USUARIO from USUARIO where CODIGO_USUARIO = ' + IntToStr(SecaoAtual.Usuario.Codigo));

  if (DtUltModificacao = 0) or
     (DtUltModificacao + SecaoAtual.Parametro.Seg_DiasTrocaSenhas < DataHora) then
  begin
    TCaixasDeDialogo.Informacao('Necessário efetuar a troca de senha.');
    Application.CreateForm(TFTrocaSenha, FTrocaSenha);
    try
      if (FTrocaSenha.ShowModal <> mrOK) then
        FecharSistema;
    finally
      FreeAndNil(FTrocaSenha);
    end;
  end;
end;

{$ENDREGION}

{$REGION 'Metodos compatibilidade externa'}


function TDMConexao.Funcao_AcbrExecuteCommand(s: string): int64;
begin
  Result := ExecuteCommand(s);
end;

function TDMConexao.Funcao_AcbrExecuteReader(s: string): OleVariant;
begin
  Result := ExecuteReader(s);
end;

function TDMConexao.Funcao_AcbrExecuteScalar(s: string): OleVariant;
begin
  Result := ExecuteScalar(s);
end;

function TDMConexao.Funcao_AcbrProximoCodigo(s: string): OleVariant;
begin
  Result := ProximoCodigo(s);
end;

{$ENDREGION}

{$REGION 'Deprecated - retirar futuramente'}

procedure TDMConexao.MostrarLog(TextoDoLog, Titulo: string; MostrarNoRichEdit: Boolean; ExibirLandscape: Boolean);
begin
  ULogSistema.Mostrar_Texto(TextoDoLog, Titulo, MostrarNoRichEdit, ExibirLandscape);
end;

procedure TDMConexao.MostrarLog(DataSet: TClientDataSet; NomeDoCampo: string; Titulo: string = ''; ExibirLandscape: Boolean = false);
begin
  ULogSistema.Mostrar_DataSet(DataSet, NomeDoCampo, Titulo, ExibirLandscape);
end;

procedure TDMConexao.MostrarLog(TextoDoLog: TStrings; MostrarNoRichEdit: Boolean = True; ExibirLandscape: Boolean = false);
begin
  ULogSistema.Mostrar_Texto(TextoDoLog.Text, '', MostrarNoRichEdit, ExibirLandscape);
end;

procedure TDMConexao.MostrarLog(MostrarNoRichEdit: Boolean; NomeDoArquivoDeLog: WideString; ExibirLandscape: Boolean);
begin
  ULogSistema.Mostrar_Arquivo(NomeDoArquivoDeLog, '', MostrarNoRichEdit, ExibirLandscape);
end;

procedure TDMConexao.MostrarLog(TextoDoLog: string; MostrarNoRichEdit: Boolean = True; ExibirLandscape: Boolean = false);
begin
  ULogSistema.Mostrar_Texto(TextoDoLog, '', MostrarNoRichEdit, ExibirLandscape);
end;

{$ENDREGION}

end.
