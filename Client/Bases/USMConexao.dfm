object SMConexao: TSMConexao
  OldCreateOrder = False
  OnCreate = DSServerModuleCreate
  OnDestroy = DSServerModuleDestroy
  Height = 213
  Width = 291
  object CDSProximoCodigo: TClientDataSet
    Aggregates = <>
    Params = <
      item
        DataType = ftString
        Name = 'TABELA'
        ParamType = ptInput
      end
      item
        DataType = ftInteger
        Name = 'QUEBRA'
        ParamType = ptInput
      end>
    ProviderName = 'DSPProximoCodigo'
    Left = 62
    Top = 102
  end
  object DSPProximoCodigo: TDataSetProvider
    DataSet = SQLDSProximoCodigo
    Constraints = False
    Exported = False
    Options = []
    OnUpdateData = DSPProximoCodigoUpdateData
    OnGetTableName = DSPProximoCodigoGetTableName
    Left = 63
    Top = 58
  end
  object SQLDSProximoCodigo: TSQLDataSet
    SchemaName = 'sysdba'
    CommandText = 
      'select '#13#10'AUTOINCREMENTOS.TABELA_AUTOINC,'#13#10'AUTOINCREMENTOS.QUEBRA' +
      '_AUTOINC,'#13#10'AUTOINCREMENTOS.CODIGO_AUTOINC'#13#10'from AUTOINCREMENTOS'#13 +
      #10'where AUTOINCREMENTOS.TABELA_AUTOINC = :TABELA'#13#10'and AUTOINCREME' +
      'NTOS.QUEBRA_AUTOINC = :QUEBRA'
    MaxBlobSize = -1
    Params = <
      item
        DataType = ftString
        Name = 'TABELA'
        ParamType = ptInput
      end
      item
        DataType = ftInteger
        Name = 'QUEBRA'
        ParamType = ptInput
      end>
    Left = 62
    Top = 13
  end
end
