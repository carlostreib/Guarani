unit frmPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.Grids, Data.DB, Datasnap.DBClient,
  frxClass, frxDBSet;

type
  TfPedido = class(TForm)
    Panel1: TPanel;
    btFechar: TBitBtn;
    btExcluir: TBitBtn;
    btGravar: TBitBtn;
    btUltimo: TBitBtn;
    btProximo: TBitBtn;
    btAnterior: TBitBtn;
    btPrimeiro: TBitBtn;
    img1: TImage;
    btNovo: TBitBtn;
    Panel2: TPanel;
    lbNome: TLabel;
    lbData: TLabel;
    lbID: TLabel;
    edCliente: TEdit;
    edID: TEdit;
    btPesq: TBitBtn;
    edData: TDateTimePicker;
    lbNomeCli: TLabel;
    Panel3: TPanel;
    edIDItem: TEdit;
    btPesqItem: TBitBtn;
    edPreco: TEdit;
    lbPreco: TLabel;
    lbItem: TLabel;
    lbQtd: TLabel;
    edQtd: TEdit;
    btAddItem: TBitBtn;
    lbDescItem: TLabel;
    gdItens: TStringGrid;
    brDel: TBitBtn;
    edValPed: TEdit;
    lbValPed: TLabel;
    btPesqCli: TBitBtn;
    btImprimir: TBitBtn;
    frxDBPedido: TfrxDBDataset;
    Report: TfrxReport;
    cdsPedido: TClientDataSet;
    cdsPedidoID: TStringField;
    cdsPedidoCLIENTE: TStringField;
    cdsPedidoDATA: TStringField;
    cdsPedidoTOTALPED: TStringField;
    cdsItens: TClientDataSet;
    frxDBItens: TfrxDBDataset;
    cdsItensITEM: TStringField;
    cdsItensQuantidade: TStringField;
    cdsItensValor: TStringField;
    cdsItensMARCA: TStringField;
    procedure btPrimeiroClick(Sender: TObject);
    procedure btAnteriorClick(Sender: TObject);
    procedure btProximoClick(Sender: TObject);
    procedure btUltimoClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure btPesqClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btAddItemClick(Sender: TObject);
    procedure edIDItemExit(Sender: TObject);
    procedure btPesqItemClick(Sender: TObject);
    procedure btPesqCliClick(Sender: TObject);
    procedure edClienteExit(Sender: TObject);
    procedure btImprimirClick(Sender: TObject);
  private
    procedure SetaCampos;
    procedure SetaCamposItens;
    function ValidaCampos: Boolean;
    function ValidaCamposItens: Boolean;
    procedure LimpaCamposTela;
    procedure LimpaCamposItens(pLimparGrid: Boolean);
    procedure CalculaTotal;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPedido: TfPedido;

implementation

uses frmDados, frmPesq;

const
  COL_ID   = 0;
  COL_DESC = 1;
  COL_QTD  = 2;
  COL_VLR  = 3;

{$R *.dfm}

procedure TfPedido.btAddItemClick(Sender: TObject);
var
  wLin: Integer;
begin
  try
    if not ValidaCamposItens then
    begin
      ShowMessage('Há informações não preenchidas, portanto o item não será adicionado ao pedido.');
      Exit;
    end;

    wLin := gdItens.RowCount -1;
    if gdItens.Cells[COL_ID,wLin] <> '' then
      Inc(wLin);
    gdItens.Cells[COL_ID,wLin]   := edIDItem.Text;
    gdItens.Cells[COL_DESC,wLin] := lbDescItem.Caption;
    gdItens.Cells[COL_QTD,wLin]  := edQtd.Text;
    gdItens.Cells[COL_VLR,wLin]  := edPreco.Text;

    gdItens.RowCount := wLin + 1;

    CalculaTotal;
    LimpaCamposItens(False);
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao adicionar o item: ' + E.Message);
    end;
  end;
end;

procedure TfPedido.btAnteriorClick(Sender: TObject);
begin
  fDados.TABPED.Prior;
  SetaCampos;
end;

