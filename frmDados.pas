unit frmDados;

interface

uses
  System.SysUtils, System.Classes, Data.DB, IBX.IBCustomDataSet, IBX.IBQuery,
  IBX.IBDatabase, IBX.IBTable, Vcl.Forms;

type
  TfDados = class(TDataModule)
    Conexao: TIBDatabase;
    Transaction: TIBTransaction;
    Query: TIBQuery;
    TABCLI: TIBTable;
    TABITE: TIBTable;
    TABMAR: TIBTable;
    TABPED: TIBTable;
    TABPEDITE: TIBTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    function RetornaID(pTabela: string; var pMsgErro: String): Integer;
    { Public declarations }
  end;

var
  fDados: TfDados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TfDados.DataModuleCreate(Sender: TObject);
begin
  Conexao.DatabaseName := Copy(ExtractFileDir(Application.ExeName),1, LastDelimiter('\', ExtractFileDir(Application.ExeName))) + 'base\Guarani.FDB';
  Conexao.Params.Add('user_name=SYSDBA');
  Conexao.Params.Add('password=guarani');
  Conexao.Params.Add('lc_ctype=WIN1252');
  Conexao.Connected  := True;
  Transaction.Active := True;
  TABCLI.Active      := True;
  TABITE.Active      := True;
  TABMAR.Active      := True;
  TABPED.Active      := True;
  TABPEDITE.Active   := True;
  Query.Database     := Conexao;
end;

procedure TfDados.DataModuleDestroy(Sender: TObject);
begin
  TABCLI.Active      := False;
  TABITE.Active      := False;
  TABMAR.Active      := False;
  TABPED.Active      := False;
  TABPEDITE.Active   := False;
  Transaction.Active := False;
  Conexao.Connected  := False;
end;

function TfDados.RetornaID(pTabela: string; var pMsgErro: String): Integer;
begin
  Result := 0;
  try
    Query.Close;
    Query.SQL.Clear;
    Query.SQL.Add('select gen_id(' + pTabela +  ',1) as ID from rdb$database');
    Query.Open;
    if not Query.Eof then
    begin
      Result := Query.FieldByName('ID').AsInteger;
    end;
    Query.Close;
  except
    On E: Exception do
    begin
      Query.Close;
      pMsgErro := 'Ocorreu o seguinte erro ao gerar o ID para o registro: ' + E.Message;
    end;
  end;
end;

end.
