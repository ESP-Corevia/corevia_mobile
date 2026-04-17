class AppointmentDoctorInfo {
  final String id;
  final String name;
  final String specialty;
  final String address;

  const AppointmentDoctorInfo({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
  });

  factory AppointmentDoctorInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentDoctorInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }
}

class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final String date;
  final String time;
  final String status;
  final String? reason;
  final String? createdAt;
  final String? updatedAt;
  final AppointmentDoctorInfo? doctor;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.time,
    required this.status,
    this.reason,
    this.createdAt,
    this.updatedAt,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final rawDoctor = json['doctor'];
    return Appointment(
      id: (json['id'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? '').toString(),
      patientId: (json['patientId'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reason: json['reason']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      doctor: rawDoctor is Map<String, dynamic>
          ? AppointmentDoctorInfo.fromJson(rawDoctor)
          : null,
    );
  }
}
