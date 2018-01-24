unit Constantes;

interface

uses Classes, Windows, SysUtils, Graphics, ClassFuncoesBaseDados;

type
  TProvedorNFSe = Record
    Name: string;
    Index: Integer;
  end;

const
  QtdBDD = 2;
  QtdeModulosExec = 26;

  CasasDecimaisEstoque = 6;

  TituloAplicacaoServidora = 'Aplicação Servidora (Tek-System)';

  Modulos: array [1 .. QtdeModulosExec + 3, 1 .. 5] of string =
  // Nome do executável          Descrição do executável                                  Tek-Prot  Atend.  Prefixo - p/email exportado
    (('FATURAMENTOMC.EXE',       'Faturamento',                                            '1',      '1',   'FATURAMENTO'),
    ('ESTOQUEMC.EXE',            'Controle de Estoque',                                    '2',      '2',   'ESTOQUE'),
    ('FINANCEIROMC.EXE',         'Controle Financeiro',                                    '3',      '6',   'FINANCEIRO'),
    ('CAIXAMC.EXE',              'Livro Caixa e Disponibilidade de Contas',                '4',      '5',   'CAIXA'),
    ('RCPEMC.EXE',               'Registro e Controle de Produção e Estoque',             '21',      '4',   'RCPE'),
    ('TELEMARKETINGMC.EXE',      'Telemarketing',                                          '5',     '19',   'TELEMARKETING'),
    ('DEPPESSOALMC.EXE',         'Departamento Pessoal',                                   '6',     '12',   'DEPTO PESSOAL'),
    ('GESTAOMC.EXE',             'Gestão',                                                 '7',      '9',   'GESTÃO'),
    ('PRODUCAOMC.EXE',           'Planejamento e Controle de Produção',                    '8',      '7',   'PRODUÇÃO'),
    ('GERARICMSMC.EXE',          'Gerador de Registro de ICMS',                           '14',      '8',   'GERADOR RICMS'),
    ('TERCEIRIZACAOMC.EXE',      'Terceirização',                                         '-1',     '17',   'TERCEIRIZAÇÃO'),
    ('DUPLICATASMC.EXE',         'Controle de Duplicatas',                                '-1',     '-1',   'DUPLICATAS'),
    ('TRANSPORTEMC.EXE',         'Controle de Transporte',                                 '9',     '15',   'TRANSPORTE'),
    ('MAQUINARIOMC.EXE',         'Controle de Maquinário',                                '10',     '10',   'MAQUINÁRIO'),
    ('RECEPCAOMC.EXE',           'Recepção de Pedidos do Site',                           '-1',     '-1',   'RECEPÇÃO'),
    ('PDVECF.EXE',               'Ponto de venda emissor de cupom fiscal',                '-1',     '-1',   'PDV ECF'),
    ('CUSTOMC.EXE',              'Apuração e Controle de Custos',                         '11',     '23',   'CUSTOS'),
    ('CONTABILIDADEMC.EXE',      'Contabilidade',                                         '12',     '18',   'CONTABILIDADE'),
    ('LIVROSFISCAISMC.EXE',      'Livros Fiscais',                                        '13',     '21',   'LIVRO FISCAL'),
    ('GERADORRELATORIOMC.EXE',   'BI - Inteligência de Negócios',                         '15',     '24',   'BI'),
    ('VENDASMOBILE.EXE',         'Mobile: Vendas',                                        '-1',     '-1',   'VENDAS MOBILE'),
    ('GESTAODAQUALIDADEMC.EXE',  'Gestão da Qualidade',                                   '19',     '37',   'GESTAO DA QUALIDADE'),
    ('INTEGRACAOMC.EXE',         'Integração de Sistemas',                                '20',     '38',   'INTEGRAÇÃO'),
    ('GESTAOMOBILE.EXE',         'Mobile: Gestão',                                        '-1',     '-1',   'GESTÃO MOBILE'),
    ('PRODUCAOMOBILE.EXE',       'Mobile: Produção',                                      '-1',     '-1',   'PRODUÇÃO MOBILE'),
    ('ESOCIALMC.EXE',            'e-Social',                                              '70',     '39',   'E-SOCIAL'),
    // Modulos apenas para controle interno, não deve permitir configuração de acesso ao usuário
    ('AGENDADORRELATORIOMC.EXE', 'Serviço Agendador de Relatório',                        '-1',     '-1',   'AGENDADOR'),
    ('COLETORSERVICO.EXE',       'Coletor de Dados',                                      '-1',     '35',   'COLETOR'),
    ('EXECMETODOINTERPERP.EXE',  'Executor de Métodos Interpretados',                     '-1',     '-1',   'EXEC METODO')
    );

  ChaveGuid = 'F59A321C-CB6A-4132-85F9-D1CC9AE10838';

  // Cores
  clAmareloPedido = $00BBFFFF;
  clVlrEntrada = clNavy;
  clVlrSaida = clMaroon;
  clVlrNegativo = clRed;
  clVlrPositivo = clNavy;
  clDestaqueGrade = clBlue;
  clSomenteLeitura = $00E1E6E8; // $00D9DEE1;
  clAzulClaro = $00F2E0D9;
  clVerdeEscuro = $0084A242;
  clVerdeMedio = $00E7F3E7;
  clVerdeClaro = $00FFFFE6;
  clGradeCorFundo = clWhite; // $00F7FBF7
  clGradeCorZebrado = $00E7F3E7;
  clGradeSomenteLeitura = $00E7EBED;
  clGradeSaida = $00BFDFFF; // Alaranjado Claro
  clGradeSaidaElaboracao = $0098FF75; // Verde Claro
  clDestaqueGradeSaida = $0095CAFF; // Alaranjado um pouco mais forte

  // retirado da unit ucad lf nota fiscal venda
  clCorICMS = $00D2D2A4; // um pouco mais claro
  clCorIPI = $00FFBBDD;
  clCorPIS = $00D8FFB0;
  clCorCOFINS = $00FFE8AA;
  clCorST = $00A6D2FF;
  clCorIndicador = $00ECE0D7;

  // Paleta de Cores de acordo com a Situação da NFS-e
  CorAguardaRetorno = $00BFEAE7; // Situação = cSitNFSeNaoRecebido
  CorNaoProcessado  = $00BBF4F0; // Situação = cSitNFSeNaoProcessado
  CorErroNFe        = $00AAC6FF; // Situação = cSitNFSeProcComErro
  CorTransmitidaNFe = $00BDE2BA; // Situação = cSitNFSeProcComSucesso
  CorCancelado      = $00F2E0D9; // Cancelado

  // Usado para limitar digitos nos campos numericos
  MaxDigitos = 14;

  Usuario_ManipulacaoEtiqueta_Estocar = '001';
  Usuario_ManipulacaoEtiqueta_Cancelar = '002';
  Usuario_ManipulacaoEtiqueta_Carregar = '003';
  Usuario_LiberarPedidoVenda = '004';
  Usuario_ExcluirApuracaoCustoAdotada = '005';
  Usuario_AutorizaExtrapolacaoDeProrrogacao = '007';

  Usuario_SiteBloquearEdicaoPrevisaoDeFaturamentoDoPedido = '012';

  Usuario_FazFechamentoCargas = '017';
  Usuario_CancelaFechamentoCargas = '018';
  Usuario_AlterarComissaoDoPedidoBloqueado = '019';
  Usuario_LiberarPedidoCompra = '020';
  Usuario_FazLimpeza = '021';
  Usuario_AlteraItemImportadoPedidoCompra = '022';
  Usuario_ExcluiItemImportadoPedidoCompra = '023';
  Usuario_IncluirCompraSemPedidoDeCompraPorCFOP = '024';
  Usuario_GravaFormacaoDePrecoNoPedidoDeVenda = '025';
  Usuario_VisualizaFormacaoDePrecoNoPedidoDeVenda = '026';
  Usuario_LiberarBloquearCarga = '027';
  Usuario_AlterarInventarioEscriturado = '028';
  Usuario_CancelaNFDuplicataComRecebimento = '029';
  Usuario_AlteraPrecoParteCustomizavelNoPedido = '030';
  Usuario_AlteraRegistroQuilometragemOrigemDiferenteManual = '031';

  Usuario_CargaCancelaConferecia_Simples = '040';
  Usuario_CargaCancelaConferecia_Completa = '041';
  Usuario_CargaAlteraPrazosDocumentos = '042';
  Usuario_BloqEmiteEtiquetaManual = '044';
  Usuario_LiberarVlrMinimoDuplicata = '045';
  Usuario_LiberarAlteracaoContabilizado = '046';
  Usuario_VisualizaSolicitacoesDeConsumo = '047';
  Usuario_CancelaContingenciaNaoAutorizada = '048';
  Usuario_CancelaDocumentoLocal = '049';
  Usuario_ConcedeAbatimentoEmValorNominalDeDuplicata = '050';
  Usuario_AlteraSequenciaDeFaturamento = '051';
  Usuario_BloqAssistenciaNaoRecolhida = '052';
  Usuario_PodeReprocessarDocContingencia = '053';
  Usuario_GravaNotaFiscalFinanceiroInconsistente = '054';
  Usuario_LancaImpostoEntradaNotaFiscal = '055';
  Usuario_CancelaFechamentoCargaFaturada = '056';
  Usuario_AlteraMovimentoEstornoEstoque = '057';

  Usuario_ManipulacaoEtiqueta_Transferencia = '058';
  Usuario_ManipulacaoEtiqueta_Confererencia = '059';
  Usuario_ManipulacaoEtiqueta_Recall = '060';

  Usuario_ConfirmaInutilizacaoProtocolo = '061';
  Usuario_ConfirmaCancelamentoProtocolo = '062';

  Usuario_PermiteExecutarRotinaEspecialExclusaoFinanceiro = '063';
  Usuario_PessoaOutrosSemDocumentos = '064';
  Usuario_ManipulacaoDeCadastroDeOpcoes = '065';

  Usuario_HabilitaBloqueiaModeloRelatorioSite = '066';

  // Tipo do Modelo de Nota Fiscal
  {Favor olhar a classe ClassModeloNotaFiscal
   cTipoModeloNotaFiscal      = 1; alterado para ClassModeloNotaFiscal.cTipoNFMOD_NotaConvencional
   cTipoModeloConhecimento    = 2; alterado para ClassModeloNotaFiscal.cTipoNFMOD_ConhecimentoTransporteConvencional
   cTipoModeloNFe             = 3; alterado para ClassModeloNotaFiscal.cTipoNFMOD_NFe

   cFormaEmissaoNF_Indefinido = 0; alterado para ClassModeloNotaFiscal.cFormaEmissaoModelo_Indefinido
   cFormaEmissaoNF_NFe_Normal = 1; alterado para ClassModeloNotaFiscal.cFormaEmissaoModelo_NFe_Normal
   cFormaEmissaoNF_NFe_SCAN   = 3; alterado para ClassModeloNotaFiscal.cFormaEmissaoModelo_NFe_SCAN
  }

  // Status NF-e
  nfeAutorizada = '100'; // Autorizado o uso da NF-e
  nfeCancelada = '101'; // Cancelamento de NF-e homologado
  nfeInutilizada = '102'; // Inutilização de número homologado
  nfeLoteRecebido = '103'; // Lote recebido com sucesso
  nfeLoteProcessado = '104'; // Lote processado
  nfeLoteEmProcesso = '105'; // Lote em processamento
  nfeLoteNaoLocalizado = '106'; // Lote não localizado
  nfeServicoEmOperacao = '107'; // Serviço em Operação
  nfeParalizadoMomento = '108'; // Serviço Paralisado Momentaneamente (curto prazo)
  nfeParalizadoSemPrev = '109'; // Serviço Paralisado sem Previsão
  nfeUsoDenegado = '110'; // Uso Denegado
  nfeConsultaUmaOcorr = '111'; // Consulta cadastro com uma ocorrência
  nfeConsultaDivOcorr = '112'; // Consulta cadastro com mais de uma ocorrência
  nfeAutorizadaForaPrazo = '150'; // Autorizado o uso da NF-e

  eveLoteProcessado = '128'; // Lote de Envento processado
  eveVinculado = '135'; // Evento registrado e vinculado a NFe
  eveNaoVinculado = '136'; // Evento registrado e não vinculado a NFe

  cteAutorizado = '100'; // Autorizado o uso do CT-e
  cteCancelado = '101'; // Cancelamento de CT-e homologado
  cteInutilizado = '102'; // Inutilização de número homologado
  cteLoteRecebido = '103'; // Lote recebido com sucesso
  cteLoteProcessado = '104'; // Lote processado
  cteLoteEmProcessamento = '105'; // Lote em processamento
  cteLoteNaoLocalizado = '106'; // Lote não localizado
  cteServicoEmOperacao = '107'; // Serviço em Operação
  cteParalizadoMomento = '108'; // Serviço Paralisado Momentaneamente (curto prazo)
  cteParalizadoSemPrev = '109'; // Serviço Paralisado sem Previsão
  cteUsoDenegado = '110'; // Uso Denegado
  cteConsultaUmaOcorr = '111'; // Consulta cadastro com uma ocorrência
  cteConsultaDivOcorr = '112'; // Consulta cadastro com mais de uma ocorrência
  cteServicoSVCEmOper = '113'; // Serviço SVC em operação. Desativação prevista para a UF em dd/mm/aa, às hh:mm horas
  cteServicoSVCDesab = '114'; // SVC-[SP/RS] desabilitada pela SEFAZ de Origem
  cteAnulado = '128'; // CT-e anulado pelo emissor
  cteSubstituido = '129'; // CT-e substituído pelo emissor
  cteTemCartadeCorrecao = '130'; // Apresentada Carta de Correção Eletrônica – CC-e
  cteDesclassificado = '131'; // CT-e desclassificado pelo Fisco

  // Compartilhamento XML via E-mail
  emailEnvioSeExistir = 0; // Envia o e-mail com XML quando existir
  emailEnvioObrigatorio = 1; // Envia obrigatoriamente o XML por e-mail (Se não existir e-mail, adverte usuário e aborta;
  emailNaoEnvia = 2; // Nunca envia o e-mail;

  // Opções Especiais definidas no cadastro do usuário
  TamanhoDescricaoOpcaoEspecial = 70;

  OpcoesEspeciais: array [1 .. 65, 1 .. 3] of string =
    ( // Cod.                                                     Descrição                                            Libera/Bloqueia/Inativo
    ('000', 'INDEFINIDO', 'L'),
    (Usuario_LiberarPedidoVenda, 'PEDIDO DE VENDA - LIBERAR', 'L'),
    (Usuario_ExcluirApuracaoCustoAdotada, 'CUSTO - EXCLUIR APURAÇÃO ADOTADA', 'L'),

    // Financeiro
    (Usuario_AutorizaExtrapolacaoDeProrrogacao, 'DUPLICATA - AUTORIZAR EXTRAPOLAÇÃO DE PRORROGAÇÕES', 'L'),
    (Usuario_ConcedeAbatimentoEmValorNominalDeDuplicata, 'DUPLICATA - CONCEDER ABATIMENTO EM VALOR NOMINAL', 'L'),

    (Usuario_AlterarComissaoDoPedidoBloqueado, 'PEDIDO - ALTERAR COMISSÃO DE PEDIDO BLOQUEADO', 'L'),

    // Serviço 60337
    ('008' {Usuario_SiteBloquearEdicaoObservacaoCliente}, 'SITE - BLOQUEAR EDIÇÃO OBSERVAÇÃO DE CLIENTE', 'I'),
    ('009' {Usuario_SiteBloquearEdicaoLimiteDeCreditoCliente}, 'SITE - BLOQUEAR EDIÇÃO LIMITE DE CRÉDITO DO CLIENTE', 'I'),
    ('010' {Usuario_SiteBloquearEdicaoComissoesSupervisorNoCliente}, 'SITE - BLOQUEAR EDIÇÃO COMISSÕES DO SUPERVISOR NO CLIENTE', 'I'),
    ('011' {Usuario_SiteBloquearEdicaoContatosPeriodicosDoCliente}, 'SITE - BLOQUEAR EDIÇÃO CONTATOS PERIÓDICOS DO CLIENTE', 'I'),

    (Usuario_SiteBloquearEdicaoPrevisaoDeFaturamentoDoPedido, 'PEDIDO - BLOQUEAR MANIPULAÇÃO DA PREVISÃO DE FATURAMENTO', 'B'), // => Este critério, inicialmente criado para o site, também será usado no faturamento

    // Serviço 60337
    ('013' {Usuario_SiteBloquearEdicaoComissoesDoPedido}, 'SITE - BLOQUEAR EDIÇÃO COMISSÕES DO PEDIDO', 'I'),
    ('014' {Usuario_SiteBloquearEdicaoComissoesDoConsultorNoCliente}, 'SITE - BLOQUEAR EDIÇÃO COMISSÕES DO CONSULTOR NO CLIENTE', 'I'),
    ('015' {Usuario_SiteBloquearEdicaoGrupoCadastroPessoas}, 'SITE - BLOQUEAR EDIÇÃO DE GRUPO DE CADASTRO DE PESSOAS', 'I'),
    ('016' {Usuario_SiteBloquearCadastroClientesFisicas}, 'SITE - BLOQUEAR CADASTRO DE CLIENTES FÍSICAS', 'I'),

    (Usuario_FazFechamentoCargas, 'CARGA - REALIZAR FECHAMENTO', 'L'),
    (Usuario_CancelaFechamentoCargas, 'CARGA - CANCELAR FECHAMENTO', 'L'),
    (Usuario_LiberarPedidoCompra, 'PEDIDO DE COMPRA - LIBERAR', 'L'),
    (Usuario_AlteraItemImportadoPedidoCompra, 'NOTA FISCAL DE ENTRADA - ALTERAR ITEM IMPORTADO DE PED.COMPRA', 'L'),
    (Usuario_ExcluiItemImportadoPedidoCompra, 'NOTA FISCAL DE ENTRADA - EXCLUIR ITEM IMPORTADO DE PED.COMPRA', 'L'),
    (Usuario_IncluirCompraSemPedidoDeCompraPorCFOP, 'NOTA FISCAL DE ENTRADA - PERMITIR INCLUIR SEM IMPORTAR DE PEDIDO DE COMPRA', 'L'),
    (Usuario_FazLimpeza, 'ROTINA ESPECIAL - EXECUTAR ROTINA PARA EXCLUSÃO DE REGISTROS', 'L'),
    (Usuario_AlteraSequenciaDeFaturamento, 'ALTERAR SEQUÊNCIA DE FATURAMENTO NA CONFIRMAÇÃO DE ENTREGA', 'L'),
    // Custos
    (Usuario_GravaFormacaoDePrecoNoPedidoDeVenda, 'MANIPULAR FORMAÇÃO DE PREÇO (NO PEDIDO E ISOLADA)', 'L'),
    (Usuario_VisualizaFormacaoDePrecoNoPedidoDeVenda, 'PEDIDO DE VENDA - VISUALIZAR FORMAÇÃO DE PREÇO', 'L'),

    (Usuario_LiberarBloquearCarga, 'LIBERAR/BLOQUEAR CARGA', 'L'),
    (Usuario_ManipulacaoEtiqueta_Estocar, 'MANIPULAÇÃO DE ETIQUETAS - ESTOCAGEM', 'L'),
    (Usuario_ManipulacaoEtiqueta_Cancelar, 'MANIPULAÇÃO DE ETIQUETAS - CANCELAMENTO', 'L'),
    (Usuario_ManipulacaoEtiqueta_Carregar, 'MANIPULAÇÃO DE ETIQUETAS - CARREGAMENTO', 'L'),

    (Usuario_AlterarInventarioEscriturado, 'ALTERAR ESCRITURAÇÃO DE INVENTÁRIO', 'L'),
    (Usuario_CancelaNFDuplicataComRecebimento, 'NOTA FISCAL - CANCELA TENDO DUPLICATA COM RECEBIMENTO', 'L'),
    (Usuario_AlteraPrecoParteCustomizavelNoPedido, 'PEDIDO DE VENDA - ALTERAR PREÇO DE PARTES CUSTOMIZÁVEIS', 'L'),

    // Transporte
    (Usuario_AlteraRegistroQuilometragemOrigemDiferenteManual, 'ALTERAR REGISTRO QUILOMETRAGEM C/ORIGEM DIFERENTE DE MANUAL', 'L'),

    // Foi inativados, favor não reaproveitar os códigos
    ('032' {Usuario_ColetaEmbalagem}, 'COLETOR - EMBALAGEM', 'I'),
    ('033' {Usuario_ColetaInvetario}, 'COLETOR - INVENTÁRIO', 'I'),
    ('034' {Usuario_ColetaRequisicaoDeTransferencia}, 'COLETOR - REQUISIÇÃO DE TRANSFERÊNCIA', 'I'),
    ('035' {Usuario_ColetaConferenciaDeTransferencia}, 'COLETOR - CONFERÊNCIA DE TRANSFERÊNCIA', 'I'),
    ('036' {Usuario_ColetaRealoacaoDeItens}, 'COLETOR - REALOCAÇÃO DE ITENS', 'I'),
    ('037' {Usuario_ColetaRealoacaoDeEnderecos}, 'COLETOR - REALOCAÇÃO DE ENDEREÇOS', 'I'),
    ('038' {Usuario_ColetaSeparacaoDeCarga}, 'COLETOR - SEPARAÇÃO DE CARGA', 'I'),
    ('039' {Usuario_ColetaCarregamento}, 'COLETOR - CARREGAMENTO', 'I'),

    (Usuario_CargaCancelaConferecia_Simples, 'CARGA - CANCELA CONFERÊNCIA SIMPLES', 'L'),
    (Usuario_CargaCancelaConferecia_Completa, 'CARGA - CANCELA CONFERÊNCIA COMPLETA', 'L'),
    (Usuario_CargaAlteraPrazosDocumentos, 'CARGA - ALTERA PRAZOS DOS DOCUMENTOS', 'L'),
    (Usuario_BloqEmiteEtiquetaManual, 'ETIQUETA - BLOQUEAR EMISSÃO MANUAL (AVULSA)', 'B'),
    (Usuario_LiberarVlrMinimoDuplicata, 'DUPLICATA - LIBERA BLOQUEIO DE VALOR MÍNIMO', 'L'),
    (Usuario_LiberarAlteracaoContabilizado, 'LIBERAR ALTERAÇÃO DE REGISTRO CONTABILIZADO', 'L'),
    (Usuario_VisualizaSolicitacoesDeConsumo, 'VISUALIZA TODAS SOLICITAÇÕES DE CONSUMO', 'L'),
    (Usuario_CancelaContingenciaNaoAutorizada, 'MDFe - CANCELA EM CONTINGÊNCIA NÃO AUTORIZADO', 'L'),
    (Usuario_CancelaDocumentoLocal, 'NFE/CTE - CANCELA LOCAL (INDISPONIBILIDADE NA SEF)', 'L'),
    (Usuario_BloqAssistenciaNaoRecolhida, 'ASSIST. - BLOQUEIA INCLUSÃO SE CLIENTE POSSUIR ASSIST. NÃO RECOLHIDA', 'B'),
    (Usuario_PodeReprocessarDocContingencia, 'NFE/CTE - REPROCESSA DOCUMENTOS NÃO AUTORIZADOS', 'L'),
    (Usuario_GravaNotaFiscalFinanceiroInconsistente, 'NOTA FISCAL DE ENTRADA - GRAVA COM FINANCEIRO INCONSISTENTE', 'L'),
    (Usuario_LancaImpostoEntradaNotaFiscal, 'NOTA FISCAL DE ENTRADA - ALTERA VALOR DO IMPOSTO COM REGRA DE LANC.', 'L'),
    (Usuario_CancelaFechamentoCargaFaturada, 'CARGA FATURADA - CANCELAR FECHAMENTO', 'L'),
    (Usuario_AlteraMovimentoEstornoEstoque, 'MOVIMENTO DE ESTOQUE - PERMITE ALTERA QUANTIDADE', 'L'),

    (Usuario_ManipulacaoEtiqueta_Transferencia, 'MANIPULAÇÃO DE ETIQUETAS - TRANSFERENCIA', 'L'),
    (Usuario_ManipulacaoEtiqueta_Confererencia, 'MANIPULAÇÃO DE ETIQUETAS - CONFERÊNCIA', 'L'),
    (Usuario_ManipulacaoEtiqueta_Recall, 'MANIPULAÇÃO DE ETIQUETAS - RECALL', 'L'),

    (Usuario_ConfirmaInutilizacaoProtocolo, 'CONFIRMA INUTILIZAÇÃO VIA PROTOCOLO', 'L'),
    (Usuario_ConfirmaCancelamentoProtocolo, 'CONFIRMA CANCELAMENTO VIA PROTOCOLO', 'L'),

    (Usuario_PermiteExecutarRotinaEspecialExclusaoFinanceiro, 'ROTINA ESPECIAL - PERMITE EXECUTAR EXCLUSÃO DE FINANCEIRO', 'L'),

    (Usuario_PessoaOutrosSemDocumentos, 'PESSOA - OUTROS, PERMITE CADASTRO SEM VALIDAR DOCUMENTO', 'L'),

    (Usuario_ManipulacaoDeCadastroDeOpcoes, 'DEPARTAMENTO PESSOAL - MANIPULAÇÃO DE CADASTRO DE OPÇÕES', 'L'),

    (Usuario_HabilitaBloqueiaModeloRelatorioSite, 'PERMITIR HABILITAR/BLOQUEAR MODELOS DE RELATÓRIOS PARA O SITE', 'L')
    );

  cTagAbortaConfig = 99;
  cTagConfigBloqCampo = 99;

  cTagDesconsideraFiltroConsulta = 97;

  cTamanhoNossoNumeroSIGCB = 17;
  cTamanhoAbreviaturaVariacao = 15;
  cTamanhoMaximoArquivo = 20 * 1024 * 1024;

  cOrigForPrecoAvulsa = 0;
  cOrigForPrecoApuracaoCusto = 1;
  cOrigForPrecoPedidoVenda = 2;

  sTelefoneTekSystem = '(32)3539-5700';
  sEMailSuporteTekSystem = 'suporte@teksystem.com.br';

  sRazaoSocialTekSystem = 'Tek-System Informática Ltda. ME';
  sCNPJTekSystem = '86.682.093/0001-05';
  sNomeContatoTekSystem_eSocial = 'José Ricardo Varella';
  sEmailContatoTekSystem_eSocial = 'ricardo@teksystem.com.br';

  UmaHora = 1 / 24; // Hora é fração do dia
  MiliSegundosNaHora = MinsPerHour * SecsPerMin * MSecsPerSec;

  Sim = '''S''';
  Nao = '''N''';

  Excecoes_Form = '-FPRINCIPAL-FRPROGRESSFORM-DIALOGFORM-TPARENTFORM-FCOMPOSICAOCONJUNTO-FTROCAEMPRESA-FDETALHAMENTO-FTEKMENU_POPUP-';
  Excecoes_Class = '-TPARENTFORM-TJVFORMDESKTOPALERT-TFINDICADOR-'; // Antonio adicionou, form do FastReport. Não rastrei outras units do fastreport para saber se ele tem form acoplado, a destruição dele é feito pelo fasrreport mesmo, ver unit frxClass por favor.

  // Conciliação Serasa
  IncRealizada = 1;
  IncRejeitada = 2;
  ExcRealizada = 3;
  ExcRejeitada = 4;
  OutrosProces = 9;
  DescrIncRealizada = 'Inclusão Confirmada Serasa';
  DescrIncRejeitada = 'Inclusão Rejeitada Serasa';
  DescrExcRealizada = 'Exclusão Confirmada Serasa';
  DescrExcRejeitada = 'Exclusão Rejeitadas Serasa';
  DescrOutrosProces = 'Outro Procedimento Serasa';

  // Diferentemente do Ambiente Nacional e demais documentos eletrônicos, a NFS-e possui um conjunto enumerado que define os motivos de cancelamento:
  // Obs: Os códigos 3 (Erro de assinatura) e 5 (Erro de processamento) são de uso restrito da Administração Tributária Municipal
  MotivoCancelamentoNFSe: array [1 .. 5, 1 .. 2] of string =
    //Descrição do Motivo       Código do Motivo
    (('1–Erro na emissão',      '1'),
     ('2–Serviço não prestado', '2'),
     ('3–Erro de assinatura',   '3'),
     ('4–Duplicidade da nota',  '4'),
     ('5–Erro de processamento','5')
    );