procedure TfPedido.btExcluirClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    wID := StrToIntDef(edID.Text,0);
    if wID = 0 then
    begin
      ShowMessage('Não há ID informado para ser excluído.');
      Exit;
    end;

    if MessageDlg('Deseja realmente excluir este registro?',mtConfirmation,mbYesNo,0) = mrYes then
    begin
      fDados.Transaction.Active := False;
      fDados.Transaction.StartTransaction;
      fDados.TABPED.Open;
      if fDados.TABPED.Locate('ID',wID,[]) then
      begin
        fDados.Query.Close;
        fDados.Query.SQL.Clear;
        fDados.Query.SQL.Add('DELETE FROM TABPEDITE WHERE IDPED = ' + IntToStr(wID));
        fDados.Query.ExecSQL;
        fDados.Query.Close;

        fDados.TABPED.Delete;
        LimpaCamposTela;
        LimpaCamposItens(True);
        fDados.Transaction.Commit;
        fDados.TABPED.Open;
        fDados.TABPEDITE.Open;

      end;
    end;
  except
    On E: Exception do
    begin
      fDados.Transaction.Rollback;
      ShowMessage('Ocorreu o seguinte erro ao excluir o registro: ' + E.Message);
    end;
  end;
end;

procedure TfPedido.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfPedido.btGravarClick(Sender: TObject);
var
  wID,x: Integer;
  wMsgErro: String;
begin
  wMsgErro := '';
  if not ValidaCampos then Exit;
  fDados.Transaction.Active := False;
  try
    try
      fDados.Transaction.StartTransaction;
      fDados.TABPED.Open;
      wID := StrToIntDef(edID.Text,0);
      if fDados.TABPED.Locate('ID',wID,[]) then
        fDados.TABPED.Edit
      else
      begin
        wID := fDados.RetornaID('gen_TABPED_id',wMsgErro);
        if wMsgErro <> '' then
        begin
          ShowMessage(wMsgErro);
          Exit;
        end;
        fDados.TABPED.Append;
        fDados.TABPED.FieldByName('ID').AsInteger := wID;
      end;

      fDados.TABPED.FieldByName('CLIENTE').AsInteger   := StrToIntDef(edCliente.Text,0);
      fDados.TABPED.FieldByName('DATA').AsDateTime     := edData.DateTime;
      fDados.TABPED.FieldByName('TOTALPED').AsFloat    := StrToFloatDef(edValPed.Text,0);
      fDados.TABPED.Post;

      if edID.Text = '' then
        edID.Text := IntToStr(wID);

      fDados.TABPEDITE.Open;
      fDados.Query.Close;
      fDados.Query.SQL.Clear;
      fDados.Query.SQL.Add('DELETE FROM TABPEDITE WHERE IDPED = ' + IntToStr(wID));
      fDados.Query.ExecSQL;

      for x := 1 to gdItens.RowCount -1  do
      begin
        fDados.TABPEDITE.Append;
        fDados.TABPEDITE.FieldByName('IDPED').AsInteger    := wID;
        fDados.TABPEDITE.FieldByName('SEQ').AsInteger      := x;
        fDados.TABPEDITE.FieldByName('IDITEM').AsInteger   := StrToIntDef(gdItens.Cells[COL_ID,x],0);
        fDados.TABPEDITE.FieldByName('QTD').AsFloat        := StrToFloatDef(gdItens.Cells[COL_QTD,x],0);
        fDados.TABPEDITE.FieldByName('VALOR').AsFloat      := StrToFloatDef(gdItens.Cells[COL_VLR,x],0);
        fDados.TABPEDITE.Post;
      end;

      fDados.Transaction.Commit;
    except
      On E: Exception do
      begin
        fDados.Transaction.Rollback;
        ShowMessage('Ocorreu o seguinte erro ao tentar gravar o registro: ' + E.Message);
      end;
    end;
  finally
    fDados.Transaction.Active := True;
    fDados.TABPED.Open;
  end;
end;

procedure TfPedido.btImprimirClick(Sender: TObject);
var
  wID: Integer;
  wNomeCli: String;
