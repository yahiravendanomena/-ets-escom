import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/exams/data/datasources/exams_local_datasource.dart';
import 'features/exams/data/datasources/exams_local_datasource_web.dart';
import 'features/exams/data/datasources/exams_remote_datasource.dart';
import 'features/exams/data/repositories/exams_repository_impl.dart';
import 'features/exams/domain/repositories/exams_repository.dart';
import 'features/exams/domain/usecases/filter_exams_usecase.dart';
import 'features/exams/domain/usecases/get_all_exams_usecase.dart';
import 'features/exams/domain/usecases/get_favorite_exams_usecase.dart';
import 'features/exams/domain/usecases/save_favorite_exam_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================
  // FEATURE: EXAMS
  // ============================================
  sl.registerFactory(() => GetAllExamsUseCase(sl()));
  sl.registerFactory(() => FilterExamsUseCase(sl()));
  sl.registerFactory(() => SaveFavoriteExamUseCase(sl()));
  sl.registerFactory(() => GetFavoriteExamsUseCase(sl()));

  sl.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ExamsRemoteDataSource>(
    () => ExamsRemoteDataSourceMockImpl(),
  );

  sl.registerLazySingleton<ExamsLocalDataSource>(
    () => kIsWeb ? ExamsLocalDataSourceWeb() : ExamsLocalDataSourceImpl(),
  );

  // ============================================
  // FEATURE: AUTH
  // ============================================
  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => LogoutUseCase(sl()));
  sl.registerFactory(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // ============================================
  // CORE
  // ============================================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}