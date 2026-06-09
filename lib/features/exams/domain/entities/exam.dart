import 'package:equatable/equatable.dart';

/// Turno en el que se presenta el ETS.
enum ExamShift {
  matutino,
  vespertino;

  /// Texto bonito para mostrar en UI.
  String get label {
    switch (this) {
      case ExamShift.matutino:
        return 'Matutino';
      case ExamShift.vespertino:
        return 'Vespertino';
    }
  }
}

/// Entidad de dominio que representa un Examen a Título de Suficiencia (ETS).
///
/// Esta clase es PURA: no depende de Flutter, ni de la API, ni de la BD.
/// Es el modelo conceptual del negocio.
class Exam extends Equatable {
  /// Identificador único del ETS.
  final String id;

  /// Nombre de la unidad de aprendizaje (ej: "Cálculo Vectorial").
  final String subject;

  /// Carrera a la que pertenece (ej: "ISC", "IIA", "LCD").
  final String careerCode;

  /// Semestre al que corresponde el ETS (1 a 9).
  final int semester;

  /// Fecha y hora de presentación.
  final DateTime date;

  /// Turno (matutino o vespertino).
  final ExamShift shift;

  /// Salón donde se aplica (ej: "3203").
  final String classroom;

  /// Edificio donde está el salón (ej: "Edificio 3").
  final String building;

  /// Profesor evaluador.
  final String professor;

  const Exam({
    required this.id,
    required this.subject,
    required this.careerCode,
    required this.semester,
    required this.date,
    required this.shift,
    required this.classroom,
    required this.building,
    required this.professor,
  });

  @override
  List<Object?> get props => [
        id,
        subject,
        careerCode,
        semester,
        date,
        shift,
        classroom,
        building,
        professor,
      ];
}