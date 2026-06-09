import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementación del repositorio de autenticación.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await localDataSource.validateCredentials(
        username: username,
        password: password,
      );

      // Si las credenciales son válidas, guardar la sesión.
      await localDataSource.saveCurrentUser(user);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    try {
      final user = await localDataSource.getCurrentUser();
      return user != null;
    } catch (_) {
      return false;
    }
  }
}