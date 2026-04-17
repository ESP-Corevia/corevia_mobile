import 'package:flutter/foundation.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository _repository;

  BookingProvider(this._repository);

  bool _isLoadingDoctors = false;
  bool _isLoadingSlots = false;
  bool _isLoadingAppointments = false;
  bool _isSubmitting = false;
  String? _error;

  List<Doctor> _doctors = [];
  List<String> _availableSlots = [];
  List<Appointment> _appointments = [];
  int _doctorsTotal = 0;
  int _appointmentsTotal = 0;

  bool get isLoadingDoctors => _isLoadingDoctors;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isLoadingAppointments => _isLoadingAppointments;
  bool get isSubmitting => _isSubmitting;
  bool get isLoading =>
      _isLoadingDoctors || _isLoadingSlots || _isLoadingAppointments;
  String? get error => _error;

  List<Doctor> get doctors => _doctors;
  List<String> get availableSlots => _availableSlots;
  List<Appointment> get appointments => _appointments;
  int get doctorsTotal => _doctorsTotal;
  int get appointmentsTotal => _appointmentsTotal;

  Future<void> loadDoctors({
    String? specialty,
    String? city,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoadingDoctors = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.listDoctors(
        specialty: specialty,
        city: city,
        search: search,
        page: page,
        limit: limit,
      );
      _doctors = response.items;
      _doctorsTotal = response.total;
      if (kDebugMode) {
        debugPrint(
          'Booking loadDoctors success: items=${_doctors.length}, total=$_doctorsTotal',
        );
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des medecins';
      if (kDebugMode) debugPrint('Booking loadDoctors error: $e');
    } finally {
      _isLoadingDoctors = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableSlots({
    required String doctorId,
    required String date,
  }) async {
    _isLoadingSlots = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _repository.getAvailableSlots(doctorId: doctorId, date: date);
      _availableSlots = response.slots;
    } catch (e) {
      _error = 'Erreur lors du chargement des creneaux disponibles';
      _availableSlots = [];
      if (kDebugMode) debugPrint('Booking loadAvailableSlots error: $e');
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  Future<Appointment?> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String? reason,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final appointment = await _repository.createAppointment(
        doctorId: doctorId,
        date: date,
        time: time,
        reason: reason,
      );
      return appointment;
    } catch (e) {
      _error = 'Impossible de creer le rendez-vous';
      if (kDebugMode) debugPrint('Booking createAppointment error: $e');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadMyAppointments({
    String? status,
    String? from,
    String? to,
    int page = 1,
    int limit = 20,
    String sort = 'dateDesc',
  }) async {
    _isLoadingAppointments = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.listMyAppointments(
        status: status,
        from: from,
        to: to,
        page: page,
        limit: limit,
        sort: sort,
      );
      _appointments = response.items;
      _appointmentsTotal = response.total;
    } catch (e) {
      _error = 'Erreur lors du chargement des rendez-vous';
      _appointments = [];
      if (kDebugMode) debugPrint('Booking loadMyAppointments error: $e');
    } finally {
      _isLoadingAppointments = false;
      notifyListeners();
    }
  }
}
