///	<summary>
///	  Contém a classe que controla, no servidor de aplicação, o cadastro de
///	  Status.
///	</summary>
unit USMCadStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.FMTBcd, Data.DB, Data.SqlExpr, Datasnap.Provider,
  USMPaiCadastro;

type
  ///	<summary>
  ///	  Classe que controla, no servidor de aplicação, o cadastro de Status.
  ///	</summary>
  TSMCadStatus = class(TSMPaiCadastro)
  protected
    procedure DSServerModuleCreate_Filho(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses ClassStatus;

procedure TSMCadStatus.DSServerModuleCreate_Filho(Sender: TObject);
begin
  FClasseFilha := TClassStatus;
  inherited;
end;

end.
