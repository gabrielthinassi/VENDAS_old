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
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Servidor: TServidor;

implementation

{$R *.dfm}

uses uSC, USMPaiCadastro, Constantes;

procedure TServidor.btnStartClick(Sender: TObject);
begin
  SC.DSTCPServerTransport.Port := StrToInt(edtServerPort.Text);
  //Não estou conseguindo Configurar o SMPaiCadastro.Conexao (ver com o pessoal)
  SC.DSServer.Start;

  if SC.DSServer.Started then
  begin
    lblStatusServidor.Font.Color := clSucesso;
    lblStatusServidor.Caption := 'Servidor Iniciado!';
  end
  else
  begin
    ShowMessage('Houve algum problema ao Iniciar!');
  end;
end;

procedure TServidor.btnStopClick(Sender: TObject);
begin
  SC.DSServer.Stop;
  if not SC.DSServer.Started then
  begin
    lblStatusServidor.Font.Color := clFalha;
    lblStatusServidor.Caption := 'Servidor Parado!';
  end
  else
  begin
    ShowMessage('Houve algum problema ao Parar!');
  end;
end;

procedure TServidor.edtDiretorioBDButtonClick(Sender: TObject);
begin
  dlgDiretorioBD.Execute();
  if dlgDiretorioBD.FileName = '' then
    Application.MessageBox('Selecione um Arquivo!','Atenção!',MB_OK);
  edtDiretorioBD.Text := dlgDiretorioBD.FileName;
end;

end.

