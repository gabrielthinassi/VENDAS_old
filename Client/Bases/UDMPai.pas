unit UDMPai;

interface

uses
  SysUtils, Classes, DB, DBClient, Data.DBXDataSnap, Data.DBXCommon,
  IPPeerClient, Data.SqlExpr;

type
  TDMPai = class(TDataModule)
    ConexaoDS: TSQLConnection;
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FecharTodosDataSets;
  end;

var
  DMPai: TDMPai;

implementation

{$R *.dfm}


procedure TDMPai.DataModuleDestroy(Sender: TObject);
begin
  FecharTodosDataSets;
end;

procedure TDMPai.FecharTodosDataSets;
var
  x: Integer;
begin
  for x := 0 to Self.ComponentCount - 1 do
    if ((Self.Components[x] is TClientDataSet) and
      (Self.Components[x] as TClientDataSet).Active) then
      (Self.Components[x] as TClientDataSet).Close;
end;

end.
