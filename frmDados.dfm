object fDados: TfDados
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 356
  Width = 378
  object Conexao: TIBDatabase
    Params.Strings = (
      'user_name=SYSDBA')
    LoginPrompt = False
    DefaultTransaction = Transaction
    ServerType = 'IBServer'
    Left = 56
    Top = 24
  end
  object Transaction: TIBTransaction
    DefaultDatabase = Conexao
    Left = 120
    Top = 24
  end
  object Query: TIBQuery
    Database = Conexao
    Transaction = Transaction
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    Left = 176
    Top = 24
  end
  object TABCLI: TIBTable
    Database = Conexao
    Transaction = Transaction
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    DefaultIndex = False
    TableName = 'TABCLI'
    UniDirectional = False
    Left = 48
    Top = 120
  end
  object TABITE: TIBTable
    Database = Conexao
    Transaction = Transaction
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    TableName = 'TABITE'
    UniDirectional = False
    Left = 104
    Top = 120
  end
  object TABMAR: TIBTable
    Database = Conexao
    Transaction = Transaction
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    TableName = 'TABMAR'
    UniDirectional = False
    Left = 160
    Top = 120
  end
  object TABPED: TIBTable
    Database = Conexao
    Transaction = Transaction
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    TableName = 'TABPED'
    UniDirectional = False
    Left = 208
    Top = 120
  end
  object TABPEDITE: TIBTable
    Database = Conexao
    Transaction = Transaction
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    TableName = 'TABPEDITE'
    UniDirectional = False
    Left = 264
    Top = 120
  end
end
