inherited FPaiAssistente: TFPaiAssistente
  Caption = 'FPaiAssistente'
  ClientHeight = 342
  ClientWidth = 579
  ExplicitWidth = 585
  ExplicitHeight = 367
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 323
    Width = 579
    Height = 19
    Panels = <>
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 579
    Height = 323
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 1
  end
  object ActionList1: TActionList
    Left = 130
    Top = 95
    object actVoltar: TAction
      Caption = 'F2 - Voltar'
      OnExecute = actVoltarExecute
      OnUpdate = actVoltarUpdate
    end
    object actAvancar: TAction
      Caption = 'F3 - Avan'#231'ar'
      OnExecute = actAvancarExecute
      OnUpdate = actAvancarUpdate
    end
    object actCancelar: TAction
      Caption = 'F6 - Cancelar'
      OnExecute = actCancelarExecute
      OnUpdate = actCancelarUpdate
    end
    object actConfirmar: TAction
      Caption = 'F5 - Confirmar'
      OnUpdate = actConfirmarUpdate
    end
  end
end
