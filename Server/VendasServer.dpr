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
  ClassStatus in '..\Class\ClassStatus.pas',
  Constantes in '..\Class\Constantes.pas',
  URegistraClassesServidoras in 'URegistraClassesServidoras.pas',
  ClassExpositorDeClasses in '..\Class\ClassExpositorDeClasses.pas',
  USMPai in 'USMPai.pas' {SMPai: TDSServerModule},
  USMPaiCadastro in 'USMPaiCadastro.pas' {SMPaiCadastro: TDSServerModule},
  USMCadStatus in 'USMCadStatus.pas' {SMCadStatus: TDSServerModule},
  ClassDataSet in '..\Class\ClassDataSet.pas',
  Duvidas in '..\Duvidas.pas',
<<<<<<< HEAD
=======
  USMConexao in 'USMConexao.pas' {SMConexao: TDSServerModule},
>>>>>>> b3f3f996bcb22b005d97f34b8589dcd32d6f1937
  Exemploes in '..\Exemploes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServidor, Servidor);
  Application.CreateForm(TSC, SC);
  Application.Run;
end.

