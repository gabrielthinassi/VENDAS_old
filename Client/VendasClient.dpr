program VendasClient;

uses
  Vcl.Forms,
  UFrmPrincipal in 'UFrmPrincipal.pas' {FrmPrincipal},
  UDMPai in 'Bases\UDMPai.pas' {DMPai: TDataModule},
  UDMPaiCadastro in 'Bases\UDMPaiCadastro.pas' {DMPaiCadastro: TDataModule},
  UPai in 'Bases\UPai.pas' {FPai},
  UPaiAssistente in 'Bases\UPaiAssistente.pas' {FPaiAssistente},
  UPaiCadastro in 'Bases\UPaiCadastro.pas' {FPaiCadastro};

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
  Application.Run;
end.
