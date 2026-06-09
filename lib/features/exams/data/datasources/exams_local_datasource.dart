import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exam_model.dart';

/// Contrato del datasource local (SQLite + SharedPreferences).
///
/// SQLite: caché de ETS para funcionar offline.
/// SharedPreferences: IDs de favoritos del usuario.
abstract class ExamsLocalDataSource {
  /// Obtiene los ETS guardados en caché local.
  /// Throws: [CacheException] si no hay datos en caché.
  Future<List<ExamModel>> getCachedExams();

  /// Guarda una lista de ETS en caché local (sobrescribe los anteriores).
  Future<void> cacheExams(List<ExamModel> exams);

  /// Obtiene los IDs de ETS marcados como favoritos.
  Future<List<String>> getFavoriteExamIds();

  /// Agrega un ETS a favoritos.
  Future<void> addFavoriteExamId(String id);

  /// Quita un ETS de favoritos.
  Future<void> removeFavoriteExamId(String id);
}

/// Implementación con sqflite y shared_preferences.
class ExamsLocalDataSourceImpl implements ExamsLocalDataSource {
  static const String _dbName = 'ets_escom.db';
  static const String _tableName = 'exams';
  static const String _favoritesKey = 'favorite_exam_ids';
  static const int _dbVersion = 1;

  Database? _database;

  /// Obtiene la instancia de la base de datos (lazy).
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos SQLite.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            subject TEXT NOT NULL,
            career_code TEXT NOT NULL,
            semester INTEGER NOT NULL,
            date INTEGER NOT NULL,
            shift TEXT NOT NULL,
            classroom TEXT NOT NULL,
            building TEXT NOT NULL,
            professor TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<ExamModel>> getCachedExams() async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      if (maps.isEmpty) {
        throw CacheException('No hay ETS en caché local');
      }

      return maps.map((map) => ExamModel.fromSqliteMap(map)).toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Error leyendo caché: $e');
    }
  }

  @override
  Future<void> cacheExams(List<ExamModel> exams) async {
    try {
      final db = await _db;
      final batch = db.batch();

      // Limpiar caché previo.
      batch.delete(_tableName);

      // Insertar los nuevos.
      for (final exam in exams) {
        batch.insert(
          _tableName,
          exam.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Error guardando en caché: $e');
    }
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