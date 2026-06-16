import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exam.dart';

/// Contrato del repositorio de ETS.
abstract class ExamsRepository {
  Future<Either<Failure, List<Exam>>> getAllExams();

  Future<Either<Failure, Exam>> getExamById(String id);

  Future<Either<Failure, List<Exam>>> filterExams({
    String? careerCode,
    int? semester,
    String? subjectQuery,
  });

  Future<Either<Failure, void>> saveFavoriteExam(String examId);

  Future<Either<Failure, void>> removeFavoriteExam(String examId);

  Future<Either<Failure, List<String>>> getFavoriteExamIds();

  /// Crea un nuevo ETS.
  Future<Either<Failure, Exam>> createExam(Exam exam);

  /// Actualiza un ETS existente.
  Future<Either<Failure, Exam>> updateExam(Exam exam);

  /// Elimina un ETS.
  Future<Either<Failure, void>> deleteExam(String examId);
}