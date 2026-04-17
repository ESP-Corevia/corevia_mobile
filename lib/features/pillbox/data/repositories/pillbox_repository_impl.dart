import '../../../../networking/api_service.dart';
import '../../../../networking/routes/pillbox_routes.dart';
import '../../domain/entities/intake.dart';
import '../../domain/entities/medication_schedule.dart';
import '../../domain/entities/medication_search_result.dart';
import '../../domain/entities/paginated_response.dart';
import '../../domain/entities/patient_medication.dart';
import '../../domain/entities/today_intakes.dart';
import '../../domain/repositories/pillbox_repository.dart';

class PillboxRepositoryImpl implements PillboxRepository {
  @override
  Future<PaginatedResponse<PatientMedication>> getMyMedications({
    int page = 1,
    int limit = 20,
    bool? isActive,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (isActive != null) {
      params['isActive'] = isActive.toString();
    }

    final response = await ApiService.authGet(
      PillboxRoutes.medications(),
      params: params,
    );
    final items = ((response['items'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PatientMedication.fromJson)
        .toList();

    return PaginatedResponse(
      items: items,
      page: (response['page'] as num?)?.toInt() ?? page,
      limit: (response['limit'] as num?)?.toInt() ?? limit,
      total: (response['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<PatientMedication> createMedication(Map<String, dynamic> body) async {
    final response =
        await ApiService.authPost(PillboxRoutes.medications(), body);
    return PatientMedication.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PatientMedication> getMedicationDetail(String id) async {
    final response = await ApiService.authGet(PillboxRoutes.medicationById(id));
    return PatientMedication.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PatientMedication> updateMedication(
      String id, Map<String, dynamic> body) async {
    final response =
        await ApiService.authPatch(PillboxRoutes.medicationById(id), body);
    return PatientMedication.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await ApiService.authDelete(PillboxRoutes.medicationById(id));
  }

  @override
  Future<TodayIntakes> getTodayIntakes() async {
    final response = await ApiService.authGet(PillboxRoutes.todayIntakes());
    return TodayIntakes.fromJson(
      response as Map<String, dynamic>,
      fallbackDate: DateTime.now(),
    );
  }

  @override
  Future<void> markIntakeTaken(String intakeId, {String? notes}) async {
    await ApiService.authPost(
      PillboxRoutes.markIntakeTaken(intakeId),
      {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  @override
  Future<void> markIntakeSkipped(String intakeId, {String? notes}) async {
    await ApiService.authPost(
      PillboxRoutes.markIntakeSkipped(intakeId),
      {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  @override
  Future<MedicationSchedule> createSchedule(Map<String, dynamic> body) async {
    final response = await ApiService.authPost(PillboxRoutes.schedules(), body);
    return MedicationSchedule.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<MedicationSchedule> updateSchedule(
      String id, Map<String, dynamic> body) async {
    final response =
        await ApiService.authPatch(PillboxRoutes.scheduleById(id), body);
    return MedicationSchedule.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await ApiService.authDelete(PillboxRoutes.scheduleById(id));
  }

  @override
  Future<PaginatedResponse<MedicationSearchResult>> searchMedications(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.authGet(
      PillboxRoutes.searchMedications(),
      params: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    final items = ((response['items'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MedicationSearchResult.fromJson)
        .toList();

    return PaginatedResponse(
      items: items,
      page: (response['page'] as num?)?.toInt() ?? page,
      limit: (response['limit'] as num?)?.toInt() ?? limit,
      total: (response['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<MedicationSearchResult?> getMedicationByCode({
    String? cis,
    String? cip,
    String? externalId,
  }) async {
    final params = <String, String>{};
    if (cis != null && cis.isNotEmpty) {
      params['cis'] = cis;
    }
    if (cip != null && cip.isNotEmpty) {
      params['cip'] = cip;
    }
    if (externalId != null && externalId.isNotEmpty) {
      params['externalId'] = externalId;
    }
    if (params.isEmpty) return null;

    final response = await ApiService.authGet(PillboxRoutes.medicationByCode(),
        params: params);
    if (response == null) return null;
    return MedicationSearchResult.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TodayIntakes> getIntakesForDate(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response =
        await ApiService.authGet(PillboxRoutes.todayIntakes(date: dateStr));
    return TodayIntakes.fromJson(
      response as Map<String, dynamic>,
      fallbackDate: date,
    );
  }

  @override
  Future<Intake> getIntakeByIdFromToday(String intakeId) async {
    final today = await getTodayIntakes();
    for (final intake in today.intakes) {
      if (intake.id == intakeId) return intake;
    }
    throw StateError('Intake introuvable: $intakeId');
  }

  @override
  Future<Map<String, bool?>> getIntakeHistory({
    required DateTime from,
    required DateTime to,
  }) async {
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final response = await ApiService.authGet(
      PillboxRoutes.intakeHistory(from: fmt(from), to: fmt(to)),
    );
    final days = (response['days'] as List?) ?? const [];
    return {
      for (final day in days.whereType<Map<String, dynamic>>())
        day['date'] as String: day['allTaken'] as bool?,
    };
  }
}
