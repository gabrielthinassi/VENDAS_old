object Servidor: TServidor
  Left = 0
  Top = 0
  Caption = 'Servidor'
  ClientHeight = 194
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblBDHost: TLabel
    Left = 66
    Top = 35
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
    Left = 68
    Top = 85
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
    Left = 440
    Top = 84
    Width = 156
    Height = 24
    Caption = 'Servidor Iniciado!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblServerPort: TLabel
    Left = 300
    Top = 33
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
    Left = 37
    Top = 135
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
  object edtHost: TEdit
    Left = 151
    Top = 38
    Width = 120
    Height = 21
    TabOrder = 0
  end
  object edtPort: TEdit
    Left = 151
    Top = 86
    Width = 120
    Height = 21
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 427
    Top = 38
    Width = 181
    Height = 21
    TabOrder = 2
  end
  object edtDiretorioBD: TJvComboEdit
    Left = 151
    Top = 138
    Width = 270
    Height = 21
    Flat = False
    ParentFlat = False
    ButtonWidth = 34
    ImageKind = ikEllipsis
    TabOrder = 3
    Text = ''
    OnButtonClick = edtDiretorioBDButtonClick
  end
  object dlgDiretorioBD: TOpenDialog
    Left = 425
    Top = 135
  end
end
