inherited DMPaiCadastro: TDMPaiCadastro
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  Width = 225
  inherited ConexaoDS: TSQLConnection
    Left = 140
    Top = 5
  end
  object CDSCadastro: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = DSPCCadastro
    BeforeOpen = CDSCadastroBeforeOpen
    AfterOpen = CDSCadastroAfterOpen
    BeforeClose = CDSCadastroBeforeClose
    BeforeEdit = CDSCadastroBeforeEdit
    BeforePost = CDSCadastroBeforePost
    AfterPost = CDSCadastroAfterPost
    BeforeCancel = CDSCadastroBeforeCancel
    AfterCancel = CDSCadastroAfterCancel
    BeforeDelete = CDSCadastroBeforeDelete
    AfterDelete = CDSCadastroAfterDelete
    BeforeScroll = CDSCadastroBeforeScroll
    AfterScroll = CDSCadastroAfterScroll
    OnNewRecord = CDSCadastroNewRecord
    OnReconcileError = CDSCadastroReconcileError
    Left = 48
    Top = 53
  end
  object DSPCCadastro: TDSProviderConnection
    Left = 49
    Top = 5
  end
end
