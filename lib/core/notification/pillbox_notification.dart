import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../features/pillbox/domain/entities/intake.dart';

const _channelId = 'pillbox_channel';
const _channelName = 'Rappels médicaments';
const _channelDesc = 'Rappels pour prendre vos médicaments';

final _plugin = FlutterLocalNotificationsPlugin();
bool _initialized = false;
final Map<int, Timer> _activeTimers = {};

// ── Foreground callbacks (set from main.dart) ─────────────────────────────────

void Function(String intakeId, String action)? _foregroundActionHandler;
void Function()? _onTapHandler;

/// Call from main.dart before [initializePillboxNotifications] to wire up
/// foreground action handling (provider access) and tap navigation.
void setPillboxNotificationHandlers({
  required void Function(String intakeId, String action) onAction,
  required void Function() onTap,
}) {
  _foregroundActionHandler = onAction;
  _onTapHandler = onTap;
}

// ── Initialization ────────────────────────────────────────────────────────────

Future<void> initializePillboxNotifications() async {
  if (_initialized) return;

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);

  await _plugin.initialize(
    settings,
    onDidReceiveNotificationResponse: _onForegroundResponse,
    onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
  );

  // Request permissions on Android 13+
  final androidImpl = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidImpl?.requestNotificationsPermission();

  _initialized = true;
}

// ── Foreground response handler ───────────────────────────────────────────────

void _onForegroundResponse(NotificationResponse details) {
  final payload = details.payload;
  final actionId = details.actionId;

  if (kDebugMode) {
    debugPrint(
        '[PillboxNotif] Foreground: action=$actionId payload=$payload');
  }

  if (actionId != null &&
      actionId.isNotEmpty &&
      payload != null &&
      payload.isNotEmpty) {
    _foregroundActionHandler?.call(payload, actionId);
    final notifId = payload.hashCode & 0x7FFFFFFF;
    _plugin.cancel(notifId);
  } else {
    _onTapHandler?.call();
  }
}

// ── Background response handler ───────────────────────────────────────────────

@pragma('vm:entry-point')
void _onBackgroundResponse(NotificationResponse details) async {
  final payload = details.payload;
  final actionId = details.actionId;

  if (actionId == null ||
      actionId.isEmpty ||
      payload == null ||
      payload.isEmpty) {
    return;
  }

  try {
    await dotenv.load(fileName: '.env');

    final baseUrl = dotenv.env['API_BASE_URL_ANDROID'] ??
        dotenv.env['API_BASE_URL'] ??
        'https://api.corevia.local';
    final hostHeader = dotenv.env['API_HOST_HEADER_ANDROID'] ??
        dotenv.env['API_HOST_HEADER'];

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token') ?? '';

    final String route;
    if (actionId == 'taken') {
      route = '/api/pillbox/intakes/$payload/taken';
    } else if (actionId == 'skipped') {
      route = '/api/pillbox/intakes/$payload/skipped';
    } else {
      return;
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Origin': baseUrl,
    };
    if (hostHeader != null && hostHeader.isNotEmpty) {
      headers['Host'] = hostHeader;
    }

    await http.post(
      Uri.parse('$baseUrl$route'),
      headers: headers,
      body: jsonEncode({}),
    );

    final notifId = payload.hashCode & 0x7FFFFFFF;
    await FlutterLocalNotificationsPlugin().cancel(notifId);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[PillboxNotif] Background handler error: $e');
    }
  }
}

// ── Schedule / cancel helpers ─────────────────────────────────────────────────

/// Cancels all pillbox notifications then reschedules every PENDING intake.
Future<void> schedulePillboxReminders(List<Intake> intakes) async {
  if (kDebugMode) {
    final pending = intakes.where((i) => i.status == 'PENDING').length;
    debugPrint(
        '[PillboxNotif] schedulePillboxReminders: ${intakes.length} intakes, $pending PENDING, initialized=$_initialized');
  }
  if (!_initialized) return;

  // Cancel all existing timers and notifications
  for (final timer in _activeTimers.values) {
    timer.cancel();
  }
  _activeTimers.clear();
  await _plugin.cancelAll();

  for (final intake in intakes) {
    if (intake.status != 'PENDING') continue;
    _scheduleIntakeReminder(intake);
  }
}

void _scheduleIntakeReminder(Intake intake) {
  final parts = intake.scheduledTime.split(':');
  if (parts.length < 2) return;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return;

  final now = DateTime.now();
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  final delay = scheduled.difference(now);
  final dosage =
      intake.dosageLabel != null ? ' — ${intake.dosageLabel}' : '';
  final notifId = intake.id.hashCode & 0x7FFFFFFF;

  const actions = [
    AndroidNotificationAction(
      'taken',
      '✅ Pris',
      showsUserInterface: true,
      cancelNotification: true,
    ),
    AndroidNotificationAction(
      'skipped',
      '❌ Ignorer',
      showsUserInterface: true,
      cancelNotification: true,
    ),
  ];

  final title = '💊 ${intake.medicationName}';
  final body = 'Il est ${intake.scheduledTime} — c\'est l\'heure de votre prise$dosage';

  final androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDesc,
    importance: Importance.high,
    priority: Priority.high,
    actions: actions,
    color: const Color(0xFF34C759),
    category: AndroidNotificationCategory.reminder,
    styleInformation: BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: 'Rappel médicament',
    ),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
    autoCancel: false,
    ongoing: false,
    visibility: NotificationVisibility.public,
    subText: 'CoreVia',
  );

  // Use Timer + show() for reliable delivery
  final timer = Timer(delay, () {
    _plugin.show(
      notifId,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: intake.id,
    );
    if (kDebugMode) {
      debugPrint(
          '[PillboxNotif] FIRED #$notifId "${intake.medicationName}" at ${intake.scheduledTime}');
    }
    _activeTimers.remove(notifId);
  });

  _activeTimers[notifId] = timer;

  if (kDebugMode) {
    debugPrint(
        '[PillboxNotif] Scheduled #$notifId "${intake.medicationName}" in ${delay.inMinutes}m${delay.inSeconds % 60}s (at ${intake.scheduledTime})');
  }
}

/// Cancels the reminder for a single intake (taken or skipped).
Future<void> cancelPillboxReminder(String intakeId) async {
  if (!_initialized) return;
  final notifId = intakeId.hashCode & 0x7FFFFFFF;

  _activeTimers[notifId]?.cancel();
  _activeTimers.remove(notifId);
  await _plugin.cancel(notifId);

  if (kDebugMode) {
    debugPrint('[PillboxNotif] Cancelled #$notifId (intake $intakeId)');
  }
}
