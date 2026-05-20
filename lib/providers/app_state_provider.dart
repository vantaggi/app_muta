import 'package:flutter/material.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:muta_manager/models/ceraiolo_model.dart';
import 'package:muta_manager/services/database_helper.dart';
import 'package:muta_manager/theme/app_theme.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Muta> _muteList = [];
  List<Ceraiolo> _ceraioliList = [];
  List<int> _availableYears = [];
  String? _errorMessage;

  List<Muta> get muteList => List.unmodifiable(_muteList);
  List<Ceraiolo> get ceraioliList => List.unmodifiable(_ceraioliList);
  List<int> get availableYears => List.unmodifiable(_availableYears);
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadAllMute() async {
    try {
      _errorMessage = null;
      _muteList = await _dbHelper.readAllMute();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load all mute entries: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMuteByYearAndCero(int year, CeroType cero) async {
    try {
      _errorMessage = null;
      _muteList = await _dbHelper.readMuteByYearAndCero(year, cero);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load mute entries for year $year: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchMuteByPerson(String query) async {
    try {
      _errorMessage = null;
      _muteList = await _dbHelper.searchMuteByPerson(query);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search mute operation failed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addMuta(Muta muta) async {
    try {
      _errorMessage = null;
      await _dbHelper.insertMuta(muta);
      await loadAvailableYears();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to insert muta entry: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editMuta(Muta muta) async {
    try {
      _errorMessage = null;
      await _dbHelper.updateMuta(muta);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update muta entry: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeMuta(String id) async {
    try {
      _errorMessage = null;
      await _dbHelper.deleteMuta(id);
      _muteList.removeWhere((element) => element.id == id);
      await loadAvailableYears();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete muta entry: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadAvailableYears() async {
    try {
      _errorMessage = null;
      _availableYears = await _dbHelper.getAvailableYears();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load registry years: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadAllCeraioli() async {
    try {
      _errorMessage = null;
      _ceraioliList = await _dbHelper.readAllCeraioli();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load ceraioli database: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addCeraiolo(Ceraiolo ceraiolo) async {
    try {
      _errorMessage = null;
      await _dbHelper.insertCeraiolo(ceraiolo);
      _ceraioliList = await _dbHelper.readAllCeraioli();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add ceraiolo profile: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editCeraiolo(Ceraiolo ceraiolo) async {
    try {
      _errorMessage = null;
      await _dbHelper.updateCeraiolo(ceraiolo);
      _ceraioliList = await _dbHelper.readAllCeraioli();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update ceraiolo profile: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeCeraiolo(String id) async {
    try {
      _errorMessage = null;
      await _dbHelper.deleteCeraiolo(id);
      _ceraioliList.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete ceraiolo profile: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchCeraioliData(String query, {CeroType? cero}) async {
    try {
      _errorMessage = null;
      _ceraioliList = await _dbHelper.searchCeraioli(query, cero: cero);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search ceraioli operation failed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }
}
