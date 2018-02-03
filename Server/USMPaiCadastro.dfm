inherited SMPaiCadastro: TSMPaiCadastro
  OldCreateOrder = True
  OnCreate = DSServerModuleCreate
  OnDestroy = DSServerModuleDestroy
  Width = 204
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
    OnGetTableName = DSPCadastroGetTableName
    Left = 124
    Top = 20
  end
end
