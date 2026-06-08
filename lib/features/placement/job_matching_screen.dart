import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';

class MockJob {
  final String id;
  final String companyName;
  final String logo;
  final String role;
  final int minLevel;
  final String requiredSkill;
  final int coinCost;
  final int xpReward;
  final int coinReward;
  final List<String> quizQuestions;
  final List<List<String>> quizOptions;
  final List<int> quizCorrectAnswers;
  final List<String> quizExplanations;
  final String badgeToUnlock;

  const MockJob({
    required this.id,
    required this.companyName,
    required this.logo,
    required this.role,
    required this.minLevel,
    required this.requiredSkill,
    required this.coinCost,
    required this.xpReward,
    required this.coinReward,
    required this.quizQuestions,
    required this.quizOptions,
    required this.quizCorrectAnswers,
    required this.quizExplanations,
    required this.badgeToUnlock,
  });
}

class JobMatchingScreen extends StatefulWidget {
  const JobMatchingScreen({super.key});

  @override
  State<JobMatchingScreen> createState() => _JobMatchingScreenState();
}

class _JobMatchingScreenState extends State<JobMatchingScreen> {
  final List<MockJob> _jobs = [
    const MockJob(
      id: 'google',
      companyName: 'Google',
      logo: 'G',
      role: 'SDE-1 (Cloud Core)',
      minLevel: 3,
      requiredSkill: 'java',
      coinCost: 50,
      xpReward: 100,
      coinReward: 50,
      badgeToUnlock: 'Google SDE Pioneer',
      quizQuestions: [
        "What is the average time complexity of searching in a HashMap?",
        "Which graph traversal uses a FIFO Queue structure?",
        "What does ACID stand for in Database Transactions?",
      ],
      quizOptions: [
        ["O(1)", "O(log N)", "O(N)", "O(N^2)"],
        ["Depth First Search (DFS)", "Breadth First Search (BFS)", "Dijkstra's Algorithm", "A* Search"],
        ["Atomicity, Consistency, Isolation, Durability", "Action, Code, Index, Data", "Automated, Concurrent, Integrated, Distributed", "None of the above"],
      ],
      quizCorrectAnswers: [0, 1, 0],
      quizExplanations: [
        "HashMap utilizes hash tables providing O(1) average time complexity for lookups.",
        "Breadth-First Search (BFS) explores neighbor nodes layer-by-layer using a FIFO queue.",
        "ACID stands for Atomicity, Consistency, Isolation, and Durability, ensuring transaction integrity.",
      ],
    ),
    const MockJob(
      id: 'amazon',
      companyName: 'Amazon',
      logo: 'A',
      role: 'Cloud Associate',
      minLevel: 2,
      requiredSkill: 'sql',
      coinCost: 30,
      xpReward: 80,
      coinReward: 40,
      badgeToUnlock: 'Amazon Cloud Cadet',
      quizQuestions: [
        "Which AWS service is used for scalable compute capacity in the cloud?",
        "What SQL command retrieves only unique values from a column?",
        "Which Cloud Computing model represents Gmail or Google Docs?",
      ],
      quizOptions: [
        ["S3", "EC2", "RDS", "Lambda"],
        ["UNIQUE", "DISTINCT", "DIFFERENT", "GROUP BY"],
        ["IaaS", "PaaS", "SaaS", "FaaS"],
      ],
      quizCorrectAnswers: [1, 1, 2],
      quizExplanations: [
        "EC2 (Elastic Compute Cloud) provides secure, resizable virtual servers in the cloud.",
        "The DISTINCT keyword filters duplicate values in SQL query results.",
        "Gmail/Docs represent SaaS (Software as a Service) where end-user apps are delivered over the web.",
      ],
    ),
    const MockJob(
      id: 'tcs',
      companyName: 'TCS',
      logo: 'T',
      role: 'Ninja/Digital Systems',
      minLevel: 1,
      requiredSkill: 'python',
      coinCost: 0,
      xpReward: 50,
      coinReward: 25,
      badgeToUnlock: 'TCS Certified Ninja',
      quizQuestions: [
        "Which data structure is LIFO (Last In First Out)?",
        "Which of these is NOT a pillar of Object Oriented Programming?",
        "What does HTML stand for?",
      ],
      quizOptions: [
        ["Queue", "Stack", "Linked List", "Tree"],
        ["Inheritance", "Encapsulation", "Polymorphism", "Compilation"],
        ["Hyper Text Markup Language", "Home Tool Markup Language", "Hyperlink Text Management Layout", "None of these"],
      ],
      quizCorrectAnswers: [1, 3, 0],
      quizExplanations: [
        "A stack is a linear data structure following the LIFO principle.",
        "The OOP pillars are Abstraction, Encapsulation, Inheritance, and Polymorphism. Compilation is not one.",
        "HTML stands for Hyper Text Markup Language.",
      ],
    ),
    const MockJob(
      id: 'startup',
      companyName: 'Unicorn Startup',
      logo: 'U',
      role: 'Flutter Frontend Engineer',
      minLevel: 2,
      requiredSkill: 'flutter',
      coinCost: 20,
      xpReward: 70,
      coinReward: 35,
      badgeToUnlock: 'Startup Disruptor',
      quizQuestions: [
        "In Flutter, which widget is typically used for a scrollable linear list of items?",
        "What is the main advantage of React's Virtual DOM?",
        "Which HTTP method is typically used to create a new resource on a server?",
      ],
      quizOptions: [
        ["ListView", "Column", "SingleChildScrollView", "Stack"],
        ["Direct browser execution", "Minimizes direct manipulation of heavy browser DOM", "Stores application data globally", "Automatically formats code styling"],
        ["GET", "PUT", "POST", "DELETE"],
      ],
      quizCorrectAnswers: [0, 1, 2],
      quizExplanations: [
        "ListView is the most commonly used scrollable widget for list records.",
        "The Virtual DOM batches updates, minimizing expensive operations on the real browser DOM tree.",
        "POST is used to submit data to be processed, creating a new resource.",
      ],
    ),
  ];

