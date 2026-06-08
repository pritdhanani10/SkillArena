import 'package:flutter/material.dart';
import 'tic_tac_toe_screen.dart';
import 'ludo_screen.dart';
import '../../core/theme/theme.dart';

class MultiplayerMenuScreen extends StatelessWidget {
  const MultiplayerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎮 Multiplayer Hub"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassBox(color: AppColors.secondary.withOpacity(0.12)),
              child: Row(
                children: [
                  const Text("🎮", style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Real-Time Online Mocks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text(
                          "Match against simulated active players. Earn +40 XP on victories.",
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            _buildCategoryCard(
              context,
              title: "Tic Tac Toe Online",
              desc: "Simulate real-time player matchmaking and coordinate turns with emoji chat options.",
              icon: Icons.close,
              color: AppColors.secondary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TicTacToeScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCategoryCard(
              context,
              title: "Ludo Online (2-Player)",
              desc: "Fast board simulation of dice rolls and moving pawns along tracks.",
              icon: Icons.casino_outlined,
              color: AppColors.accentOrange,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LudoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: AppTheme.glassBox(border: Border.all(color: color.withOpacity(0.4))),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35)),
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
