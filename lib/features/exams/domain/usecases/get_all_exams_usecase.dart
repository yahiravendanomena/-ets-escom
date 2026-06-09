import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exam.dart';
import '../repositories/exams_repository.dart';

/// Caso de uso: obtener todos los ETS disponibles.
class GetAllExamsUseCase implements UseCase<List<Exam>, NoParams> {
  final ExamsRepository repository;

  GetAllExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(NoParams params) {
    return repository.getAllExams();
  }
}