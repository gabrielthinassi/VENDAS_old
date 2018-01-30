unit uFrmServidor;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, JvExMask, JvToolEdit, JvBaseEdits,
  Vcl.Buttons;

type
  TServidor = class(TForm)
    lblBDHost: TLabel;
    lblBDPort: TLabel;
    edtHostBD: TEdit;
    edtPortBD: TEdit;
    lblStatusServidor: TLabel;
    lblServerPort: TLabel;
    edtServerPort: TEdit;
    lblDiretorioBD: TLabel;
    dlgDiretorioBD: TOpenDialog;
    edtDiretorioBD: TJvComboEdit;
    btnStart: TSpeedButton;
    btnStop: TSpeedButton;
    procedure edtDiretorioBDButtonClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Servidor: TServidor;

implementation

{$R *.dfm}

uses uSC, USMPaiCadastro;

procedure TServidor.btnStartClick(Sender: TObject);
begin
  SC.DSTCPServerTransport.Port := edtServerPort.Text;
  //SMPaiCadastro.Conexao.Add
end;

procedure TServidor.edtDiretorioBDButtonClick(Sender: TObject);
begin
  dlgDiretorioBD.Execute();
  if dlgDiretorioBD.FileName = '' then
    Application.MessageBox('Selecione um Arquivo!','Atenção!',MB_OK);
  edtDiretorioBD.Text := dlgDiretorioBD.FileName;
end;

end.

