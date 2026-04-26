class Intake {
  final String id;
  final String patientMedicationId;
  final String scheduleId;
  final String medicationName;
  final String? medicationForm;
  final String? dosageLabel;
  final String scheduledTime;
  final String intakeMoment;
  final double? quantity;
  final String? unit;
  final String status;
  final DateTime? takenAt;
  final String? notes;

  Intake({
    required this.id,
    required this.patientMedicationId,
    required this.scheduleId,
    required this.medicationName,
    required this.scheduledTime,
    required this.intakeMoment,
    required this.status,
    this.medicationForm,
    this.dosageLabel,
    this.quantity,
    this.unit,
    this.takenAt,
    this.notes,
  });

  factory Intake.fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    return Intake(
      id: (json['id'] ?? '').toString(),
      patientMedicationId: (json['patientMedicationId'] ?? '').toString(),
      scheduleId: (json['scheduleId'] ?? '').toString(),
      medicationName: (json['medicationName'] ?? '').toString(),
      medicationForm: json['medicationForm'] as String?,
      dosageLabel: json['dosageLabel'] as String?,
      scheduledTime: (json['scheduledTime'] ?? '').toString(),
      intakeMoment: (json['intakeMoment'] ?? 'CUSTOM').toString(),
      quantity: rawQuantity is num
          ? rawQuantity.toDouble()
          : double.tryParse(rawQuantity?.toString() ?? ''),
      unit: json['unit'] as String?,
      status: (json['status'] ?? '').toString(),
      takenAt: json['takenAt'] != null
          ? DateTime.tryParse(json['takenAt'].toString())
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientMedicationId': patientMedicationId,
      'scheduleId': scheduleId,
      'medicationName': medicationName,
      'medicationForm': medicationForm,
      'dosageLabel': dosageLabel,
      'scheduledTime': scheduledTime,
      'intakeMoment': intakeMoment,
      'quantity': quantity,
      'unit': unit,
      'status': status,
      'takenAt': takenAt?.toIso8601String(),
      'notes': notes,
    };
  }

  Intake copyWith({
    String? status,
    DateTime? takenAt,
    String? notes,
  }) {
    return Intake(
      id: id,
      patientMedicationId: patientMedicationId,
      scheduleId: scheduleId,
      medicationName: medicationName,
      medicationForm: medicationForm,
      dosageLabel: dosageLabel,
      scheduledTime: scheduledTime,
      intakeMoment: intakeMoment,
      quantity: quantity,
      unit: unit,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
      notes: notes ?? this.notes,
    );
  }
}
