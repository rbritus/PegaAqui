object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 276
  Width = 349
  object Conn: TFDConnection
    Params.Strings = (
      'Database=D:\99CRM\Fontes\ServidorHorse\Database\BANCO.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Protocol=TCPIP'
      'Server=127.0.0.1'
      'DriverID=FB')
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 56
    Top = 32
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 192
    Top = 40
  end
end
