import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/exam.dart';
import '../../domain/repositories/exams_repository.dart';
import '../../domain/usecases/filter_exams_usecase.dart';
import '../../domain/usecases/get_all_exams_usecase.dart';
import '../../domain/usecases/get_favorite_exams_usecase.dart';
import '../../domain/usecases/save_favorite_exam_usecase.dart';
import 'exams_state.dart';

/// Notifier que controla el estado de búsqueda de ETS.
class ExamsNotifier extends StateNotifier<ExamsState> {
  final GetAllExamsUseCase _getAllExams;
  final FilterExamsUseCase _filterExams;
  final SaveFavoriteExamUseCase _saveFavorite;
  final GetFavoriteExamsUseCase _getFavorites;
  final ExamsRepository _examsRepository;

  ExamsNotifier({
    required GetAllExamsUseCase getAllExams,
    required FilterExamsUseCase filterExams,
    required SaveFavoriteExamUseCase saveFavorite,
    required GetFavoriteExamsUseCase getFavorites,
    required ExamsRepository examsRepository,
  })  : _getAllExams = getAllExams,
        _filterExams = filterExams,
        _saveFavorite = saveFavorite,
        _getFavorites = getFavorites,
        _examsRepository = examsRepository,
        super(ExamsState.initial());

  /// Carga inicial: trae todos los ETS y los favoritos del usuario.
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllExams(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (exams) {
        state = state.copyWith(exams: exams, isLoading: false);
      },
    );

    await _loadFavorites();
  }

  /// Aplica los filtros actuales y recarga la lista.
  Future<void> applyFilters() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final params = FilterExamsParams(
      careerCode: state.selectedCareer,
      semester: state.selectedSemester,
      subjectQuery: state.subjectQuery.isNotEmpty ? state.subjectQuery : null,
    );

    final result = await _filterExams(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (exams) {
        state = state.copyWith(exams: exams, isLoading: false);
      },
    );
  }

  /// Actualiza la carrera seleccionada y refiltra.
  void setCareer(String? careerCode) {
    if (careerCode == null) {
      state = state.copyWith(clearCareer: true);
    } else {
      state = state.copyWith(selectedCareer: careerCode);
    }
    applyFilters();
  }

  /// Actualiza el semestre seleccionado y refiltra.
  void setSemester(int? semester) {
    if (semester == null) {
      state = state.copyWith(clearSemester: true);
    } else {
      state = state.copyWith(selectedSemester: semester);
    }
    applyFilters();
  }

  /// Actualiza la búsqueda por materia y refiltra.
  void setSubjectQuery(String query) {
    state = state.copyWith(subjectQuery: query);
    applyFilters();
  }

  /// Quita todos los filtros aplicados.
  void clearAllFilters() {
    state = state.copyWith(
      clearCareer: true,
      clearSemester: true,
      subjectQuery: '',
    );
    applyFilters();
  }

  /// Marca o desmarca un ETS como favorito.
  Future<void> toggleFavorite(String examId) async {
    final isCurrentlyFavorite = state.favoriteIds.contains(examId);

    if (isCurrentlyFavorite) {
      state = state.copyWith(
        favoriteIds: state.favoriteIds.where((id) => id != examId).toList(),
      );
    } else {
      await _saveFavorite(ExamIdParams(examId));
      state = state.copyWith(
        favoriteIds: [...state.favoriteIds, examId],
      );
    }
  }

  /// Crea un nuevo ETS y refresca la lista.
  Future<bool> createExam(Exam exam) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _examsRepository.createExam(exam);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        loadInitialData();
        return true;
      },
    );
  }

  /// Actualiza un ETS existente.
  Future<bool> updateExam(Exam exam) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _examsRepository.updateExam(exam);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        loadInitialData();
        return true;
      },
    );
  }

  /// Elimina un ETS.
  Future<bool> deleteExam(String examId) async {
    final result = await _examsRepository.deleteExam(examId);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        loadInitialData();
        return true;
      },
    );
  }

  /// Carga los IDs de favoritos del usuario.
  Future<void> _loadFavorites() async {
    final result = await _getFavorites(const NoParams());
    result.fold(
      (_) => null,
      (exams) => state = state.copyWith(
        favoriteIds: exams.map((e) => e.id).toList(),
      ),
    );
  }
}

/// Provider global para acceder al ExamsNotifier desde cualquier widget.
final examsProvider = StateNotifierProvider<ExamsNotifier, ExamsState>((ref) {
  return ExamsNotifier(
    getAllExams: sl(),
    filterExams: sl(),
    saveFavorite: sl(),
    getFavorites: sl(),
    examsRepository: sl(),
  );
});