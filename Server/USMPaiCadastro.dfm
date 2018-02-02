inherited SMPaiCadastro: TSMPaiCadastro
  OldCreateOrder = True
  OnCreate = DSServerModuleCreate
  OnDestroy = DSServerModuleDestroy
  Width = 424
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
  object Conexao: TSQLConnection
    DriverName = 'Firebird'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXFirebird'
      
        'DriverPackageLoader=TDBXDynalinkDriverLoader,DbxCommonDriver240.' +
        'bpl'
      
        'DriverAssemblyLoader=Borland.Data.TDBXDynalinkDriverLoader,Borla' +
        'nd.Data.DbxCommonDriver,Version=24.0.0.0,Culture=neutral,PublicK' +
        'eyToken=91d62ebb5b0d1b1b'
      
        'MetaDataPackageLoader=TDBXFirebirdMetaDataCommandFactory,DbxFire' +
        'birdDriver240.bpl'
      
        'MetaDataAssemblyLoader=Borland.Data.TDBXFirebirdMetaDataCommandF' +
        'actory,Borland.Data.DbxFirebirdDriver,Version=24.0.0.0,Culture=n' +
        'eutral,PublicKeyToken=91d62ebb5b0d1b1b'
      'GetDriverFunc=getSQLDriverINTERBASE'
      'LibraryName=dbxfb.dll'
      'LibraryNameOsx=libsqlfb.dylib'
      'VendorLib=fbclient.dll'
      'VendorLibWin64=fbclient.dll'
      'VendorLibOsx=/Library/Frameworks/Firebird.framework/Firebird'
      'Database=127.0.0.1/3054:C:\TRABALHO\VENDAS\Dados\VENDAS.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Role=RoleName'
      'MaxBlobSize=-1'
      'LocaleCode=0000'
      'IsolationLevel=ReadCommitted'
      'SQLDialect=3'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'TrimChar=False'
      'BlobSize=-1'
      'ErrorResourceFile='
      'RoleName=RoleName'
      'ServerCharSet='
      'Trim Char=False')
    Left = 80
    Top = 85
  end
  object SQLDSProximoCodigo: TSQLDataSet
    CommandText = 
      'select '#13#10'AUTOINCREMENTOS.TABELA_AUTOINC,'#13#10'AUTOINCREMENTOS.CODIGO' +
      '_AUTOINC'#13#10'from AUTOINCREMENTOS'#13#10'where AUTOINCREMENTOS.TABELA_AUT' +
      'OINC = :TABELA'
    MaxBlobSize = -1
    Params = <>
    Left = 227
    Top = 8
  end
  object DSPProximoCodigo: TDataSetProvider
    DataSet = SQLDSProximoCodigo
    Constraints = False
    Exported = False
    Options = []
    Left = 228
    Top = 53
  end
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
    Left = 227
    Top = 97
  end
end
