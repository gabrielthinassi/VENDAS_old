unit URegistraClassesServidoras;

{
 Responsável por expor todas as classes do servidor para a aplicação cliente.
 Essa unit deve crescer bastante, pois para exportar algo deve-se adicionar a
 unit desejada e registrar o nome da classe a ser exportada.
}

interface

uses
  System.Classes,
  Datasnap.DSServer,
  Datasnap.DSNames,
  DSCommonServer;

  procedure RegistrarClassesServidoras(AOwner: TComponent; AServer: TDSServer);

implementation

uses
  //Lista de Units que Contém os Server Módules ou Outras Classes a serem exportadas;
  USMPai, USMPaiCadastro, USMCadStatus, ClassExpositorDeClasses;



procedure RegistrarClassesServidoras(AOwner: TComponent; AServer: TDSServer);
begin
  //Assert é usado para testar, caso passe na Condição, irá continuar o processamento, senão mostra a mensagem à frente.
  Assert(AServer.Started = false, 'Não é possível adicionar classes com o servidor ativo');

  //Lista de Classes que Serão Exportadas para a Aplicação Cliente - Favor manter a Ordem Alfabética'}
  TExpositorDeClasses.Create(AOwner, AServer, TSMCadStatus, True, TDSLifeCycle.Session);
end;

{
O gerenciamento de memória do DataSnap é definido através do componente DSServerClass e sua respectiva propriedade LifeCycle, que pode ser definida como:
Server     -> O servidor mantém uma única instância da classe no server, todos os clientes ao solicitar essa classe receberão sempre a mesma instância (Singleton)
Session    -> O servidor mantém uma instância da classe por sessão do DataSnap, cada cliente recebe uma instância diferente da classe (Statefull)
Invocation -> A cada execução de um server method uma instância da classe será criada e logo depois destruída (Stateless),
você pode intervir no processo de criação e destruição desta classe a partir do servidor.
}
end.


