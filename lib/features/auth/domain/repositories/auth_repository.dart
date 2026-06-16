import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Contrato del repositorio de autenticación.
abstract class AuthRepository {
  /// Inicia sesión con username + password.
  /// Devuelve el [User] si las credenciales son válidas.
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  /// Cierra la sesión actual.
  Future<Either<Failure, void>> logout();

  /// Obtiene el usuario actualmente autenticado (si existe).
  /// Devuelve null si no hay sesión activa.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Verifica si hay una sesión activa.
  Future<bool> get isAuthenticated;
}