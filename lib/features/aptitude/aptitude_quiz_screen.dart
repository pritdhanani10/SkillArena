import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';
import '../../core/models/feature_models.dart';
import '../../core/services/dynamic_data_service.dart';
import '../../shared/widgets/premium_data_loader.dart';
class AptitudeQuizScreen extends StatefulWidget {
  final String domain;
  final String topic;
  final String mode;

  const AptitudeQuizScreen({
    super.key,
    required this.domain,
    required this.topic,
    required this.mode,
  });

  @override
  State<AptitudeQuizScreen> createState() => _AptitudeQuizScreenState();
}

class _AptitudeQuizScreenState extends State<AptitudeQuizScreen> {
  late List<AptitudeQuestion> _questions;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;
  List<int> _userSelectedAnswers = [];

  // Timers
  Timer? _timer;
  int _secondsRemaining = 20;

  // Battle Mode Bot variables
  double _botProgress = 0.0;
  Timer? _botTimer;
  String _botStatus = "Rival is thinking...";

  // Confetti
  late ConfettiController _confettiController;

  // Game over state
  bool _isQuizOver = false;

  late Future<List<AptitudeQuestion>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _questionsFuture = DynamicDataService.getAptitudeQuestions(widget.topic).then((questions) {
      if (mounted) {
        setState(() {
          _questions = questions;
          _userSelectedAnswers = List<int>.filled(questions.length, -1);
        });
        _startModeActivities();
      }
      return questions;
    });
  }

  void _startModeActivities() {
    if (widget.mode == 'Timed Quiz') {
      _startTimer();
    } else if (widget.mode == 'Battle Mode') {
      _startBattleBot();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 20;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _onTimeExpired();
      }
    });
  }

  void _startBattleBot() {
    _botTimer?.cancel();
    _botProgress = 0.0;
    _botStatus = "Rival is thinking...";
    _botTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isQuizOver) {
        timer.cancel();
        return;
      }
      setState(() {
        // Randomly progress bot progress
        _botProgress += 0.007;
        if (_botProgress >= 1.0) {
          _botProgress = 1.0;
          _botStatus = "Rival finished!";
          timer.cancel();
        }
      });
    });
  }

  void _onTimeExpired() {
    setState(() {
      _selectedOptionIndex = -1; // timed out
      _userSelectedAnswers[_currentQuestionIndex] = -1;
      _isAnswered = true;
    });
  }

  void _onOptionSelected(int index) {
    if (_isAnswered) return;
    _timer?.cancel();
    setState(() {
      _selectedOptionIndex = index;
      _userSelectedAnswers[_currentQuestionIndex] = index;
      _isAnswered = true;
      if (index == _questions[_currentQuestionIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
      _startModeActivities();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    _botTimer?.cancel();
    setState(() {
      _isQuizOver = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    
    // Add XP & Coins
    appState.addXp(20);
    appState.addCoins(10);

    // Build the questions review list for detailed history
    final List<Map<String, dynamic>> questionHistory = [];
    for (int i = 0; i < _questions.length; i++) {
      questionHistory.add({
        'question': _questions[i].text,
        'options': _questions[i].options,
        'selected': _userSelectedAnswers[i],
        'correct': _questions[i].correctIndex,
        'explanation': _questions[i].explanation,
      });
    }

    appState.recordQuizResult(_score, _questions.length, questionsHistory: questionHistory);

    // Sync daily challenge
    appState.completeDailyAptitude();

    if (_score == _questions.length) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _botTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} (${widget.mode})', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Show interstitial ad simulation on exit
            MockAdWidgets.showInterstitialAd(context, onClosed: () {
              Navigator.of(context).pop();
            });
          },
        ),
      ),
      body: PremiumDataLoader<List<AptitudeQuestion>>(
        loader: () => _questionsFuture,
        loadingText: "Loading Arena Questions...",
        builder: (context, questions) {
          _questions = questions;
          final currentQuestion = _questions[_currentQuestionIndex];
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _isQuizOver ? _buildScoreCard() : _buildGameplay(currentQuestion),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [Colors.amber, Colors.lightBlue, Colors.pinkAccent, Colors.tealAccent],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameplay(AptitudeQuestion currentQuestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Battle Mode split HUD
          if (widget.mode == 'Battle Mode') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassBox(color: AppColors.surface),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Your Progress", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      Text("Q ${_currentQuestionIndex + 1}/${_questions.length}", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + (_isAnswered ? 1 : 0)) / _questions.length,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Opponent (Rival Bot)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentPink)),
                      Text(_botStatus, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _botProgress,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Question header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              if (widget.mode == 'Timed Quiz')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _secondsRemaining <= 5 
                        ? AppColors.accentPink.withOpacity(0.15) 
                        : AppColors.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _secondsRemaining <= 5 ? AppColors.accentPink : AppColors.accentOrange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer, 
                        size: 14, 
                        color: _secondsRemaining <= 5 ? AppColors.accentPink : AppColors.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${_secondsRemaining}s",
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.bold,
                          color: _secondsRemaining <= 5 ? AppColors.accentPink : AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Text
          Text(
            currentQuestion.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Options List
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentQuestion.options.length,
              itemBuilder: (context, index) {
                final option = currentQuestion.options[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildOptionCard(index, option, currentQuestion.correctIndex),
                );
              },
            ),
          ),

          // Explanation Banner
          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.glassBox(
                color: AppColors.surfaceLight.withOpacity(0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.accentYellow, size: 18),
                      SizedBox(width: 6),
                      Text("Explanation", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentYellow)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentQuestion.explanation,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _nextQuestion,
              child: Text(
                _currentQuestionIndex == _questions.length - 1 ? "View Scorecard" : "Next Question",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String option, int correctIndex) {
    bool isSelected = _selectedOptionIndex == index;
    bool isCorrect = index == correctIndex;
    
    Color cardColor = AppColors.surface;
    Color borderColor = AppColors.border;
    Widget trailingIcon = const SizedBox.shrink();

    if (_isAnswered) {
      if (isCorrect) {
        cardColor = AppColors.accentGreen.withOpacity(0.12);
        borderColor = AppColors.accentGreen;
        trailingIcon = const Icon(Icons.check_circle, color: AppColors.accentGreen);
      } else if (isSelected) {
        cardColor = AppColors.accentPink.withOpacity(0.12);
        borderColor = AppColors.accentPink;
        trailingIcon = const Icon(Icons.cancel, color: AppColors.accentPink);
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primary;
      }
    }

    return InkWell(
      onTap: _isAnswered ? null : () => _onOptionSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                option,
                style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            trailingIcon,
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    double accuracy = _score / _questions.length;
    bool isWinner = widget.mode != 'Battle Mode' || _botProgress < 1.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "QUIZ COMPLETE",
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900, 
                  color: accuracy >= 0.7 ? AppColors.accentGreen : AppColors.accentOrange,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Results percentage ring simulation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accuracy >= 0.7 ? AppColors.accentGreen : AppColors.accentOrange, 
                    width: 6,
                  ),
                ),
                child: Center(
                  child: Text(
                    "${(accuracy * 100).round()}%",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              if (widget.mode == 'Battle Mode') ...[
                Text(
                  isWinner ? "👑 Victory! You defeated the Rival!" : "❌ Defeat! The Rival solved faster.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isWinner ? AppColors.accentGreen : AppColors.accentPink,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Text(
                "You answered $_score out of ${_questions.length} questions correctly.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // Rewards Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("🪙 +10", style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Coins Rewarded", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                    VerticalDivider(color: AppColors.border, width: 20, thickness: 1),
                    Column(
                      children: [
                        Text("⚡ +20", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("XP Gained", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Show interstitial ad simulation on exit
                  MockAdWidgets.showInterstitialAd(context, onClosed: () {
                    Navigator.of(context).pop();
                  });
                },
                child: const Text("Return to Arena", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
