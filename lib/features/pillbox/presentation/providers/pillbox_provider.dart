import 'package:flutter/foundation.dart';
import '../../../../core/notification/pillbox_notification.dart';
import '../../domain/entities/intake.dart';
import '../../domain/entities/patient_medication.dart';
import '../../domain/entities/today_intakes.dart';
import '../../domain/repositories/pillbox_repository.dart';

class PillboxProvider with ChangeNotifier {
  final PillboxRepository _repository;

  PillboxProvider(this._repository);

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  TodayIntakes? _todayIntakes;
  List<PatientMedication> _medications = [];
  int _page = 1;
  final int _limit = 20;
  int _total = 0;

  // Today badge state — updated on every mark action and load
  // Values: 'allTaken' | 'partial' | 'hasSkipped' | null
  String? _todayBadgeStatus;

  // History state
  DateTime _historySelectedDate = DateTime.now();
  final Map<String, TodayIntakes> _historyCache = {};
  final Map<String, bool?> _complianceCache = {};
  bool _isLoadingHistory = false;
  String? _historyError;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  TodayIntakes? get todayIntakes => _todayIntakes;
  List<Intake> get intakes => _todayIntakes?.intakes ?? const [];
  List<PatientMedication> get medications => _medications;
  int get page => _page;
  int get total => _total;
  bool get hasMore => _medications.length < _total;

  // History getters
  DateTime get historySelectedDate => _historySelectedDate;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;
  List<Intake> get historyIntakes =>
      _historyCache[_dateKey(_historySelectedDate)]?.intakes ?? const [];
  Map<String, TodayIntakes> get historyCache => _historyCache;

  bool? getComplianceForDate(DateTime date) =>
      _complianceCache[_dateKey(date)];

  String? get todayBadgeStatus => _todayBadgeStatus;

