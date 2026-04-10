import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/pillbox/domain/entities/intake.dart';

const _channelId = 'pillbox_channel';
const _channelName = 'Rappels médicaments';
const _channelDesc = 'Rappels pour prendre vos médicaments';

final _plugin = FlutterLocalNotificationsPlugin();
bool _initialized = false;

Future<void> initializePillboxNotifications() async {
  if (_initialized) return;

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await _plugin.initialize(settings: settings);

  // Request permission on Android 13+
  final androidImpl = _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidImpl?.requestNotificationsPermission();

  _initialized = true;
}

/// Cancels all pillbox notifications then reschedules every PENDING intake.
Future<void> schedulePillboxReminders(List<Intake> intakes) async {
  if (!_initialized) return;
  await _plugin.cancelAll();

  for (final intake in intakes) {
    if (intake.status != 'PENDING') continue;
    await _scheduleIntakeReminder(intake);
  }
}

Future<void> _scheduleIntakeReminder(Intake intake) async {
  final parts = intake.scheduledTime.split(':');
  if (parts.length < 2) return;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return;

  final now = tz.TZDateTime.now(tz.local);
  var scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  final dosage =
      intake.dosageLabel != null ? ' — ${intake.dosageLabel}' : '';
  final notifId = intake.id.hashCode & 0x7FFFFFFF;

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDesc,
    importance: Importance.high,
    priority: Priority.high,
  );

  await _plugin.zonedSchedule(
    id: notifId,
    title: 'Rappel médicament',
    body:
        'Pensez à prendre ${intake.medicationName}$dosage à ${intake.scheduledTime}',
    scheduledDate: scheduled,
    notificationDetails: const NotificationDetails(android: androidDetails),
    androidScheduleMode: AndroidScheduleMode.inexact,
    matchDateTimeComponents: DateTimeComponents.time,
  );

  if (kDebugMode) {
    debugPrint(
        '[PillboxNotif] Scheduled #$notifId "${intake.medicationName}" at ${intake.scheduledTime}');
  }
}

/// Cancels the reminder for a single intake (taken or skipped).
Future<void> cancelPillboxReminder(String intakeId) async {
  if (!_initialized) return;
  final notifId = intakeId.hashCode & 0x7FFFFFFF;
  await _plugin.cancel(id: notifId);
  if (kDebugMode) {
    debugPrint('[PillboxNotif] Cancelled #$notifId (intake $intakeId)');
  }
}
