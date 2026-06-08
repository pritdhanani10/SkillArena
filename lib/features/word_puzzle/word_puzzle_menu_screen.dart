import 'package:flutter/material.dart';
import 'word_search_screen.dart';
import 'vocabulary_builder_screen.dart';
import '../../core/theme/theme.dart';

class WordPuzzleMenuScreen extends StatelessWidget {
  const WordPuzzleMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔤 Word Puzzle Arena"),
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
              decoration: AppTheme.glassBox(color: AppColors.accentGreen.withOpacity(0.12)),
              child: Row(
                children: [
                  const Text("🔤", style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Word Puzzles & Vocabulary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text(
                          "Enrich computer science definitions and vocab retention. Earn +20 Coins per completed search.",
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
              title: "Word Search Game",
              desc: "Find hidden computer science terms inside a randomized letter grid.",
              icon: Icons.grid_on,
              color: AppColors.accentGreen,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const WordSearchScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildCategoryCard(
              context,
              title: "Vocabulary Builder",
              desc: "Learn new aptitude words daily, review meanings, and complete word retention quizzes.",
              icon: Icons.menu_book,
              color: AppColors.primary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const VocabularyBuilderScreen()),
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
