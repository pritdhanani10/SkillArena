import 'notification_helper_stub.dart'
    if (dart.library.js) 'notification_helper_web.dart';

void showWebNotification(String title, String message) {
  triggerNotification(title, message);
}
