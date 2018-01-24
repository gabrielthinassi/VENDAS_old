unit uFrmServidor;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, JvExMask, JvToolEdit, JvBaseEdits;

type
  TServidor = class(TForm)
    lblBDHost: TLabel;
    lblBDPort: TLabel;
    edtHost: TEdit;
    edtPort: TEdit;
    lblStatusServidor: TLabel;
    lblServerPort: TLabel;
    Edit1: TEdit;
    lblDiretorioBD: TLabel;
    dlgDiretorioBD: TOpenDialog;
    edtDiretorioBD: TJvComboEdit;
    procedure edtDiretorioBDButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Servidor: TServidor;

implementation

{$R *.dfm}

procedure TServidor.edtDiretorioBDButtonClick(Sender: TObject);
begin
  dlgDiretorioBD.Execute();
  if dlgDiretorioBD.FileName = '' then
    Application.MessageBox('Selecione um Arquivo!','Atenção!',MB_OK);
  edtDiretorioBD.Text := dlgDiretorioBD.FileName;
end;

end.

