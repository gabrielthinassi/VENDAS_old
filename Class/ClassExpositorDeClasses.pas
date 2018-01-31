unit ClassExpositorDeClasses;

{
   Cont�m c�digo que permite expor classes do servidor para a aplica��o cliente em tempo de execu��o
   Criada seguindo orienta��es dos links:
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
  // Definindo o tipo de ciclo de vida que a classe exportada ter�
  Self.LifeCycle := CicloDeVida;
  // Informando qual classe ser� exportada
  FClasseASerExposta := ClasseASerExposta;
  // Definindo se vai expor os Providers
  FNecessitaExporProviders := NecessitaExporProviders;
  //Registrando a Classe no Servidor DS
  RegisterClass(ClasseASerExposta);
end;

function TExpositorDeClasses.GetDSClass: TDSClass;
var isAdapted: Boolean;
begin
  // Verificando se � derivado de TProviderDataModule
  isAdapted := FClasseASerExposta.InheritsFrom(TProviderDataModule);

  // Criando a classe desejada
  Result := TDSClass.Create(FClasseASerExposta, isAdapted);

  // Se quer expor TDataSetProvider e est� adaptado para isto, ent�o
  // Transmita a classe desejada expondo tamb�m os Providers
  if FNecessitaExporProviders and isAdapted then
    Result := TDSClass.Create(TDSProviderDataModuleAdapter, Result);
end;

{
Voc� pode utilizar a palavra reservada "reintroduce" em um m�todo quando voc� deseja que o comportamento da classe pai seja mantido.
No caso do construtor, normalmente, "reintroduce" � usado para retirar warning confirmando para o compilador que voc� realmente deseja sobreescrever um m�todo de uma classe pai declarada como virtual.
Vou te dar um exemplo...

C�digo:
  TPai = class
  public
    constructor Create(); virtual;
  end;

  TFilho = class(TPessoa)
  public
    constructor Create(); reintroduce;
  end;

Se voc� tentar verificar essas classes, se voc� retirar o "reintroduce" da classe filha voc� vai receber um warning de compila��o: "Method 'Create' hides virtual method of base type 'TPai'"
Tanto a palavra reservada "reintroduce" como "override" s�o declaradas na classe filha. Outra informa��o interessante � que o "reintroduce" diferentemente do "override" pode ainda ser usado em m�todos n�o virtuais e n�o din�micos.
}

end.
