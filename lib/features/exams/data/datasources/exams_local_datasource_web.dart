import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exam_model.dart';
import 'exams_local_datasource.dart';

/// Implementación del datasource local para Web.
///
/// En web, sqflite no está disponible. Esta implementación:
/// - Para favoritos: usa SharedPreferences (sí funciona en web).
/// - Para caché de ETS: no se persisten (siempre se pide a la API).
///
/// En móvil se usa [ExamsLocalDataSourceImpl] con SQLite real.
class ExamsLocalDataSourceWeb implements ExamsLocalDataSource {
  static const String _favoritesKey = 'favorite_exam_ids';

  @override
  Future<List<ExamModel>> getCachedExams() async {
    throw CacheException('Caché de ETS no disponible en web');
  }

  @override
  Future<void> cacheExams(List<ExamModel> exams) async {
    // En web no cacheamos los ETS, no es error.
    return;
  }

  @override
  Future<List<String>> getFavoriteExamIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      throw CacheException('Error leyendo favoritos: $e');
    }
  }

  @override
  Future<void> addFavoriteExamId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_favoritesKey) ?? [];

      if (!current.contains(id)) {
        current.add(id);
        await prefs.setStringList(_favoritesKey, current);
      }
    } catch (e) {
      throw CacheException('Error guardando favorito: $e');
    }
  }

  @override
  Future<void> removeFavoriteExamId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_favoritesKey) ?? [];
      current.remove(id);
      await prefs.setStringList(_favoritesKey, current);
    } catch (e) {
      throw CacheException('Error eliminando favorito: $e');
    }
  }
}