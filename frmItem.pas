unit frmItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfItem = class(TForm)
    Panel1: TPanel;
    btFechar: TBitBtn;
    btExcluir: TBitBtn;
    btGravar: TBitBtn;
    btUltimo: TBitBtn;
    btProximo: TBitBtn;
    btAnterior: TBitBtn;
    btPrimeiro: TBitBtn;
    img1: TImage;
    lbNome: TLabel;
    lbRazSoc: TLabel;
    lbDescMarca: TLabel;
    lbEndereco: TLabel;
    edDesc: TEdit;
    edMarca: TEdit;
    edPreco: TEdit;
    lbID: TLabel;
    edID: TEdit;
    btNovo: TBitBtn;
    btPesq: TBitBtn;
    btPesqMar: TBitBtn;
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
    procedure btPesqMarClick(Sender: TObject);
    procedure edPrecoExit(Sender: TObject);
    procedure edMarcaExit(Sender: TObject);
  private
    procedure SetaCampos;
    function ValidaCampos: Boolean;
    procedure LimpaCamposTela;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fItem: TfItem;

implementation

uses frmDados, frmPesq;

{$R *.dfm}

procedure TfItem.btAnteriorClick(Sender: TObject);
begin
  fDados.TABITE.Prior;
  SetaCampos;
end;

procedure TfItem.btExcluirClick(Sender: TObject);
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
      fDados.TABITE.Open;
      if fDados.TABITE.Locate('ID',wID,[]) then
      begin
        fDados.TABITE.Delete;
        fDados.Transaction.Commit;
        LimpaCamposTela;
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

procedure TfItem.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfItem.btGravarClick(Sender: TObject);
var
  wID: Integer;
  wMsgErro: String;
begin
  wMsgErro := '';
  if not ValidaCampos then Exit;
  fDados.Transaction.Active := False;
  try
    try
      fDados.Transaction.StartTransaction;
      fDados.TABITE.Open;
      wID := StrToIntDef(edID.Text,0);
      if fDados.TABITE.Locate('ID',wID,[]) then
        fDados.TABITE.Edit
      else
      begin
        wID := fDados.RetornaID('gen_TABITE_id',wMsgErro);
        if wMsgErro <> '' then
        begin
          ShowMessage(wMsgErro);
          Exit;
        end;
        fDados.TABITE.Append;
        fDados.TABITE.FieldByName('ID').AsInteger := wID;
      end;

      fDados.TABITE.FieldByName('DESCRICAO').AsString  := edDesc.Text;
      fDados.TABITE.FieldByName('MARCA').AsInteger     := StrToIntDef(edMarca.Text,0);
      fDados.TABITE.FieldByName('PRECO').AsFloat       := StrToFloatDef(edPreco.Text,0);

      fDados.TABITE.Post;
      fDados.Transaction.Commit;
      if edID.Text = '' then
        edID.Text := IntToStr(wID);
    except
      On E: Exception do
      begin
        fDados.Transaction.Rollback;
        ShowMessage('Ocorreu o seguinte erro ao tentar gravar o registro: ' + E.Message);
      end;
    end;
  finally
    fDados.Transaction.Active := True;
    fDados.TABITE.Open;
  end;
end;

procedure TfItem.btNovoClick(Sender: TObject);
begin
  LimpaCamposTela;
  edDesc.SetFocus;
end;

procedure TfItem.btPesqClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    try
      fPesq.SetarDadosTela(TITEM);
      fPesq.ShowModal;
      if fPesq.ModalResult = mrOk then
      begin
        wID := StrToIntDef(fPesq.gdPesq.Cells[0,fPesq.gdPesq.Row],0);
        if wID > 0 then
        begin
          fDados.TABITE.Locate('ID',wID,[]);
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

procedure TfItem.btPesqMarClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    try
      fPesq.SetarDadosTela(TMARCA);
      fPesq.ShowModal;
      if fPesq.ModalResult = mrOk then
      begin
        wID := StrToIntDef(fPesq.gdPesq.Cells[0,fPesq.gdPesq.Row],0);
        if wID > 0 then
        begin
          if fDados.TABMAR.Locate('ID',wID,[]) then
          begin
            edMarca.Text        := fDados.TABMAR.FieldByName('ID').AsString;
            lbDescMarca.Caption := fDados.TABMAR.FieldByName('DESCRICAO').AsString;
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

procedure TfItem.btPrimeiroClick(Sender: TObject);
begin
  fDados.TABITE.First;
  SetaCampos;
end;

procedure TfItem.btProximoClick(Sender: TObject);
begin
  fDados.TABITE.Next;
  SetaCampos;
end;

procedure TfItem.btUltimoClick(Sender: TObject);
begin
  fDados.TABITE.Last;
  SetaCampos;
end;

procedure TfItem.edMarcaExit(Sender: TObject);
var
  wCod: Integer;
begin
  try
    wCod := StrToIntDef(edMarca.Text,0);
    if wCod = 0 then Exit;
    fDados.TABMAR.Open;
    if not fDados.TABMAR.Locate('ID',wCod,[]) then
    begin
      lbDescMarca.Caption := '';
      ShowMessage('ID da marca não cadastrado.');
      Exit;
    end;
    lbDescMarca.Caption := fDados.TABMAR.FieldByName('DESCRICAO').AsString;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar a marca: ' + E.Message);
    end;
  end;
end;

procedure TfItem.edPrecoExit(Sender: TObject);
begin
  if edPreco.Text <> '' then
    btGravar.SetFocus;
end;

procedure TfItem.FormShow(Sender: TObject);
begin
  fDados.TABITE.Open;
end;

procedure TfItem.LimpaCamposTela;
begin
  edID.Clear;
  edDesc.Clear;
  edMarca.Clear;
  lbDescMarca.Caption := '';
  edPreco.Clear;
  fDados.TABITE.Open;
end;

procedure TfItem.SetaCampos;
var
  wIDMarca: Integer;
begin
  try
    edID.Text           := fDados.TABITE.FieldByName('ID').AsString;
    edDesc.Text         := fDados.TABITE.FieldByName('DESCRICAO').AsString;
    edMarca.Text        := fDados.TABITE.FieldByName('MARCA').AsString;
    edPreco.Text        := fDados.TABITE.FieldByName('PRECO').AsString;
    lbDescMarca.Caption := '';

    wIDMarca := fDados.TABITE.FieldByName('MARCA').AsInteger;
    if wIDMarca > 0  then
    begin
      fDados.TABMAR.Open;
      if fDados.TABMAR.Locate('ID',wIDMarca,[]) then
        lbDescMarca.Caption := fDados.TABMAR.FieldByName('DESCRICAO').AsString;
    end;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar os registros: ' + E.Message);
    end;
  end;
end;

function TfItem.ValidaCampos: Boolean;
var
  wErro: Boolean;
begin
  wErro := False;
  try
    try
      if (edDesc.Text = '') then
      begin
        wErro := True;
        ShowMessage('Erro ao validar os campos. Campo Descrição deve estar preenchido!');
      end;
    except
      On E: Exception do
      begin
        ShowMessage('Ocorreu o seguinte erro ao validar o registro: ' + E.Message);
      end;
    end;
  finally
    Result := not wErro;
  end;
end;

end.
