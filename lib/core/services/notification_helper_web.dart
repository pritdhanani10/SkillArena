import 'dart:js' as js;

Future<void> initPlatformNotifications() async {
  // Web notifications request permissions inside the JS function showBrowserNotification if needed.
}

void triggerNotification(String title, String message) {
  try {
    js.context.callMethod('showBrowserNotification', [
      title,
      message,
      'favicon.png'
    ]);
  } catch (e) {
    // Fail silently
  }
}
