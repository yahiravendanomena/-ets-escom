import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exam.dart';
import '../repositories/exams_repository.dart';

/// Caso de uso: filtrar ETS por carrera, semestre y/o materia.
class FilterExamsUseCase implements UseCase<List<Exam>, FilterExamsParams> {
  final ExamsRepository repository;

  FilterExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(FilterExamsParams params) {
    return repository.filterExams(
      careerCode: params.careerCode,
      semester: params.semester,
      subjectQuery: params.subjectQuery,
    );
  }
}

/// Parámetros para filtrar ETS.
/// Cualquier campo puede ser null para no aplicar ese filtro.
class FilterExamsParams extends Equatable {
  final String? careerCode;
  final int? semester;
  final String? subjectQuery;

  const FilterExamsParams({
    this.careerCode,
    this.semester,
    this.subjectQuery,
  });

  @override
  List<Object?> get props => [careerCode, semester, subjectQuery];
}