import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';

class AptitudeQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const AptitudeQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadQuestions();
    _startModeActivities();
  }

  void _loadQuestions() {
    final allQuestions = {
      'Percentage': [
        const AptitudeQuestion(
          text: "If 20% of a number is 120, then 120% of that number is:",
          options: ["480", "720", "360", "240"],
          correctIndex: 1,
          explanation: "Let the number be x. 20% of x = 120 => (20/100)*x = 120 => x = 600. Therefore, 120% of x = (120/100)*600 = 720.",
        ),
        const AptitudeQuestion(
          text: "A student has to secure 40% marks to pass. He gets 178 marks and fails by 22 marks. The maximum marks are:",
          options: ["500", "400", "600", "800"],
          correctIndex: 0,
          explanation: "Passing marks = 178 + 22 = 200. Since 40% of maximum marks = 200, Max Marks = 200 * (100/40) = 500.",
        ),
        const AptitudeQuestion(
          text: "If the price of a book is first decreased by 25% and then increased by 20%, the net change in the price will be:",
          options: ["No change", "10% decrease", "5% decrease", "8% increase"],
          correctIndex: 1,
          explanation: "Let original price be 100. Decreased by 25% = 75. Increased by 20% = 75 + (20% of 75) = 75 + 15 = 90. Net change = 100 to 90 (10% decrease).",
        ),
      ],
      'Profit Loss': [
        const AptitudeQuestion(
          text: "A shopkeeper sells a refrigerator for ₹22,000 at a profit of 10%. If he sells it for ₹18,000, what is his loss percentage?",
          options: ["5%", "8%", "10%", "12%"],
          correctIndex: 2,
          explanation: "Selling Price (SP) = ₹22,000. Profit = 10%. Cost Price (CP) = SP * 100 / (100+Profit%) = 22000 * 100/110 = ₹20,000. New SP = ₹18,000. Loss = 20000 - 18000 = 2000. Loss% = (2000/20000)*100 = 10%.",
        ),
        const AptitudeQuestion(
          text: "If cost price of 15 articles is equal to the selling price of 12 articles, find the gain percentage.",
          options: ["20%", "25%", "30%", "15%"],
          correctIndex: 1,
          explanation: "Let CP of each article be ₹1. CP of 15 articles = ₹15. SP of 12 articles = CP of 15 articles = ₹15. CP of 12 articles = ₹12. Gain = SP - CP = 15 - 12 = 3. Gain% = (3/12)*100 = 25%.",
        ),
      ],
      'Time Work': [
        const AptitudeQuestion(
          text: "A can do a piece of work in 10 days and B in 15 days. Working together, in how many days can they complete the work?",
          options: ["5 days", "6 days", "8 days", "7 days"],
          correctIndex: 1,
          explanation: "A's 1 day work = 1/10. B's 1 day work = 1/15. Together 1 day work = 1/10 + 1/15 = 5/30 = 1/6. Hence, they complete in 6 days.",
        ),
      ],
      'Blood Relations': [
        const AptitudeQuestion(
          text: "Pointing to a photograph of a boy, Suresh said, 'He is the son of the only son of my mother.' How Suresh is related to that boy?",
          options: ["Brother", "Uncle", "Father", "Cousin"],
          correctIndex: 2,
          explanation: "The 'only son of Suresh's mother' is Suresh himself. Therefore, the boy in the photo is the son of Suresh. Suresh is the father.",
        ),
      ],
      'Synonyms': [
        const AptitudeQuestion(
          text: "Choose the correct synonym of the word: DILIGENT",
          options: ["Lazy", "Intelligent", "Hard-working", "Clever"],
          correctIndex: 2,
          explanation: "Diligent means having or showing care and conscientiousness in one's work. Synonym is hard-working.",
        ),
      ],
    };

    // Fallback if topic is empty or not in dictionary
    _questions = allQuestions[widget.topic] ?? [
      AptitudeQuestion(
        text: "Solve this general aptitude puzzle: What is next in sequence 2, 4, 8, 16, ...?",
        options: const ["32", "24", "64", "48"],
        correctIndex: 0,
        explanation: "The sequence doubles each term. Next is 16 * 2 = 32.",
      ),
      AptitudeQuestion(
        text: "Under ${widget.topic}, which of the following is correct?",
        options: const ["Option A", "Option B", "Option C", "Option D"],
        correctIndex: 1,
        explanation: "Option B is correct for this general template.",
      )
    ];
  }

  void _startModeActivities() {
    if (widget.mode == 'Timed Quiz') {
      _startTimer();
    } else if (widget.mode == 'Battle Mode') {
      _startBattleBot();
    }
  }

  void _startTimer() {
    final appState = Provider.of<AppState>(context, listen: false);
    _secondsRemaining = appState.quizTimeLimit;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _onTimeExpired();
      }
    });
  }

  void _startBattleBot() {
    _botProgress = 0.0;
    _botStatus = "Rival is thinking...";
    _botTimer?.cancel();
    _botTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
      _isAnswered = true;
    });
  }

  void _onOptionSelected(int index) {
    if (_isAnswered) return;
    _timer?.cancel();
    setState(() {
      _selectedOptionIndex = index;
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
    appState.recordQuizResult(_score, _questions.length);

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
    final currentQuestion = _questions[_currentQuestionIndex];

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
      body: Stack(
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
