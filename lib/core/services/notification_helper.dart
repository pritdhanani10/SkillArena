import 'notification_helper_stub.dart'
    if (dart.library.js) 'notification_helper_web.dart';

Future<void> initializeAppNotifications() async {
  await initPlatformNotifications();
}

void showSystemNotification(String title, String message) {
  triggerNotification(title, message);
}
