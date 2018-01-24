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

  TituloAplicacaoServidora = 'Aplica��o Servidora (Tek-System)';

  Modulos: array [1 .. QtdeModulosExec + 3, 1 .. 5] of string =
  // Nome do execut�vel          Descri��o do execut�vel                                  Tek-Prot  Atend.  Prefixo - p/email exportado
    (('FATURAMENTOMC.EXE',       'Faturamento',                                            '1',      '1',   'FATURAMENTO'),
    ('ESTOQUEMC.EXE',            'Controle de Estoque',                                    '2',      '2',   'ESTOQUE'),
    ('FINANCEIROMC.EXE',         'Controle Financeiro',                                    '3',      '6',   'FINANCEIRO'),
    ('CAIXAMC.EXE',              'Livro Caixa e Disponibilidade de Contas',                '4',      '5',   'CAIXA'),
    ('RCPEMC.EXE',               'Registro e Controle de Produ��o e Estoque',             '21',      '4',   'RCPE'),
    ('TELEMARKETINGMC.EXE',      'Telemarketing',                                          '5',     '19',   'TELEMARKETING'),
    ('DEPPESSOALMC.EXE',         'Departamento Pessoal',                                   '6',     '12',   'DEPTO PESSOAL'),
    ('GESTAOMC.EXE',             'Gest�o',                                                 '7',      '9',   'GEST�O'),
    ('PRODUCAOMC.EXE',           'Planejamento e Controle de Produ��o',                    '8',      '7',   'PRODU��O'),
    ('GERARICMSMC.EXE',          'Gerador de Registro de ICMS',                           '14',      '8',   'GERADOR RICMS'),
    ('TERCEIRIZACAOMC.EXE',      'Terceiriza��o',                                         '-1',     '17',   'TERCEIRIZA��O'),
    ('DUPLICATASMC.EXE',         'Controle de Duplicatas',                                '-1',     '-1',   'DUPLICATAS'),
    ('TRANSPORTEMC.EXE',         'Controle de Transporte',                                 '9',     '15',   'TRANSPORTE'),
    ('MAQUINARIOMC.EXE',         'Controle de Maquin�rio',                                '10',     '10',   'MAQUIN�RIO'),
    ('RECEPCAOMC.EXE',           'Recep��o de Pedidos do Site',                           '-1',     '-1',   'RECEP��O'),
    ('PDVECF.EXE',               'Ponto de venda emissor de cupom fiscal',                '-1',     '-1',   'PDV ECF'),
    ('CUSTOMC.EXE',              'Apura��o e Controle de Custos',                         '11',     '23',   'CUSTOS'),
    ('CONTABILIDADEMC.EXE',      'Contabilidade',                                         '12',     '18',   'CONTABILIDADE'),
    ('LIVROSFISCAISMC.EXE',      'Livros Fiscais',                                        '13',     '21',   'LIVRO FISCAL'),
    ('GERADORRELATORIOMC.EXE',   'BI - Intelig�ncia de Neg�cios',                         '15',     '24',   'BI'),
    ('VENDASMOBILE.EXE',         'Mobile: Vendas',                                        '-1',     '-1',   'VENDAS MOBILE'),
    ('GESTAODAQUALIDADEMC.EXE',  'Gest�o da Qualidade',                                   '19',     '37',   'GESTAO DA QUALIDADE'),
    ('INTEGRACAOMC.EXE',         'Integra��o de Sistemas',                                '20',     '38',   'INTEGRA��O'),
    ('GESTAOMOBILE.EXE',         'Mobile: Gest�o',                                        '-1',     '-1',   'GEST�O MOBILE'),
    ('PRODUCAOMOBILE.EXE',       'Mobile: Produ��o',                                      '-1',     '-1',   'PRODU��O MOBILE'),
    ('ESOCIALMC.EXE',            'e-Social',                                              '70',     '39',   'E-SOCIAL'),
    // Modulos apenas para controle interno, n�o deve permitir configura��o de acesso ao usu�rio
    ('AGENDADORRELATORIOMC.EXE', 'Servi�o Agendador de Relat�rio',                        '-1',     '-1',   'AGENDADOR'),
    ('COLETORSERVICO.EXE',       'Coletor de Dados',                                      '-1',     '35',   'COLETOR'),
    ('EXECMETODOINTERPERP.EXE',  'Executor de M�todos Interpretados',                     '-1',     '-1',   'EXEC METODO')
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

  // Paleta de Cores de acordo com a Situa��o da NFS-e
  CorAguardaRetorno = $00BFEAE7; // Situa��o = cSitNFSeNaoRecebido
  CorNaoProcessado  = $00BBF4F0; // Situa��o = cSitNFSeNaoProcessado
  CorErroNFe        = $00AAC6FF; // Situa��o = cSitNFSeProcComErro
  CorTransmitidaNFe = $00BDE2BA; // Situa��o = cSitNFSeProcComSucesso
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
  nfeInutilizada = '102'; // Inutiliza��o de n�mero homologado
  nfeLoteRecebido = '103'; // Lote recebido com sucesso
  nfeLoteProcessado = '104'; // Lote processado
  nfeLoteEmProcesso = '105'; // Lote em processamento
  nfeLoteNaoLocalizado = '106'; // Lote n�o localizado
  nfeServicoEmOperacao = '107'; // Servi�o em Opera��o
  nfeParalizadoMomento = '108'; // Servi�o Paralisado Momentaneamente (curto prazo)
  nfeParalizadoSemPrev = '109'; // Servi�o Paralisado sem Previs�o
  nfeUsoDenegado = '110'; // Uso Denegado
  nfeConsultaUmaOcorr = '111'; // Consulta cadastro com uma ocorr�ncia
  nfeConsultaDivOcorr = '112'; // Consulta cadastro com mais de uma ocorr�ncia
  nfeAutorizadaForaPrazo = '150'; // Autorizado o uso da NF-e

  eveLoteProcessado = '128'; // Lote de Envento processado
  eveVinculado = '135'; // Evento registrado e vinculado a NFe
  eveNaoVinculado = '136'; // Evento registrado e n�o vinculado a NFe

  cteAutorizado = '100'; // Autorizado o uso do CT-e
  cteCancelado = '101'; // Cancelamento de CT-e homologado
  cteInutilizado = '102'; // Inutiliza��o de n�mero homologado
  cteLoteRecebido = '103'; // Lote recebido com sucesso
  cteLoteProcessado = '104'; // Lote processado
  cteLoteEmProcessamento = '105'; // Lote em processamento
  cteLoteNaoLocalizado = '106'; // Lote n�o localizado
  cteServicoEmOperacao = '107'; // Servi�o em Opera��o
  cteParalizadoMomento = '108'; // Servi�o Paralisado Momentaneamente (curto prazo)
  cteParalizadoSemPrev = '109'; // Servi�o Paralisado sem Previs�o
  cteUsoDenegado = '110'; // Uso Denegado
  cteConsultaUmaOcorr = '111'; // Consulta cadastro com uma ocorr�ncia
  cteConsultaDivOcorr = '112'; // Consulta cadastro com mais de uma ocorr�ncia
  cteServicoSVCEmOper = '113'; // Servi�o SVC em opera��o. Desativa��o prevista para a UF em dd/mm/aa, �s hh:mm horas
  cteServicoSVCDesab = '114'; // SVC-[SP/RS] desabilitada pela SEFAZ de Origem
  cteAnulado = '128'; // CT-e anulado pelo emissor
  cteSubstituido = '129'; // CT-e substitu�do pelo emissor
  cteTemCartadeCorrecao = '130'; // Apresentada Carta de Corre��o Eletr�nica � CC-e
  cteDesclassificado = '131'; // CT-e desclassificado pelo Fisco

  // Compartilhamento XML via E-mail
  emailEnvioSeExistir = 0; // Envia o e-mail com XML quando existir
  emailEnvioObrigatorio = 1; // Envia obrigatoriamente o XML por e-mail (Se n�o existir e-mail, adverte usu�rio e aborta;
  emailNaoEnvia = 2; // Nunca envia o e-mail;

  // Op��es Especiais definidas no cadastro do usu�rio
  TamanhoDescricaoOpcaoEspecial = 70;

  OpcoesEspeciais: array [1 .. 65, 1 .. 3] of string =
    ( // Cod.                                                     Descri��o                                            Libera/Bloqueia/Inativo
    ('000', 'INDEFINIDO', 'L'),
    (Usuario_LiberarPedidoVenda, 'PEDIDO DE VENDA - LIBERAR', 'L'),
    (Usuario_ExcluirApuracaoCustoAdotada, 'CUSTO - EXCLUIR APURA��O ADOTADA', 'L'),

    // Financeiro
    (Usuario_AutorizaExtrapolacaoDeProrrogacao, 'DUPLICATA - AUTORIZAR EXTRAPOLA��O DE PRORROGA��ES', 'L'),
    (Usuario_ConcedeAbatimentoEmValorNominalDeDuplicata, 'DUPLICATA - CONCEDER ABATIMENTO EM VALOR NOMINAL', 'L'),

    (Usuario_AlterarComissaoDoPedidoBloqueado, 'PEDIDO - ALTERAR COMISS�O DE PEDIDO BLOQUEADO', 'L'),

    // Servi�o 60337
    ('008' {Usuario_SiteBloquearEdicaoObservacaoCliente}, 'SITE - BLOQUEAR EDI��O OBSERVA��O DE CLIENTE', 'I'),
    ('009' {Usuario_SiteBloquearEdicaoLimiteDeCreditoCliente}, 'SITE - BLOQUEAR EDI��O LIMITE DE CR�DITO DO CLIENTE', 'I'),
    ('010' {Usuario_SiteBloquearEdicaoComissoesSupervisorNoCliente}, 'SITE - BLOQUEAR EDI��O COMISS�ES DO SUPERVISOR NO CLIENTE', 'I'),
    ('011' {Usuario_SiteBloquearEdicaoContatosPeriodicosDoCliente}, 'SITE - BLOQUEAR EDI��O CONTATOS PERI�DICOS DO CLIENTE', 'I'),

    (Usuario_SiteBloquearEdicaoPrevisaoDeFaturamentoDoPedido, 'PEDIDO - BLOQUEAR MANIPULA��O DA PREVIS�O DE FATURAMENTO', 'B'), // => Este crit�rio, inicialmente criado para o site, tamb�m ser� usado no faturamento

    // Servi�o 60337
    ('013' {Usuario_SiteBloquearEdicaoComissoesDoPedido}, 'SITE - BLOQUEAR EDI��O COMISS�ES DO PEDIDO', 'I'),
    ('014' {Usuario_SiteBloquearEdicaoComissoesDoConsultorNoCliente}, 'SITE - BLOQUEAR EDI��O COMISS�ES DO CONSULTOR NO CLIENTE', 'I'),
    ('015' {Usuario_SiteBloquearEdicaoGrupoCadastroPessoas}, 'SITE - BLOQUEAR EDI��O DE GRUPO DE CADASTRO DE PESSOAS', 'I'),
    ('016' {Usuario_SiteBloquearCadastroClientesFisicas}, 'SITE - BLOQUEAR CADASTRO DE CLIENTES F�SICAS', 'I'),

    (Usuario_FazFechamentoCargas, 'CARGA - REALIZAR FECHAMENTO', 'L'),
    (Usuario_CancelaFechamentoCargas, 'CARGA - CANCELAR FECHAMENTO', 'L'),
    (Usuario_LiberarPedidoCompra, 'PEDIDO DE COMPRA - LIBERAR', 'L'),
    (Usuario_AlteraItemImportadoPedidoCompra, 'NOTA FISCAL DE ENTRADA - ALTERAR ITEM IMPORTADO DE PED.COMPRA', 'L'),
    (Usuario_ExcluiItemImportadoPedidoCompra, 'NOTA FISCAL DE ENTRADA - EXCLUIR ITEM IMPORTADO DE PED.COMPRA', 'L'),
    (Usuario_IncluirCompraSemPedidoDeCompraPorCFOP, 'NOTA FISCAL DE ENTRADA - PERMITIR INCLUIR SEM IMPORTAR DE PEDIDO DE COMPRA', 'L'),
    (Usuario_FazLimpeza, 'ROTINA ESPECIAL - EXECUTAR ROTINA PARA EXCLUS�O DE REGISTROS', 'L'),
    (Usuario_AlteraSequenciaDeFaturamento, 'ALTERAR SEQU�NCIA DE FATURAMENTO NA CONFIRMA��O DE ENTREGA', 'L'),
    // Custos
    (Usuario_GravaFormacaoDePrecoNoPedidoDeVenda, 'MANIPULAR FORMA��O DE PRE�O (NO PEDIDO E ISOLADA)', 'L'),
    (Usuario_VisualizaFormacaoDePrecoNoPedidoDeVenda, 'PEDIDO DE VENDA - VISUALIZAR FORMA��O DE PRE�O', 'L'),

    (Usuario_LiberarBloquearCarga, 'LIBERAR/BLOQUEAR CARGA', 'L'),
    (Usuario_ManipulacaoEtiqueta_Estocar, 'MANIPULA��O DE ETIQUETAS - ESTOCAGEM', 'L'),
    (Usuario_ManipulacaoEtiqueta_Cancelar, 'MANIPULA��O DE ETIQUETAS - CANCELAMENTO', 'L'),
    (Usuario_ManipulacaoEtiqueta_Carregar, 'MANIPULA��O DE ETIQUETAS - CARREGAMENTO', 'L'),

    (Usuario_AlterarInventarioEscriturado, 'ALTERAR ESCRITURA��O DE INVENT�RIO', 'L'),
    (Usuario_CancelaNFDuplicataComRecebimento, 'NOTA FISCAL - CANCELA TENDO DUPLICATA COM RECEBIMENTO', 'L'),
    (Usuario_AlteraPrecoParteCustomizavelNoPedido, 'PEDIDO DE VENDA - ALTERAR PRE�O DE PARTES CUSTOMIZ�VEIS', 'L'),

    // Transporte
    (Usuario_AlteraRegistroQuilometragemOrigemDiferenteManual, 'ALTERAR REGISTRO QUILOMETRAGEM C/ORIGEM DIFERENTE DE MANUAL', 'L'),

    // Foi inativados, favor n�o reaproveitar os c�digos
    ('032' {Usuario_ColetaEmbalagem}, 'COLETOR - EMBALAGEM', 'I'),
    ('033' {Usuario_ColetaInvetario}, 'COLETOR - INVENT�RIO', 'I'),
    ('034' {Usuario_ColetaRequisicaoDeTransferencia}, 'COLETOR - REQUISI��O DE TRANSFER�NCIA', 'I'),
    ('035' {Usuario_ColetaConferenciaDeTransferencia}, 'COLETOR - CONFER�NCIA DE TRANSFER�NCIA', 'I'),
    ('036' {Usuario_ColetaRealoacaoDeItens}, 'COLETOR - REALOCA��O DE ITENS', 'I'),
    ('037' {Usuario_ColetaRealoacaoDeEnderecos}, 'COLETOR - REALOCA��O DE ENDERE�OS', 'I'),
    ('038' {Usuario_ColetaSeparacaoDeCarga}, 'COLETOR - SEPARA��O DE CARGA', 'I'),
    ('039' {Usuario_ColetaCarregamento}, 'COLETOR - CARREGAMENTO', 'I'),

    (Usuario_CargaCancelaConferecia_Simples, 'CARGA - CANCELA CONFER�NCIA SIMPLES', 'L'),
    (Usuario_CargaCancelaConferecia_Completa, 'CARGA - CANCELA CONFER�NCIA COMPLETA', 'L'),
    (Usuario_CargaAlteraPrazosDocumentos, 'CARGA - ALTERA PRAZOS DOS DOCUMENTOS', 'L'),
    (Usuario_BloqEmiteEtiquetaManual, 'ETIQUETA - BLOQUEAR EMISS�O MANUAL (AVULSA)', 'B'),
    (Usuario_LiberarVlrMinimoDuplicata, 'DUPLICATA - LIBERA BLOQUEIO DE VALOR M�NIMO', 'L'),
    (Usuario_LiberarAlteracaoContabilizado, 'LIBERAR ALTERA��O DE REGISTRO CONTABILIZADO', 'L'),
    (Usuario_VisualizaSolicitacoesDeConsumo, 'VISUALIZA TODAS SOLICITA��ES DE CONSUMO', 'L'),
    (Usuario_CancelaContingenciaNaoAutorizada, 'MDFe - CANCELA EM CONTING�NCIA N�O AUTORIZADO', 'L'),
    (Usuario_CancelaDocumentoLocal, 'NFE/CTE - CANCELA LOCAL (INDISPONIBILIDADE NA SEF)', 'L'),
    (Usuario_BloqAssistenciaNaoRecolhida, 'ASSIST. - BLOQUEIA INCLUS�O SE CLIENTE POSSUIR ASSIST. N�O RECOLHIDA', 'B'),
    (Usuario_PodeReprocessarDocContingencia, 'NFE/CTE - REPROCESSA DOCUMENTOS N�O AUTORIZADOS', 'L'),
    (Usuario_GravaNotaFiscalFinanceiroInconsistente, 'NOTA FISCAL DE ENTRADA - GRAVA COM FINANCEIRO INCONSISTENTE', 'L'),
    (Usuario_LancaImpostoEntradaNotaFiscal, 'NOTA FISCAL DE ENTRADA - ALTERA VALOR DO IMPOSTO COM REGRA DE LANC.', 'L'),
    (Usuario_CancelaFechamentoCargaFaturada, 'CARGA FATURADA - CANCELAR FECHAMENTO', 'L'),
    (Usuario_AlteraMovimentoEstornoEstoque, 'MOVIMENTO DE ESTOQUE - PERMITE ALTERA QUANTIDADE', 'L'),

    (Usuario_ManipulacaoEtiqueta_Transferencia, 'MANIPULA��O DE ETIQUETAS - TRANSFERENCIA', 'L'),
    (Usuario_ManipulacaoEtiqueta_Confererencia, 'MANIPULA��O DE ETIQUETAS - CONFER�NCIA', 'L'),
    (Usuario_ManipulacaoEtiqueta_Recall, 'MANIPULA��O DE ETIQUETAS - RECALL', 'L'),

    (Usuario_ConfirmaInutilizacaoProtocolo, 'CONFIRMA INUTILIZA��O VIA PROTOCOLO', 'L'),
    (Usuario_ConfirmaCancelamentoProtocolo, 'CONFIRMA CANCELAMENTO VIA PROTOCOLO', 'L'),

    (Usuario_PermiteExecutarRotinaEspecialExclusaoFinanceiro, 'ROTINA ESPECIAL - PERMITE EXECUTAR EXCLUS�O DE FINANCEIRO', 'L'),

    (Usuario_PessoaOutrosSemDocumentos, 'PESSOA - OUTROS, PERMITE CADASTRO SEM VALIDAR DOCUMENTO', 'L'),

    (Usuario_ManipulacaoDeCadastroDeOpcoes, 'DEPARTAMENTO PESSOAL - MANIPULA��O DE CADASTRO DE OP��ES', 'L'),

    (Usuario_HabilitaBloqueiaModeloRelatorioSite, 'PERMITIR HABILITAR/BLOQUEAR MODELOS DE RELAT�RIOS PARA O SITE', 'L')
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

  sRazaoSocialTekSystem = 'Tek-System Inform�tica Ltda. ME';
  sCNPJTekSystem = '86.682.093/0001-05';
  sNomeContatoTekSystem_eSocial = 'Jos� Ricardo Varella';
  sEmailContatoTekSystem_eSocial = 'ricardo@teksystem.com.br';

  UmaHora = 1 / 24; // Hora � fra��o do dia
  MiliSegundosNaHora = MinsPerHour * SecsPerMin * MSecsPerSec;

  Sim = '''S''';
  Nao = '''N''';

  Excecoes_Form = '-FPRINCIPAL-FRPROGRESSFORM-DIALOGFORM-TPARENTFORM-FCOMPOSICAOCONJUNTO-FTROCAEMPRESA-FDETALHAMENTO-FTEKMENU_POPUP-';
  Excecoes_Class = '-TPARENTFORM-TJVFORMDESKTOPALERT-TFINDICADOR-'; // Antonio adicionou, form do FastReport. N�o rastrei outras units do fastreport para saber se ele tem form acoplado, a destrui��o dele � feito pelo fasrreport mesmo, ver unit frxClass por favor.

  // Concilia��o Serasa
  IncRealizada = 1;
  IncRejeitada = 2;
  ExcRealizada = 3;
  ExcRejeitada = 4;
  OutrosProces = 9;
  DescrIncRealizada = 'Inclus�o Confirmada Serasa';
  DescrIncRejeitada = 'Inclus�o Rejeitada Serasa';
  DescrExcRealizada = 'Exclus�o Confirmada Serasa';
  DescrExcRejeitada = 'Exclus�o Rejeitadas Serasa';
  DescrOutrosProces = 'Outro Procedimento Serasa';

  // Diferentemente do Ambiente Nacional e demais documentos eletr�nicos, a NFS-e possui um conjunto enumerado que define os motivos de cancelamento:
  // Obs: Os c�digos 3 (Erro de assinatura) e 5 (Erro de processamento) s�o de uso restrito da Administra��o Tribut�ria Municipal
  MotivoCancelamentoNFSe: array [1 .. 5, 1 .. 2] of string =
    //Descri��o do Motivo       C�digo do Motivo
    (('1�Erro na emiss�o',      '1'),
     ('2�Servi�o n�o prestado', '2'),
     ('3�Erro de assinatura',   '3'),
     ('4�Duplicidade da nota',  '4'),
     ('5�Erro de processamento','5')
    );

ResourceString

  CaracterMarca = '�';

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
  sDataInvalida = 'Data inv�lida, verifique.';
  sDataInicialMaiorQueFinal = 'Data inicial maior que a data final, verifique.';
  sCNPJInvalido = 'Aten��o C.N.P.J. inv�lido, verifique.';
  sCPFInvalido = 'Aten��o C.P.F. inv�lido, verifique.';
  sInscricaoInvalida = 'Aten��o Inscri��o Estadual inv�lida para esse estado, verifique.';

  // Sucesso
  sSucessoEmProcesso = 'Processo executado com sucesso.';
  sProcessoTerminado = 'Processo terminado.';

  // Processos
  sMontandoRelatorio = 'Montando Relat�rio na Mem�ria';
  sPreparandoSQL = 'Preparando Pesquisa ';
  sExecutandoSQL = 'Fazendo Pesquisa ';
  sAplicando = 'Procedimentos no Servidor de Aplica��o';
  sPreprandoPacotes = 'Preparando Pacotes para Envio';
  sProcessoRequerAutorizacao = #13 + 'Esse processo requer autoriza��o. Solicitar agora?';
  sProcessoInicializacao = 'Servidor em processo de inicializa��o, tente novamente em alguns instantes.';
  sProcessoExclusivoServ = 'Servidor executando procedimento(s), tente novamente em alguns instantes.';

  // Cancelamentos
  sProcessoCancelado = 'Processo encerrado antes do t�rmino, por solicita��o do usu�rio.'; // 'Processo cancelado pelo usu�rio.';
  sRelatorioCancelado = ' RELAT�RIO CANCELADO PELO USU�RIO - TOTAIS PODEM NAO CONFERIR ';

  // Perguntas
  sDesejaExcluir = 'Deseja excluir o registro da tabela %S?';
  sConfirmaSaida = 'Confirma a sa�da do sistema "%s"?';
  sConfirmaGravacao = 'Confirma grava��o?';
  sCancelaImpressao = 'Deseja cancelar a gera��o do relat�rio?';
  sCancelaProcesso = 'Deseja cancelar o processo em andamento?';
  sSenhaFiscal = '                                * * *    A T E N � � O    * * *' + #13 +
    '               Voc� solicitou a execu��o da reorganiza��o dos arquivos.' + #13 +
    '                             Essa opera��o n�o tem retorno.' + #13 +
    '                 Certifique-se de que o backup esteja ok ou cancele.' + #13 +
    'Ser� feito um registro da execu��o dessa a��o, que � de sua responsabilidade.' + #13 +
    '                                       Deseja continuar?';

  // Erros
  sErroNaRede = 'Ocorreu uma perda de conex�o com o servidor de aplica��o.' + #13 +
    'Certifique-se de que a rede est� operando corretamente e tente entrar no sistema novamente.' + #13#13;
  sOcorreuErro = 'Ocorreu o seguinte erro: '#13;
  ErroServidorApl = '>> ERRO DO SERVIDOR DE APLICA��O <<'#13#13;
  MensagemServidorApl = '>> MENSAGEM DO SERVIDOR DE APLICA��O <<'#13#13;
  MensagemPersonalizadaServidorApl = '>> MENSAGEM PERSONALIZADA DO SERVIDOR DE APLICA��O <<'#13#13;

  // Seguranca nos Dados
  sRegistroCadastrado = 'Registro j� cadastrado por outro usu�rio, verifique.';
  sRegBloq = 'Este registro da tabela %S j� est� em uso por outro usu�rio da rede ou por outro processo. ';
  sNaoAutorizado = 'Voc� n�o possui autoriza��o para executar esse processo';
  sValorItemZerado = 'Existem itens com valor total igual a zero, favor verificar' + #13 + 'O processamento ser� interrompido';
  sValorDocumentoZerado = 'Valor do documento com valor igual a zero, favor verificar' + #13 + 'O processamento ser� interrompido';
  sRegVinculadoRecibo = 'Este registro n�o pode ser %s. Est� vinculado a um recibo.';
  sRegPlanoSaudeInvalido = 'C�digo da operadora de plano de sa�de inv�lido.';
  sRegFuncPlanoSaude = 'Registro do funcion�rio inv�lido.';
  sRegistroSistema = 'Este cadastro � espec�fico do Sistema e n�o pode ser exclu�do ou alterado';
  sRegistroBloqueado = 'Esse registro da tabela %S j� est� sendo editado pelo usu�rio %S' + ' desde %S ' + #13 + 'Chave para desbloqueio: %S';
  sImpedirCorrecaoApont = 'Registro em edi��o.' + #13 + ' Grave ou cancele antes de prosseguir para Corre��o de Apontamentos.';

  // Arquivos
  sDLLInscricao = 'DllInscE32.Dll';

  sNomeDLL = 'ClienteTek.DLL';
  ArquivoIniClient = 'ClienteTek.ini';
  ArquivoConexoesDBX = 'ConexoesDBX.ini';
  ArquivoIniIndicesGrade = 'IndicesGrade.ini';
  ArquivoServidoresAplicacao = 'ServApl.cds';
  ArquivoHelpGeral = 'HelpMC.chm';

  // N�o Encontrado ou N�o Definido
  sSemRegistroParaExcluir = 'N�o h� registro para ser exclu�do.';
  sSemRegistroParaProcessar = 'N�o h� registro para ser processado.';
  sNaoSelecionado = 'N�o foi selecionado nenhum item para %S verifique.';
  sNaoEncontrado = 'Registro n�o encontrado, verifique.';
  sNaoEncontradoComTabela = 'Registro %s n�o encontrado, verifique.';

  // Outras
  sEntreEmContato = 'Se este erro persistir, entre em contato com o suporte t�cnico da Tek-System:' + #13 +
    'Telefone: ' + sTelefoneTekSystem + '        E-mail: ' + sEMailSuporteTekSystem;
  sMensagemSistemaSomenteLeitura = 'O sistema est� operando com a licen�a somente leitura. ' +
    'Apenas consultas podem ser realizadas. ' +
    'Entre em contato com a Tek-System, atrav�s do telefone ' + sTelefoneTekSystem +
    ' ou e-mail ' + sEMailSuporteTekSystem + ', ' +
    'caso queira voltar a trabalhar integralmente com o sistema.';
  sProgramaNaoLiberado = 'Programa n�o liberado para usu�rio.';
  sNumeroMaximoTabela = 'O n�mero m�ximo de tabelas a imprimir � 5.'#13'Desmarque outra e depois escolha essa.';
  sEscrituracaoApenasLivroAnexo = 'Escritura��o permitida apenas no m�dulo: Livro Fiscal'; // ou Anexo VII; // Anexo nao existe, apesar de ter o teste do programa origem
  sNFSeNaoExisteBDProvedor = 'REGISTRO N�O EXISTE NA BASE DA PREFEITURA';

  sCondicaodeUsoCartaCorrecao = 'A Carta de Corre��o � disciplinada pelo � 1�-A do art. 7�' +
    ' do Conv�nio S/N, de 15 de dezembro de 1970 e pode ser' +
    ' utilizada para regulariza��o de erro ocorrido na emiss�o de' +
    ' documento fiscal, desde que o erro n�o esteja relacionado' +
    ' com: ' + #13 +
    '    I - as vari�veis que determinam o valor do imposto' +
    ' tais como: base de c�lculo, al�quota, diferen�a de pre�o,' +
    ' quantidade, valor da opera��o ou da presta��o; ' + #13 +
    '    II - a corre��o de dados cadastrais que implique mudan�a do' +
    ' remetente ou do destinat�rio; ' + #13 +
    '    III - a data de emiss�o ou de sa�da.';

  sChaveCriptografia = 'SISTEMA DE GESTAO INDUSTRIAL/COMERCIAL MULTICAMADAS  - TEK-SYSTEM INFORMATICA - UBA.MG';

  // Prefixos e Sufixos
  SufixoFrete = '-FR';
  PrefixoOrdemPagto = 'OP-';
  PrefixoGrade = 'GRA_';
  PrefixoPrecoBruto = 'PRB_';
  PrefixoPrecoLiquido = 'PRL_';
  PrefixoPrecoMoeda = 'PMO_';
  PrefixoChaveGrade = 'AUT_';

  // Restri��es de Cadastros
  sRestricaoInclusao = 'Voc� n�o tem permiss�o para INSERIR registros nesse cadastro.';
  sRestricaoAlteracao = 'Voc� n�o tem permiss�o para ALTERAR registros nesse cadastro.';
  sRestricaoExclusao = 'Voc� n�o tem permiss�o para EXCLUIR registros desse cadastro.';

  sCadastro_PosicionarNoCodigo = 'PosicionarNoCodigo';
  sCadastro_BloquearManipulacao = 'BloquearTrocaCodigo';

  // Relatorio
  sDiretorioRelatoriosPDF = 'RELATORIOS_PDF';
  sNaoPodeAlterarRelatorio = 'Modelo de relat�rio n�o pode ser alterado' + #13 + 'Verifique a autoria do modelo ou se � um modelo de sistema.';

  // Producao
  sNaoConfiguracaoPreparacao = 'Sistema n�o est� configurado para utilizar tabela de prepara��o.';
  sDiaNaoUtil = 'A data informada n�o � um dia �til.';

  // Geram funcionamentos especiais
  sOcultarDoMonitorDeSQL = '/* Retire esse coment�rio para aparecer no monitor de SQL */' + #13;
  sIgnorarConteudo = '<IGNORAR_CONTEUDO>';
  sIgnorarRegistro = '<IGNORAR_REGISTRO>';

  // F�rmula Padr�o do Custo
  sFormulaCustoPadrao = '(VALOR_MERCADORIA + ( VALOR_IPI + VALOR_FRETE + VALOR_SEGURO + VALOR_OUTRASDESP) - (VALOR_ICMS + VALOR_PIS + VALOR_COFINS + VALOR_DESCONTO))';

  // Site IBGE para consulta do c�digo do munic�pio
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
