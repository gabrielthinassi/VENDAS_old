object SC: TSC
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 222
  Width = 233
  object DSServer: TDSServer
    AutoStart = False
    Left = 96
    Top = 16
  end
  object DSTCPServerTransport: TDSTCPServerTransport
    Port = 0
    Server = DSServer
    Filters = <>
    Left = 96
    Top = 83
  end
  object DSServerClass: TDSServerClass
    OnGetClass = DSServerClassGetClass
    Server = DSServer
    Left = 95
    Top = 141
  end
end
