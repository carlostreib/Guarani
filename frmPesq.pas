unit frmPesq;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Buttons;

type
  TTelaOrigem = (TCLIENTE,TITEM,TPEDIDO,TMARCA);

  TfPesq = class(TForm)
    Panel1: TPanel;
    btFechar: TBitBtn;
    btCarregar: TBitBtn;
    img1: TImage;
    edPesq: TEdit;
    lbPesq: TLabel;
    gdPesq: TStringGrid;
    procedure btCarregarClick(Sender: TObject);
    procedure gdPesqDblClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
  private
    gTela: TTelaOrigem;
    procedure SetaTituloGrid;
    procedure LimparGrid;
    { Private declarations }
  public
    procedure SetarDadosTela(pTelaOrigem: TTelaOrigem);
    { Public declarations }
  end;

var
  fPesq: TfPesq;

implementation

{$R *.dfm}

uses frmDados;

{ TfPesq }

procedure TfPesq.btFecharClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfPesq.btCarregarClick(Sender: TObject);
var
  wLin: Integer;
  wCampo, wWhere: String;
begin
  try
    wCampo := UpperCase(edPesq.Text);
    wWhere := '';
    case gTela of
      TCLIENTE:
        begin
          if wCampo <> '' then
            wWhere := '  WHERE ' +
                      ' UPPER(FANTASIA) LIKE ''%' + wCampo + '%'' OR ' +
                      ' UPPER(RAZSOC) LIKE ''%' + wCampo + '%''';
          fDados.Query.Close;
          fDados.Query.SQL.Clear;
          fDados.Query.SQL.Add('SELECT ID,FANTASIA,RAZSOC FROM TABCLI ' + wWhere);
          fDados.Query.Open;
          wLin := 0;
          while not fDados.Query.Eof  do
          begin
            Inc(wLin);
            gdPesq.Cells[0,wLin] := fDados.Query.FieldByName('ID').AsString;
            gdPesq.Cells[1,wLin] := fDados.Query.FieldByName('FANTASIA').AsString + ' - ' +
                                    fDados.Query.FieldByName('RAZSOC').AsString;
            fDados.Query.Next;
          end;
          gdPesq.RowCount := fDados.Query.RecordCount + 1;
          fDados.Query.Close;
        end;
      TITEM:
        begin
          if wCampo <> '' then
            wWhere := '  WHERE ' +
                      ' UPPER(DESCRICAO) LIKE ''%' + wCampo + '%''' ;
          fDados.Query.Close;
          fDados.Query.SQL.Clear;
          fDados.Query.SQL.Add('SELECT ID,DESCRICAO FROM TABITE ' + wWhere);
          fDados.Query.Open;
          wLin := 0;
          while not fDados.Query.Eof  do
          begin
            Inc(wLin);
            gdPesq.Cells[0,wLin] := fDados.Query.FieldByName('ID').AsString;
            gdPesq.Cells[1,wLin] := fDados.Query.FieldByName('DESCRICAO').AsString;
            fDados.Query.Next;
          end;
          gdPesq.RowCount := fDados.Query.RecordCount + 1;
          fDados.Query.Close;
        end;
      TPEDIDO:
        begin
          if wCampo <> '' then
            wWhere := '  WHERE ' +
                      ' UPPER(TABCLI.FANTASIA) LIKE ''%' + wCampo + '%'' OR ' +
                      ' UPPER(TABCLI.RAZSOC) LIKE ''%' + wCampo + '%''';
          fDados.Query.Close;
          fDados.Query.SQL.Clear;
          fDados.Query.SQL.Add('SELECT TABPED.ID,TABCLI.FANTASIA,TABCLI.RAZSOC ' +
                               ' FROM TABPED ' +
                               ' LEFT OUTER JOIN TABCLI ON TABCLI.ID = TABPED.CLIENTE ' + wWhere);
          fDados.Query.Open;
          wLin := 0;
          while not fDados.Query.Eof  do
          begin
            Inc(wLin);
            gdPesq.Cells[0,wLin] := fDados.Query.FieldByName('ID').AsString;
            gdPesq.Cells[1,wLin] := fDados.Query.FieldByName('FANTASIA').AsString + ' - ' +
                                    fDados.Query.FieldByName('RAZSOC').AsString;
            fDados.Query.Next;
          end;
          gdPesq.RowCount := fDados.Query.RecordCount + 1;
          fDados.Query.Close;
        end;
      TMARCA:
        begin
          if wCampo <> '' then
            wWhere := '  WHERE ' +
                      ' UPPER(DESCRICAO) LIKE ''%' + wCampo + '%''' ;
          fDados.Query.Close;
          fDados.Query.SQL.Clear;
          fDados.Query.SQL.Add('SELECT ID,DESCRICAO FROM TABMAR ' + wWhere);
          fDados.Query.Open;
          wLin := 0;
          while not fDados.Query.Eof  do
          begin
            Inc(wLin);
            gdPesq.Cells[0,wLin] := fDados.Query.FieldByName('ID').AsString;
            gdPesq.Cells[1,wLin] := fDados.Query.FieldByName('DESCRICAO').AsString;
            fDados.Query.Next;
          end;
          gdPesq.RowCount := fDados.Query.RecordCount + 1;
          fDados.Query.Close;
        end;
      else
      begin
      end;
    end;
  except
    On E: Exception do
    begin
      fDados.Query.Close;
      ShowMessage('Ocorreu o seguinte erro ao carregar os registros: ' + E.Message);
    end;
  end;
