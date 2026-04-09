import 'intake.dart';

class TodayIntakes {
  final DateTime date;
  final List<Intake> intakes;

  TodayIntakes({
    required this.date,
    required this.intakes,
  });

  factory TodayIntakes.fromJson(Map<String, dynamic> json) {
    final rawIntakes = (json['intakes'] as List?) ?? const [];
    return TodayIntakes(
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      intakes: rawIntakes
          .whereType<Map<String, dynamic>>()
          .map(Intake.fromJson)
          .toList(),
    );
  }
}
