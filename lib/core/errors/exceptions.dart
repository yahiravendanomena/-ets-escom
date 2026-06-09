/// Excepciones que se lanzan en la capa de Data (datasources).
/// Estas NO suben hasta la UI; se transforman en Failures en el repositorio.
library;

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error del servidor']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Error de red']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Error de caché local']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'No encontrado']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Error de autenticación']);
}