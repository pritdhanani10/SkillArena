import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillarena/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'coins': 120,
      'xp': 180,
      'streak': 3,
      'isLoggedIn': false,
    });
    final prefs = await SharedPreferences.getInstance();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify that our app name is found (Splash Screen / Welcome screen has SkillArena).
    expect(find.text('SkillArena'), findsOneWidget);
  });
}