begin
  try
    if edID.Text = '' then Exit;
    wID := StrToIntDef(edID.Text,0);
    if fDados.TABPED.Locate('ID',wID,[]) then
    begin
      cdsPedido.Close;
      cdsPedido.CreateDataSet;
      cdsItens.Close;
      cdsItens.CreateDataSet;

      fDados.Query.Close;
      fDados.Query.SQL.Clear;
      fDados.Query.SQL.Add('SELECT PED.ID,PED.CLIENTE,CLI.FANTASIA,CLI.RAZSOC,PED.DATA,PED.TOTALPED ' +
                           ' FROM tabped PED ' +
                           ' LEFT OUTER JOIN TABCLI CLI ON CLI.id = PED.CLIENTE ' +
                           ' WHERE PED.ID = ' + edID.Text);
      fDados.Query.Open;

      if not fDados.Query.EOF then
      begin
        wNomeCli := fDados.Query.FieldByName('FANTASIA').AsString;
        if wNomeCli = '' then
          wNomeCli := fDados.Query.FieldByName('RAZSOC').AsString;

        cdsPedido.Append;
        cdsPedido.FieldByName('ID').AsString       := edID.Text;
        cdsPedido.FieldByName('CLIENTE').AsString  := fDados.Query.FieldByName('CLIENTE').AsString + ' ' + wNomeCli;
        cdsPedido.FieldByName('DATA').AsString     := fDados.Query.FieldByName('DATA').AsString;
        cdsPedido.FieldByName('TOTALPED').AsString := fDados.Query.FieldByName('TOTALPED').AsString;
        cdsPedido.Post;
      end;


      fDados.Query.Close;
      fDados.Query.SQL.Clear;
      fDados.Query.SQL.Add('SELECT PED.iditem,ite.descricao,PED.qtd,PED.valor,ITE.MARCA,MAR.DESCRICAO AS DESCMARCA  ' +
                           ' FROM tabpedite PED ' +
                           ' LEFT OUTER JOIN tabite ite ON ite.id = PED.iditem ' +
                           ' LEFT OUTER JOIN TABMAR MAR ON MAR.id = ITE.marca ' +
                           ' WHERE PED.IDped = ' + edID.Text);
      fDados.Query.Open;

      while not fDados.Query.EOF do
      begin
        cdsItens.Append;
        cdsItens.FieldByName('ITEM').AsString       := fDados.Query.FieldByName('IDITEM').AsString + ' ' +
                                                        fDados.Query.FieldByName('DESCRICAO').AsString;
        cdsItens.FieldByName('MARCA').AsString      := fDados.Query.FieldByName('DESCMARCA').AsString;
        cdsItens.FieldByName('QUANTIDADE').AsString := fDados.Query.FieldByName('QTD').AsString;
        cdsItens.FieldByName('VALOR').AsString      := fDados.Query.FieldByName('VALOR').AsString;
        cdsItens.Post;

        fDados.Query.Next;
      end;
      fDados.Query.Close;

      Report.LoadFromFile(ExtractFilePath(Application.ExeName) + '\RelatorioPedido.fr3');
      Report.PrepareReport;
      Report.ShowReport;
    end;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao tentar imprimir: ' + E.Message);
    end;
  end;
end;

procedure TfPedido.btNovoClick(Sender: TObject);
begin
  LimpaCamposTela;
  LimpaCamposItens(True);
  edCliente.SetFocus;
end;

procedure TfPedido.btPesqClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    try
      fPesq.SetarDadosTela(TPEDIDO);
      fPesq.ShowModal;
      if fPesq.ModalResult = mrOk then
      begin
        fDados.TABPED.Open;
        wID := StrToIntDef(fPesq.gdPesq.Cells[0,fPesq.gdPesq.Row],0);
        if wID > 0 then
        begin
          fDados.TABPED.Locate('ID',wID,[]);
          SetaCampos;
        end;
      end;
    except
      On E: Exception do
      begin
        ShowMessage('Ocorreu o seguinte erro ao pesquisar os registros: ' + E.Message);
      end;
    end;
  finally
    fPesq.Caption := '';
  end;
end;

procedure TfPedido.btPesqCliClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    try
      fPesq.SetarDadosTela(TCLIENTE);
      fPesq.ShowModal;
      if fPesq.ModalResult = mrOk then
      begin
        fDados.TABCLI.Open;
        wID := StrToIntDef(fPesq.gdPesq.Cells[0,fPesq.gdPesq.Row],0);
        if wID > 0 then
        begin
          fDados.TABCLI.Locate('ID',wID,[]);
          edCliente.Text := IntToStr(wID);
          if fDados.TABCLI.FieldByName('FANTASIA').AsString <> '' then
            lbNomeCli.Caption := fDados.TABCLI.FieldByName('FANTASIA').AsString
          else
            lbNomeCli.Caption := fDados.TABCLI.FieldByName('RAZSOC').AsString;
        end;
      end;
    except
      On E: Exception do
      begin
        ShowMessage('Ocorreu o seguinte erro ao pesquisar os registros: ' + E.Message);
      end;
    end;
  finally
    fPesq.Caption := '';
  end;
