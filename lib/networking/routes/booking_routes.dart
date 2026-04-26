class BookingRoutes {
  static const String base = '/api';

  static String doctors() => '$base/doctors';

  static String availableSlots(String doctorId) =>
      '$base/doctors/$doctorId/available-slots';

  static String appointments() => '$base/appointments';

  static String appointmentById(String id) => '$base/appointments/$id';
}
