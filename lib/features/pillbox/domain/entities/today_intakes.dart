import 'intake.dart';

class TodayIntakes {
  final DateTime date;
  final List<Intake> intakes;

  TodayIntakes({
    required this.date,
    required this.intakes,
  });

  factory TodayIntakes.fromJson(
    Map<String, dynamic> json, {
    DateTime? fallbackDate,
  }) {
    final rawIntakes = (json['intakes'] as List?) ?? const [];
    final parsedDate = DateTime.tryParse((json['date'] ?? '').toString());
    final resolvedDate = parsedDate ?? fallbackDate;
    if (resolvedDate == null) {
      throw const FormatException('Invalid or missing intakes date');
    }

    return TodayIntakes(
      date: resolvedDate,
      intakes: rawIntakes
          .whereType<Map<String, dynamic>>()
          .map(Intake.fromJson)
          .toList(),
    );
  }
}
