inherited SMPaiCadastro: TSMPaiCadastro
  OldCreateOrder = True
  OnCreate = DSServerModuleCreate
  OnDestroy = DSServerModuleDestroy
  object SQLDSCadastro: TSQLDataSet
    AfterOpen = SQLDSCadastroAfterOpen
    MaxBlobSize = -1
    Params = <>
    Left = 36
    Top = 20
  end
  object DSPCadastro: TDataSetProvider
    DataSet = SQLDSCadastro
    Options = [poCascadeDeletes, poCascadeUpdates]
    UpdateMode = upWhereKeyOnly
    OnUpdateError = DSPCadastroUpdateError
    BeforeUpdateRecord = DSPCadastroBeforeUpdateRecord
    BeforeApplyUpdates = DSPCadastroBeforeApplyUpdates
    AfterApplyUpdates = DSPCadastroAfterApplyUpdates
    OnGetTableName = DSPCadastroGetTableName
    Left = 124
    Top = 20
  end
end
