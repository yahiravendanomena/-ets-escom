import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> validateCredentials({
    required String username,
    required String password,
  });
  Future<void> saveCurrentUser(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _currentUserKey = 'current_user';
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Lista de admins autorizados.
  ///
  /// Las contraseñas se almacenan como hash SHA-256.
  /// Al validar, también se hashea el input antes de comparar.
  static final List<_AdminCredential> _admins = [
    _AdminCredential(
      id: 'adm-001',
      username: 'admin',
      plainPassword: 'Admin123!',
      fullName: 'Administrador General',
      email: 'admin@escom.ipn.mx',
    ),
    _AdminCredential(
      id: 'adm-002',
      username: 'escom',
      plainPassword: 'Escom2026',
      fullName: 'Coordinación ESCOM',
      email: 'coordinacion@escom.ipn.mx',
    ),
  ];

  /// Calcula el hash SHA-256 de una cadena (encriptación de contraseñas).
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> validateCredentials({
    required String username,
    required String password,
  }) async {
    // Simula latencia de servidor.
    await Future.delayed(const Duration(milliseconds: 600));

    final inputHash = _hashPassword(password);

    try {
      final admin = _admins.firstWhere(
        (a) =>
            a.username.toLowerCase() == username.toLowerCase() &&
            _hashPassword(a.plainPassword) == inputHash,
      );

      return UserModel(
        id: admin.id,
        username: admin.username,
        fullName: admin.fullName,
        email: admin.email,
      );
    } catch (_) {
      throw AuthException('Usuario o contraseña incorrectos');
    }
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    try {
      await _secureStorage.write(
        key: _currentUserKey,
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Error guardando sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final jsonString = await _secureStorage.read(key: _currentUserKey);
      if (jsonString == null) return null;
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null; // En web puede fallar, no es crítico.
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _currentUserKey);
    } catch (e) {
      throw CacheException('Error cerrando sesión: $e');
    }
  }
}

class _AdminCredential {
  final String id;
  final String username;
  final String plainPassword;
  final String fullName;
  final String email;

  _AdminCredential({
    required this.id,
    required this.username,
    required this.plainPassword,
    required this.fullName,
    required this.email,
  });
}