import 'package:flutter/material.dart';
import 'memory_cards_screen.dart';
import 'pattern_matching_screen.dart';
import '../../core/theme/theme.dart';

class BrainTrainingMenuScreen extends StatelessWidget {
  const BrainTrainingMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Brain Gym"),
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
              decoration: AppTheme.glassBox(color: AppColors.accentPink.withOpacity(0.12)),
              child: Row(
                children: [
                  const Text("🎯", style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Cognitive Adaptability", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text(
                          "Sharpen pattern recalls and speed reactions. Earn +20 Coins and +20 XP per session completion.",
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
              title: "Memory Cards (Match)",
              desc: "Tap cards in a grid layout to discover and match emoji pairs in minimal moves.",
              icon: Icons.grid_view_outlined,
              color: AppColors.accentPink,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MemoryCardsScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCategoryCard(
              context,
              title: "Pattern Matching (Simon)",
              desc: "Observe flashing color sequences and repeat them correctly to level up.",
              icon: Icons.smart_toy_outlined,
              color: AppColors.accentOrange,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PatternMatchingScreen()),
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
