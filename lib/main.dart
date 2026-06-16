import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme.dart';
import 'core/routes/routes.dart';
import 'core/services/app_state.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppNotifications();
  await FirebaseService.initialize();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(prefs)),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'SkillArena',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            themeAnimationDuration: const Duration(milliseconds: 300),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
