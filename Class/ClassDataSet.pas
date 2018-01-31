unit ClassDataSet;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DBClient,
  Data.DB,
  Data.SqlExpr,
  System.DateUtils,
  System.Variants,
  Data.FMTBcd,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  System.JSON.Writers,
  System.StrUtils;

type
  TFieldTek = class helper for TField
  public
    function CampoTipoData: Boolean;
    function CampoTipoFloat: Boolean;
    function CampoTipoInteiro: Boolean;
    function CampoTipoNumerico: Boolean;
    function CampoTipoString: Boolean;
    function CampoBoolean: Boolean;
  end;

  TDataSetTek = class helper for TDataSet
  private
  public
    // Verificação
    function EstaEditando: Boolean;

    // Manipulação
    procedure EditarDataSet;
    procedure PostarDataSet;

    procedure AdicionarCampos(const bVerificarSeJaExiste: Boolean = True);
    procedure RemoverCampos;

    procedure ConfigurarProviderFlags(const aChavePrimaria: array of const);
  end;

  TSQLDataSetSetTek = class helper for TSQLDataSet
  public
  end;

  TClientDataSetTek = class helper for TClientDataSet
  private
  public
    // Manipulação da estrutura
    procedure RemoverCampos; overload;

    procedure CriarCampoFloat(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer); deprecated;
    procedure CriarCampoCurrency(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
    procedure CriarCampoFmtBCD(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
    procedure CriarCampoData(const sFieldName, sDisplayLabel: string; const iTag: Integer);
    procedure CriarCampoDataHora(const sFieldName, sDisplayLabel: string; const iTag: Integer);
    procedure CriarCampoInteiro(const sFieldName, sDisplayLabel: string; const iTag: Integer);
    procedure CriarCampoString(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
    procedure CriarCampoMemo(const sFieldName, sDisplayLabel: string; const iTag: Integer);
  end;

  TFuncoesClientDataSet = class
  public
  end;

implementation

uses Constantes;

{$region 'TFieldTek'}

function TFieldTek.CampoTipoData: Boolean;
begin
  Result := (DataType in [ftDate, ftDateTime, ftTimeStamp]);
end;

function TFieldTek.CampoTipoFloat: Boolean;
begin
  Result := (DataType in [ftExtended, ftFloat, ftCurrency, ftBCD, ftFMTBcd]);
end;

function TFieldTek.CampoTipoInteiro: Boolean;
begin
  Result := (DataType in [ftSmallint, ftInteger, ftLargeint, ftAutoInc, ftShortint, ftLongWord, ftWord]);
end;

function TFieldTek.CampoTipoNumerico: Boolean;
begin
  Result := CampoTipoInteiro or CampoTipoFloat;
end;

function TFieldTek.CampoTipoString: Boolean;
begin
  Result := (DataType in [ftString, ftWideString, ftMemo, ftWideMemo, ftFixedWideChar, ftFmtMemo]);
end;

function TFieldTek.CampoBoolean: Boolean;
begin
  Result := (CustomConstraint = sCC_ValueSimNao);
end;

{$endregion}

{$region 'TDataSetTek'}

function TDataSetTek.EstaEditando: Boolean;
begin
  Result := (State in [dsInsert, dsEdit]);
end;

procedure TDataSetTek.EditarDataSet;
begin
  if not Active then
    Exit;

  if not(State in [dsInsert, dsEdit]) then
    Edit;
end;

procedure TDataSetTek.PostarDataSet;
begin
  if (State in [dsInsert, dsEdit]) then
    Post;
end;

procedure TDataSetTek.AdicionarCampos(const bVerificarSeJaExiste: Boolean = True);
var
  X: Integer;
begin
  // Atualizando os tipos dos TFields, conforme tipos dos campos definidos no banco de dados
  Active := False;
  FieldDefs.Update;

  // Criar os TFields inserindo-os no DataSet.
  for X := 0 to FieldDefs.Count - 1 do
    if (not bVerificarSeJaExiste) or (FindField(FieldDefs[x].Name) = nil) then
      FieldDefs.Items[X].CreateField(Self);
end;

procedure TDataSetTek.RemoverCampos;
begin
  Close;
  if (FieldCount > 0) then
    Fields.Clear;
  if (FieldDefs.Count > 0) then
    FieldDefs.Clear;
end;

procedure TDataSetTek.ConfigurarProviderFlags(const aChavePrimaria: array of const);
var
  x, Y: integer;
begin
  for x := 0 to FieldDefList.Count - 1 do
  begin
    // Para todos os campos
    Fields[x].ProviderFlags := [pfInUpdate];
    Fields[x].Required := False;

    // Para as Chaves Primárias
    for Y := Low(aChavePrimaria) to High(aChavePrimaria) do
      if (AnsiUpperCase(FieldDefList[x].Name) = AnsiUpperCase(aChavePrimaria[Y].{$IFDEF VER185} VPChar {$ELSE} VPWideChar {$endif})) then
      begin
        Fields[x].ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
        Break;
      end;
  end;
end;

{$endregion}

{$region 'TClientDataSetTek'}

procedure TClientDataSetTek.CriarCampoFmtBCD(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TFMTBCDField.Create(Self);
  with TFMTBCDField(Campo) do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Precision := 15;
    Size := iTamanho;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoFloat(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TFloatField.Create(Self);
  with TFloatField(Campo) do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Precision := iTamanho;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoCurrency(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TCurrencyField.Create(Self);
  with TCurrencyField(Campo) do
  begin
    DisplayLabel := sDisplayLabel;
    Currency := False;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Precision := iTamanho;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoData(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TDateField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoDataHora(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TDateTimeField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoInteiro(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TIntegerField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoString(const sFieldName, sDisplayLabel: string; const iTamanho, iTag: Integer);
var
  Campo: TField;
begin
  Campo := TStringField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Size := iTamanho;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.CriarCampoMemo(const sFieldName, sDisplayLabel: string; const iTag: Integer);
var
  Campo: TField;
begin
  Campo := TMemoField.Create(Self);
  with Campo do
  begin
    DisplayLabel := sDisplayLabel;
    Name := sFieldName;
    FieldName := sFieldName;
    FieldKind := fkData;
    Index := Self.FieldCount;
    DataSet := Self;
    Required := False;
    Tag := iTag;
  end;
end;

procedure TClientDataSetTek.RemoverCampos;
begin
  Close;
  if (FieldCount > 0) then
    Fields.Clear;
  if (FieldDefs.Count > 0) then
    FieldDefs.Clear;
end;

{$endregion}

end.
