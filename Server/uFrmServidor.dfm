object Servidor: TServidor
  Left = 0
  Top = 0
  Caption = 'Servidor'
  ClientHeight = 118
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblBDHost: TLabel
    Left = 41
    Top = 8
    Width = 79
    Height = 23
    Caption = 'BDHOST:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblBDPort: TLabel
    Left = 43
    Top = 37
    Width = 77
    Height = 23
    Caption = 'BDPORT:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblStatusServidor: TLabel
    Left = 275
    Top = 39
    Width = 6
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblServerPort: TLabel
    Left = 275
    Top = 9
    Width = 121
    Height = 23
    Caption = 'SERVERPORT:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblDiretorioBD: TLabel
    Left = 12
    Top = 70
    Width = 108
    Height = 23
    Caption = 'Diretorio BD:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object btnStart: TSpeedButton
    Left = 512
    Top = 57
    Width = 71
    Height = 26
    Caption = '&Start'
    OnClick = btnStartClick
  end
  object btnStop: TSpeedButton
    Left = 512
    Top = 84
    Width = 71
    Height = 26
    Caption = '&Stop'
    OnClick = btnStopClick
  end
  object edtHostBD: TEdit
    Left = 126
    Top = 10
    Width = 120
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edtPortBD: TEdit
    Left = 126
    Top = 37
    Width = 120
    Height = 21
    TabOrder = 1
    Text = '3054'
  end
  object edtServerPort: TEdit
    Left = 402
    Top = 12
    Width = 181
    Height = 21
    TabOrder = 2
    Text = '200'
  end
  object edtDiretorioBD: TJvComboEdit
    Left = 126
    Top = 73
    Width = 270
    Height = 21
    Flat = False
    ParentFlat = False
    ButtonWidth = 34
    ImageKind = ikEllipsis
    TabOrder = 3
    Text = 'C:\TRABALHO\VENDAS\Dados\VENDAS.FDB'
    OnButtonClick = edtDiretorioBDButtonClick
  end
  object dlgDiretorioBD: TOpenDialog
    Left = 310
    Top = 65
  end
end
