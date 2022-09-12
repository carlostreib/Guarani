program Guarani;

uses
  Vcl.Forms,
  frmPrinc in 'frmPrinc.pas' {fPrinc},
  frmDados in 'frmDados.pas' {fDados: TDataModule},
  frmPesq in 'frmPesq.pas' {fPesq},
  frmItem in 'frmItem.pas' {fItem},
  frmMarca in 'frmMarca.pas' {fMarca},
  frmPedido in 'frmPedido.pas' {fPedido},
  frmCliente in 'frmCliente.pas' {fCliente},
  frmRelatorio in 'frmRelatorio.pas' {fRelatorio};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrinc, fPrinc);
  Application.CreateForm(TfItem, fItem);
  Application.CreateForm(TfDados, fDados);
  Application.CreateForm(TfPesq, fPesq);
  Application.CreateForm(TfMarca, fMarca);
  Application.CreateForm(TfPedido, fPedido);
  Application.CreateForm(TfCliente, fCliente);
  Application.CreateForm(TfRelatorio, fRelatorio);
  Application.Run;
end.