ResourceString

  CaracterMarca = 'ü';

  // CustomConstraint
  sCC_ValueIsNotNull = 'VALUE IS NOT NULL';
  sCC_ValueIsNotNullAndNotVazio = 'VALUE IS NOT NULL AND VALUE <> ''''';
  sCC_ValueIsNotNullAndNotZero = 'VALUE IS NOT NULL AND VALUE <> 0';
  sCC_ValueMasculinoFeminino = 'VALUE = ''M'' OR VALUE = ''F''';
  sCC_ValueSimNao = 'VALUE = ''S'' OR VALUE = ''N''';
  sCC_ValueAliquota = 'VALUE >= 0 AND VALUE <=100';
  sCC_ValueMaiorIgualZero = 'VALUE >= 0';
  sCC_ValueMaiorQueZero = 'VALUE > 0';
  sCC_CodigosGPS = '(VALUE = 0) OR ((VALUE >= 1000) AND (VALUE <= 9999))';
  sCC_NaturezaJuridica = '(VALUE = 0) OR ((VALUE >= 1000) AND (VALUE <= 9999))';
  sCC_CodigosRecFGTS = '(VALUE = 0) OR ((VALUE >= 100)  AND (VALUE <= 999))';
  sCC_VinculoEmpregaticio = '(VALUE = 0) OR ((VALUE >= 1)  AND (VALUE <= 99))';
  sCC_Categoria = '(VALUE = 0) OR ((VALUE >= 1)  AND (VALUE <= 99))';
  sCC_DP_ResutadoEvento = 'VALUE >= 0 AND VALUE <=2';

  sCEM_OCampoDeveSerPreenchido = 'O Campo %s deve ser preenchido.';

  sMascaraTelefone = '!(99)cc999-9999;1; ';
  sMascaraCep = '99999-999;1; ';
  sMascaraCnpj = '99.999.999/9999-99;1; ';
  sMascaraCei = '99.999.99999/99;1; ';
  sMascaraCpf = '999.999.999-99;1; ';
  sMascaraData = '99/99/9999;1; ';
  sMascaraDataHora = '99/99/9999 99:99;1; ';
  sMascaraDataHoraMinSeg = '99/99/9999 99:99:99;1; ';
  sMascaraHora = '!99:99;1; ';
  sMascaraHoraCentesimal = '!990:99;1; ';
  sMascaraHoraMinSeg = '!99:99:99;1; ';
  sMascaraHoraMinSeg2 = '999:99:99;1; ';
  sMascaraHoraMinSegMS = '!99:99:99,999;1; ';
  sMascaraPlaca = '>cca-9999;0;_';
  sMascaraCodigoSAT = '999.999-9;1; ';

  sDisplayFormatData = 'dd/mm/yyyy';
  sDisplayFormatDataHora = 'dd/mm/yyyy hh:nn';
  sDisplayFormatDataHora_HoraMinSeg = 'dd/mm/yyyy hh:nn:ss';
  sDisplayFormatHora = 'hh:nn';
  sDisplayFormatHora_HoraMinSeg = 'hh:nn:ss';
  sDisplayFormatHora_HoraMinSegMS = 'hh:nn:ss,zzz';

  // Digitacao Invalida
  sDataInvalida = 'Data inválida, verifique.';
  sDataInicialMaiorQueFinal = 'Data inicial maior que a data final, verifique.';
  sCNPJInvalido = 'Atenção C.N.P.J. inválido, verifique.';
  sCPFInvalido = 'Atenção C.P.F. inválido, verifique.';
  sInscricaoInvalida = 'Atenção Inscrição Estadual inválida para esse estado, verifique.';

  // Sucesso
  sSucessoEmProcesso = 'Processo executado com sucesso.';
  sProcessoTerminado = 'Processo terminado.';

  // Processos
  sMontandoRelatorio = 'Montando Relatório na Memória';
  sPreparandoSQL = 'Preparando Pesquisa ';
  sExecutandoSQL = 'Fazendo Pesquisa ';
  sAplicando = 'Procedimentos no Servidor de Aplicação';
  sPreprandoPacotes = 'Preparando Pacotes para Envio';
  sProcessoRequerAutorizacao = #13 + 'Esse processo requer autorização. Solicitar agora?';
  sProcessoInicializacao = 'Servidor em processo de inicialização, tente novamente em alguns instantes.';
  sProcessoExclusivoServ = 'Servidor executando procedimento(s), tente novamente em alguns instantes.';

  // Cancelamentos
  sProcessoCancelado = 'Processo encerrado antes do término, por solicitação do usuário.'; // 'Processo cancelado pelo usuário.';
  sRelatorioCancelado = ' RELATÓRIO CANCELADO PELO USUÁRIO - TOTAIS PODEM NAO CONFERIR ';

  // Perguntas
  sDesejaExcluir = 'Deseja excluir o registro da tabela %S?';
  sConfirmaSaida = 'Confirma a saída do sistema "%s"?';
  sConfirmaGravacao = 'Confirma gravação?';
  sCancelaImpressao = 'Deseja cancelar a geração do relatório?';
  sCancelaProcesso = 'Deseja cancelar o processo em andamento?';
  sSenhaFiscal = '                                * * *    A T E N Ç Ã O    * * *' + #13 +
    '               Você solicitou a execução da reorganização dos arquivos.' + #13 +
    '                             Essa operação não tem retorno.' + #13 +
    '                 Certifique-se de que o backup esteja ok ou cancele.' + #13 +
    'Será feito um registro da execução dessa ação, que é de sua responsabilidade.' + #13 +
    '                                       Deseja continuar?';

  // Erros
  sErroNaRede = 'Ocorreu uma perda de conexão com o servidor de aplicação.' + #13 +
    'Certifique-se de que a rede está operando corretamente e tente entrar no sistema novamente.' + #13#13;
  sOcorreuErro = 'Ocorreu o seguinte erro: '#13;
  ErroServidorApl = '>> ERRO DO SERVIDOR DE APLICAÇÃO <<'#13#13;
  MensagemServidorApl = '>> MENSAGEM DO SERVIDOR DE APLICAÇÃO <<'#13#13;
  MensagemPersonalizadaServidorApl = '>> MENSAGEM PERSONALIZADA DO SERVIDOR DE APLICAÇÃO <<'#13#13;

  // Seguranca nos Dados
  sRegistroCadastrado = 'Registro já cadastrado por outro usuário, verifique.';
  sRegBloq = 'Este registro da tabela %S já está em uso por outro usuário da rede ou por outro processo. ';
  sNaoAutorizado = 'Você não possui autorização para executar esse processo';
  sValorItemZerado = 'Existem itens com valor total igual a zero, favor verificar' + #13 + 'O processamento será interrompido';
  sValorDocumentoZerado = 'Valor do documento com valor igual a zero, favor verificar' + #13 + 'O processamento será interrompido';
  sRegVinculadoRecibo = 'Este registro não pode ser %s. Está vinculado a um recibo.';
  sRegPlanoSaudeInvalido = 'Código da operadora de plano de saúde inválido.';
  sRegFuncPlanoSaude = 'Registro do funcionário inválido.';
  sRegistroSistema = 'Este cadastro é específico do Sistema e não pode ser excluído ou alterado';
  sRegistroBloqueado = 'Esse registro da tabela %S já está sendo editado pelo usuário %S' + ' desde %S ' + #13 + 'Chave para desbloqueio: %S';
  sImpedirCorrecaoApont = 'Registro em edição.' + #13 + ' Grave ou cancele antes de prosseguir para Correção de Apontamentos.';

  // Arquivos
  sDLLInscricao = 'DllInscE32.Dll';

  sNomeDLL = 'ClienteTek.DLL';
  ArquivoIniClient = 'ClienteTek.ini';
  ArquivoConexoesDBX = 'ConexoesDBX.ini';
  ArquivoIniIndicesGrade = 'IndicesGrade.ini';
  ArquivoServidoresAplicacao = 'ServApl.cds';
  ArquivoHelpGeral = 'HelpMC.chm';

  // Não Encontrado ou Não Definido
  sSemRegistroParaExcluir = 'Não há registro para ser excluído.';
  sSemRegistroParaProcessar = 'Não há registro para ser processado.';
  sNaoSelecionado = 'Não foi selecionado nenhum item para %S verifique.';
  sNaoEncontrado = 'Registro não encontrado, verifique.';
  sNaoEncontradoComTabela = 'Registro %s não encontrado, verifique.';

  // Outras
  sEntreEmContato = 'Se este erro persistir, entre em contato com o suporte técnico da Tek-System:' + #13 +
    'Telefone: ' + sTelefoneTekSystem + '        E-mail: ' + sEMailSuporteTekSystem;
  sMensagemSistemaSomenteLeitura = 'O sistema está operando com a licença somente leitura. ' +
    'Apenas consultas podem ser realizadas. ' +
    'Entre em contato com a Tek-System, através do telefone ' + sTelefoneTekSystem +
    ' ou e-mail ' + sEMailSuporteTekSystem + ', ' +
    'caso queira voltar a trabalhar integralmente com o sistema.';
  sProgramaNaoLiberado = 'Programa não liberado para usuário.';
  sNumeroMaximoTabela = 'O número máximo de tabelas a imprimir é 5.'#13'Desmarque outra e depois escolha essa.';
  sEscrituracaoApenasLivroAnexo = 'Escrituração permitida apenas no módulo: Livro Fiscal'; // ou Anexo VII; // Anexo nao existe, apesar de ter o teste do programa origem
  sNFSeNaoExisteBDProvedor = 'REGISTRO NÃO EXISTE NA BASE DA PREFEITURA';

  sCondicaodeUsoCartaCorrecao = 'A Carta de Correção é disciplinada pelo § 1º-A do art. 7º' +
    ' do Convênio S/N, de 15 de dezembro de 1970 e pode ser' +
    ' utilizada para regularização de erro ocorrido na emissão de' +
    ' documento fiscal, desde que o erro não esteja relacionado' +
    ' com: ' + #13 +
    '    I - as variáveis que determinam o valor do imposto' +
    ' tais como: base de cálculo, alíquota, diferença de preço,' +
    ' quantidade, valor da operação ou da prestação; ' + #13 +
    '    II - a correção de dados cadastrais que implique mudança do' +
    ' remetente ou do destinatário; ' + #13 +
    '    III - a data de emissão ou de saída.';

  sChaveCriptografia = 'SISTEMA DE GESTAO INDUSTRIAL/COMERCIAL MULTICAMADAS  - TEK-SYSTEM INFORMATICA - UBA.MG';

  // Prefixos e Sufixos
  SufixoFrete = '-FR';
  PrefixoOrdemPagto = 'OP-';
  PrefixoGrade = 'GRA_';
  PrefixoPrecoBruto = 'PRB_';
  PrefixoPrecoLiquido = 'PRL_';
  PrefixoPrecoMoeda = 'PMO_';
  PrefixoChaveGrade = 'AUT_';

  // Restrições de Cadastros
  sRestricaoInclusao = 'Você não tem permissão para INSERIR registros nesse cadastro.';
  sRestricaoAlteracao = 'Você não tem permissão para ALTERAR registros nesse cadastro.';
  sRestricaoExclusao = 'Você não tem permissão para EXCLUIR registros desse cadastro.';

  sCadastro_PosicionarNoCodigo = 'PosicionarNoCodigo';
  sCadastro_BloquearManipulacao = 'BloquearTrocaCodigo';

  // Relatorio
  sDiretorioRelatoriosPDF = 'RELATORIOS_PDF';
  sNaoPodeAlterarRelatorio = 'Modelo de relatório não pode ser alterado' + #13 + 'Verifique a autoria do modelo ou se é um modelo de sistema.';

  // Producao
  sNaoConfiguracaoPreparacao = 'Sistema não está configurado para utilizar tabela de preparação.';
  sDiaNaoUtil = 'A data informada não é um dia útil.';

  // Geram funcionamentos especiais
  sOcultarDoMonitorDeSQL = '/* Retire esse comentário para aparecer no monitor de SQL */' + #13;
  sIgnorarConteudo = '<IGNORAR_CONTEUDO>';
  sIgnorarRegistro = '<IGNORAR_REGISTRO>';

  // Fórmula Padrão do Custo
  sFormulaCustoPadrao = '(VALOR_MERCADORIA + ( VALOR_IPI + VALOR_FRETE + VALOR_SEGURO + VALOR_OUTRASDESP) - (VALOR_ICMS + VALOR_PIS + VALOR_COFINS + VALOR_DESCONTO))';

  // Site IBGE para consulta do código do município
  sSiteIBGE = 'http://www.ibge.gov.br/home/geociencias/areaterritorial/area.shtm';

  cFCadPessoa = 'FCadPessoa';

  sPlataformaWin = 'Win32';
  sPlataformaWeb = 'Web';
  sPlataformaApp = 'App';

