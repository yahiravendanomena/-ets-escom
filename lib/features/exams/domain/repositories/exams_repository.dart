import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exam.dart';

/// Contrato del repositorio de ETS (Exámenes a Título de Suficiencia).
///
/// Define QUÉ operaciones se pueden hacer con los ETS,
/// pero NO cómo se hacen. Esa es responsabilidad de la implementación
/// en la capa de Data (ExamsRepositoryImpl).
///
/// El tipo de retorno `Either<Failure, T>` permite manejar errores como datos:
/// - Left(failure): hubo un error.
/// - Right(value): operación exitosa con resultado de tipo T.
abstract class ExamsRepository {
  /// Obtiene todos los ETS disponibles.
  /// Usa caché local si no hay conexión (offline-first).
  Future<Either<Failure, List<Exam>>> getAllExams();

  /// Obtiene un ETS específico por su ID.
  Future<Either<Failure, Exam>> getExamById(String id);

  /// Obtiene los ETS filtrados por carrera, semestre y/o materia.
  ///
  /// Cualquier parámetro puede ser null para no aplicar ese filtro.
  Future<Either<Failure, List<Exam>>> filterExams({
    String? careerCode,
    int? semester,
    String? subjectQuery,
  });

  /// Guarda un ETS como favorito en el dispositivo (caché local).
  Future<Either<Failure, void>> saveFavoriteExam(String examId);

  /// Quita un ETS de favoritos.
  Future<Either<Failure, void>> removeFavoriteExam(String examId);

  /// Obtiene los IDs de los ETS marcados como favoritos.
  Future<Either<Failure, List<String>>> getFavoriteExamIds();
}