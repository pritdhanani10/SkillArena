import 'dart:js' as js;

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
