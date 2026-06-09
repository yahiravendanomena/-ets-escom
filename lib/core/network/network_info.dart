import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Contrato para verificar el estado de la conexión a internet.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación que verifica conectividad real haciendo una petición DNS.
///
/// En web siempre devuelve true (asumimos que si la app cargó, hay internet).
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    if (kIsWeb) {
      return true;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}