  Future<void> loadTodayIntakes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayIntakes = await _repository.getTodayIntakes();
      _refreshTodayCompliance();
      // Schedule notifications for all PENDING intakes
      schedulePillboxReminders(_todayIntakes?.intakes ?? []);
    } catch (e) {
      _error = 'Erreur lors du chargement du pilulier du jour';
      if (kDebugMode) debugPrint('Pillbox loadTodayIntakes error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedications({bool refresh = true}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    if (refresh) {
      _page = 1;
      _medications = [];
    }
    notifyListeners();

    try {
      final response =
          await _repository.getMyMedications(page: _page, limit: _limit);
      _total = response.total;
      if (_page == 1) {
        _medications = response.items;
      } else {
        _medications = [..._medications, ...response.items];
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des médicaments';
      if (kDebugMode) debugPrint('Pillbox loadMedications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMedications() async {
    if (!hasMore || _isLoading) return;
    final nextPage = _page + 1;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response =
          await _repository.getMyMedications(page: nextPage, limit: _limit);
      _page = nextPage;
      _total = response.total;
      _medications = [..._medications, ...response.items];
    } catch (e) {
      _error = 'Erreur lors du chargement des médicaments';
      if (kDebugMode) debugPrint('Pillbox loadMoreMedications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markIntakeTaken(String intakeId, {String? notes}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.markIntakeTaken(intakeId, notes: notes);
      _updateLocalIntakeStatus(intakeId, status: 'TAKEN');
      _refreshTodayCompliance();
      cancelPillboxReminder(intakeId);
    } catch (e) {
      _error = 'Impossible de marquer la prise comme effectuée';
      if (kDebugMode) debugPrint('Pillbox markIntakeTaken error: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> markIntakeSkipped(String intakeId, {String? notes}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.markIntakeSkipped(intakeId, notes: notes);
      _updateLocalIntakeStatus(intakeId, status: 'SKIPPED');
      _refreshTodayCompliance();
      cancelPillboxReminder(intakeId);
    } catch (e) {
      _error = 'Impossible de marquer la prise comme ignorée';
      if (kDebugMode) debugPrint('Pillbox markIntakeSkipped error: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> createMedication(Map<String, dynamic> body) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _repository.createMedication(body);
      _medications = [created, ..._medications];
      _total += 1;
      // Rafraichir les intakes du jour pour afficher le nouveau medicament
      try {
        _todayIntakes = await _repository.getTodayIntakes();
        _refreshTodayCompliance();
        schedulePillboxReminders(_todayIntakes?.intakes ?? []);
      } catch (_) {}
    } catch (e) {
      _error = 'Impossible de créer le médicament';
      if (kDebugMode) debugPrint('Pillbox createMedication error: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<PatientMedication?> getMedicationDetail(String id) async {
    try {
      return await _repository.getMedicationDetail(id);
    } catch (e) {
      _error = 'Impossible de charger le détail du médicament';
      if (kDebugMode) debugPrint('Pillbox getMedicationDetail error: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> updateMedication(String id, Map<String, dynamic> body) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _repository.updateMedication(id, body);
      _medications = _medications
          .map((medication) => medication.id == id ? updated : medication)
          .toList();
    } catch (e) {
      _error = 'Impossible de modifier le médicament';
      if (kDebugMode) debugPrint('Pillbox updateMedication error: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteMedication(id);
      _medications =
          _medications.where((medication) => medication.id != id).toList();
      if (_total > 0) _total -= 1;
      // Refresh today's intakes to remove deleted medication's entries
      try {
        _todayIntakes = await _repository.getTodayIntakes();
        _refreshTodayCompliance();
      } catch (_) {}
    } catch (e) {
      _error = 'Impossible de supprimer le médicament';
      if (kDebugMode) debugPrint('Pillbox deleteMedication error: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> createSchedule(Map<String, dynamic> body) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _repository.createSchedule(body);
      _medications = _medications.map((medication) {
        if (medication.id != created.patientMedicationId) return medication;
        return medication.copyWith(
          schedules: [...medication.schedules, created],
        );
      }).toList();
    } catch (e) {
      _error = 'Impossible d\'ajouter un horaire';
      if (kDebugMode) debugPrint('Pillbox createSchedule error: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> body) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _repository.updateSchedule(id, body);
      _medications = _medications.map((medication) {
        final hasSchedule = medication.schedules.any((s) => s.id == id);
        if (!hasSchedule) return medication;
        final schedules = medication.schedules
            .map((s) => s.id == id ? updated : s)
            .toList();
        return medication.copyWith(schedules: schedules);
      }).toList();
    } catch (e) {
      _error = 'Impossible de modifier l\'horaire';
      if (kDebugMode) debugPrint('Pillbox updateSchedule error: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String id) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteSchedule(id);
      _medications = _medications.map((medication) {
        final schedules =
            medication.schedules.where((s) => s.id != id).toList();
        return medication.copyWith(schedules: schedules);
      }).toList();
    } catch (e) {
      _error = 'Impossible de supprimer l\'horaire';
      if (kDebugMode) debugPrint('Pillbox deleteSchedule error: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── History methods ──────────────────────────────────────────────────────

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void selectHistoryDate(DateTime date) {
    _historySelectedDate = date;
    notifyListeners();
    loadIntakesForDate(date);
  }

  Future<void> loadIntakesForDate(DateTime date) async {
    final key = _dateKey(date);
    if (_historyCache.containsKey(key)) return;

    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      final result = await _repository.getIntakesForDate(date);
      _historyCache[key] = result;
    } catch (e) {
      _historyError = 'Erreur lors du chargement des prises';
      if (kDebugMode) debugPrint('Pillbox loadIntakesForDate error: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthIntakes(DateTime month) async {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    try {
      final history =
          await _repository.getIntakeHistory(from: first, to: last);
      _complianceCache.addAll(history);
    } catch (e) {
      if (kDebugMode) debugPrint('Pillbox loadMonthIntakes error: $e');
    }
    notifyListeners();
  }

  TodayIntakes? getIntakesForCachedDate(DateTime date) {
    return _historyCache[_dateKey(date)];
  }

  void _refreshTodayCompliance() {
    final current = _todayIntakes;
    if (current == null || current.intakes.isEmpty) {
      _todayBadgeStatus = null;
      return;
    }
    final intakes = current.intakes;
    final takenCount =
        intakes.where((i) => i.status.toUpperCase() == 'TAKEN').length;
    final skippedCount =
        intakes.where((i) => i.status.toUpperCase() == 'SKIPPED').length;
    final total = intakes.length;

    _complianceCache[_dateKey(DateTime.now())] = takenCount == total;

    if (takenCount == total) {
      _todayBadgeStatus = 'allTaken';
    } else if (takenCount > 0) {
      _todayBadgeStatus = 'partial';
    } else if (skippedCount > 0) {
      _todayBadgeStatus = 'hasSkipped';
    } else {
      _todayBadgeStatus = null;
    }
  }

  void _updateLocalIntakeStatus(String intakeId, {required String status}) {
    final current = _todayIntakes;
    if (current == null) return;

    final updatedIntakes = current.intakes.map((intake) {
      if (intake.id != intakeId) return intake;
      return intake.copyWith(
        status: status,
        takenAt: status == 'TAKEN' ? DateTime.now() : intake.takenAt,
      );
    }).toList();

    _todayIntakes = TodayIntakes(date: current.date, intakes: updatedIntakes);
  }
}
