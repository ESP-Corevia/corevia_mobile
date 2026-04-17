import '../entities/intake.dart';
import '../entities/medication_schedule.dart';
import '../entities/medication_search_result.dart';
import '../entities/paginated_response.dart';
import '../entities/patient_medication.dart';
import '../entities/today_intakes.dart';

abstract class PillboxRepository {
  Future<PaginatedResponse<PatientMedication>> getMyMedications({
    int page = 1,
    int limit = 20,
    bool? isActive,
  });

  Future<PatientMedication> createMedication(Map<String, dynamic> body);

  Future<PatientMedication> getMedicationDetail(String id);

  Future<PatientMedication> updateMedication(
      String id, Map<String, dynamic> body);

  Future<void> deleteMedication(String id);

  Future<TodayIntakes> getTodayIntakes();

  Future<TodayIntakes> getIntakesForDate(DateTime date);

  Future<void> markIntakeTaken(String intakeId, {String? notes});

  Future<void> markIntakeSkipped(String intakeId, {String? notes});

  Future<MedicationSchedule> createSchedule(Map<String, dynamic> body);

  Future<MedicationSchedule> updateSchedule(
      String id, Map<String, dynamic> body);

  Future<void> deleteSchedule(String id);

  Future<PaginatedResponse<MedicationSearchResult>> searchMedications(
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<MedicationSearchResult?> getMedicationByCode({
    String? cis,
    String? cip,
    String? externalId,
  });

  Future<Intake> getIntakeByIdFromToday(String intakeId);
}
