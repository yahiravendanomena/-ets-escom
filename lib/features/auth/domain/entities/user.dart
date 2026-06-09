import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un usuario administrador.
///
/// Clase pura: no depende de Flutter ni de la API.
class User extends Equatable {
  /// Identificador único.
  final String id;

  /// Nombre de usuario para iniciar sesión.
  final String username;

  /// Nombre completo del administrador.
  final String fullName;

  /// Correo institucional (opcional).
  final String? email;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
  });

  @override
  List<Object?> get props => [id, username, fullName, email];
}