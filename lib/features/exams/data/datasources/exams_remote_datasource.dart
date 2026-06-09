import '../../../../core/errors/exceptions.dart';
import '../models/exam_model.dart';

/// Contrato del datasource remoto (API REST).
///
/// Define qué operaciones se hacen contra el backend.
abstract class ExamsRemoteDataSource {
  /// Obtiene todos los ETS desde la API.
  /// Throws: [ServerException], [NetworkException].
  Future<List<ExamModel>> getAllExams();

  /// Obtiene un ETS específico desde la API.
  /// Throws: [NotFoundException], [ServerException].
  Future<ExamModel> getExamById(String id);
}

/// Implementación con datos MOCK (de prueba).
///
/// TODO: Reemplazar por implementación real con Dio cuando el backend
/// esté listo. Solo este archivo cambia, el resto de la arquitectura
/// permanece intacto.
class ExamsRemoteDataSourceMockImpl implements ExamsRemoteDataSource {
  /// Datos de prueba: ETS simulados para desarrollar la UI.
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
    // Simula latencia de red real.
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      return _mockExamsJson.map((json) => ExamModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Error parseando ETS: $e');
    }
  }

  @override
  Future<ExamModel> getExamById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final json = _mockExamsJson.firstWhere(
        (json) => json['id'] == id,
        orElse: () => throw NotFoundException('ETS con id $id no encontrado'),
      );
      return ExamModel.fromJson(json);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw ServerException('Error obteniendo ETS: $e');
    }
  }
}

/* 
================================================================================
  📌 IMPLEMENTACIÓN REAL CON DIO (descomentarla cuando el backend esté listo)
================================================================================

import 'package:dio/dio.dart';

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final Dio dio;
  
  static const String _baseUrl = 'https://tu-api.com/api/v1';

  ExamsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ExamModel>> getAllExams() async {
    try {
      final response = await dio.get('$_baseUrl/exams');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ExamModel.fromJson(json)).toList();
      } else {
        throw ServerException('Error HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Timeout: el servidor tardó mucho');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException('Recurso no encontrado');
      } else if (e.response?.statusCode == 500) {
        throw ServerException('Error interno del servidor');
      }
      throw NetworkException('Error de red: ${e.message}');
    }
  }

  @override
  Future<ExamModel> getExamById(String id) async {
    try {
      final response = await dio.get('$_baseUrl/exams/$id');
      
      if (response.statusCode == 200) {
        return ExamModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw NotFoundException('ETS no encontrado');
      } else {
        throw ServerException('Error HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException('ETS no encontrado');
      }
      throw NetworkException('Error de red: ${e.message}');
    }
  }
}

================================================================================
*/