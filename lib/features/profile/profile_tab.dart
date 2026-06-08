import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

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
                icon: const Icon(Icons.settings, color: Colors.white, size: 24),
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
          const Text("Performance Metrics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          const Text("Achievements & Badges", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Theme Switcher Section
          const Text("Visual Interface Theme", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassBox(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose your arena styling theme:",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    _buildThemeOption(context, appState, 'cyberpunk', 'Cyberpunk', [const Color(0xFF7C3AED), const Color(0xFF06B6D4)]),
                    _buildThemeOption(context, appState, 'emerald', 'Forest', [const Color(0xFF10B981), const Color(0xFF34D399)]),
                    _buildThemeOption(context, appState, 'sunset', 'Synthwave', [const Color(0xFFEC4899), const Color(0xFFF97316)]),
                    _buildThemeOption(context, appState, 'glacier', 'Glacier', [const Color(0xFF0EA5E9), const Color(0xFF22D3EE)]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Database Sync logs console view
          const Row(
            children: [
              Icon(Icons.cloud_sync, color: AppColors.secondary, size: 18),
              SizedBox(width: 8),
              Text("Firebase Realtime DB Sync Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF06070B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: appState.dbSyncLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    appState.dbSyncLogs[index],
                    style: const TextStyle(fontFamily: 'Courier New', fontSize: 11, color: AppColors.accentGreen),
                  ),
                );
              },
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
                Text(displayValue, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildThemeOption(
    BuildContext context,
    AppState appState,
    String id,
    String name,
    List<Color> palette,
  ) {
    final isSelected = appState.selectedTheme == id;
    return InkWell(
      onTap: () {
        appState.setTheme(id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? palette[0].withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? palette[0] : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: palette[0],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: palette[1],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
