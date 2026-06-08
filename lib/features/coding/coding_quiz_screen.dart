import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';

class CodingProblem {
  final String text;
  final String codeSnippet;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String expectedOutput;

  const CodingProblem({
    required this.text,
    required this.codeSnippet,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.expectedOutput,
  });
}

class CodingQuizScreen extends StatefulWidget {
  final String topic;
  final String level;
  final bool isCompanyPack;

  const CodingQuizScreen({
    super.key,
    required this.topic,
    required this.level,
    this.isCompanyPack = false,
  });

  @override
  State<CodingQuizScreen> createState() => _CodingQuizScreenState();
}

class _CodingQuizScreenState extends State<CodingQuizScreen> {
  late List<CodingProblem> _problems;
  int _currentIndex = 0;
  int? _selectedIdx;
  bool _isCompiled = false;
  bool _showCorrect = false;
  int _score = 0;
  
  // Console log simulations
  String _consoleOutput = "Ready to compile...";
  bool _isCompiling = false;

  late ConfettiController _confettiController;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadProblems();
  }

  void _loadProblems() {
    final Map<String, List<CodingProblem>> allProblems = {
      'Arrays': [
        const CodingProblem(
          text: "What will be the output of the following Java program regarding array indexing?",
          codeSnippet: "public class ArrayTest {\n    public static void main(String[] args) {\n        int[] arr = new int[5];\n        System.out.println(arr[4]);\n    }\n}",
          options: ["0", "NullPointerException", "ArrayIndexOutOfBoundsException", "Garbage value"],
          correctIndex: 0,
          expectedOutput: "0",
          explanation: "In Java, primitive int arrays are automatically initialized to their default value, which is 0. Since arr has a size of 5, indexes are 0 to 4. Printing arr[4] outputs 0.",
        ),
        const CodingProblem(
          text: "Find the time complexity of the binary search algorithm on a sorted array of size N.",
          codeSnippet: "int binarySearch(int arr[], int l, int r, int x) {\n    while (l <= r) {\n        int m = l + (r - l) / 2;\n        if (arr[m] == x) return m;\n        if (arr[m] < x) l = m + 1;\n        else r = m - 1;\n    }\n    return -1;\n}",
          options: ["O(N)", "O(log N)", "O(N log N)", "O(1)"],
          correctIndex: 1,
          expectedOutput: "O(log N)",
          explanation: "Binary search repeatedly divides the search space in half. Hence, the time complexity is logarithmic, or O(log N).",
        ),
      ],
      'Strings': [
        const CodingProblem(
          text: "What does the following C++ code return when matching strings?",
          codeSnippet: "#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s1 = \"Skill\";\n    string s2 = \"Arena\";\n    cout << (s1 + s2).length();\n    return 0;\n}",
          options: ["5", "10", "SkillArena", "Compilation error"],
          correctIndex: 1,
          expectedOutput: "10",
          explanation: "s1 has length 5 ('Skill') and s2 has length 5 ('Arena'). Concatenating them (s1 + s2) yields 'SkillArena', which has length 10.",
        ),
      ],
      'SQL': [
        const CodingProblem(
          text: "Which SQL clause is used to filter group results after applying an aggregate function?",
          codeSnippet: "SELECT department, AVG(salary)\nFROM employees\nGROUP BY department\n??? AVG(salary) > 50000;",
          options: ["WHERE", "HAVING", "FILTER", "ORDER BY"],
          correctIndex: 1,
          expectedOutput: "HAVING",
          explanation: "The HAVING clause was added to SQL because the WHERE keyword could not be used with aggregate functions.",
        ),
      ],
    };

    _problems = allProblems[widget.topic] ?? [
      CodingProblem(
        text: "Select the correct option to complete this ${widget.topic} code logic:",
        codeSnippet: "// Mock challenge block for ${widget.topic}\nvoid runChallenge() {\n    int target = 42;\n    print(target);\n}",
        options: const ["Compile Success", "Memory Leak", "Stack Overflow", "Syntax Error"],
        correctIndex: 0,
        expectedOutput: "42",
        explanation: "Simple display statement will print the value of target, which is 42.",
      ),
    ];
  }

  void _compileAndTest() async {
    if (_selectedIdx == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an option before compiling!")),
      );
      return;
    }
    
    setState(() {
      _isCompiling = true;
      _consoleOutput = "Compiling... Running Test Cases...\n";
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    final problem = _problems[_currentIndex];
    final isCorrect = _selectedIdx == problem.correctIndex;

    setState(() {
      _isCompiling = false;
      _isCompiled = true;
      if (isCorrect) {
        _score++;
        _showCorrect = true;
        _consoleOutput = "✔ Compilation Successful!\n✔ All test cases passed.\nOutput: ${problem.expectedOutput}";
      } else {
        _showCorrect = false;
        _consoleOutput = "❌ Execution Failed!\n❌ Wrong Answer. Test Case 1/1 failed.\nOutput received: ${problem.options[_selectedIdx!]}\nExpected output: ${problem.expectedOutput}";
      }
    });
  }

  void _nextProblem() {
    if (_currentIndex < _problems.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIdx = null;
        _isCompiled = false;
        _consoleOutput = "Ready to compile...";
      });
    } else {
      _finishChallenge();
    }
  }

  void _finishChallenge() {
    setState(() {
      _isGameOver = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addXp(30);
    appState.addCoins(15);
    appState.recordCodingProblemSolved();
    appState.completeDailyCoding();

    if (_score == _problems.length) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final problem = _problems[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} - Level ${widget.level}', style: const TextStyle(fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            MockAdWidgets.showInterstitialAd(context, onClosed: () {
              Navigator.of(context).pop();
            });
          },
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _isGameOver ? _buildScoreCard() : _buildGameplay(problem),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [Colors.amber, Colors.cyan, Colors.purple, Colors.teal],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameplay(CodingProblem problem) {
    return Column(
      children: [
        // Problem Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Challenge ${_currentIndex + 1} of ${_problems.length}",
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                problem.text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Simulated Code Editor View
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF070913),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Courier New', fontSize: 13, height: 1.4, color: Colors.white),
                  children: _parseCodeHighlights(problem.codeSnippet),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Options List (Compact Grid or List)
        Expanded(
          flex: 3,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: problem.options.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIdx == index;
              Color borderCol = isSelected ? AppColors.secondary : AppColors.border;
              if (_isCompiled) {
                if (index == problem.correctIndex) {
                  borderCol = AppColors.accentGreen;
                } else if (isSelected) {
                  borderCol = AppColors.accentPink;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: _isCompiled ? null : () => setState(() => _selectedIdx = index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderCol, width: 1.5),
                    ),
                    child: Text(
                      "${String.fromCharCode(65 + index)}.   ${problem.options[index]}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Simulated Compiler Output Drawer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F111A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.terminal, color: AppColors.textSecondary, size: 14),
                  SizedBox(width: 6),
                  Text("CONSOLE LOGS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _consoleOutput,
                style: TextStyle(
                  fontFamily: 'Courier New', 
                  fontSize: 11, 
                  color: _consoleOutput.contains('Failed') ? AppColors.accentPink : (_consoleOutput.contains('Successful') ? AppColors.accentGreen : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),

        // Bottom CTA Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              if (!_isCompiled)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isCompiling ? null : _compileAndTest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isCompiling)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        else
                          const Icon(Icons.play_arrow, size: 20),
                        const SizedBox(width: 8),
                        const Text("Compile & Run", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _nextProblem,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentIndex == _problems.length - 1 ? "Submit Solution" : "Next Challenge",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.navigate_next, size: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    double accuracy = _score / _problems.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("💻", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                "CHALLENGE APPROVED",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: accuracy >= 0.7 ? AppColors.accentGreen : AppColors.accentOrange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Successfully compiled $_score out of ${_problems.length} puzzles.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              // Rewards
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
                        Text("🪙 +15", style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Coins Earned", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                    VerticalDivider(color: AppColors.border, width: 20, thickness: 1),
                    Column(
                      children: [
                        Text("⚡ +30", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("XP Awarded", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
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

  // Simple Java/C++ tokenizer to simulate syntax styling in TextSpans
  List<TextSpan> _parseCodeHighlights(String code) {
    final List<TextSpan> spans = [];
    final words = code.split(RegExp(r'(\s+|[{}()\[\];.,<>+\-*/=])'));
    final Set<String> keywords = {
      'public', 'class', 'static', 'void', 'int', 'new', 'return', 'if', 'else', 
      'while', 'for', 'string', 'include', 'using', 'namespace', 'cout', 'double'
    };

    int lastIndex = 0;
    // Iterate over matching segments to preserve characters
    final regex = RegExp(r'(\w+|[^\w\s]+|\s+)');
    final matches = regex.allMatches(code);

    for (final match in matches) {
      final text = match.group(0)!;
      if (keywords.contains(text.trim())) {
        spans.add(TextSpan(text: text, style: const TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold)));
      } else if (text.startsWith('"') || text.endsWith('"')) {
        spans.add(TextSpan(text: text, style: const TextStyle(color: Color(0xFF10B981))));
      } else if (RegExp(r'^\d+$').hasMatch(text)) {
        spans.add(TextSpan(text: text, style: const TextStyle(color: Color(0xFFF59E0B))));
      } else if (text.startsWith('//')) {
        spans.add(TextSpan(text: text, style: const TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic)));
      } else {
        spans.add(TextSpan(text: text));
      }
    }
    return spans;
  }
}