end;

procedure TfPesq.gdPesqDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfPesq.LimparGrid;
var
  wLin, wCol: integer;
begin
  try
    for wLin := 1 to gdPesq.RowCount - 1 do
      for wCol := 0 to gdPesq.ColCount - 1 do
        gdPesq.Cells[wCol, wLin] := '';
    gdPesq.RowCount := 2;
    edPesq.Clear;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao limpar os registros: ' + E.Message);
    end;
  end;
end;

procedure TfPesq.SetarDadosTela(pTelaOrigem: TTelaOrigem);
begin
  try
    gTela := pTelaOrigem;
    SetaTituloGrid;
    case pTelaOrigem of
      TCLIENTE:
        begin
          Caption := 'Pesquisar cliente';
          lbPesq.Caption := 'Nome fantasia ou Razão social:';
        end;
      TITEM:
        begin
          Caption := 'Pesquisar item';
          lbPesq.Caption := 'Descrição do item:';
        end;
      TPEDIDO:
        begin
          Caption := 'Pesquisar pedido';
          lbPesq.Caption := 'Cliente:';
        end;
      TMARCA:
        begin
          Caption := 'Pesquisar marca';
          lbPesq.Caption := 'Descrição da marca:';
        end;
      else
      begin
        Caption := 'Pesquisar cliente';
        lbPesq.Caption := 'Nome fantasia ou Razão social:';
      end;
    end;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao setar os dados da tela: ' + E.Message);
    end;
  end;
end;

procedure TfPesq.SetaTituloGrid;
begin
  try
    LimparGrid;
    case gTela of
      TCLIENTE:
        begin
          gdPesq.Cells[0,0] := 'ID';
          gdPesq.Cells[1,0] := 'Nome fantasia - Razão social';
        end;
      TITEM:
        begin
          gdPesq.Cells[0,0] := 'ID';
          gdPesq.Cells[1,0] := 'Descrição';
        end;
      TPEDIDO:
        begin
          gdPesq.Cells[0,0] := 'ID';
          gdPesq.Cells[1,0] := 'Descrição';
        end;
      TMARCA:
        begin
          gdPesq.Cells[0,0] := 'ID';
          gdPesq.Cells[1,0] := 'Descrição';
        end;
      else
      begin
        gdPesq.Cells[0,0] := 'ID';
        gdPesq.Cells[1,0] := 'Nome fantasia - Razão social';
      end;
    end;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao setar os títulos da tela: ' + E.Message);
    end;
  end;
end;

end.
