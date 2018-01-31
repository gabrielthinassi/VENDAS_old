unit ClassExpositorDeClasses;

{
   Contém código que permite expor classes do servidor para a aplicação cliente em tempo de execução
   Criada seguindo orientações dos links:
   http://www.andreanolanusse.com/pt/registrando-datasnap-server-class-em-tempo-de-execucao-no-delphi/
   http://www.andreanolanusse.com/pt/publicando-providers-durante-o-registro-dinamico-de-datasnap-server-class/
}

interface

uses
  System.Classes,
  Datasnap.DSServer,
  Datasnap.DSCommonServer,
  Datasnap.DSReflect,
  Datasnap.DataBkr,
  DataSnap.DSProviderDataModuleAdapter;

type
  TExpositorDeClasses = class(TDSServerClass)
  private
    FClasseASerExposta: TPersistentClass;
    FNecessitaExporProviders: Boolean;
  protected
    function GetDSClass: TDSClass; override;
  public
    constructor Create(Owner                    :TComponent;
                       SevidorDataSnap          :TDSCustomServer;
                       ClasseASerExposta        :TPersistentClass;
                       NecessitaExporProviders  :Boolean;
                       CicloDeVida              :String); reintroduce; overload;
  end;

implementation

constructor TExpositorDeClasses.Create(Owner                    :TComponent;
                                       SevidorDataSnap          :TDSCustomServer;
                                       ClasseASerExposta        :TPersistentClass;
                                       NecessitaExporProviders  :Boolean;
                                       CicloDeVida              :String);
begin
  inherited
  // Criando um expositor de classes normalmente
  Create(Owner);
  // Registrando-o no servidor DataSnap
  Self.Server := SevidorDataSnap;
  // Definindo o tipo de ciclo de vida que a classe exportada terá
  Self.LifeCycle := CicloDeVida;
  // Informando qual classe será exportada
  FClasseASerExposta := ClasseASerExposta;
  // Definindo se vai expor os Providers
  FNecessitaExporProviders := NecessitaExporProviders;
  //Registrando a Classe no Servidor DS
  RegisterClass(ClasseASerExposta);
end;

function TExpositorDeClasses.GetDSClass: TDSClass;
var isAdapted: Boolean;
begin
  // Verificando se é derivado de TProviderDataModule
  isAdapted := FClasseASerExposta.InheritsFrom(TProviderDataModule);

  // Criando a classe desejada
  Result := TDSClass.Create(FClasseASerExposta, isAdapted);

  // Se quer expor TDataSetProvider e está adaptado para isto, então
  // Transmita a classe desejada expondo também os Providers
  if FNecessitaExporProviders and isAdapted then
    Result := TDSClass.Create(TDSProviderDataModuleAdapter, Result);
end;

{
Você pode utilizar a palavra reservada "reintroduce" em um método quando você deseja que o comportamento da classe pai seja mantido.
No caso do construtor, normalmente, "reintroduce" é usado para retirar warning confirmando para o compilador que você realmente deseja sobreescrever um método de uma classe pai declarada como virtual.
Vou te dar um exemplo...

Código:
  TPai = class
  public
    constructor Create(); virtual;
  end;

  TFilho = class(TPessoa)
  public
    constructor Create(); reintroduce;
  end;

Se você tentar verificar essas classes, se você retirar o "reintroduce" da classe filha você vai receber um warning de compilação: "Method 'Create' hides virtual method of base type 'TPai'"
Tanto a palavra reservada "reintroduce" como "override" são declaradas na classe filha. Outra informação interessante é que o "reintroduce" diferentemente do "override" pode ainda ser usado em métodos não virtuais e não dinâmicos.
}

end.