end;

procedure TfPedido.btPesqItemClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    try
      fPesq.SetarDadosTela(TITEM);
      fPesq.ShowModal;
      if fPesq.ModalResult = mrOk then
      begin
        fDados.TABITE.Open;
        wID := StrToIntDef(fPesq.gdPesq.Cells[0,fPesq.gdPesq.Row],0);
        if wID > 0 then
        begin
          if fDados.TABITE.Locate('ID',wID,[]) then
          begin
            edIDItem.Text      := fDados.TABITE.FieldByName('ID').AsString;
            edPreco.Text       := fDados.TABITE.FieldByName('PRECO').AsString;
            lbDescItem.Caption := fDados.TABITE.FieldByName('DESCRICAO').AsString;
            edQtd.SetFocus;
          end;
        end;
      end;
    except
      On E: Exception do
      begin
        ShowMessage('Ocorreu o seguinte erro ao pesquisar os registros: ' + E.Message);
      end;
    end;
  finally
    fPesq.Caption := '';
  end;
end;

procedure TfPedido.btPrimeiroClick(Sender: TObject);
begin
  fDados.TABPED.First;
  SetaCampos;
end;

procedure TfPedido.btProximoClick(Sender: TObject);
begin
  fDados.TABPED.Next;
  SetaCampos;
end;

procedure TfPedido.btUltimoClick(Sender: TObject);
begin
  fDados.TABPED.Last;
  SetaCampos;
end;

procedure TfPedido.CalculaTotal;
var
  x: Integer;
  wValTot,wVal: Double;
begin
  wValTot := 0;
  for x := 1 to gdItens.RowCount do
  begin
    wVal    := StrToFloatDef(gdItens.Cells[COL_QTD,x],0) * StrToFloatDef(gdItens.Cells[COL_VLR,x],0);
    wValTot := wValTot + wVal;
  end;
  edValPed.Text := FloatToStr(wValTot);
end;

procedure TfPedido.edClienteExit(Sender: TObject);
var
  wCod: Integer;
begin
  try
    wCod := StrToIntDef(edCliente.Text,0);
    if wCod = 0 then Exit;
    fDados.TABCLI.Open;
    lbNomeCli.Caption := '';
    if not fDados.TABCLI.Locate('ID',wCod,[]) then
    begin
      ShowMessage('ID do cliente não cadastrado.');
      Exit;
    end;
    lbNomeCli.Caption := fDados.TABCLI.FieldByName('FANTASIA').AsString;
    if lbNomeCli.Caption = '' then
      lbNomeCli.Caption := fDados.TABCLI.FieldByName('RAZSOC').AsString;
    edData.SetFocus;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar o cliente: ' + E.Message);
    end;
  end;

end;

procedure TfPedido.edIDItemExit(Sender: TObject);
var
  wCod: Integer;
begin
  try
    edPreco.Text       := '';
    lbDescItem.Caption := '';
    wCod := StrToIntDef(edIDItem.Text,0);
    if wCod = 0 then Exit;
    fDados.TABITE.Open;
    if not fDados.TABITE.Locate('ID',wCod,[]) then
    begin
      ShowMessage('ID do item não cadastrado.');
      Exit;
    end;
    edPreco.Text       := fDados.TABITE.FieldByName('PRECO').AsString;
    lbDescItem.Caption := fDados.TABITE.FieldByName('DESCRICAO').AsString;
    edQtd.SetFocus;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar o item: ' + E.Message);
    end;
  end;
end;

procedure TfPedido.FormShow(Sender: TObject);
begin
  fDados.TABPED.Open;
  gdItens.Cells[COL_ID,0] := 'ID item';
  gdItens.Cells[COL_DESC,0] := 'Descrição';
  gdItens.Cells[COL_QTD,0] := 'Quantidade';
  gdItens.Cells[COL_VLR,0] := 'Valor';
end;

procedure TfPedido.LimpaCamposItens(pLimparGrid: Boolean);
var
  wLin, wCol: integer;
begin
  edIDItem.Clear;
  edPreco.Clear;
  edQtd.Clear;
  if pLimparGrid then
  begin
    for wLin := 1 to gdItens.RowCount - 1 do
      for wCol := 0 to gdItens.ColCount - 1 do
        gdItens.Cells[wCol, wLin] := '';
    gdItens.RowCount := 2;
  end;
end;

