unit uSC;

interface

uses System.SysUtils, System.Classes,
  Datasnap.DSTCPServerTransport,
  Datasnap.DSServer, Datasnap.DSCommonServer,
  IPPeerServer, IPPeerAPI, Datasnap.DSAuth, Data.DBXFirebird, Data.DB,
  Data.SqlExpr;

type
  TSC = class(TDataModule)
    DSServer: TDSServer;
    DSTCPServerTransport: TDSTCPServerTransport;
    DSServerClass: TDSServerClass;
    procedure DSServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  SC: TSC;

implementation


{$R *.dfm}

uses
  USMConexao, URegistraClassesServidoras;

procedure TSC.DataModuleCreate(Sender: TObject);
begin
  //Registrando as Classes Exportadas (Deve ser feito antes da Inicialização do Servidor)
  URegistraClassesServidoras.RegistrarClassesServidoras(Self, DSServer);
  //Iniciando Servidor
  //DSServer.Start;
end;

procedure TSC.DSServerClassGetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := USMConexao.TSMConexao;
end;

end.

