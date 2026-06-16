import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import 'history_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Upper Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textPrimary, size: 24),
                onPressed: () => Navigator.of(context).pushNamed("/settings"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header details
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: appState.isPremium ? AppColors.premiumGradient : AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      appState.username.isNotEmpty ? appState.username[0].toUpperCase() : 'G',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appState.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    if (appState.isPremium) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: AppColors.secondary, size: 18),
                    ],
                  ],
                ),
                Text(appState.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Statistics: Accuracy Radial charts
          const Text("Performance Metrics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "Quiz Accuracy",
                  percent: appState.quizAccuracy,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: "Games Won",
                  centerValue: "${appState.totalGamesWon}",
                  percent: min(appState.totalGamesWon / 20.0, 1.0),
                  color: AppColors.accentPink,
                  customLabel: "Goal: 20 wins",
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Unlocked Badges
          const Text("Achievements & Badges", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: appState.unlockedBadges.length,
              itemBuilder: (context, index) {
                final badge = appState.unlockedBadges[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: AppTheme.glassBox(
                      border: Border.all(color: AppColors.accentYellow.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🏅", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 6),
                        Text(
                          badge,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),



          // Persistent Activity History Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassBox(
              border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history, color: AppColors.secondary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Activity History",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    if (appState.historyLogs.isNotEmpty)
                      Text(
                        "${appState.historyLogs.length} attempts",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Review your quiz scores, questions, correct answers, and detailed explanations for all quantitative test attempts and coding mock practices.",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.15),
                    foregroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.secondary, width: 1.5),
                    ),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.analytics, size: 18),
                  label: const Text("View Detailed History", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout / Login actions
          if (appState.isLoggedIn)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink.withOpacity(0.12),
                foregroundColor: AppColors.accentPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.accentPink),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                appState.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out from Firebase Realtime Database.")),
                );
              },
              child: const Text("Log Out from Firebase", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed("/auth");
              },
              child: const Text("Login / Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    double? percent,
    String? centerValue,
    required Color color,
    String? customLabel,
  }) {
    final displayValue = centerValue ?? "${(percent! * 100).round()}%";
    final pctVal = percent ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassBox(),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          // Custom circular paint progress
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 65,
                  height: 65,
                  child: CircularProgressIndicator(
                    value: pctVal,
                    strokeWidth: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(displayValue, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customLabel ?? "Accuracy rating",
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }


}
