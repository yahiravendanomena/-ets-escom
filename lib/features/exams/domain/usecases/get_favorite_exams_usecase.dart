import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exam.dart';
import '../repositories/exams_repository.dart';

/// Caso de uso: obtener los ETS marcados como favoritos por el usuario.
///
/// Cruza los IDs guardados localmente con la lista completa de ETS
/// para devolver las entidades completas.
class GetFavoriteExamsUseCase implements UseCase<List<Exam>, NoParams> {
  final ExamsRepository repository;

  GetFavoriteExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(NoParams params) async {
    // 1. Obtener IDs de favoritos guardados localmente.
    final favoriteIdsResult = await repository.getFavoriteExamIds();

    // Si falla, devolver el error.
    if (favoriteIdsResult.isLeft()) {
      return Left(
        favoriteIdsResult.fold((l) => l, (r) => throw UnimplementedError()),
      );
    }

    final favoriteIds = favoriteIdsResult.getOrElse(() => []);

    // Si no hay favoritos, devolver lista vacía.
    if (favoriteIds.isEmpty) {
      return const Right(<Exam>[]);
    }

    // 2. Obtener todos los ETS y filtrar los que están en favoritos.
    final allExamsResult = await repository.getAllExams();

    return allExamsResult.fold(
      (failure) => Left(failure),
      (exams) {
        final favorites =
            exams.where((exam) => favoriteIds.contains(exam.id)).toList();
        return Right(favorites);
      },
    );
  }
}