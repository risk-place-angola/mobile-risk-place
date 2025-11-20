import 'dart:io';

String getMessageForStatusCode(int statusCode) {
  Map<int, String> statusMessages = {
    HttpStatus.ok: 'Requisição bem-sucedida.',
    HttpStatus.created: 'Recurso criado com sucesso.',
    HttpStatus.accepted: 'Requisição aceita, mas não processada ainda.',
    HttpStatus.noContent: 'Requisição processada, mas sem conteúdo.',
    HttpStatus.badRequest:
        'Requisição malformada. Verifique os dados enviados.',
    HttpStatus.unauthorized: 'Dados incorretos',
    HttpStatus.forbidden: 'Acesso proibido. Você não tem permissão.',
    HttpStatus.notFound: 'Recurso não encontrado.',
    HttpStatus.methodNotAllowed: 'Método não permitido para este recurso.',
    HttpStatus.conflict:
        'Conflito de dados. Não foi possível concluir a operação.',
    HttpStatus.internalServerError:
        'Erro interno no servidor. Tente novamente mais tarde.',
    HttpStatus.notImplemented: 'Método não implementado.',
    HttpStatus.serviceUnavailable:
        'Serviço temporariamente indisponível. Tente novamente mais tarde.',
  };

  return statusMessages[statusCode] ?? 'Erro desconhecido. Tente novamente.';
}
