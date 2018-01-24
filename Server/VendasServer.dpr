program VendasServer;

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  uFrmServidor in 'uFrmServidor.pas' {Servidor},
  uSC in 'uSC.pas' {SC: TDataModule},
  uSM in 'uSM.pas' {SM: TDSServerModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServidor, Servidor);
  Application.CreateForm(TSC, SC);
  Application.Run;
end.

