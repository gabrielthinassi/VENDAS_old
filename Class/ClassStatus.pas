unit ClassStatus;

interface

uses Classes, DB, SysUtils, ClassPaiCadastro;

type
  TClassStatus = class(TClassPaiCadastro)
  public
    class function Descricao: string; override;
    class function TabelaPrincipal: string; override;
    class function CampoChave: string; override;
    class function CampoDescricao: string; override;

    class function CamposCadastro: string; override;
    class function SQLBaseCadastro: string; override;
    class function SQLBaseRelatorio: string; override;
    class function SQLBaseConsulta: string; override;

    class procedure ConfigurarPropriedadesDoCampo(CDS: TDataSet; Campo: string);
  end;

implementation

uses Constantes;

class function TClassStatus.Descricao: string;
begin
  Result := 'Status';
end;

class function TClassStatus.TabelaPrincipal: string;
begin
  Result := 'STATUS';
end;

class function TClassStatus.CampoChave: string;
begin
  Result := 'CODIGO_STATUS';
end;

class function TClassStatus.CampoDescricao: string;
begin
  Result := 'DESCRICAO_STATUS';
end;

class function TClassStatus.CamposCadastro: string;
begin
  Result :=
    '  STATUS.CODIGO_STATUS,' +
    '  STATUS.DESCRICAO_STATUS';
end;

class function TClassStatus.SQLBaseCadastro: string;
begin
  Result := 'select' + #13 +
            CamposCadastro + #13 +
            'from STATUS' + #13 +
            'where (STATUS.CODIGO_STATUS = :COD)';
end;

class function TClassStatus.SQLBaseConsulta: string;
begin
  Result := 'select' + #13 +
            CamposCadastro + #13 +
            'from STATUS';
end;

class function TClassStatus.SQLBaseRelatorio: string;
begin
  Result := 'select' + #13 +
            CamposCadastro + #13 +
            'from STATUS';
end;

class procedure TClassStatus.ConfigurarPropriedadesDoCampo(CDS: TDataSet; Campo: string);
begin
  inherited;
  with CDS.FieldByName(Campo) do
    if (Campo = 'CODIGO_STATUS') then
      DisplayLabel := 'Código'
    else if (Campo = 'DESCRICAO_STATUS') then
    begin
      DisplayLabel := 'Descrição do Status';
      CustomConstraint := sCC_ValueIsNotNull;
    end
end;

initialization
  //Registra a Classe para ser utilizada posteriormente com a function FindClass('TClassStatus');
  //Pode ser utilizada para criação dinâmica de formulários;
  RegisterClass(TClassStatus);

end.

