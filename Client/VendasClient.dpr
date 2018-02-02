program VendasClient;

uses
  Vcl.Forms,
  UFrmPrincipal in 'UFrmPrincipal.pas' {FrmPrincipal},
  UDMPai in 'Bases\UDMPai.pas' {DMPai: TDataModule},
  UDMPaiCadastro in 'Bases\UDMPaiCadastro.pas' {DMPaiCadastro: TDataModule},
  UPai in 'Bases\UPai.pas' {FPai},
  UPaiAssistente in 'Bases\UPaiAssistente.pas' {FPaiAssistente},
  UPaiCadastro in 'Bases\UPaiCadastro.pas' {FPaiCadastro},
  ClassDataSet in '..\Class\ClassDataSet.pas',
  ClassExpositorDeClasses in '..\Class\ClassExpositorDeClasses.pas',
  ClassPai in '..\Class\ClassPai.pas',
  ClassPaiCadastro in '..\Class\ClassPaiCadastro.pas',
  ClassStatus in '..\Class\ClassStatus.pas',
  Constantes in '..\Class\Constantes.pas',
  UDMConexao in 'Bases\UDMConexao.pas' {DMConexao: TDataModule},
  USMConexao in 'Bases\USMConexao.pas' {SMConexao: TDSServerModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDMPai, DMPai);
  Application.CreateForm(TDMPaiCadastro, DMPaiCadastro);
  Application.CreateForm(TFPai, FPai);
  Application.CreateForm(TFPaiAssistente, FPaiAssistente);
  Application.CreateForm(TFPaiCadastro, FPaiCadastro);
  Application.CreateForm(TDMConexao, DMConexao);
  Application.Run;
end.
