class AvailableSlots {
  final String doctorId;
  final String date;
  final List<String> slots;

  const AvailableSlots({
    required this.doctorId,
    required this.date,
    required this.slots,
  });

  factory AvailableSlots.fromJson(Map<String, dynamic> json) {
    final rawSlots = (json['slots'] as List?) ?? const [];
    return AvailableSlots(
      doctorId: (json['doctorId'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      slots: rawSlots.map((s) => s.toString()).toList(),
    );
  }
}
