import '../../domain/entities/exam.dart';

/// Modelo de datos para Exam.
///
/// Extiende a la entidad pura [Exam] y agrega capacidad de serialización
/// JSON para comunicarse con la API REST.
///
/// Patrón: la UI usa [Exam] (entidad), las llamadas HTTP usan [ExamModel].
class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.subject,
    required super.careerCode,
    required super.semester,
    required super.date,
    required super.shift,
    required super.classroom,
    required super.building,
    required super.professor,
  });

  /// Crea un [ExamModel] desde un JSON recibido de la API.
  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      careerCode: json['career_code'] as String,
      semester: json['semester'] as int,
      date: DateTime.parse(json['date'] as String),
      shift: _parseShift(json['shift'] as String),
      classroom: json['classroom'] as String,
      building: json['building'] as String,
      professor: json['professor'] as String,
    );
  }

  /// Convierte el modelo a JSON para enviarlo a la API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'career_code': careerCode,
      'semester': semester,
      'date': date.toIso8601String(),
      'shift': shift.name,
      'classroom': classroom,
      'building': building,
      'professor': professor,
    };
  }

  /// Convierte el modelo a un Map para guardarlo en SQLite.
  /// Las fechas se guardan como millisecondsSinceEpoch para optimizar.
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'subject': subject,
      'career_code': careerCode,
      'semester': semester,
      'date': date.millisecondsSinceEpoch,
      'shift': shift.name,
      'classroom': classroom,
      'building': building,
      'professor': professor,
    };
  }

  /// Crea un [ExamModel] desde un Map de SQLite.
  factory ExamModel.fromSqliteMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'] as String,
      subject: map['subject'] as String,
      careerCode: map['career_code'] as String,
      semester: map['semester'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      shift: _parseShift(map['shift'] as String),
      classroom: map['classroom'] as String,
      building: map['building'] as String,
      professor: map['professor'] as String,
    );
  }

  /// Parsea el string del turno a su enum correspondiente.
  static ExamShift _parseShift(String value) {
    return ExamShift.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ExamShift.matutino,
    );
  }
}