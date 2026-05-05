import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      rethrow;
    }
  }

  void _onNotificationTap(NotificationResponse response) {}

  Future<bool> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'freelanceflow_channel',
      'FreelanceFlow Notifications',
      channelDescription: 'Notifications from FreelanceFlow',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'freelanceflow_channel',
      'FreelanceFlow Notifications',
      channelDescription: 'Notifications from FreelanceFlow',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> schedulePaymentReminder({
    required String paymentId,
    required String clientName,
    required double amount,
    required DateTime dueDate,
  }) async {
    final reminderDate = dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: paymentId.hashCode,
        title: 'Payment Due Tomorrow',
        body: '$clientName - \$${amount.toStringAsFixed(2)} is due tomorrow',
        scheduledDate: reminderDate,
        payload: 'payment:$paymentId',
      );
    }
  }

  Future<void> scheduleProjectDeadlineReminder({
    required String projectId,
    required String projectTitle,
    required String clientName,
    required DateTime deadline,
  }) async {
    final reminderDate = deadline.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: projectId.hashCode,
        title: 'Project Deadline Tomorrow',
        body: '$projectTitle for $clientName is due tomorrow',
        scheduledDate: reminderDate,
        payload: 'project:$projectId',
      );
    }
  }

  Future<void> scheduleInvoiceReminder({
    required String invoiceId,
    required String invoiceNumber,
    required String clientName,
    required DateTime dueDate,
    required double total,
  }) async {
    final reminderDate = dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: invoiceId.hashCode,
        title: 'Invoice Due Tomorrow',
        body:
            '$invoiceNumber for $clientName - \$${total.toStringAsFixed(2)} is due tomorrow',
        scheduledDate: reminderDate,
        payload: 'invoice:$invoiceId',
      );
    }
  }

  Future<void> showRecurringGenerated({
    required String invoiceId,
    required String invoiceNumber,
    required String clientName,
  }) async {
    await showNotification(
      id: 'recurring_$invoiceId'.hashCode,
      title: 'Invoice Auto-Created',
      body: 'Invoice $invoiceNumber has been generated for $clientName — review it',
      payload: 'invoice:$invoiceId',
    );
  }
}
