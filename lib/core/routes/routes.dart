import 'package:flutter/material.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/onboarding/auth_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/aptitude/aptitude_menu_screen.dart';
import '../../features/coding/coding_menu_screen.dart';
import '../../features/placement/placement_menu_screen.dart';
import '../../features/placement/job_matching_screen.dart';
import '../../features/word_puzzle/word_puzzle_menu_screen.dart';
import '../../features/brain_training/brain_training_menu_screen.dart';
import '../../features/multiplayer/multiplayer_menu_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/profile/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String aptitude = '/aptitude';
  static const String coding = '/coding';
  static const String placement = '/placement';
  static const String wordPuzzle = '/word-puzzle';
  static const String brainTraining = '/brain-training';
  static const String multiplayer = '/multiplayer';
  static const String premium = '/premium';
  static const String jobMatching = '/job-matching';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case aptitude:
        return MaterialPageRoute(builder: (_) => const AptitudeMenuScreen());
      case coding:
        return MaterialPageRoute(builder: (_) => const CodingMenuScreen());
      case placement:
        return MaterialPageRoute(builder: (_) => const PlacementMenuScreen());
      case wordPuzzle:
        return MaterialPageRoute(builder: (_) => const WordPuzzleMenuScreen());
      case brainTraining:
        return MaterialPageRoute(builder: (_) => const BrainTrainingMenuScreen());
      case multiplayer:
        return MaterialPageRoute(builder: (_) => const MultiplayerMenuScreen());
      case premium:
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
      case jobMatching:
        return MaterialPageRoute(builder: (_) => const JobMatchingScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