var
{$IF DEFINED(SERVIDOR)}
  ServidorProxy: String = '';
  PortaProxy: Integer = 0;
  UsuarioProxy: String = '';
  SenhaProxy: String = '';
{$ELSE}
  TempoOcio: DWORD;
  ListaDeStrings: TStrings;
  EmProcesso: Boolean;
  Debugando: Boolean;
  DelphiRodando: Boolean;
{$IFEND}

  TekAgendadorPorta: Integer = 5792;
  InteracaoRequerida: Boolean;
  DriverBDDAtual: Integer = 0;
  ParticularidadesBDD: TParticularidadesBDD;
{$IF (not DEFINED(SERVIDOR)) AND (not DEFINED(WS)) AND (not DEFINED(COLETOR)) AND (not DEFINED(MT))}
  DMConexaoExistente: TDataModule;
{$IFEND}
  sPlataformaAtual: string = {$IF DEFINED(MOBILE)} sPlataformaApp {$ELSEIF DEFINED(WS)} sPlataformaWeb {$ELSE} sPlataformaWin {$IFEND};

implementation

initialization

{$IF not DEFINED(SERVIDOR)}
{$WARN SYMBOL_PLATFORM OFF}
  Debugando := DebugHook <> 0;
{$WARN SYMBOL_PLATFORM ON}
  DelphiRodando := FindWindow('TAppBuilder', nil) > 0;

  ListaDeStrings := TStringList.Create;
  EmProcesso := False;
  InteracaoRequerida := False;
{$IFEND}

finalization

{$IF not DEFINED(SERVIDOR)}
  ListaDeStrings.Free;
{$IFEND}

end.
