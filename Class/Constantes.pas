unit Constantes;

interface

uses Classes, Windows, SysUtils, Graphics;

const
  // Cores
  clSucesso = clGreen;
  clFalha = clRed;
  clAmareloPedido = $00BBFFFF;
  clVlrEntrada = clNavy;
  clVlrSaida = clMaroon;
  clVlrNegativo = clRed;
  clVlrPositivo = clNavy;
  clDestaqueGrade = clBlue;
  clSomenteLeitura = $00E1E6E8; // $00D9DEE1;
  clAzulClaro = $00F2E0D9;
  clVerdeEscuro = $0084A242;
  clVerdeMedio = $00E7F3E7;
  clVerdeClaro = $00FFFFE6;
  clGradeCorFundo = clWhite; // $00F7FBF7
  clGradeCorZebrado = $00E7F3E7;
  clGradeSomenteLeitura = $00E7EBED;
  clGradeSaida = $00BFDFFF; // Alaranjado Claro
  clGradeSaidaElaboracao = $0098FF75; // Verde Claro
  clDestaqueGradeSaida = $0095CAFF; // Alaranjado um pouco mais forte

  // Usado para limitar digitos nos campos numericos
  MaxDigitos = 14;

  sTelefoneDesenvolvedor = '(32)99956-6663';
  sEmailDesenvolvedor = 'gabrielthinassi@teksystem.com.br';
  sNomeDesenvolvedor = 'Gabriel M. Thinassi';

  // CustomConstraint
  sCC_ValueIsNotNull = 'VALUE IS NOT NULL';
  sCC_ValueIsNotNullAndNotVazio = 'VALUE IS NOT NULL AND VALUE <> ''''';
  sCC_ValueIsNotNullAndNotZero = 'VALUE IS NOT NULL AND VALUE <> 0';
  sCC_ValueMasculinoFeminino = 'VALUE = ''M'' OR VALUE = ''F''';
  sCC_ValueSimNao = 'VALUE = ''S'' OR VALUE = ''N''';
  sCC_ValueAliquota = 'VALUE >= 0 AND VALUE <=100';
  sCC_ValueMaiorIgualZero = 'VALUE >= 0';
  sCC_ValueMaiorQueZero = 'VALUE > 0';
  sCC_CodigosGPS = '(VALUE = 0) OR ((VALUE >= 1000) AND (VALUE <= 9999))';
  sCC_NaturezaJuridica = '(VALUE = 0) OR ((VALUE >= 1000) AND (VALUE <= 9999))';
  sCC_CodigosRecFGTS = '(VALUE = 0) OR ((VALUE >= 100)  AND (VALUE <= 999))';
  sCC_VinculoEmpregaticio = '(VALUE = 0) OR ((VALUE >= 1)  AND (VALUE <= 99))';
  sCC_Categoria = '(VALUE = 0) OR ((VALUE >= 1)  AND (VALUE <= 99))';
  sCC_DP_ResutadoEvento = 'VALUE >= 0 AND VALUE <=2';

ResourceString

  sMascaraTelefone = '!(99)cc999-9999;1; ';
  sMascaraCep = '99999-999;1; ';
  sMascaraCnpj = '99.999.999/9999-99;1; ';
  sMascaraCei = '99.999.99999/99;1; ';
  sMascaraCpf = '999.999.999-99;1; ';
  sMascaraData = '99/99/9999;1; ';
  sMascaraDataHora = '99/99/9999 99:99;1; ';
  sMascaraDataHoraMinSeg = '99/99/9999 99:99:99;1; ';
  sMascaraHora = '!99:99;1; ';
  sMascaraHoraCentesimal = '!990:99;1; ';
  sMascaraHoraMinSeg = '!99:99:99;1; ';
  sMascaraHoraMinSeg2 = '999:99:99;1; ';
  sMascaraHoraMinSegMS = '!99:99:99,999;1; ';

  sDisplayFormatData = 'dd/mm/yyyy';
  sDisplayFormatDataHora = 'dd/mm/yyyy hh:nn';
  sDisplayFormatDataHora_HoraMinSeg = 'dd/mm/yyyy hh:nn:ss';
  sDisplayFormatHora = 'hh:nn';
  sDisplayFormatHora_HoraMinSeg = 'hh:nn:ss';
  sDisplayFormatHora_HoraMinSegMS = 'hh:nn:ss,zzz';

  // Digitacao Invalida
  sDataInvalida = 'Data inválida, verifique.';
  sDataInicialMaiorQueFinal = 'Data inicial maior que a data final, verifique.';
  sCNPJInvalido = 'Atenção C.N.P.J. inválido, verifique.';
  sCPFInvalido = 'Atenção C.P.F. inválido, verifique.';

  // Sucesso
  sSucessoEmProcesso = 'Processo executado com sucesso.';
  sProcessoTerminado = 'Processo terminado.';

  // Processos
  sMontandoRelatorio = 'Montando Relatório na Memória';
  sPreparandoSQL = 'Preparando Pesquisa ';
  sExecutandoSQL = 'Fazendo Pesquisa ';
  sAplicando = 'Procedimentos no Servidor de Aplicação';
  sPreprandoPacotes = 'Preparando Pacotes para Envio';

  // Perguntas
  sDesejaExcluir = 'Deseja excluir o registro da tabela %S?';
  sConfirmaSaida = 'Confirma a saída do sistema "%s"?';
  sConfirmaGravacao = 'Confirma gravação?';

  // Erros
  sErroNaRede = 'Ocorreu uma perda de conexão com o servidor de aplicação.' + #13 +
    'Certifique-se de que a rede está operando corretamente e tente entrar no sistema novamente.' + #13#13;
  sOcorreuErro = 'Ocorreu o seguinte erro: '#13;
  ErroServidorApl = '>> ERRO DO SERVIDOR DE APLICAÇÃO <<'#13#13;
  MensagemServidorApl = '>> MENSAGEM DO SERVIDOR DE APLICAÇÃO <<'#13#13;

  // Seguranca nos Dados
  sRegistroCadastrado = 'Registro já cadastrado por outro usuário, verifique.';
  sValorItemZerado = 'Existem itens com valor total igual a zero, favor verificar' + #13 + 'O processamento será interrompido';
  sValorDocumentoZerado = 'Valor do documento com valor igual a zero, favor verificar' + #13 + 'O processamento será interrompido';
  sRegistroSistema = 'Este cadastro é específico do Sistema e não pode ser excluído ou alterado';

  // Arquivos
  ArquivoConexoesDBX = 'ConexoesDBX.ini';

  implementation

end.
