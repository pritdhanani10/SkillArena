import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

Future<void> initPlatformNotifications() async {
  try {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifications.initialize(settings: settings);
    
    // Request permission on Android 13+
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  } catch (e) {
    // Fail silently on non-mobile platform compilation
  }
}

void triggerNotification(String title, String message) async {
  const androidDetails = AndroidNotificationDetails(
    'skillarena_channel',
    'SkillArena Alerts',
    channelDescription: 'SkillArena game notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
  
  try {
    await _localNotifications.show(
      id: DateTime.now().hashCode,
      title: title,
      body: message,
      notificationDetails: details,
    );
  } catch (e) {
    // Fail silently
  }
}
