unit URegistraClassesServidoras;

{
 Respons�vel por expor todas as classes do servidor para a aplica��o cliente.
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
  //Lista de Units que Cont�m os Server M�dules ou Outras Classes a serem exportadas;
  USMPai, USMPaiCadastro, USMCadStatus, ClassExpositorDeClasses;



procedure RegistrarClassesServidoras(AOwner: TComponent; AServer: TDSServer);
begin
  //Assert � usado para testar, caso passe na Condi��o, ir� continuar o processamento, sen�o mostra a mensagem � frente.
  Assert(AServer.Started = false, 'N�o � poss�vel adicionar classes com o servidor ativo');

  //Lista de Classes que Ser�o Exportadas para a Aplica��o Cliente - Favor manter a Ordem Alfab�tica'}
  TExpositorDeClasses.Create(AOwner, AServer, TSMCadStatus, True, TDSLifeCycle.Session);
end;

{
O gerenciamento de mem�ria do DataSnap � definido atrav�s do componente DSServerClass e sua respectiva propriedade LifeCycle, que pode ser definida como:
Server     -> O servidor mant�m uma �nica inst�ncia da classe no server, todos os clientes ao solicitar essa classe receber�o sempre a mesma inst�ncia (Singleton)
Session    -> O servidor mant�m uma inst�ncia da classe por sess�o do DataSnap, cada cliente recebe uma inst�ncia diferente da classe (Statefull)
Invocation -> A cada execu��o de um server method uma inst�ncia da classe ser� criada e logo depois destru�da (Stateless),
voc� pode intervir no processo de cria��o e destrui��o desta classe a partir do servidor.
}
end.


