import 'package:equatable/equatable.dart';

/// Clase base abstracta para representar errores en la capa de Dominio.
///
/// Las capas de UI NO trabajan con Exceptions directamente; trabajan con
/// Failures. Esto permite manejar los errores como datos, no como excepciones.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error del servidor (HTTP 500, errores remotos, etc).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor']);
}

/// Error de red (sin conexión, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Error del caché local (SQLite, SharedPreferences).
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error en el caché local']);
}

/// Recurso no encontrado (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Error de validación de entradas.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error de autenticación (credenciales inválidas, sesión expirada).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}