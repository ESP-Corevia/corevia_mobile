import 'medication_schedule.dart';

class PatientMedication {
  final String id;
  final String patientId;
  final String medicationName;
  final String? medicationForm;
  final String? dosageLabel;
  final String? instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? cis;
  final String? cip;
  final String? medicationExternalId;
  final String? source;
  final List<String> activeSubstances;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MedicationSchedule> schedules;

  PatientMedication({
    required this.id,
    required this.patientId,
    required this.medicationName,
    required this.startDate,
    required this.isActive,
    this.medicationForm,
    this.dosageLabel,
    this.instructions,
    this.endDate,
    this.cis,
    this.cip,
    this.medicationExternalId,
    this.source,
    this.activeSubstances = const [],
    this.createdAt,
    this.updatedAt,
    this.schedules = const [],
  });

  factory PatientMedication.fromJson(Map<String, dynamic> json) {
    final rawSchedules = (json['schedules'] as List?) ?? const [];
    final rawSubstances = (json['activeSubstances'] as List?) ?? const [];

    return PatientMedication(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? '').toString(),
      medicationName: (json['medicationName'] ?? '').toString(),
      medicationForm: json['medicationForm'] as String?,
      dosageLabel: json['dosageLabel'] as String?,
      instructions: json['instructions'] as String?,
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()) ??
          DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      isActive: json['isActive'] == true,
      cis: json['cis'] as String?,
      cip: json['cip'] as String?,
      medicationExternalId: json['medicationExternalId'] as String?,
      source: json['source'] as String?,
      activeSubstances: rawSubstances.map((item) => item.toString()).toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      schedules: rawSchedules
          .whereType<Map<String, dynamic>>()
          .map(MedicationSchedule.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationName': medicationName,
      'medicationForm': medicationForm,
      'dosageLabel': dosageLabel,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'cis': cis,
      'cip': cip,
      'medicationExternalId': medicationExternalId,
      'source': source,
      'activeSubstances': activeSubstances,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }

  PatientMedication copyWith({
    String? dosageLabel,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<MedicationSchedule>? schedules,
  }) {
    return PatientMedication(
      id: id,
      patientId: patientId,
      medicationName: medicationName,
      medicationForm: medicationForm,
      dosageLabel: dosageLabel ?? this.dosageLabel,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      cis: cis,
      cip: cip,
      medicationExternalId: medicationExternalId,
      source: source,
      activeSubstances: activeSubstances,
      createdAt: createdAt,
      updatedAt: updatedAt,
      schedules: schedules ?? this.schedules,
    );
  }
}
