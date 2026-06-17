import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/catalogs_service.dart';

/// Estado de los catálogos.
class CatalogsState {
  final List<String> careers;
  final List<String> buildings;
  final bool isLoading;

  const CatalogsState({
    this.careers = const [],
    this.buildings = const [],
    this.isLoading = false,
  });

  CatalogsState copyWith({
    List<String>? careers,
    List<String>? buildings,
    bool? isLoading,
  }) {
    return CatalogsState(
      careers: careers ?? this.careers,
      buildings: buildings ?? this.buildings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier para gestionar los catálogos.
class CatalogsNotifier extends StateNotifier<CatalogsState> {
  final CatalogsService _service;

  CatalogsNotifier(this._service) : super(const CatalogsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    final careers = await _service.getCareers();
    final buildings = await _service.getBuildings();
    state = state.copyWith(
      careers: careers,
      buildings: buildings,
      isLoading: false,
    );
  }

  Future<void> addCareer(String career) async {
    await _service.addCareer(career);
    await loadAll();
  }

  Future<void> removeCareer(String career) async {
    await _service.removeCareer(career);
    await loadAll();
  }

  Future<void> addBuilding(String building) async {
    await _service.addBuilding(building);
    await loadAll();
  }

  Future<void> removeBuilding(String building) async {
    await _service.removeBuilding(building);
    await loadAll();
  }
}

final catalogsProvider =
    StateNotifierProvider<CatalogsNotifier, CatalogsState>((ref) {
  return CatalogsNotifier(CatalogsService());
});
