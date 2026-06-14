import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home_tab.dart';
import '../leaderboard/leaderboard_tab.dart';
import '../profile/profile_tab.dart';
import '../../shared/widgets/mock_ad_widgets.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../core/services/notification_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ChallengesTab(),
    const LeaderboardTab(),
    const ProfileTab(),
  ];

  AppNotification? _activeNotification;
  late AnimationController _notificationController;
  late Animation<Offset> _notificationOffsetAnimation;
  late AnimationController _iconPulseController;
  bool _wasDailyCompleted = false;

  @override
  void initState() {
    super.initState();
    
    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _notificationOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.easeOutBack,
    ));

    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      _wasDailyCompleted = appState.isDailyChallengeCompleted;
      appState.addListener(_onAppStateChanged);
      _checkAndShowStreakNotification();
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<AppState>(context, listen: false).removeListener(_onAppStateChanged);
    } catch (_) {}
    _notificationController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isLoggedIn) {
      if (appState.testNotificationTriggered) {
        _checkAndShowStreakNotification();
        return;
      }
      if (appState.isDailyChallengeCompleted && !_wasDailyCompleted) {
        _wasDailyCompleted = true;
        _showNotification(AppNotification(
          title: "Streak Secured! 🔥",
          message: "Amazing job! Your ${appState.streak}-day streak is safe for today.",
          icon: Icons.emoji_events_rounded,
          color: AppColors.accentYellow,
        ));
      } else if (!appState.isDailyChallengeCompleted) {
        _wasDailyCompleted = false;
      }
    } else {
      _wasDailyCompleted = false;
    }
  }

  void _checkAndShowStreakNotification() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isLoggedIn) return;

    if (appState.isDailyChallengeCompleted) {
      _showNotification(AppNotification(
        title: "Streak Secured! 🔥",
        message: "Your ${appState.streak}-day streak is safe for today. Complete challenges tomorrow to grow your streak!",
        icon: Icons.emoji_events_rounded,
        color: AppColors.accentYellow,
      ));
    } else {
      _showNotification(AppNotification(
        title: "Streak in Danger! ⚠️",
        message: "Your ${appState.streak}-day streak resets in less than 24 hours! Complete your challenges now.",
        icon: Icons.warning_amber_rounded,
        color: AppColors.accentOrange,
        isWarning: true,
      ));
    }
  }

  void _showNotification(AppNotification notification) {
    if (!mounted) return;
    setState(() {
      _activeNotification = notification;
    });
    _notificationController.forward();

    // Trigger physical haptic feedback if enabled in settings
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    // Trigger native system notification drawer pop-ups (compile-safe across web/mobile)
    showSystemNotification(notification.title, notification.message);

    // Auto-dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _activeNotification == notification) {
        _notificationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _activeNotification = null;
            });
          }
        });
      }
    });
  }

  Widget _buildNotificationWidget() {
    if (_activeNotification == null) return const SizedBox.shrink();
    final n = _activeNotification!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: n.color.withOpacity(0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: App Identity & Time (mimicking native OS notifications)
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: n.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: n.color.withOpacity(0.3), width: 0.5),
                    ),
                    child: Center(
                      child: Icon(
                        n.icon,
                        size: 10,
                        color: n.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "SKILLARENA",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "•",
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "now",
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.4), size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _notificationController.reverse().then((_) {
                        if (mounted) {
                          setState(() {
                            _activeNotification = null;
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Body Row: Title, Message and Interactive Action Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon wrapper with pulsing animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _iconPulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            n.color.withOpacity(0.25),
                            n.color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: n.color.withOpacity(0.3), width: 1),
                      ),
                      child: Icon(
                        n.icon,
                        color: n.color,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Message Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          n.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          n.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Action button for Streak warning
                  if (n.isWarning)
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: n.color.withOpacity(0.2),
                        foregroundColor: n.color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        _notificationController.reverse().then((_) {
                          if (mounted) {
                            setState(() {
                              _activeNotification = null;
                              _currentIndex = 1; // Open Challenges Tab
                            });
                          }
                        });
                      },
                      child: const Text(
                        "Play",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Mobile Tray Pull-down Handle Bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    Widget bodyContent = IndexedStack(
      index: _currentIndex,
      children: _tabs,
    );

    if (isWide) {
      bodyContent = Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: AppColors.surface,
            selectedIconTheme: const IconThemeData(color: AppColors.secondary),
            unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
            selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 12),
            unselectedLabelTextStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sports_esports_outlined),
                selectedIcon: Icon(Icons.sports_esports),
                label: Text('Challenges'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: Text('Leaderboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _tabs,
                      ),
                    ),
                  ),
                ),
                const MockBannerAd(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background subtle ambient lights
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 60,
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: bodyContent,
          ),
          if (_activeNotification != null)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: SafeArea(
                child: SlideTransition(
                  position: _notificationOffsetAnimation,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.up,
                        onDismissed: (direction) {
                          setState(() {
                            _activeNotification = null;
                          });
                        },
                        child: _buildNotificationWidget(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bottom Navigation Bar
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedItemColor: AppColors.secondary,
                    unselectedItemColor: AppColors.textMuted,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    unselectedLabelStyle: const TextStyle(fontSize: 11),
                    type: BottomNavigationBarType.fixed,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home, color: AppColors.secondary),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.sports_esports_outlined),
                        activeIcon: Icon(Icons.sports_esports, color: AppColors.secondary),
                        label: 'Challenges',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.emoji_events_outlined),
                        activeIcon: Icon(Icons.emoji_events, color: AppColors.secondary),
                        label: 'Leaderboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person, color: AppColors.secondary),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
                // Ad Banner
                const MockBannerAd(),
              ],
            ),
    );
  }
}

// Subtab for direct category navigation
class ChallengesTab extends StatelessWidget {
  const ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Game Arena",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          Text(
            "Test your limits, score points, and unlock achievements.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildChallengeCard(
            context,
            title: "Aptitude Arena",
            subtitle: "Quantitative, Logical, & Verbal",
            icon: Icons.lightbulb_outline,
            color: AppColors.primary,
            route: "/aptitude",
          ),
          _buildChallengeCard(
            context,
            title: "Coding Challenge",
            subtitle: "DSA, Language Basics & Code MCQs",
            icon: Icons.code,
            color: AppColors.secondary,
            route: "/coding",
          ),
          _buildChallengeCard(
            context,
            title: "Word Puzzles",
            subtitle: "Word Searches & Crosswords",
            icon: Icons.text_fields,
            color: AppColors.accentOrange,
            route: "/word-puzzle",
          ),
          _buildChallengeCard(
            context,
            title: "Brain Training",
            subtitle: "Memory & Pattern Recall Games",
            icon: Icons.psychology,
            color: AppColors.accentPink,
            route: "/brain-training",
          ),
          _buildChallengeCard(
            context,
            title: "Multiplayer Arena",
            subtitle: "Realtime Tic-Tac-Toe & Ludo",
            icon: Icons.people,
            color: AppColors.accentGreen,
            route: "/multiplayer",
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassBox(),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isWarning;

  const AppNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.isWarning = false,
  });
}
