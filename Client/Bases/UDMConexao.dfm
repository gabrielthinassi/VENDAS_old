object DMConexao: TDMConexao
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 539
  Width = 901
  object KeyNavigator1: TKeyNavigator
    MudaEnter.Strings = (
      'TEdit'
      'TEditComp'
      'TMaskEdit'
      'TJvMaskEdit'
      'TCheckBox'
      'TPageControl'
      'TTabSheet'
      'TDBEdit'
      'TDBCheckBox'
      'TJvComboEdit'
      'TJvDateEdit'
      'TJvDBComboEdit'
      'TJvDBDateEdit'
      'TJvFileNameEdit'
      'TJvDBDateTimePicker'
      'TBitBtn'
      'TButton'
      'TCheckListBox'
      'TComboBox'
      'TJvDBComboBox'
      'TGroupBox'
      'TSpinEdit'
      'TJvSpinEdit'
      'TJvCalcEdit'
      'TJvDBCalcEdit'
      'TGroupButton'
      'TListBox'
      'TJvCheckBox'
      'TJvDBCheckBox'
      'TJvTimeEdit'
      'TJvComboBox')
    MudaCima.Strings = (
      'TEdit'
      'TEditComp'
      'TMaskEdit'
      'TCheckBox'
      'TPageControl'
      'TTabSheet'
      'TDBEdit'
      'TDBCheckBox'
      'TJvComboEdit'
      'TJvCalcEdit'
      'TJvDateEdit'
      'TJvDBComboEdit'
      'TJvDBCalcEdit'
      'TJvDBDateEdit'
      'TJvFileNameEdit'
      'TJvDBDateTimePicker'
      'TBitBtn'
      'TButton'
      'TJvMaskEdit'
      'TJvTimeEdit'
      'TJvComboBox')
    MudaBaixo.Strings = (
      'TEdit'
      'TEditComp'
      'TMaskEdit'
      'TCheckBox'
      'TPageControl'
      'TTabSheet'
      'TDBEdit'
      'TDBCheckBox'
      'TJvComboEdit'
      'TJvCalcEdit'
      'TJvDateEdit'
      'TJvDBComboEdit'
      'TJvDBCalcEdit'
      'TJvDBDateEdit'
      'TJvFileNameEdit'
      'TBitBtn'
      'TButton'
      'TJvMaskEdit'
      'TJvTimeEdit'
      'TJvComboBox')
    Left = 337
    Top = 19
  end
  object CDSServidores: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterOpen = CDSServidoresAfterOpen
    BeforePost = CDSServidoresBeforePost
    Left = 49
    Top = 16
    object CDSServidoresOrdem: TIntegerField
      FieldName = 'Ordem'
    end
    object CDSServidoresDescricao: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      DisplayWidth = 50
      FieldName = 'Descricao'
      Size = 80
    end
    object CDSServidoresServidor: TStringField
      CustomConstraint = 'VALUE IS NOT NULL'
      ConstraintErrorMessage = 'Host do servidor de ser preenchido'
      FieldName = 'Servidor'
      Size = 50
    end
    object CDSServidoresPorta: TIntegerField
      CustomConstraint = 'VALUE > 0'
      ConstraintErrorMessage = 'Porta do servidor de ser maior que zero'
      FieldName = 'Porta'
    end
    object CDSServidoresProxy_Host: TStringField
      DisplayLabel = 'Proxy - Host'
      DisplayWidth = 80
      FieldName = 'Proxy_Host'
      Size = 80
    end
    object CDSServidoresProxy_Porta: TIntegerField
      DefaultExpression = '8888'
      DisplayLabel = 'Proxy - Porta'
      FieldName = 'Proxy_Porta'
    end
    object CDSServidoresProxy_Usuario: TStringField
      DisplayLabel = 'Proxy - Usuario'
      FieldName = 'Proxy_Usuario'
      Size = 50
    end
    object CDSServidoresProxy_Senha: TStringField
      DisplayLabel = 'Proxy - Senha'
      FieldName = 'Proxy_Senha'
      Size = 50
    end
    object CDSServidoresSecundario_Host: TStringField
      DisplayLabel = 'Secundario - Host'
      FieldName = 'Secundario_Host'
      Size = 50
    end
    object CDSServidoresSecundario_Porta: TIntegerField
      DisplayLabel = 'Secundario - Porta'
      FieldName = 'Secundario_Porta'
    end
    object CDSServidoresProtecao_Host: TStringField
      ConstraintErrorMessage = 'Host da prote'#231#227'o de ser preenchido'
      DisplayLabel = 'Protecao - Host'
      FieldName = 'Protecao_Host'
      Size = 50
    end
    object CDSServidoresProtecao_Porta: TIntegerField
      ConstraintErrorMessage = 'Porta da prote'#231#227'o de ser maior que zero'
      DisplayLabel = 'Protecao - Porta'
      FieldName = 'Protecao_Porta'
    end
    object CDSServidoresTipo: TSmallintField
      Alignment = taLeftJustify
      DefaultExpression = '1'
      DisplayWidth = 13
      FieldName = 'Tipo'
      OnGetText = CDSServidoresTipoGetText
    end
    object CDSServidoresRede: TSmallintField
      Alignment = taLeftJustify
      DefaultExpression = '0'
      FieldName = 'Rede'
      OnGetText = CDSServidoresRedeGetText
    end
  end
  object PopupMenuGrid: TPopupMenu
    OnPopup = PopupMenuGridPopup
    Left = 256
    Top = 67
    object OcultarColuna1: TMenuItem
      Caption = 'Ocultar Coluna em Foco'
      OnClick = OcultarColuna1Click
    end
    object ReexibirColunas1: TMenuItem
      Caption = 'Reexibir Colunas'
      OnClick = ReexibirColunas1Click
    end
    object AutoAjusteColunas1: TMenuItem
      Caption = 'Auto Ajuste Tamanho Colunas'
      ShortCut = 49217
      OnClick = AutoAjusteColunas1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PesquisaIncremental1: TMenuItem
      Caption = 'Pesquisa Incremental...'
      ShortCut = 16416
      OnClick = PesquisaIncremental1Click
    end
    object FiltrarRegistros1: TMenuItem
      Caption = 'Filtrar Registros...'
      Visible = False
      OnClick = FiltrarRegistros1Click
    end
    object AnalisaremCubodeDeciso1: TMenuItem
      Caption = 'Analisar em Cubo de Decis'#227'o...'
      OnClick = AnalisaremCubodeDeciso1Click
    end
    object CopiarRegistrosparareadeTransferncia1: TMenuItem
      Caption = 'Exportar Dados'
      object Todaagrade1: TMenuItem
        Caption = 'Toda a grade'
        OnClick = Todaagrade1Click
      end
      object ApenasColunaAtual1: TMenuItem
        Caption = 'Apenas Coluna Atual'
        OnClick = ApenasColunaAtual1Click
      end
      object ApenasLinhaAtual1: TMenuItem
        Caption = 'Apenas Linha Atual'
        OnClick = ApenasLinhaAtual1Click
      end
      object ApenasClulaatual1: TMenuItem
        Caption = 'Apenas C'#233'lula Atual'
        ShortCut = 16451
        OnClick = ApenasClulaatual1Click
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Exportar1: TMenuItem
        Caption = 'Para Arquivo...'
        OnClick = Exportar1Click
      end
    end
    object SeparadorFuncaoAgregacao: TMenuItem
      Caption = '-'
    end
    object FuncoesdeAgregacao1: TMenuItem
      Caption = 'Fun'#231#245'es de Agrega'#231#227'o'
      object ContarRegistros1: TMenuItem
        Caption = 'Contar Registros'
        OnClick = ContarRegistros1Click
      end
      object SomarColuna1: TMenuItem
        Tag = 1
        Caption = 'Somar Coluna'
        OnClick = SomarOuMediaColuna1Click
      end
      object MediaColuna1: TMenuItem
        Tag = 2
        Caption = 'M'#233'dia Aritm'#233'tica da Coluna'
        OnClick = SomarOuMediaColuna1Click
      end
      object SeparadorOpcoesAgregacao: TMenuItem
        Caption = '-'
      end
      object ContarRegistrosMarcados1: TMenuItem
        Tag = 1
        Caption = 'Contar Registros Marcados'
        OnClick = ContarRegistros1Click
      end
      object SomarColunaapenasdosRegistrosMarcados1: TMenuItem
        Tag = 3
        Caption = 'Somar Coluna (apenas dos Registros Marcados)'
        OnClick = SomarOuMediaColuna1Click
      end
      object MediaAritmeticadaColunaapenasdosRegistrosMarcados1: TMenuItem
        Tag = 4
        Caption = 'M'#233'dia Aritm'#233'tica da Coluna (apenas dos Registros Marcados)'
        OnClick = SomarOuMediaColuna1Click
      end
    end
    object FuncoesdeAtribuicao: TMenuItem
      Caption = 'Fun'#231#245'es de Atribui'#231#227'o'
      object Formula: TMenuItem
        Tag = 1
        Caption = 'F'#243'rmula'
        OnClick = AtribuicaoClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Arredondarpara2casasdecimais: TMenuItem
        Tag = 2
        Caption = 'Arredondar para 2 casas decimais'
        OnClick = AtribuicaoClick
      end
      object Arredondarpara1casadecimal: TMenuItem
        Tag = 3
        Caption = 'Arredondar para 1 casa decimal'
        OnClick = AtribuicaoClick
      end
      object Arredondarparaunidade: TMenuItem
        Tag = 4
        Caption = 'Arredondar para unidade'
        OnClick = AtribuicaoClick
      end
      object Arredondarparadezena: TMenuItem
        Tag = 5
        Caption = 'Arredondar para dezena'
        OnClick = AtribuicaoClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Ajustarparaprximointeiro: TMenuItem
        Tag = 6
        Caption = 'Ajustar para pr'#243'ximo inteiro'
        OnClick = AtribuicaoClick
      end
      object Ajustarparainteiroanterior: TMenuItem
        Tag = 7
        Caption = 'Ajustar para inteiro anterior'
        OnClick = AtribuicaoClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Atribuirvalorfixo: TMenuItem
        Tag = 8
        Caption = 'Atribuir valor fixo'
        OnClick = AtribuicaoClick
      end
    end
  end
  object GridParaHTML1: TGridParaHTML
    Autor = 'Denis Pereira Raymundo'
    Visualizar = False
    CorpoFontePadrao = False
    CabecalhoFontePadrao = False
    Left = 256
    Top = 116
  end
  object DataSetParaCSV1: TDataSetParaCSV
    Autor = 'Denis Pereira Raymundo'
    Delimitador = '"'
    DoInicio = True
    Extensao = '.CSV'
    Separador = ','
    MaximoRegistrosPorArquivo = 0
    Left = 336
    Top = 116
  end
  object SaveDialogGrid: TSaveDialog
    Filter = 'CSV|*.CSV|HTML|*.HTML;*.HTM|XML|*.XML|CDS|*.CDS|TXT|*.TXT'
    Options = [ofReadOnly, ofHideReadOnly, ofEnableSizing]
    Left = 255
    Top = 168
  end
  object CDSDefaults: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 48
    Top = 274
  end
  object RDprint1: TRDprint
    ImpressoraPersonalizada.NomeImpressora = 'Modelo Personalizado - (Epson)'
    ImpressoraPersonalizada.AvancaOitavos = '27 48'
    ImpressoraPersonalizada.AvancaSextos = '27 50'
    ImpressoraPersonalizada.SaltoPagina = '12'
    ImpressoraPersonalizada.TamanhoPagina = '27 67 66'
    ImpressoraPersonalizada.Negrito = '27 69'
    ImpressoraPersonalizada.Italico = '27 52'
    ImpressoraPersonalizada.Sublinhado = '27 45 49'
    ImpressoraPersonalizada.Expandido = '27 14'
    ImpressoraPersonalizada.Normal10 = '18 27 80'
    ImpressoraPersonalizada.Comprimir12 = '18 27 77'
    ImpressoraPersonalizada.Comprimir17 = '27 80 27 15'
    ImpressoraPersonalizada.Comprimir20 = '27 77 27 15'
    ImpressoraPersonalizada.Reset = '27 80 18 20 27 53 27 70 27 45 48'
    ImpressoraPersonalizada.Inicializar = '27 64'
    OpcoesPreview.PaginaZebrada = True
    OpcoesPreview.MostrarSETUP = True
    OpcoesPreview.Remalina = False
    OpcoesPreview.CaptionPreview = 'Previs'#227'o para Impress'#227'o (Modo Texto)'
    OpcoesPreview.PreviewZoom = 100
    OpcoesPreview.CorPapelPreview = clWhite
    OpcoesPreview.CorLetraPreview = clBlack
    OpcoesPreview.Preview = False
    OpcoesPreview.BotaoSetup = Ativo
    OpcoesPreview.BotaoImprimir = Ativo
    OpcoesPreview.BotaoGravar = Ativo
    OpcoesPreview.BotaoLer = Ativo
    OpcoesPreview.BotaoProcurar = Ativo
    OpcoesPreview.BotaoPDF = Ativo
    OpcoesPreview.BotaoEMAIL = Ativo
    Margens.Left = 10
    Margens.Right = 10
    Margens.Top = 10
    Margens.Bottom = 10
    Autor = Deltress
    RegistroUsuario.NomeRegistro = 'TEK-SYSTEM INFORM'#193'TICA LTDA'
    RegistroUsuario.SerieProduto = 'SINGLE 6.1 - 495/0916 (DX101)'
    RegistroUsuario.AutorizacaoKey = 'JQVBJ-YEJQF-8SHNF-PT59E-SJNV6-OVHYI-FOGYP'
    About = 'RDprint 6.1c'
    Acentuacao = SemAcento
    CaptionSetup = 'Configure a Impress'#227'o'
    TitulodoRelatorio = 'Gerado por RDprint'
    UsaGerenciadorImpr = True
    CorForm = clBtnFace
    CorFonte = clBlack
    Impressora = Epson
    Mapeamento.Strings = (
      '//--- Grafico Compativel com Windows/USB ---//'
      '//'
      'GRAFICO=GRAFICO'
      'HP=GRAFICO'
      'DESKJET=GRAFICO'
      'LASERJET=GRAFICO'
      'INKJET=GRAFICO'
      'STYLUS=GRAFICO'
      'EPL=GRAFICO'
      'USB=GRAFICO'
      '//'
      '//--- Linha Epson Matricial 9 e 24 agulhas ---//'
      '//'
      'EPSON=EPSON'
      'GENERICO=EPSON'
      'LX-300=EPSON'
      'LX-810=EPSON'
      'FX-2170=EPSON'
      'FX-1170=EPSON'
      'LQ-1170=EPSON'
      'LQ-2170=EPSON'
      'OKIDATA=EPSON'
      '//'
      '//--- Rima e Emilia ---//'
      '//'
      'RIMA=RIMA'
      'EMILIA=RIMA'
      '//'
      '//--- Linha HP/Xerox padr'#227'o PCL ---//'
      '//'
      'PCL=HP'
      '//'
      '//--- Impressoras 40 Colunas ---//'
      '//'
      'DARUMA=BOBINA'
      'SIGTRON=BOBINA'
      'SWEDA=BOBINA'
      'BEMATECH=BOBINA')
    MostrarProgresso = True
    TamanhoQteLinhas = 66
    TamanhoQteColunas = 80
    TamanhoQteLPP = Seis
    NumerodeCopias = 1
    FonteTamanhoPadrao = S10cpp
    FonteEstiloPadrao = []
    Orientacao = poPortrait
    FonteGrafica = sCourierNew
    ReduzParaCaber = True
    Left = 340
    Top = 266
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    OnMessage = ApplicationEvents1Message
    Left = 253
    Top = 19
  end
  object SaveDialogReg: TSaveDialog
    Filter = 'XML|*.XML|CDS|*.CDS'
    FilterIndex = 2
    Options = [ofReadOnly, ofHideReadOnly, ofEnableSizing]
    Left = 336
    Top = 170
  end
  object OpenDialogReg: TOpenDialog
    Filter = 'XML|*.XML|CDS|*.CDS'
    FilterIndex = 2
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 256
    Top = 219
  end
  object ImageList1: TImageList
    Left = 340
    Top = 218
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000873AD00007BB500086B9C000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000943931009C42
      2900D6845A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E7AD7300FFCE9400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000007BB50031B5E7000084BD000084B500007BB500006B9C00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6A59400D6946300FFD6A500F7BD8400EFA5
      7300F7AD7B007B18080000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E7BD9C00F7AD6300DECEBD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000884
      BD0031B5E70031B5EF000084BD000084B500007BB500007BB50008527300006B
      A50008639C000000000000000000000000000000000000000000000000001094
      1000109C100018A5180018A51800DEB59C00FFCE9400F7B58400EFAD7B00EF9C
      6B00EFA56B008C21100073100000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F7BD8C00EFA5520000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000094C600315A
      730031B5E70042BDEF000084BD000084B500007BB500007BB50010526B000073
      AD000073A5000073A500000000000000000000000000000000000000000073BD
      730052EF7B0063FF940063FF9400E7C6AD00F7B58400EFAD7300EFA56B00E794
      6300E7945A009429100084180000000000000000000000000000000000000000
      000000000000000000000000000000000000B5B5B50084848400848484009C9C
      9C00CE8C4200E794420000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000094CE0031B5EF003173
      8C0031B5EF005ACEF700008CBD000084BD000084B500007BB500104A6300007B
      AD000073AD000073AD009CC6DE000000000000000000000000000000000021B5
      31004AE7730052EF840063FF940000000000EFA57300E79C6300E7946300DE8C
      5200DE7B4200A539100094290800000000000000000000000000000000000000
      0000000000000000000000000000000000009C9C9C00949494007B7B7B008C94
      9400DE842900AD6B31009C9C9C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000018A5DE0031BDEF00318C
      AD0039BDF70052636B001863840029424A000084B5000084BD0018425200007B
      AD00007BAD00007BAD0073ADCE000000000000000000000000004294420031CE
      4A0042DE6300089C100031CE4A0000000000E7946300DE845200E7AD8400F7CE
      AD00E7A57300D6947B00A5391800000000000000000000000000000000000000
      0000000000000000000000000000B57B4A00A5A5A500A5A5A500BDBDBD00FFFF
      FF008C7B730094949C0084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021ADDE0039BDF700397B
      940039A5D60084D6F700008CC600008CBD00008CC600086B9400293131000863
      8C000084BD000084B5004294BD00000000000000000000000000107B100029C6
      420008840800000000000000000000000000D6842900FFC69400EFAD7B00E79C
      6B00E7945A00DE845200D67B4A00000000000000000000000000000000000000
      00000000000000000000C65A0000DE943100B5B5B500BDBDBD00D6D6D600CECE
      CE0084848400A5A5A500A5A5A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000031B5EF00294A7B00298C
      EF002984F7006BADFF00008CCE00008CC600008CBD00008CBD00214252000084
      BD000084B5001842520084B5D60000000000000000000021EF00397BA50018B5
      29003973EF000829CE0018189C000000000000000000CE843900DE8C5200B552
      0800BD633900DEB5A50000000000000000000000000000000000000000000000
      000000000000BD5A0000E7840000FF9C1000D6D6E700C6C6C600CECECE00BDBD
      BD00BDBDBD00ADADAD0094949400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000106BBD003994FF002173
      FF0052B5FF002952FF000073DE00008CCE00008CC600008CBD0021425200008C
      BD000084BD000084BD00006B9C00000000004A63FF00ADE7FF0094CEFF001073
      31003973FF000842FF000029F7009C9CDE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BD5A0000EF840000FF940000FFC66300FF9C0800E7EFFF00C6C6C600BDBD
      BD00B5B5B500B5B5B500E7DEDE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000002984F700085AFF0073E7
      FF0042EFFF006BCEFF000039F7000884D6000094C6000094C60021425200008C
      C600008CBD00008CBD00006BA50000000000000000005A94F7009CDEFF006BA5
      FF00316BFF000031FF000000A500000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C65A
      0000EF840000FF940000FFB54200FF9C0000FF9C0000FF8C0000F7A54200D6BD
      9C00BD9C6B00D68C630000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000094CEF7001863FF00218CFF0000CE
      FF0000CEFF004AE7FF000042F7000073DE000094CE000094C600214A5A000094
      C6000094C6000094C600007BAD0000000000000000006B7BFF00ADEFFF006BA5
      FF002963FF000029FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CE630000EF84
      0000FF9C0000FF9C0800FF9C0000FF9C0000FF940000EF840000E77B0000DE73
      0000B55A18000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000073BDE7007BDEFF0042A5FF0042EF
      FF0010D6FF0039A5FF000852FF00399CF70094DEFF0073D6F70029424A000094
      C6000094CE000094C6000084BD00000000000000000000000000426BE70073AD
      FF00184AFF0008089C0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DED6D600DEC6AD00F7A53100FF94
      0000FF9C0000FF9C0000FF9C0000F7940000EF840000E77B0000DE730000AD4A
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000052BDDE004A9CFF002163FF004AB5
      F70063C6F7003994EF00185AE70031A5EF00395A630039A5CE0031B5EF0031B5
      E70031B5E70039BDE7000073AD000000000000000000000000008C94F7008CCE
      FF000031FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EFE7E700ADBD
      BD00CECED600FFD69C00FF940000EF840000E77B0000D6730000CE6300000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021A5DE000884E70073E7
      F7001863F7002163C600397BBD0039BDF70031ADDE00317B9C00295263000094
      CE004AADD6000000000000000000000000000000000000000000000000002142
      D6002121AD000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600A5A5AD00CEBDA500D66B0800CE7B31000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000006BC6DE0029A5D6008CCEE700000000000000
      000000000000000000000000000000000000000000000000000000000000ADB5
      EF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000BDBDBD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFF0000F8FFFFC7FFF90000
      F03FFE03FFF10000E007E001FFF30000C003E001FF0300008001E101FF010000
      8001C101FE0100008001C701FC01000080018183F8010000800100FFF0010000
      800181FFE0030000000183FFC00700000001C3FF000F00000001C7FFC01F0000
      8007E7FFFC1F0000FE3FEFFFFFBF000000000000000000000000000000000000
      000000000000}
  end
  object CDSDiasNaoUteis: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 45
    Top = 373
  end
  object frxExportaPDF: TfrxPDFExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    Compressed = False
    PrintOptimized = False
    Outline = False
    Background = False
    HTMLTags = True
    Quality = 95
    Transparency = False
    Author = 'Tek-System Inform'#225'tica'
    Subject = 'Exporta'#231#227'o de Relat'#243'rio'
    ProtectionFlags = [ePrint, eCopy, eAnnot]
    HideToolbar = False
    HideMenubar = False
    HideWindowUI = False
    FitWindow = False
    CenterWindow = False
    PrintScaling = False
    PdfA = False
    Left = 495
    Top = 6
  end
  object frxExportaMail: TfrxMailExport
    ShowDialog = False
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    OnBeginExport = frxExportaMailBeginExport
    ShowExportDialog = True
    SmtpPort = 25
    UseIniFile = True
    TimeOut = 60
    ConfurmReading = False
    OnSendMail = frxExportaMailSendMail
    UseMAPI = SMTP
    Left = 570
    Top = 6
  end
  object frxExportaHTML: TfrxHTMLExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    FixedWidth = True
    Background = False
    Centered = False
    EmptyLines = True
    Print = False
    PictureType = gpPNG
    Left = 495
    Top = 51
  end
  object frxExportaXLS: TfrxXLSExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    ExportEMF = True
    AsText = True
    Background = True
    FastExport = True
    PageBreaks = True
    EmptyLines = True
    SuppressPageHeadersFooters = False
    Left = 495
    Top = 96
  end
  object frxExportaODS: TfrxODSExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    CreationTime = 0.000000000000000000
    DataOnly = False
    PictureType = gpPNG
    Background = True
    Creator = 'Tek-System Inform'#225'tica'
    SingleSheet = False
    Language = 'en'
    SuppressPageHeadersFooters = False
    Left = 570
    Top = 52
  end
  object frxExportaODT: TfrxODTExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    CreationTime = 0.000000000000000000
    DataOnly = False
    PictureType = gpPNG
    Background = True
    Creator = 'Tek-System Inform'#225'tica'
    SingleSheet = False
    Language = 'en'
    SuppressPageHeadersFooters = False
    Left = 570
    Top = 96
  end
  object frxExportaXML: TfrxXMLExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    Background = True
    Creator = 'Tek-System Inform'#225'tica'
    EmptyLines = True
    SuppressPageHeadersFooters = False
    RowsCount = 0
    Split = ssNotSplit
    Left = 495
    Top = 141
  end
  object frxExportaBMP: TfrxBMPExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    Left = 495
    Top = 186
  end
  object frxExportaSimpleText: TfrxSimpleTextExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    Frames = False
    EmptyLines = False
    OEMCodepage = False
    DeleteEmptyColumns = True
    Left = 570
    Top = 141
  end
  object frxExportaJPEG: TfrxJPEGExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    Left = 495
    Top = 231
  end
  object frxExportCSV: TfrxCSVExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    Separator = ';'
    OEMCodepage = False
    UTF8 = False
    NoSysSymbols = True
    ForcedQuotes = False
    Left = 570
    Top = 186
  end
  object frxDialogControls1: TfrxDialogControls
    Left = 689
    Top = 4
  end
  object frxDotMatrixExport1: TfrxDotMatrixExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    EscModel = 0
    GraphicFrames = False
    SaveToFile = False
    UseIniSettings = True
    Left = 571
    Top = 234
  end
  object SQLConexao: TSQLConnection
    DriverName = 'Datasnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      'HostName=localhost'
      'Port=211'
      'CommunicationProtocol=tcp/ip'
      'DatasnapContext=datasnap/'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=16.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b'
      'Filters={}')
    AfterConnect = SQLConexaoAfterConnect
    AfterDisconnect = SQLConexaoAfterDisconnect
    Left = 50
    Top = 65
  end
  object CDSPermissoes: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 128
    Top = 274
  end
  object CDSConfigCamposClasses: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 128
    Top = 322
  end
  object CDSAtalhos: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DSPCadastro'
    RemoteServer = DSPCCadAtalho
    Left = 48
    Top = 421
  end
  object DSPCCadAtalho: TDSProviderConnection
    ServerClassName = 'TSMCadAtalhos'
    SQLConnection = SQLConexao
    Left = 129
    Top = 421
  end
  object CDSConfigClasses: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 48
    Top = 322
  end
  object CDSIndicadores: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterInsert = CDSIndicadoresAfterInsert
    AfterDelete = CDSIndicadoresAfterInsert
    OnNewRecord = CDSIndicadoresNewRecord
    Left = 131
    Top = 372
  end
  object frxADOComponents1: TfrxADOComponents
    Left = 694
    Top = 109
  end
  object frxDBXComponents1: TfrxDBXComponents
    Left = 691
    Top = 54
  end
  object SynPasSynPadrao: TSynPasSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = 16744448
    NumberAttri.Foreground = 8388863
    StringAttri.Foreground = clGreen
    SymbolAttri.Foreground = clRed
    Left = 506
    Top = 383
  end
  object SynSQLSynPadrao: TSynSQLSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = clBlue
    DelimitedIdentifierAttri.Foreground = clPurple
    NumberAttri.Foreground = 16744703
    StringAttri.Foreground = clGreen
    SymbolAttri.Foreground = clRed
    TableNameAttri.Foreground = 33023
    TableNameAttri.Style = [fsUnderline]
    Left = 507
    Top = 433
  end
  object fcxXMLExport1: TfcxXMLExport
    Version = '2.6.3'
    Left = 810
    Top = 10
  end
  object fcxODSExport1: TfcxODSExport
    Version = '2.6.3'
    CreationTime = 0.000000000000000000
    Creator = 'FastReport'
    Language = 'en'
    Left = 810
    Top = 55
  end
  object fcxBIFFExport1: TfcxBIFFExport
    Version = '2.6.3'
    Left = 815
    Top = 100
  end
  object fcxHTMLExport1: TfcxHTMLExport
    Version = '2.6.3'
    HTMLFormat = hfHTML
    RepeatValues = False
    Left = 815
    Top = 145
  end
  object fcxDBFExport1: TfcxDBFExport
    Version = '2.6.3'
    Left = 815
    Top = 190
  end
  object fcxCSVExport1: TfcxCSVExport
    Version = '2.6.3'
    OEMCodepage = False
    UTF8 = False
    Separator = ';'
    NoSysSymbols = True
    ForcedQuotes = False
    Left = 815
    Top = 245
  end
  object TekPesquisaGrid1: TTekPesquisaGrid
    Tela_Left = 0
    Tela_Top = 0
    Left = 335
    Top = 65
  end
end
