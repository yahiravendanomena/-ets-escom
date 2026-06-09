import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/exams_repository.dart';

/// Caso de uso: guardar un ETS como favorito en el dispositivo.
class SaveFavoriteExamUseCase implements UseCase<void, ExamIdParams> {
  final ExamsRepository repository;

  SaveFavoriteExamUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ExamIdParams params) {
    return repository.saveFavoriteExam(params.examId);
  }
}

/// Parámetro: ID del ETS sobre el cual actuar (favorito/quitar favorito).
class ExamIdParams extends Equatable {
  final String examId;

  const ExamIdParams(this.examId);

  @override
  List<Object?> get props => [examId];
}