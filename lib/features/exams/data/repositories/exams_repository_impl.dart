import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/exam.dart';
import '../../domain/repositories/exams_repository.dart';
import '../datasources/exams_local_datasource.dart';
import '../datasources/exams_remote_datasource.dart';
/// Implementación del repositorio de ETS.
///
/// Aplica la estrategia OFFLINE-FIRST:
/// 1. Si hay internet → pide a la API y actualiza caché local.
/// 2. Si NO hay internet → usa la caché local.
/// 3. Si NO hay internet NI caché → devuelve error.
class ExamsRepositoryImpl implements ExamsRepository {
  final ExamsRemoteDataSource remoteDataSource;
  final ExamsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ExamsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Exam>>> getAllExams() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteExams = await remoteDataSource.getAllExams();

        // Intenta cachear. Si falla (ej. en web), no es crítico.
        try {
          await localDataSource.cacheExams(remoteExams);
        } catch (_) {
          // Caché no disponible (ej. plataforma web).
        }

        return Right(remoteExams);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error inesperado: $e'));
      }
    } else {
      // Sin internet: usar caché.
      try {
        final cachedExams = await localDataSource.getCachedExams();
        return Right(cachedExams);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Exam>> getExamById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final exam = await remoteDataSource.getExamById(id);
        return Right(exam);
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Error inesperado: $e'));
      }
    } else {
      // Sin internet: buscar en caché.
      try {
        final cached = await localDataSource.getCachedExams();
        final exam = cached.firstWhere(
          (e) => e.id == id,
          orElse: () => throw const NotFoundFailure(),
        );
        return Right(exam);
      } on NotFoundFailure catch (f) {
        return Left(f);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Exam>>> filterExams({
    String? careerCode,
    int? semester,
    String? subjectQuery,
  }) async {
    // Reutilizamos getAllExams y filtramos en memoria.
    // Para datasets grandes, sería mejor filtrar en el servidor o SQL.
    final result = await getAllExams();

    return result.fold(
      (failure) => Left(failure),
      (exams) {
        var filtered = exams;

        if (careerCode != null && careerCode.isNotEmpty) {
          filtered =
              filtered.where((e) => e.careerCode == careerCode).toList();
        }

        if (semester != null) {
          filtered = filtered.where((e) => e.semester == semester).toList();
        }

        if (subjectQuery != null && subjectQuery.isNotEmpty) {
          final query = subjectQuery.toLowerCase();
          filtered = filtered
              .where((e) => e.subject.toLowerCase().contains(query))
              .toList();
        }

        return Right(filtered);
      },
    );
  }

  @override
  Future<Either<Failure, void>> saveFavoriteExam(String examId) async {
    try {
      await localDataSource.addFavoriteExamId(examId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavoriteExam(String examId) async {
    try {
      await localDataSource.removeFavoriteExamId(examId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteExamIds() async {
    try {
      final ids = await localDataSource.getFavoriteExamIds();
      return Right(ids);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}