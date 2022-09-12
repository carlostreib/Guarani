unit frmCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfCliente = class(TForm)
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
    lbCNPJ: TLabel;
    lbEndereco: TLabel;
    lbTelefone: TLabel;
    edNome: TEdit;
    edRazSoc: TEdit;
    edCNPJ: TEdit;
    edEndereco: TEdit;
    edTelefone: TEdit;
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
    procedure edCNPJExit(Sender: TObject);
  private
    procedure SetaCampos;
    function ValidaCampos: Boolean;
    procedure LimpaCamposTela;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fCliente: TfCliente;

implementation

uses frmDados, frmPesq;

{$R *.dfm}

procedure TfCliente.btAnteriorClick(Sender: TObject);
begin
  fDados.TABCLI.Prior;
  SetaCampos;
end;

procedure TfCliente.btExcluirClick(Sender: TObject);
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
      fDados.TABCLI.Open;
      if fDados.TABCLI.Locate('ID',wID,[]) then
      begin
        fDados.TABCLI.Delete;
        fDados.Transaction.Commit;
        LimpaCamposTela;
        fDados.TABCLI.Open;
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

procedure TfCliente.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfCliente.btGravarClick(Sender: TObject);
var
  wID: Integer;
  wMsgErro: String;
begin
  // Obs: metade do código abaixo seria desnecessário caso usasse o componente ligado direto na tabela. Mas, como foi solicitado
  // para usar de forma manual, coloquei este código todo.
  wMsgErro := '';
  if not ValidaCampos then Exit;
  fDados.Transaction.Active := False;
  try
    try
      fDados.Transaction.StartTransaction;
      fDados.TABCLI.Open;
      wID := StrToIntDef(edID.Text,0);
      if fDados.TABCLI.Locate('ID',wID,[]) then
        fDados.TABCLI.Edit
      else
      begin
        wID := fDados.RetornaID('gen_tabcli_id',wMsgErro);
        if wMsgErro <> '' then
        begin
          ShowMessage(wMsgErro);
          Exit;
        end;
        fDados.TABCLI.Append;
        fDados.TABCLI.FieldByName('ID').AsInteger := wID;
      end;

      fDados.TABCLI.FieldByName('FANTASIA').AsString   := edNome.Text;
      fDados.TABCLI.FieldByName('RAZSOC').AsString     := edRazSoc.Text;
      fDados.TABCLI.FieldByName('CNPJ').AsLargeInt     := StrToInt64Def(edCNPJ.Text,0);
      fDados.TABCLI.FieldByName('ENDERECO').AsString   := edEndereco.Text;
      fDados.TABCLI.FieldByName('TELEFONE').AsLargeInt := StrToInt64Def(edTelefone.Text,0);

      fDados.TABCLI.Post;
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
    fDados.TABCLI.Open;
  end;
end;

procedure TfCliente.btNovoClick(Sender: TObject);
begin
  LimpaCamposTela;
  edNome.SetFocus;
end;

procedure TfCliente.btPesqClick(Sender: TObject);
var
  wID: Integer;
begin
  try
    try
      fPesq.SetarDadosTela(TCLIENTE);
      fPesq.ShowModal;
      if fPesq.ModalResult = mrOk then
      begin
        wID := StrToIntDef(fPesq.gdPesq.Cells[0,fPesq.gdPesq.Row],0);
        if wID > 0 then
        begin
          fDados.TABCLI.Locate('ID',wID,[]);
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

procedure TfCliente.btPrimeiroClick(Sender: TObject);
begin
  fDados.TABCLI.First;
  SetaCampos;
end;

procedure TfCliente.btProximoClick(Sender: TObject);
begin
  fDados.TABCLI.Next;
  SetaCampos;
end;

procedure TfCliente.btUltimoClick(Sender: TObject);
begin
  fDados.TABCLI.Last;
  SetaCampos;
end;

procedure TfCliente.edCNPJExit(Sender: TObject);
begin
  if edCNPJ.Text <> '' then
    btGravar.SetFocus;
end;

procedure TfCliente.FormShow(Sender: TObject);
begin
  fDados.TABCLI.Open;
end;

procedure TfCliente.LimpaCamposTela;
begin
  edID.Clear;
  edNome.Clear;
  edRazSoc.Clear;
  edCNPJ.Clear;
  edEndereco.Clear;
  edTelefone.Clear;
  fDados.TABCLI.Open;
end;

procedure TfCliente.SetaCampos;
begin
  // Observação: eu particularmente usaria os componentes que são ligados ao banco, TDBTEXT,
  // mas como no enunciado estava para fazer de forma manual, fiz assim. Funciona bem, mas tem bastante código desnecessário.
  try
    edID.Text        := fDados.TABCLI.FieldByName('ID').AsString;
    edNome.Text      := fDados.TABCLI.FieldByName('FANTASIA').AsString;
    edRazSoc.Text    := fDados.TABCLI.FieldByName('RAZSOC').AsString;
    edCNPJ.Text      := fDados.TABCLI.FieldByName('CNPJ').AsString;
    edEndereco.Text  := fDados.TABCLI.FieldByName('ENDERECO').AsString;
    edTelefone.Text  := fDados.TABCLI.FieldByName('TELEFONE').AsString;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao carregar os registros: ' + E.Message);
    end;
  end;
end;

function TfCliente.ValidaCampos: Boolean;
var
  x: Integer;
  wErro: Boolean;
  wCampo: String;
begin
  // Nesta function eu já trataria pra obrigar o telefone a ser preenchido, evitar que fosse até o banco.
  wErro := False;
  try
    try
      wCampo := edCNPJ.Text;
      for x := 1 to Length(wCampo) do
      begin
        if not (CharInSet(wCampo[x],['0'..'9'])) then
        begin
          wErro := True;
          ShowMessage('Erro ao validar os campos. Campo CNPJ deve conter apenas números!');
          Exit;
        end;
      end;

      wCampo := edTelefone.Text;
      for x := 1 to Length(wCampo) do
      begin
        if not (CharInSet(wCampo[x],['0'..'9'])) then
        begin
          wErro := True;
          ShowMessage('Erro ao validar os campos. Campo telefone deve conter apenas números!');
          Exit;
        end;
      end;

      if (edNome.Text = '') and (edRazSoc.Text = '') then
      begin
        wErro := True;
        ShowMessage('Erro ao validar os campos. Campo Nome fantasia ou Razão social deve estar preenchido!');
      end;
    except
      On E: Exception do
      begin
        fDados.Transaction.Rollback;
        ShowMessage('Ocorreu o seguinte erro ao validar o registro: ' + E.Message);
      end;
    end;
  finally
    Result := not wErro;
  end;
end;

end.
