import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio centralizado para gestionar notificaciones locales.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa el plugin de notificaciones.
  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    // Configura zona horaria (necesario para programar notificaciones).
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Solicitar permisos en Android 13+ (todo en una línea para que el parser no se confunda).
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Programa una notificación para un momento específico.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'ets_reminders',
      'Recordatorios de ETS',
      channelDescription: 'Notificaciones para recordar tus ETS',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Muestra una notificación inmediata (para pruebas).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ets_reminders',
        'Recordatorios de ETS',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }

  /// Cancela una notificación programada por su ID.
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  /// Cancela todas las notificaciones programadas.
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}