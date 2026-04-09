import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/medication_search_result.dart';
import '../../domain/repositories/pillbox_repository.dart';

class MedicationSearchProvider with ChangeNotifier {
  final PillboxRepository _repository;

  MedicationSearchProvider(this._repository);

  List<MedicationSearchResult> _results = [];
  bool _isSearching = false;
  String? _error;
  Timer? _debounce;
  int _searchVersion = 0;

  List<MedicationSearchResult> get results => _results;
  bool get isSearching => _isSearching;
  String? get error => _error;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    _debounce?.cancel();
    if (trimmed.length < 3) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }

    final currentVersion = ++_searchVersion;
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _isSearching = true;
      _error = null;
      notifyListeners();
      try {
        final response = await _repository.searchMedications(trimmed);
        if (currentVersion != _searchVersion) return;
        _results = response.items;
      } catch (e) {
        if (currentVersion != _searchVersion) return;
        final message = e.toString();
        if (kDebugMode) debugPrint('MedicationSearch error: $message');
        if (message.contains('401') || message.contains('403')) {
          _error = 'Session expirée. Reconnecte-toi.';
        } else if (message.contains('expirée') || message.contains('timeout')) {
          _error = 'Connexion au serveur impossible (timeout)';
        } else {
          _error = 'Erreur: ${message.length > 100 ? message.substring(0, 100) : message}';
        }
      } finally {
        if (currentVersion == _searchVersion) {
          _isSearching = false;
          notifyListeners();
        }
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    _results = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
