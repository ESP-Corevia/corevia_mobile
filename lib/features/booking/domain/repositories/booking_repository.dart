import '../../../pillbox/domain/entities/paginated_response.dart';
import '../entities/appointment.dart';
import '../entities/available_slots.dart';
import '../entities/doctor.dart';

abstract class BookingRepository {
  Future<PaginatedResponse<Doctor>> listDoctors({
    String? specialty,
    String? city,
    String? search,
    int page = 1,
    int limit = 20,
  });

  Future<AvailableSlots> getAvailableSlots({
    required String doctorId,
    required String date,
  });

  Future<Appointment> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String? reason,
  });

  Future<PaginatedResponse<Appointment>> listMyAppointments({
    String? status,
    String? from,
    String? to,
    int page = 1,
    int limit = 20,
    String sort = 'dateDesc',
  });

  Future<Appointment> getAppointmentDetail(String id);
}
