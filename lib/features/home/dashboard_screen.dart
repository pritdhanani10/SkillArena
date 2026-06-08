import 'package:flutter/material.dart';
import 'home_tab.dart';
import '../leaderboard/leaderboard_tab.dart';
import '../profile/profile_tab.dart';
import '../../shared/widgets/mock_ad_widgets.dart';
import '../../core/theme/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ChallengesTab(),
    const LeaderboardTab(),
    const ProfileTab(),
  ];

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
