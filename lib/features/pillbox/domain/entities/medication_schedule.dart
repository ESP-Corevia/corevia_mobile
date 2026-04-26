class MedicationSchedule {
  final String id;
  final String patientMedicationId;
  final String intakeTime;
  final String intakeMoment;
  final int? weekday;
  final double? quantity;
  final String? unit;
  final String? notes;

  MedicationSchedule({
    required this.id,
    required this.patientMedicationId,
    required this.intakeTime,
    required this.intakeMoment,
    this.weekday,
    this.quantity,
    this.unit,
    this.notes,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    final rawWeekday = json['weekday'];
    return MedicationSchedule(
      id: (json['id'] ?? '').toString(),
      patientMedicationId: (json['patientMedicationId'] ?? '').toString(),
      intakeTime: (json['intakeTime'] ?? '').toString(),
      intakeMoment: (json['intakeMoment'] ?? 'CUSTOM').toString(),
      weekday: rawWeekday is int
          ? rawWeekday
          : int.tryParse(rawWeekday?.toString() ?? ''),
      quantity: rawQuantity is num
          ? rawQuantity.toDouble()
          : double.tryParse(rawQuantity?.toString() ?? ''),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientMedicationId': patientMedicationId,
      'intakeTime': intakeTime,
      'intakeMoment': intakeMoment,
      'weekday': weekday,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }
}
