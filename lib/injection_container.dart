import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'core/network/network_info.dart';
import 'features/exams/data/datasources/exams_local_datasource.dart';
import 'features/exams/data/datasources/exams_local_datasource_web.dart';
import 'features/exams/data/datasources/exams_remote_datasource.dart';
import 'features/exams/data/repositories/exams_repository_impl.dart';
import 'features/exams/domain/repositories/exams_repository.dart';
import 'features/exams/domain/usecases/filter_exams_usecase.dart';
import 'features/exams/domain/usecases/get_all_exams_usecase.dart';
import 'features/exams/domain/usecases/get_favorite_exams_usecase.dart';
import 'features/exams/domain/usecases/save_favorite_exam_usecase.dart';

/// Service Locator global para inyección de dependencias.
final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación.
Future<void> initDependencies() async {
  // ============================================
  // FEATURE: EXAMS
  // ============================================

  // Use cases
  sl.registerFactory(() => GetAllExamsUseCase(sl()));
  sl.registerFactory(() => FilterExamsUseCase(sl()));
  sl.registerFactory(() => SaveFavoriteExamUseCase(sl()));
  sl.registerFactory(() => GetFavoriteExamsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Remote data source
  sl.registerLazySingleton<ExamsRemoteDataSource>(
    () => ExamsRemoteDataSourceMockImpl(),
  );

  // Local data source: web usa SharedPreferences, móvil usa SQLite.
  sl.registerLazySingleton<ExamsLocalDataSource>(
    () => kIsWeb
        ? ExamsLocalDataSourceWeb()
        : ExamsLocalDataSourceImpl(),
  );

  // ============================================
  // CORE
  // ============================================

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}