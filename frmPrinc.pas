unit frmPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

type
  TfPrinc = class(TForm)
    fmenu: TMainMenu;
    Cadastro1: TMenuItem;
    Cliente1: TMenuItem;
    Item1: TMenuItem;
    Lanamento1: TMenuItem;
    Pedido1: TMenuItem;
    Fechar1: TMenuItem;
    Image1: TImage;
    Marca1: TMenuItem;
    Relatrio1: TMenuItem;
    procedure Cliente1Click(Sender: TObject);
    procedure Item1Click(Sender: TObject);
    procedure Marca1Click(Sender: TObject);
    procedure Pedido1Click(Sender: TObject);
    procedure Fechar1Click(Sender: TObject);
    procedure Relatrio1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPrinc: TfPrinc;


implementation

{$R *.dfm}

uses frmDados,frmItem, frmMarca,frmCliente,frmPedido,frmRelatorio;


procedure TfPrinc.Cliente1Click(Sender: TObject);
begin
  try
    frmCliente.fCliente.ShowModal;
  except

  end;
end;

procedure TfPrinc.Fechar1Click(Sender: TObject);
begin
  Close;
end;

procedure TfPrinc.Item1Click(Sender: TObject);
begin
  try
    frmItem.fItem.ShowModal;
  except

  end;
end;

procedure TfPrinc.Marca1Click(Sender: TObject);
begin
  try
    frmMarca.fmarca.ShowModal;
  except

  end;
end;

procedure TfPrinc.Pedido1Click(Sender: TObject);
begin
  try
    frmPedido.fPedido.ShowModal;
  except

  end;
end;

procedure TfPrinc.Relatrio1Click(Sender: TObject);
begin
  try
    frmRelatorio.fRelatorio.ShowModal;
  except

  end;
end;

end.
