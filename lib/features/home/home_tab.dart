import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/fade_in_slide.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Status Header
          _buildUserHeader(context, appState),
          const SizedBox(height: 24),

          // Daily Challenge Status Widget
          _buildDailyChallengeCard(context, appState),
          const SizedBox(height: 24),

          // Categories Title
          const Text(
            "Explore Modules",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Categories Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              FadeInSlide(
                delay: 50,
                child: _buildCategoryCard(
                  context,
                  title: "Aptitude Arena",
                  icon: "🧠",
                  tagline: "Practice & Quizzes",
                  gradient: AppTheme.primaryGradient,
                  route: "/aptitude",
                ),
              ),
              FadeInSlide(
                delay: 100,
                child: _buildCategoryCard(
                  context,
                  title: "Coding Challenge",
                  icon: "💻",
                  tagline: "DSA & Languages",
                  gradient: AppTheme.secondaryGradient,
                  route: "/coding",
                ),
              ),
              FadeInSlide(
                delay: 150,
                child: _buildCategoryCard(
                  context,
                  title: "Placement Prep",
                  icon: "📚",
                  tagline: "Q&A, Resume, AI",
                  gradient: AppTheme.pinkGradient,
                  route: "/placement",
                ),
              ),
              FadeInSlide(
                delay: 200,
                child: _buildCategoryCard(
                  context,
                  title: "Word Puzzle",
                  icon: "🔤",
                  tagline: "Search, Daily Words",
                  gradient: AppTheme.greenGradient,
                  route: "/word-puzzle",
                ),
              ),
              FadeInSlide(
                delay: 250,
                child: _buildCategoryCard(
                  context,
                  title: "Brain Training",
                  icon: "🎯",
                  tagline: "Memory & Simon",
                  gradient: AppTheme.orangeGradient,
                  route: "/brain-training",
                ),
              ),
              FadeInSlide(
                delay: 300,
                child: _buildCategoryCard(
                  context,
                  title: "Multiplayer Games",
                  icon: "🎮",
                  tagline: "Tic-Tac-Toe & Ludo",
                  gradient: AppTheme.secondaryGradient,
                  route: "/multiplayer",
                ),
              ),
              FadeInSlide(
                delay: 350,
                child: _buildCategoryCard(
                  context,
                  title: "Leaderboard",
                  icon: "🏆",
                  tagline: "Rankings & XP",
                  gradient: AppTheme.orangeGradient,
                  route: "/dashboard",
                  isLeaderboard: true,
                ),
              ),
              FadeInSlide(
                delay: 400,
                child: _buildCategoryCard(
                  context,
                  title: "Daily Streak",
                  icon: "🔥",
                  tagline: "${appState.streak} Days Active",
                  gradient: AppTheme.pinkGradient,
                  route: "",
                  isStreak: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          // Premium CTA Card
          _buildPremiumCTA(context, appState),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassBox(),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: appState.isPremium ? AppColors.premiumGradient : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    appState.username.isNotEmpty ? appState.username[0].toUpperCase() : 'G',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & Streak
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          appState.username,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (appState.isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: AppColors.premiumGradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "PRO",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("🔥", style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                "${appState.streak} Day Streak",
                                style: const TextStyle(fontSize: 11, color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("🪙", style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                "${appState.coins} Coins",
                                style: const TextStyle(fontSize: 11, color: AppColors.accentYellow, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // XP Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Level ${appState.level}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              Text(
                "${appState.xp % 300} / 300 XP",
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: appState.xpProgressPercent,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String icon,
    required String tagline,
    required LinearGradient gradient,
    required String route,
    bool isLeaderboard = false,
    bool isStreak = false,
  }) {
    return Container(
      decoration: AppTheme.glassBox(
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isLeaderboard) {
                // Find nearest tab controller to switch index or navigate
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Click the 'Leaderboard' tab at the bottom to view rankings!")),
                );
              } else if (isStreak) {
                _showStreakInfoDialog(context);
              } else {
                Navigator.of(context).pushNamed(route);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context, AppState appState) {
    int completedCount = 0;
    if (appState.dailyCompletedAptitude) completedCount++;
    if (appState.dailyCompletedCoding) completedCount++;
    if (appState.dailyCompletedWord) completedCount++;
    if (appState.dailyCompletedMemory) completedCount++;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () => _showDailyChallengeDialog(context, appState),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text("🔥", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text(
                        "Daily Challenge Hub",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Complete today's challenges to secure +50 Coins and keep your streak!",
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completedCount / 4.0,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$completedCount/4 Done",
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCTA(BuildContext context, AppState appState) {
    if (appState.isPremium) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.glassBox(
          color: AppColors.surface,
          border: Border.all(color: AppColors.accentGreen.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: AppColors.accentGreen, size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Premium Active",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "You have unlimited hints and access to all company packs.",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: AppTheme.glassBox(
        border: Border.all(color: Colors.transparent),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.premiumGradient,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "💎 Go Premium",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "₹99/mo",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Unlock Amazon, TCS, Infosys Company Packs, advanced placement analytics, unlimited quiz hints, and enjoy an ad-free experience.",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/premium");
                    },
                    child: const Text(
                      "Unlock Placement Packs Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("🔥 Active Streak"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "You are on a streak! Complete your Daily Challenges every day to grow your streak multiplier.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 12),
              Text(
                "Streaks reset if you miss completing a challenge for more than 24 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.accentOrange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Got It"),
            )
          ],
        );
      },
    );
  }

  void _showDailyChallengeDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Row(
                children: [
                  Text("🔥"),
                  SizedBox(width: 10),
                  Text("Today's Challenges"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDailyItem(
                    title: "Solve 1 Aptitude Question",
                    completed: appState.dailyCompletedAptitude,
                    color: AppColors.primary,
                    onPressed: () {
                      appState.completeDailyAptitude();
                      setDialogState(() {});
                    },
                  ),
                  _buildDailyItem(
                    title: "Solve 1 Coding MCQ",
                    completed: appState.dailyCompletedCoding,
                    color: AppColors.secondary,
                    onPressed: () {
                      appState.completeDailyCoding();
                      setDialogState(() {});
                    },
                  ),
                  _buildDailyItem(
                    title: "Find a Word in Word Search",
                    completed: appState.dailyCompletedWord,
                    color: AppColors.accentGreen,
                    onPressed: () {
                      appState.completeDailyWord();
                      setDialogState(() {});
                    },
                  ),
                  _buildDailyItem(
                    title: "Win 1 Memory Cards Game",
                    completed: appState.dailyCompletedMemory,
                    color: AppColors.accentPink,
                    onPressed: () {
                      appState.completeDailyMemory();
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  if (appState.isDailyChallengeCompleted)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "All Challenges Completed! +50 Coins claimed.",
                          style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    const Text(
                      "Tip: You can manually sync completions here, or earn them naturally by playing the modules!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDailyItem({
    required String title,
    required bool completed,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Checkbox(
            value: completed,
            activeColor: color,
            onChanged: completed ? null : (_) => onPressed(),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: completed ? AppColors.textMuted : Colors.white,
                decoration: completed ? TextDecoration.lineThrough : null,
                fontSize: 14,
              ),
            ),
          ),
          if (!completed)
            TextButton(
              onPressed: onPressed,
              child: const Text("Complete", style: TextStyle(fontSize: 12, color: AppColors.secondary)),
            ),
        ],
      ),
    );
  }
}