  // Simulator Stages
  // 'list': job selection board
  // 'screening': animated review loader
  // 'quiz': technical round questions
  // 'hired': congratulatory screen with rewards
  String _stage = 'list';

  MockJob? _selectedJob;
  int _currentQuizIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _correctCount = 0;

  // Screening animation steps
  int _screeningStep = 0;
  Timer? _screeningTimer;
  final List<String> _screeningTexts = [
    "Scanning database for matched resumes...",
    "Verifying applicant eligibility level...",
    "Parsing technical resume keyword patterns...",
    "Evaluating SkillArena streak activity bonus...",
    "Shortlisting complete! Accessing portal...",
  ];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _screeningTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _applyForJob(MockJob job, AppState appState) async {
    // 1. Verify Prerequisites
    if (appState.level < job.minLevel) {
      _showErrorDialog("Prerequisite Failed", "Level is too low. This job requires Level ${job.minLevel}. Practice quantitative, logical and coding modules to level up!");
      return;
    }

    if (appState.savedResumes.isEmpty) {
      _showErrorDialog("Resume Missing", "You have not created a resume. Please launch the 'Resume Builder Wizard' to build and archive a resume first.");
      return;
    }

    // Check skills
    bool skillMatched = false;
    for (var resume in appState.savedResumes) {
      final skillsStr = (resume['skills'] ?? '').toString().toLowerCase();
      if (skillsStr.contains(job.requiredSkill.toLowerCase())) {
        skillMatched = true;
        break;
      }
    }

    if (!skillMatched) {
      _showErrorDialog("Skills Mismatch", "None of your archived resumes list the required skill: '${job.requiredSkill}'. Please update your resume to include this skill.");
      return;
    }

    if (appState.coins < job.coinCost) {
      _showErrorDialog("Coins Required", "You have ${appState.coins} coins but this application fee is ${job.coinCost} coins. Complete daily challenges to earn coins.");
      return;
    }

    // 2. Accept and Deduct coins
    if (job.coinCost > 0) {
      await appState.spendCoins(job.coinCost);
    }

    setState(() {
      _selectedJob = job;
      _stage = 'screening';
      _screeningStep = 0;
    });

    // 3. Start Screening Simulation
    _screeningTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_screeningStep < _screeningTexts.length - 1) {
        setState(() {
          _screeningStep++;
        });
      } else {
        timer.cancel();
        _startTechnicalRound();
      }
    });
  }

  void _startTechnicalRound() {
    setState(() {
      _stage = 'quiz';
      _currentQuizIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswered = false;
      _correctCount = 0;
    });
  }

  void _onAnswerSelected(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index == _selectedJob!.quizCorrectAnswers[_currentQuizIndex]) {
        _correctCount++;
      }
    });
  }

  void _nextQuizQuestion() {
    if (_currentQuizIndex < _selectedJob!.quizQuestions.length - 1) {
      setState(() {
        _currentQuizIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      _finishAssessment();
    }
  }

  void _finishAssessment() {
    if (_correctCount >= 2) {
      // Hired!
      setState(() {
        _stage = 'hired';
      });
      _confettiController.play();
      
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addXp(_selectedJob!.xpReward);
      appState.addCoins(_selectedJob!.coinReward);
      appState.unlockBadge(_selectedJob!.badgeToUnlock);
    } else {
      // Failed
      _showFailureDialog();
    }
  }

  void _showErrorDialog(String title, String desc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: Text(desc, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got It"),
            )
          ],
        );
      },
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("Interview Feedback", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: Text(
            "Unfortunately, you answered only $_correctCount out of ${_selectedJob!.quizQuestions.length} questions correctly. The recruiter recommends reviewing technical core notes and trying again.",
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _stage = 'list';
                });
              },
              child: const Text("Return to Board"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("💼 AI Career Pathfinder"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_stage == 'quiz' || _stage == 'screening') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text("Abort application?"),
                  content: const Text("Your fee is non-refundable if you exit mid-screening."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Abort", style: TextStyle(color: AppColors.accentPink)),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          if (_stage == 'list') _buildJobBoard(appState),
          if (_stage == 'screening') _buildScreeningLoader(),
          if (_stage == 'quiz') _buildQuizView(),
          if (_stage == 'hired') _buildOfferLetter(appState),
          
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

  Widget _buildJobBoard(AppState appState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Pathfinder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.glassBox(
              color: AppColors.primary.withOpacity(0.12),
            ),
            child: const Row(
              children: [
                Text("🚀", style: TextStyle(fontSize: 40)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Career Pathfinder Board",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Apply to simulated corporations. Pass screening and assessments to secure credentials and rewards.",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Open Placements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _jobs.length,
            itemBuilder: (context, index) {
              final job = _jobs[index];
              final meetsLvl = appState.level >= job.minLevel;
              final color = job.id == 'google' 
                  ? const Color(0xFFEA4335) 
                  : (job.id == 'amazon' ? const Color(0xFFFF9900) : AppColors.secondary);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: AppTheme.glassBox(
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: color.withOpacity(0.5)),
                            ),
                            child: Center(
                              child: Text(
                                job.logo,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.role,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  job.companyName,
                                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: job.coinCost > 0 ? AppColors.accentYellow.withOpacity(0.12) : AppColors.accentGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job.coinCost > 0 ? "🪙 ${job.coinCost}" : "FREE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: job.coinCost > 0 ? AppColors.accentYellow : AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("PREREQUISITE", style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(
                                "Level ${job.minLevel} + Skill: '${job.requiredSkill}'",
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: meetsLvl ? Colors.white70 : AppColors.accentPink,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("REWARDS", style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(
                                "+${job.xpReward} XP / +${job.coinReward} Coins",
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: meetsLvl ? AppColors.primary : AppColors.surfaceLight,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          disabledBackgroundColor: AppColors.surfaceLight,
                        ),
                        onPressed: () => _applyForJob(job, appState),
                        child: Text(
                          meetsLvl ? "Apply & Start Screening" : "Level ${job.minLevel} Required",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningLoader() {
    final pct = (_screeningStep + 1) / _screeningTexts.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: AppTheme.glassBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "RECRUITER REVIEW IN PROGRESS",
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _screeningTexts[_screeningStep],
                  key: ValueKey<int>(_screeningStep),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizView() {
    final qIndex = _currentQuizIndex;
    final total = _selectedJob!.quizQuestions.length;
    final question = _selectedJob!.quizQuestions[qIndex];
    final options = _selectedJob!.quizOptions[qIndex];
    final correct = _selectedJob!.quizCorrectAnswers[qIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Technical Assessment: ${_selectedJob!.companyName}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              Text(
                "${qIndex + 1}/$total",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                bool isSelected = _selectedAnswerIndex == index;
                bool isCorrect = index == correct;

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
                } else if (isSelected) {
                  borderColor = AppColors.primary;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: _isAnswered ? null : () => _onAnswerSelected(index),
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
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          trailingIcon,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.glassBox(
                color: AppColors.surfaceLight.withOpacity(0.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.accentYellow, size: 16),
                      SizedBox(width: 6),
                      Text("Solution Breakdown", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentYellow, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedJob!.quizExplanations[qIndex],
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _nextQuizQuestion,
              child: Text(
                qIndex == total - 1 ? "Submit Assessment" : "Next Question",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferLetter(AppState appState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: AppTheme.glassBox(
            border: Border.all(color: AppColors.accentGreen.withOpacity(0.5), width: 2),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("👑", style: TextStyle(fontSize: 54)),
              const SizedBox(height: 12),
              const Text(
                "PLACEMENT SECURED!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentGreen,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              
              // Offer body
              Text(
                "OFFER OF EMPLOYMENT",
                style: TextStyle(fontFamily: 'Courier New', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 12),
              Text(
                "This certifies that applicant '${appState.username}' has successfully qualified through the technical and behavioral screening protocols of ${_selectedJob!.companyName} and is hereby offered the position of ${_selectedJob!.role}.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              
              // Rewards info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("+${_selectedJob!.coinReward}", style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Coins credited", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                    Container(height: 24, width: 1, color: AppColors.border),
                    Column(
                      children: [
                        Text("+${_selectedJob!.xpReward}", style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("XP Credited", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Achievement Chip
              Chip(
                backgroundColor: AppColors.accentYellow.withOpacity(0.12),
                side: const BorderSide(color: AppColors.accentYellow),
                avatar: const Icon(Icons.emoji_events, color: AppColors.accentYellow, size: 14),
                label: Text(
                  "Unlocked Badge: ${_selectedJob!.badgeToUnlock}",
                  style: const TextStyle(fontSize: 11, color: AppColors.accentYellow, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    _stage = 'list';
                    _selectedJob = null;
                  });
                },
                child: const Text("Return to Job Board", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
