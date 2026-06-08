import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class VocabularyBuilderScreen extends StatefulWidget {
  const VocabularyBuilderScreen({super.key});

  @override
  State<VocabularyBuilderScreen> createState() => _VocabularyBuilderScreenState();
}

class _VocabularyBuilderScreenState extends State<VocabularyBuilderScreen> {
  final List<Map<String, String>> _dailyWords = [
    {
      'word': 'Perseverance',
      'meaning': 'Persistence in doing something despite difficulty or delay in achieving success.',
      'example': 'Preparing for placements requires consistency and perseverance.',
      'synonyms': 'Persistence, tenacity, determination',
      'antonyms': 'Apathy, laziness, weakness',
    },
    {
      'word': 'Cognitive',
      'meaning': 'Relating to, being, or involving conscious intellectual activity (such as thinking, reasoning, or remembering).',
      'example': 'Brain training games improve cognitive adaptability and reasoning speeds.',
      'synonyms': 'Mental, intellectual, analytical',
      'antonyms': 'Physical, visceral',
    },
    {
      'word': 'Optimistic',
      'meaning': 'Hopeful and confident about the future or the success of something.',
      'style': 'Positive and forward-looking.',
      'example': 'Remain optimistic during interview sessions; confidence is key.',
      'synonyms': 'Hopeful, positive, confident',
      'antonyms': 'Pessimistic, gloomy',
    }
  ];

  int _wordIndex = 0;
  bool _quizMode = false;
  int _quizQuestionIdx = 0;
  int? _selectedAnswerIdx;
  bool _quizChecked = false;
  int _quizScore = 0;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'Which word matches the definition: "Persistence despite difficulty or delay"?',
      'options': ['Cognitive', 'Perseverance', 'Optimistic', 'Apathy'],
      'correct': 1,
    },
    {
      'question': 'What is a direct antonym of "Optimistic"?',
      'options': ['Pessimistic', 'Hopeful', 'Diligent', 'Tenacious'],
      'correct': 0,
    }
  ];

  void _nextWord() {
    setState(() {
      _wordIndex = (_wordIndex + 1) % _dailyWords.length;
    });
  }

  void _submitQuizAnswer(int index) {
    if (_quizChecked) return;
    setState(() {
      _selectedAnswerIdx = index;
      _quizChecked = true;
      if (index == _quizQuestions[_quizQuestionIdx]['correct']) {
        _quizScore++;
      }
    });
  }

  void _nextQuizQuestion() {
    if (_quizQuestionIdx < _quizQuestions.length - 1) {
      setState(() {
        _quizQuestionIdx++;
        _selectedAnswerIdx = null;
        _quizChecked = false;
      });
    } else {
      // End quiz, award coins
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addCoins(10);
      appState.addXp(10);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text("Quiz Complete!"),
            content: Text(
              "You scored $_quizScore out of ${_quizQuestions.length} correct. +10 Coins added to your purse.",
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _quizMode = false;
                    _quizQuestionIdx = 0;
                    _selectedAnswerIdx = null;
                    _quizChecked = false;
                    _quizScore = 0;
                  });
                },
                child: const Text("Return to Dictionary"),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = _dailyWords[_wordIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Vocabulary Builder"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Mode selector (Daily Word vs Vocabulary Quiz)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_quizMode ? AppColors.primary : AppColors.surface,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _quizMode = false),
                    child: const Text("Daily Words"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _quizMode ? AppColors.primary : AppColors.surface,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _quizMode = true),
                    child: const Text("Retention Quiz"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content card
            Expanded(
              child: _quizMode ? _buildQuizView() : _buildWordView(word),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordView(Map<String, String> word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    word['word']!,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: AppColors.secondary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Pronouncing: ${word['word']!}"),
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              const Text("MEANING", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(
                word['meaning']!,
                style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45),
              ),
              const SizedBox(height: 20),
              const Text("USAGE EXAMPLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentOrange, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(
                "\"${word['example']!}\"",
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SYNONYMS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(word['synonyms']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ANTONYMS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(word['antonyms']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              side: const BorderSide(color: AppColors.border),
            ),
            onPressed: _nextWord,
            child: const Text("Next Word", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    final quiz = _quizQuestions[_quizQuestionIdx];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Question ${_quizQuestionIdx + 1} of ${_quizQuestions.length}",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Text(
                quiz['question']!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
              ),
              const SizedBox(height: 24),
              
              // Options
              ...List.generate(quiz['options'].length, (index) {
                final option = quiz['options'][index];
                
                Color borderCol = AppColors.border;
                Color fillCol = AppColors.surfaceLight;

                if (_quizChecked) {
                  if (index == quiz['correct']) {
                    borderCol = AppColors.accentGreen;
                    fillCol = AppColors.accentGreen.withOpacity(0.1);
                  } else if (index == _selectedAnswerIdx) {
                    borderCol = AppColors.accentPink;
                    fillCol = AppColors.accentPink.withOpacity(0.1);
                  }
                } else if (_selectedAnswerIdx == index) {
                  borderCol = AppColors.primary;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: _quizChecked ? null : () => _submitQuizAnswer(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: fillCol,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderCol, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(option, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          if (_quizChecked && index == quiz['correct'])
                            const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20)
                          else if (_quizChecked && index == _selectedAnswerIdx)
                            const Icon(Icons.cancel, color: AppColors.accentPink, size: 20)
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          if (_quizChecked)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: _nextQuizQuestion,
              child: const Text("Next Question", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