procedure TfPedido.LimpaCamposTela;
begin
  edID.Clear;
  edCliente.Clear;
  lbNomeCli.Caption := '';
  edValPed.Clear;
  edData.Date := Date;
end;

procedure TfPedido.SetaCampos;
var
  wCliente: Integer;
begin
  try
    lbNomeCli.Caption := '';
    edID.Text         := fDados.TABPED.FieldByName('ID').AsString;
    edCliente.Text    := fDados.TABPED.FieldByName('CLIENTE').AsString;
    edValPed.Text     := fDados.TABPED.FieldByName('TOTALPED').AsString;
    if fDados.TABPED.FieldByName('DATA').AsString <> '' then
      edData.Date   := fDados.TABPED.FieldByName('DATA').AsDateTime
    else
      edData.Date := Date;

    wCliente := fDados.TABPED.FieldByName('CLIENTE').AsInteger;
    if wCliente > 0 then
    begin
      fDados.TABCLI.Open;
      if fDados.TABCLI.Locate('ID',wCliente,[]) then
      begin
        lbNomeCli.Caption := fDados.TABCLI.FieldByName('FANTASIA').AsString;
        if lbNomeCli.Caption = '' then
          lbNomeCli.Caption := fDados.TABCLI.FieldByName('RAZSOC').AsString;
      end;
    end;
    SetaCamposItens;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar os registros: ' + E.Message);
    end;
  end;
end;

procedure TfPedido.SetaCamposItens;
var
  wLin: Integer;
begin
  try
    LimpaCamposItens(True);

    fDados.Query.Close;
    fDados.Query.SQL.Clear;
    fDados.Query.SQL.Add('SELECT PED.iditem,ite.descricao,PED.qtd,PED.valor,ITE.MARCA,MAR.DESCRICAO AS DESCMARCA  ' +
                         ' FROM tabpedite PED ' +
                         ' LEFT OUTER JOIN tabite ite ON ite.id = PED.iditem ' +
                         ' LEFT OUTER JOIN TABMAR MAR ON MAR.id = ITE.marca ' +
                         ' WHERE PED.IDped = ' + edID.Text);
    fDados.Query.Open;

    wLin := 0;
    while not fDados.Query.EOF do
    begin
      Inc(wLin);
      gdItens.Cells[COL_ID,wLin]   := fDados.Query.FieldByName('IDITEM').AsString;
      gdItens.Cells[COL_DESC,wLin] := fDados.Query.FieldByName('DESCRICAO').AsString;
      gdItens.Cells[COL_QTD,wLin]  := fDados.Query.FieldByName('QTD').AsString;
      gdItens.Cells[COL_VLR,wLin]  := fDados.Query.FieldByName('VALOR').AsString;

      fDados.Query.Next;
    end;
    gdItens.RowCount := wLin + 1;
    fDados.Query.Close;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar os itens do pedido: ' + E.Message);
    end;
  end;
end;

function TfPedido.ValidaCampos: Boolean;
var
  x: Integer;
  wErro: Boolean;
  wCod: Integer;
begin
  wErro := False;
  try
    try
      wCod := StrToIntDef(edCliente.Text,0);
      if wCod = 0 then Exit;
      fDados.TABCLI.Open;
      lbNomeCli.Caption := '';
      if not fDados.TABCLI.Locate('ID',wCod,[]) then
      begin
        ShowMessage('ID do cliente não cadastrado.');
        Exit;
      end;

      for x := 1 to gdItens.RowCount - 1 do
      begin
        if gdItens.Cells[COL_ID,x] = '' then
        begin
          wErro := True;
          ShowMessage('Erro ao validar os campos. Há itens sem ID preenchido no grid!');
          Exit;
        end;
      end;

    except
      On E: Exception do
      begin
        ShowMessage('Ocorreu o seguinte erro ao validar os registros: ' + E.Message);
      end;
    end;
  finally
    Result := not wErro;
  end;
end;

function TfPedido.ValidaCamposItens: Boolean;
var
  wID: Integer;
begin
  Result := False;
  try
    if (edIDItem.Text = '') or (edQtd.Text = '') or  (edPreco.Text = '') then Exit;
    wID := StrToIntDef(edIDItem.Text,0);
    fDados.TABITE.Open;
    if not fDados.TABITE.Locate('ID',wID,[]) then
    begin
      ShowMessage('ID de item não cadastrado');
      Exit;
    end;

    Result := True;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar os registros: ' + E.Message);
    end;
  end;
end;

end.
