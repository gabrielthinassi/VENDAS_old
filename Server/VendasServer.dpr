program VendasServer;

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  uFrmServidor in 'uFrmServidor.pas' {Servidor},
  uSC in 'uSC.pas' {SC: TDataModule},
  uSM in 'uSM.pas' {SM: TDSServerModule},
  ClassPai in '..\Class\ClassPai.pas',
  ClassPaiCadastro in '..\Class\ClassPaiCadastro.pas',
  ClassStatus in '..\Class\ClassStatus.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServidor, Servidor);
  Application.CreateForm(TSC, SC);
  Application.Run;
end.

