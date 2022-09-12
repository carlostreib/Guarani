unit frmRelatorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, frxClass,
  frxDBSet, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Buttons;

type
  TfRelatorio = class(TForm)
    Report: TfrxReport;
    frxDBItens: TfrxDBDataset;
    cdsItens: TClientDataSet;
    cdsItensITEM: TStringField;
    cdsItensQuantidade: TStringField;
    lbDataIni: TLabel;
    edDataIni: TDateTimePicker;
    lbDataFim: TLabel;
    edDataFim: TDateTimePicker;
    btImprimir: TBitBtn;
    img1: TImage;
    procedure btImprimirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fRelatorio: TfRelatorio;

implementation

{$R *.dfm}

uses frmDados;

procedure TfRelatorio.btImprimirClick(Sender: TObject);
begin
  try
    cdsItens.Close;
    cdsItens.CreateDataSet;

    fDados.Query.Close;
    fDados.Query.SQL.Clear;
    fDados.Query.SQL.Add('select * from retornaped(' + QuotedStr(formatdatetime('yyyy.mm.dd',edDataIni.Date)) + ',' +
                          QuotedStr(formatdatetime('yyyy.mm.dd',edDataFim.Date)) + ')');
    fDados.Query.Open;


    while not fDados.Query.EOF do
    begin
      cdsItens.Append;
      cdsItens.FieldByName('ITEM').AsString       := fDados.Query.FieldByName('ITEM').AsString + ' ' +
                                                      fDados.Query.FieldByName('DESCITEM').AsString;
      cdsItens.FieldByName('QUANTIDADE').AsString := fDados.Query.FieldByName('QTD').AsString;
      cdsItens.Post;

      fDados.Query.Next;
    end;
    fDados.Query.Close;

    Report.LoadFromFile(ExtractFilePath(Application.ExeName) + '\ItensMaisVendidos.fr3');
    Report.PrepareReport;
    Report.ShowReport;
  except
    On E: Exception do
    begin
      ShowMessage('Ocorreu o seguinte erro ao tentar imprimir: ' + E.Message);
    end;
  end;

end;

procedure TfRelatorio.FormCreate(Sender: TObject);
begin
  edDataIni.Date := Date;
  edDataFim.Date := Date;
end;

end.
