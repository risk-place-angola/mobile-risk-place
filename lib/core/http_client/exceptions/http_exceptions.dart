/// Base exception for all HTTP-related errors
class HttpException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  HttpException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}

/// Exception for network connectivity issues
class NetworkException extends HttpException {
  NetworkException({String message = 'Sem conexão com a internet'})
      : super(message: message);
}

/// Exception for timeout errors
class TimeoutException extends HttpException {
  TimeoutException({String message = 'A requisição demorou muito tempo'})
      : super(message: message);
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends HttpException {
  UnauthorizedException({String message = 'Não autorizado'})
      : super(message: message, statusCode: 401);
}

/// Exception for forbidden access (403)
class ForbiddenException extends HttpException {
  ForbiddenException({String message = 'Acesso negado'})
      : super(message: message, statusCode: 403);
}

/// Exception for not found errors (404)
class NotFoundException extends HttpException {
  NotFoundException({String message = 'Recurso não encontrado'})
      : super(message: message, statusCode: 404);
}

/// Exception for server errors (500+)
class ServerException extends HttpException {
  ServerException({
    String message = 'Erro interno do servidor',
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

/// Exception for bad request (400)
class BadRequestException extends HttpException {
  BadRequestException({
    String message = 'Requisição inválida',
    dynamic data,
  }) : super(message: message, statusCode: 400, data: data);
}

/// Exception for validation errors (422)
class ValidationException extends HttpException {
  final Map<String, List<String>>? errors;

  ValidationException({
    String message = 'Erro de validação',
    this.errors,
    dynamic data,
  }) : super(message: message, statusCode: 422, data: data);
}
