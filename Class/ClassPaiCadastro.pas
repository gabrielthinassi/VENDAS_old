unit ClassPaiCadastro;

interface

uses
  Classes, DB, SysUtils, DBClient, StrUtils, Variants, FMTBcd, Controls, SqlTimSt,
  {$IF DEFINED(servidor)} SqlExpr, {$endif}
  TypInfo, Rtti, ClassPai;

type
  TClassPaiCadastro = class(TClassPai)
  public
    class function Descricao: string; virtual;
    class function TabelaPrincipal: string; virtual;

    class function ClassOriginal: string; virtual;
    class function ClassRelacional: string; virtual;

    class function CampoEmpresa: string; virtual;
    class function CampoChave: string; virtual;
    class function CampoRegistroSecundario: string; virtual;
    class function CamposFechamento: string; virtual;

    class function CampoDescricao: string; virtual;
    class function CampoStatus: string; virtual;

    class function CamposCadastro: string; virtual;
    class function SQLBaseCadastro: string; virtual; abstract;
    class function SQLBaseConsulta: string; virtual;
    class function SQLBaseRelatorio: string; overload; virtual; abstract;

    class function FiltroSql: string; virtual;
  end;

  TFClassPaiCadastro = class of TClassPaiCadastro;

function CriarClassePeloNome(const Nome: string): TClassPaiCadastro;

implementation

uses Constantes; //UDMConexao, UDMPaiCadastro;

class function TClassPaiCadastro.Descricao: string;
begin
  Result := ClassName;
end;

class function TClassPaiCadastro.TabelaPrincipal: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.ClassOriginal: string;
begin
  // Nome da classe o qual é derivada
  // ex: tabela de 'ClassPessoaCad_Cliente', a classe original é a 'ClassPessoa'
  Result := '';
end;

class function TClassPaiCadastro.ClassRelacional: string;
begin
  // Nome da classe o qual é relacionada (mestre detalhe), no caso o cliente setando o master.
  // ex: tabela de 'ClassPessoa_Endereco', a classe relacional é a 'ClassPessoa'
  Result := '';
end;

class function TClassPaiCadastro.CampoEmpresa: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CamposCadastro: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoChave: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoRegistroSecundario: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CamposFechamento: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoDescricao: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.CampoStatus: string;
begin
  Result := '';
end;

class function TClassPaiCadastro.SQLBaseConsulta: string;
begin
  Result := '';
end;


class function TClassPaiCadastro.FiltroSql: string;
begin
  Result := '';
end;

function CriarClassePeloNome(const Nome: string): TClassPaiCadastro;
var
  Classe: TFClassPaiCadastro;
  Persist: TPersistentClass;
begin
  // Cria uma classe derivada de ClassPaiCadastro, pelo nome dela
  // Isso evita que essa unit tenha referência a todas as classes
  try
    Result := nil;
    try
      Persist := FindClass(Nome);
    except
      raise Exception.Create('A classe ' + Nome + ' não está disponível nesse módulo, entre em contato com a Tek-System');
    end;
    Classe := TFClassPaiCadastro(Persist);
    Result := Classe.Create;
  finally
  end;
end;

end.

