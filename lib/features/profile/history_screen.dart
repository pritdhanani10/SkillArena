import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final historyLogs = appState.historyLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detailed Activity History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: historyLogs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("✨", style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text(
                      "No activity logged yet.",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Complete quizzes or practice tasks to build your history log.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: historyLogs.length,
                itemBuilder: (context, index) {
                  final log = historyLogs[index];
                  final hasReview = log.containsKey('questions') && (log['questions'] as List).isNotEmpty;
                  final featureColor = _getFeatureColor(log['feature'] ?? '');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      decoration: AppTheme.glassBox(
                        border: Border.all(color: featureColor.withOpacity(0.3)),
                      ),
                      child: ListTile(
                        onTap: hasReview
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AttemptReviewScreen(log: log),
                                  ),
                                );
                              }
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: featureColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getFeatureIcon(log['feature'] ?? ''),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                log['feature'] ?? 'Activity',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                              ),
                            ),
                            Text(
                              _formatTime(log['date']),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${log['details'] ?? ''} • ${log['result'] ?? ''}",
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              if (hasReview) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.rate_review, color: featureColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Tap to Review Answers",
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: featureColor),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                        trailing: hasReview
                            ? Icon(Icons.arrow_forward_ios, color: featureColor, size: 14)
                            : null,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _getFeatureIcon(String feature) {
    final f = feature.toLowerCase();
    if (f.contains('aptitude')) return '🧠';
    if (f.contains('coding')) return '💻';
    if (f.contains('word')) return '🔤';
    if (f.contains('memory')) return '🎯';
    if (f.contains('vocab')) return '📖';
    if (f.contains('resume')) return '📝';
    if (f.contains('security') || f.contains('login') || f.contains('mpin')) return '🔐';
    if (f.contains('game')) return '🎮';
    return '⚡';
  }

  Color _getFeatureColor(String feature) {
    final f = feature.toLowerCase();
    if (f.contains('aptitude')) return AppColors.primary;
    if (f.contains('coding')) return AppColors.secondary;
    if (f.contains('word') || f.contains('vocab')) return AppColors.accentGreen;
    if (f.contains('memory') || f.contains('game')) return AppColors.accentPink;
    if (f.contains('resume')) return AppColors.accentYellow;
    return Colors.white70;
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) {
        return "Just now";
      } else if (diff.inHours < 1) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inDays < 1) {
        return "${diff.inHours}h ago";
      } else {
        return "${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
    } catch (_) {
      return '';
    }
  }
}

class AttemptReviewScreen extends StatelessWidget {
  final Map<String, dynamic> log;

  const AttemptReviewScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final questionsList = log['questions'] as List<dynamic>;
    final feature = log['feature'] ?? 'Quiz';
    final details = log['details'] ?? '';
    final result = log['result'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("$feature Review"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassBox(
                border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text("🎯 Score Results", style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    result,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("Questions Detail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            // Scrollable List of questions
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questionsList.length,
              itemBuilder: (context, index) {
                final q = Map<String, dynamic>.from(questionsList[index]);
                final questionText = q['question'] ?? '';
                final codeSnippet = q['codeSnippet'] ?? '';
                final options = List<String>.from(q['options'] ?? []);
                final selectedIdx = q['selected'] as int?;
                final correctIdx = q['correct'] as int?;
                final explanation = q['explanation'] ?? '';

                final isCorrect = selectedIdx == correctIdx;

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassBox(
                    border: Border.all(
                      color: isCorrect 
                          ? AppColors.accentGreen.withOpacity(0.4) 
                          : AppColors.accentPink.withOpacity(0.4)
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Number & correctness tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Question ${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCorrect 
                                  ? AppColors.accentGreen.withOpacity(0.12) 
                                  : AppColors.accentPink.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCorrect ? "✔ Correct" : "❌ Incorrect",
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                                color: isCorrect ? AppColors.accentGreen : AppColors.accentPink
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Question text
                      Text(
                        questionText,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),

                      // Code snippet (if any, e.g. for coding problems)
                      if (codeSnippet.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Text(
                            codeSnippet,
                            style: TextStyle(
                              fontFamily: 'Courier New', 
                              fontSize: 12, 
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Options list
                      Column(
                        children: List.generate(options.length, (optIdx) {
                          final isThisSelected = selectedIdx == optIdx;
                          final isThisCorrect = correctIdx == optIdx;

                          Color optionBorderColor = AppColors.border;
                          Color optionBgColor = Colors.transparent;
                          IconData? suffixIcon;
                          Color suffixColor = Colors.white54;

                          if (isThisCorrect) {
                            optionBorderColor = AppColors.accentGreen;
                            optionBgColor = AppColors.accentGreen.withOpacity(0.12);
                            suffixIcon = Icons.check_circle;
                            suffixColor = AppColors.accentGreen;
                          } else if (isThisSelected) {
                            optionBorderColor = AppColors.accentPink;
                            optionBgColor = AppColors.accentPink.withOpacity(0.12);
                            suffixIcon = Icons.cancel;
                            suffixColor = AppColors.accentPink;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: optionBgColor,
                              border: Border.all(color: optionBorderColor, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                options[optIdx],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: (isThisCorrect || isThisSelected) ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontWeight: (isThisCorrect || isThisSelected) ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: suffixIcon != null
                                  ? Icon(suffixIcon, color: suffixColor, size: 18)
                                  : null,
                            ),
                          );
                        }),
                      ),

                      // If selected index was -1 / timeout
                      if (selectedIdx == -1) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: AppColors.accentYellow, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "You timed out and did not select an answer.",
                              style: TextStyle(color: AppColors.accentYellow, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],

                      // Explanation block
                      if (explanation.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Explanation:",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                explanation,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
