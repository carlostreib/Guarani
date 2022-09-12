unit frmMarca;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfMarca = class(TForm)
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
    edDesc: TEdit;
    lbID: TLabel;
    edID: TEdit;
    btNovo: TBitBtn;
    btPesq: TBitBtn;
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
    procedure edDescExit(Sender: TObject);
  private
    procedure SetaCampos;
    function ValidaCampos: Boolean;
    procedure LimpaCamposTela;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMarca: TfMarca;

implementation

uses frmDados, frmPesq;

{$R *.dfm}

procedure TfMarca.btAnteriorClick(Sender: TObject);
begin
  fDados.TABMAR.Prior;
  SetaCampos;
end;

procedure TfMarca.btExcluirClick(Sender: TObject);
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

    // Eu faria um tratamento para criar uma rotina que substituísse o messageDLG para usar em português
    if MessageDlg('Deseja realmente excluir este registro?',mtConfirmation,mbYesNo,0) = mrYes then
    begin
      fDados.Transaction.Active := False;
      fDados.Transaction.StartTransaction;
      fDados.TABMAR.Open;
      if fDados.TABMAR.Locate('ID',wID,[]) then
      begin
        fDados.TABMAR.Delete;
        fDados.Transaction.Commit;
        LimpaCamposTela;
        fDados.TABMAR.Open;
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

procedure TfMarca.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfMarca.btGravarClick(Sender: TObject);
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
      fDados.TABMAR.Open;
      wID := StrToIntDef(edID.Text,0);
      if fDados.TABMAR.Locate('ID',wID,[]) then
        fDados.TABMAR.Edit
      else
      begin
        wID := fDados.RetornaID('gen_TABMAR_id',wMsgErro);
        if wMsgErro <> '' then
        begin
          ShowMessage(wMsgErro);
          Exit;
        end;
        fDados.TABMAR.Append;
        fDados.TABMAR.FieldByName('ID').AsInteger := wID;
      end;

      fDados.TABMAR.FieldByName('DESCRICAO').AsString   := edDesc.Text;

      fDados.TABMAR.Post;
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
    fDados.TABMAR.Open;
  end;
end;

procedure TfMarca.btNovoClick(Sender: TObject);
begin
  LimpaCamposTela;
  edDesc.SetFocus;
end;

procedure TfMarca.btPesqClick(Sender: TObject);
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
          fDados.TABMAR.Locate('ID',wID,[]);
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

procedure TfMarca.btPrimeiroClick(Sender: TObject);
begin
  fDados.TABMAR.First;
  SetaCampos;
end;

procedure TfMarca.btProximoClick(Sender: TObject);
begin
  fDados.TABMAR.Next;
  SetaCampos;
end;

procedure TfMarca.btUltimoClick(Sender: TObject);
begin
  fDados.TABMAR.Last;
  SetaCampos;
end;

procedure TfMarca.edDescExit(Sender: TObject);
begin
  if edDesc.Text <> '' then
    btGravar.SetFocus;
end;

procedure TfMarca.FormShow(Sender: TObject);
begin
  fDados.TABMAR.Open;
end;

procedure TfMarca.LimpaCamposTela;
begin
  edID.Clear;
  edDesc.Clear;
  fDados.TABMAR.Open;
end;

procedure TfMarca.SetaCampos;
begin
  try
    edID.Text        := fDados.TABMAR.FieldByName('ID').AsString;
    edDesc.Text      := fDados.TABMAR.FieldByName('DESCRICAO').AsString;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar os registros: ' + E.Message);
    end;
  end;
end;

function TfMarca.ValidaCampos: Boolean;
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
