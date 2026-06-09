import 'package:equatable/equatable.dart';
import '../../domain/entities/exam.dart';

/// Estado de la pantalla de búsqueda de ETS.
///
/// Modela qué información necesita la UI en cualquier momento:
/// - los ETS mostrados,
/// - los filtros activos,
/// - si está cargando,
/// - si hubo error.
class ExamsState extends Equatable {
  /// Lista de ETS que actualmente se muestran (después de filtrar).
  final List<Exam> exams;

  /// IDs de los ETS marcados como favoritos.
  final List<String> favoriteIds;

  /// Carrera seleccionada en el filtro (null = todas).
  final String? selectedCareer;

  /// Semestre seleccionado en el filtro (null = todos).
  final int? selectedSemester;

  /// Texto de búsqueda por materia.
  final String subjectQuery;

  /// Estado de carga.
  final bool isLoading;

  /// Mensaje de error (si hay).
  final String? errorMessage;

  const ExamsState({
    this.exams = const [],
    this.favoriteIds = const [],
    this.selectedCareer,
    this.selectedSemester,
    this.subjectQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  /// Estado inicial (todo vacío, sin cargar).
  factory ExamsState.initial() => const ExamsState();

  /// Crea una copia del estado modificando solo los campos que se pasan.
  /// Es el patrón usado para manejar estado inmutable en Riverpod.
  ExamsState copyWith({
    List<Exam>? exams,
    List<String>? favoriteIds,
    String? selectedCareer,
    int? selectedSemester,
    String? subjectQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearCareer = false,
    bool clearSemester = false,
  }) {
    return ExamsState(
      exams: exams ?? this.exams,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedCareer:
          clearCareer ? null : (selectedCareer ?? this.selectedCareer),
      selectedSemester:
          clearSemester ? null : (selectedSemester ?? this.selectedSemester),
      subjectQuery: subjectQuery ?? this.subjectQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        exams,
        favoriteIds,
        selectedCareer,
        selectedSemester,
        subjectQuery,
        isLoading,
        errorMessage,
      ];
}