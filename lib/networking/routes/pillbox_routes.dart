class PillboxRoutes {
  static const String base = '/api';

  static String medications() => '$base/pillbox';
  static String medicationById(String id) => '$base/pillbox/$id';
  static String todayIntakes({String? date}) =>
      date != null ? '$base/pillbox/today?date=$date' : '$base/pillbox/today';

  static String schedules() => '$base/pillbox/schedules';
  static String scheduleById(String id) => '$base/pillbox/schedules/$id';

  static String markIntakeTaken(String id) => '$base/pillbox/intakes/$id/taken';
  static String markIntakeSkipped(String id) =>
      '$base/pillbox/intakes/$id/skipped';

  static String searchMedications() => '$base/medications/search';
  static String medicationByCode() => '$base/medications/by-code';
}
