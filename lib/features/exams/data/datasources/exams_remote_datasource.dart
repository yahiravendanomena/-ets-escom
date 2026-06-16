import '../../../../core/errors/exceptions.dart';
import '../models/exam_model.dart';

abstract class ExamsRemoteDataSource {
  Future<List<ExamModel>> getAllExams();
  Future<ExamModel> getExamById(String id);
  Future<ExamModel> createExam(ExamModel exam);
  Future<ExamModel> updateExam(ExamModel exam);
  Future<void> deleteExam(String examId);
}

/// Implementación con datos MOCK (de prueba).
class ExamsRemoteDataSourceMockImpl implements ExamsRemoteDataSource {
  /// Lista mutable de ETS en memoria.
  /// En backend real, esto vendría de la base de datos.
  static final List<Map<String, dynamic>> _mockExamsJson = [
    {
      'id': 'ets-001',
      'subject': 'Cálculo Vectorial',
      'career_code': 'ISC',
      'semester': 3,
      'date': '2026-06-15T09:00:00Z',
      'shift': 'matutino',
      'classroom': '3203',
      'building': 'Edificio 3',
      'professor': 'Dr. Hernández López',
    },
    {
      'id': 'ets-002',
      'subject': 'Programación Orientada a Objetos',
      'career_code': 'ISC',
      'semester': 3,
      'date': '2026-06-16T11:00:00Z',
      'shift': 'matutino',
      'classroom': '2105',
      'building': 'Edificio 2',
      'professor': 'Mtra. Ramírez Soto',
    },
    {
      'id': 'ets-003',
      'subject': 'Estructuras de Datos',
      'career_code': 'ISC',
      'semester': 4,
      'date': '2026-06-17T14:00:00Z',
      'shift': 'vespertino',
      'classroom': '3105',
      'building': 'Edificio 3',
      'professor': 'Dr. Vargas Mendoza',
    },
    {
      'id': 'ets-004',
      'subject': 'Bases de Datos',
      'career_code': 'ISC',
      'semester': 5,
      'date': '2026-06-18T09:00:00Z',
      'shift': 'matutino',
      'classroom': '3201',
      'building': 'Edificio 3',
      'professor': 'Mtro. González Pérez',
    },
    {
      'id': 'ets-005',
      'subject': 'Cálculo Aplicado',
      'career_code': 'IIA',
      'semester': 3,
      'date': '2026-06-15T16:00:00Z',
      'shift': 'vespertino',
      'classroom': '4102',
      'building': 'Edificio 4',
      'professor': 'Dra. Castillo Ruiz',
    },
    {
      'id': 'ets-006',
      'subject': 'Algoritmos para IA',
      'career_code': 'IIA',
      'semester': 5,
      'date': '2026-06-19T11:00:00Z',
      'shift': 'matutino',
      'classroom': '4205',
      'building': 'Edificio 4',
      'professor': 'Dr. Méndez Torres',
    },
    {
      'id': 'ets-007',
      'subject': 'Visualización de Datos',
      'career_code': 'LCD',
      'semester': 4,
      'date': '2026-06-20T14:00:00Z',
      'shift': 'vespertino',
      'classroom': '2202',
      'building': 'Edificio 2',
      'professor': 'Mtra. Fernández Luna',
    },
    {
      'id': 'ets-008',
      'subject': 'Sistemas Operativos',
      'career_code': 'ISC',
      'semester': 5,
      'date': '2026-06-21T09:00:00Z',
      'shift': 'matutino',
      'classroom': '3204',
      'building': 'Edificio 3',
      'professor': 'Dr. Aguilar Núñez',
    },
  ];

  @override
  Future<List<ExamModel>> getAllExams() async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _mockExamsJson.map((json) => ExamModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Error parseando ETS: $e');
    }
  }

  @override
  Future<ExamModel> getExamById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final json = _mockExamsJson.firstWhere(
        (json) => json['id'] == id,
        orElse: () => throw NotFoundException('ETS no encontrado'),
      );
      return ExamModel.fromJson(json);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error: $e');
    }
  }

  @override
  Future<ExamModel> createExam(ExamModel exam) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final json = exam.toJson();
      _mockExamsJson.add(json);
      return exam;
    } catch (e) {
      throw ServerException('Error creando ETS: $e');
    }
  }

  @override
  Future<ExamModel> updateExam(ExamModel exam) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final index = _mockExamsJson.indexWhere((j) => j['id'] == exam.id);
      if (index == -1) {
        throw NotFoundException('ETS no encontrado para actualizar');
      }
      _mockExamsJson[index] = exam.toJson();
      return exam;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error actualizando ETS: $e');
    }
  }

  @override
  Future<void> deleteExam(String examId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = _mockExamsJson.indexWhere((j) => j['id'] == examId);
      if (index == -1) {
        throw NotFoundException('ETS no encontrado para eliminar');
      }
      _mockExamsJson.removeAt(index);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error eliminando ETS: $e');
    }
  }
}