import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que gestiona los catálogos de Carreras y Edificios.
///
/// Persiste los datos en SharedPreferences.
class CatalogsService {
  static const _careersKey = 'catalog_careers';
  static const _buildingsKey = 'catalog_buildings';

  /// Catálogo por defecto si no hay nada guardado.
  static const List<String> _defaultCareers = ['ISC', 'IIA', 'LCD'];
  static const List<String> _defaultBuildings = [
    'Edificio 1',
    'Edificio 2',
    'Edificio 3',
    'Edificio 4',
  ];

  // ============================================
  // CARRERAS
  // ============================================

  Future<List<String>> getCareers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_careersKey);
    if (json == null) return List.from(_defaultCareers);
    return (jsonDecode(json) as List).cast<String>();
  }

  Future<void> addCareer(String career) async {
    final list = await getCareers();
    final clean = career.trim().toUpperCase();
    if (clean.isEmpty || list.contains(clean)) return;
    list.add(clean);
    await _saveCareers(list);
  }

  Future<void> removeCareer(String career) async {
    final list = await getCareers();
    list.remove(career);
    await _saveCareers(list);
  }

  Future<void> _saveCareers(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_careersKey, jsonEncode(list));
  }

  // ============================================
  // EDIFICIOS
  // ============================================

  Future<List<String>> getBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_buildingsKey);
    if (json == null) return List.from(_defaultBuildings);
    return (jsonDecode(json) as List).cast<String>();
  }

  Future<void> addBuilding(String building) async {
    final list = await getBuildings();
    final clean = building.trim();
    if (clean.isEmpty || list.contains(clean)) return;
    list.add(clean);
    await _saveBuildings(list);
  }

  Future<void> removeBuilding(String building) async {
    final list = await getBuildings();
    list.remove(building);
    await _saveBuildings(list);
  }

  Future<void> _saveBuildings(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_buildingsKey, jsonEncode(list));
  }
}
