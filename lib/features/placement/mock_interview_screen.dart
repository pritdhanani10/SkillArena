import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  // Category settings
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'SWE',
      'name': 'Software Engineer (General)',
      'icon': Icons.code,
      'questions': [
        "Hello! Welcome to the SkillArena SDE Mock. Let's start. How do you handle deadlocks in a distributed database system?",
        "Excellent. Next, describe a challenging technical bug you encountered in a project, and how you went about debugging it.",
        "Good. Behavioral round: How do you prioritize task delivery when you have conflicting deadlines from different product leads?",
        "Finally, can you explain the differences between relational databases and non-relational (NoSQL) databases, and when to use which?",
      ],
    },
    {
      'id': 'Frontend',
      'name': 'Frontend Engineer',
      'icon': Icons.web,
      'questions': [
        "Hello! Welcome to the Frontend Mock. How do you optimize page loading performance for a heavy React application?",
        "Great. Next, describe the difference between state management using Redux and Context API, and when you would prefer which.",
        "Good. How do you ensure your web application is accessible (Web Accessibility / WCAG Guidelines) for users with impairments?",
        "Finally, explain the CSS box model and the difference between flexbox and CSS grid layouts.",
      ],
    },
    {
      'id': 'DataScience',
      'name': 'Data Scientist / AI Engineer',
      'icon': Icons.analytics,
      'questions': [
        "Hello! Welcome to the Data Science Mock. Can you explain the difference between supervised and unsupervised learning, and give an example of each?",
        "Excellent. Next, how do you deal with overfitting in a machine learning model?",
        "Good. What is the role of activation functions in a deep neural network, and why is ReLU preferred over Sigmoid in hidden layers?",
        "Finally, write a SQL query logic or explain how you would find the second highest salary from an Employee table.",
      ],
    },
    {
      'id': 'HR',
      'name': 'HR & Behavioral Round',
      'icon': Icons.people,
      'questions': [
        "Hello! Welcome to the HR round. Tell me about a time you worked in a team and had a disagreement. How did you resolve it?",
        "Great. Next, how do you handle feedback or criticism from a supervisor that you disagree with?",
        "Good. Where do you see yourself in 5 years, and how does this role align with your career goals?",
        "Finally, why are you interested in working with our company, and what unique value do you bring?",
      ],
    },
  ];

  String? _selectedCategoryId;
  final List<String> _questions = [];
  final List<Map<String, dynamic>> _chatMessages = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _responseController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _totalScore = 0;
  bool _isFinished = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // Bot does not initiate until category is selected
  }

  void _startInterview(String categoryId) {
    final cat = _categories.firstWhere((c) => c['id'] == categoryId);
    setState(() {
      _selectedCategoryId = categoryId;
      _questions.clear();
      _questions.addAll(List<String>.from(cat['questions']));
      _currentQuestionIndex = 0;
      _totalScore = 0;
      _isFinished = false;
    });
    _addBotMessage(_questions[0]);
  }

  void _addBotMessage(String text) {
    setState(() {
      _chatMessages.add({
        'isBot': true,
        'text': text,
        'time': _getCurrentTime(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _chatMessages.add({
        'isBot': false,
        'text': text,
        'time': _getCurrentTime(),
      });
    });
    _scrollToBottom();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitResponse() async {
    final response = _responseController.text.trim();
    if (response.isEmpty) return;

    _responseController.clear();
    _addUserMessage(response);

    // AI analysis simulation
    setState(() {
      _chatMessages.add({'isBot': true, 'text': 'Analyzing response...', 'isSystem': true});
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1200));

    // Remove system analyzing message
    setState(() {
      _chatMessages.removeLast();
    });

    // Score response based on selected category and index
    final scoreResult = _evaluateResponse(response, _selectedCategoryId ?? 'SWE', _currentQuestionIndex);
    _totalScore += scoreResult['score'] as int;

    // Show score feedback from Bot
    _addBotMessage("Response Scored: ${scoreResult['score']}/100.\nFeedback: ${scoreResult['feedback']}");

    // Proceed to next question or wrap up
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      await Future.delayed(const Duration(milliseconds: 800));
      _addBotMessage(_questions[_currentQuestionIndex]);
    } else {
      setState(() {
        _isFinished = true;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      _addBotMessage("Interview completed. Average placement rating: ${(_totalScore / _questions.length).round()}/100. Feel free to view your final scorecard below.");
    }
  }

  void _simulateSpeechToText() async {
    if (_isListening) return;
    setState(() {
      _isListening = true;
    });

    await Future.delayed(const Duration(milliseconds: 2000));

    String generatedResponse = "";
    final qIndex = _currentQuestionIndex;
    final category = _selectedCategoryId;

    if (category == 'SWE') {
      if (qIndex == 0) generatedResponse = "To prevent or handle deadlocks, we can use distributed deadlock detection using wait-for graphs or prevention protocols like wound-wait and wait-die schemes.";
      else if (qIndex == 1) generatedResponse = "I once solved a memory leak bug by isolating references using memory profiling logs, tracking down an unclosed stream subscription, and adding a proper unsubscribe action.";
      else if (qIndex == 2) generatedResponse = "I prioritize conflicting tasks by aligning with lead managers, communicating urgency, delegating where possible, and using the Eisenhower urgency-importance matrix.";
      else generatedResponse = "Relational databases use schemas and ACID transactions, which are great for structured integrity. NoSQL databases are key-value or document stores that scale horizontally.";
    } else if (category == 'Frontend') {
      if (qIndex == 0) generatedResponse = "To optimize React page load, I implement code splitting with React.lazy and Suspense, minify bundles, configure CDNs, and cache assets properly.";
      else if (qIndex == 1) generatedResponse = "Redux uses a single store and actions, which avoids unnecessary re-renders for global state, while Context API is great for lightweight, low-frequency state sharing.";
      else if (qIndex == 2) generatedResponse = "I ensure accessibility by using semantic HTML elements, adding alt tags for screen readers, ensuring high contrast, and complying with WCAG guidelines.";
      else generatedResponse = "The CSS Box Model includes margin, border, padding, and content. Flexbox handles 1-dimensional layouts while CSS Grid is designed for 2-dimensional layouts.";
    } else if (category == 'DataScience') {
      if (qIndex == 0) generatedResponse = "Supervised learning models classification and regression on labeled datasets. Unsupervised learning performs clustering, like k-means, on unlabeled data.";
      else if (qIndex == 1) generatedResponse = "To prevent overfitting, I apply L1/L2 regularization, dropout layers in neural networks, early stopping, and cross-validation techniques.";
      else if (qIndex == 2) generatedResponse = "Activation functions introduce non-linearity. ReLU is preferred over Sigmoid in hidden layers because it avoids the vanishing gradient problem.";
      else generatedResponse = "We can find the second highest salary using a subquery or using LIMIT and OFFSET in SQL, or by using the DENSE_RANK window function.";
    } else if (category == 'HR') {
      if (qIndex == 0) generatedResponse = "When disagreements arise, I focus on active communication, listening to understand their perspective, and compromising to align on project objectives.";
      else if (qIndex == 1) generatedResponse = "I view feedback as a constructive tool for growth, listening objectively to my supervisor's critique and setting up concrete milestones to improve.";
      else if (qIndex == 2) generatedResponse = "In 5 years, I see myself growing into a senior engineer role, expanding my technical depth, leading projects, and mentoring junior developers.";
      else generatedResponse = "I am excited about this company because of your focus on innovation and your culture of high-growth engineering. My skills align perfectly with your technical stack.";
    }

    setState(() {
      _responseController.text = generatedResponse;
      _isListening = false;
    });
  }

  Map<String, dynamic> _evaluateResponse(String response, String category, int index) {
    final text = response.toLowerCase();
    final appState = Provider.of<AppState>(context, listen: false);
    final rigor = appState.interviewRigor;

    int score = 35; // base score
    if (rigor == 'Lenient') {
      score = 45;
    } else if (rigor == 'Strict') {
      score = 20;
    }

    String feedback = "";
    int matches = 0;

    if (category == 'SWE') {
      if (index == 0) {
        final keys = ["detection", "avoidance", "prevention", "kill", "wait-for", "lock", "transaction", "abort"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        if (text.length > 50) score += 10;
        feedback = matches >= 2 
            ? "Excellent keyword matching for deadlock handling strategies." 
            : "Satisfactory. Try including technical terms like 'wait-for graphs' or 'preventative locking'.";
      } else if (index == 1) {
        final keys = ["logs", "breakpoint", "stack", "debug", "console", "testing", "fix", "solve", "isolate"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 12;
        if (text.length > 60) score += 10;
        feedback = matches >= 2 ? "Good breakdown of testing and isolating processes." : "Focus on detail; explain how you isolated the root cause.";
      } else if (index == 2) {
        final keys = ["priority", "matrix", "schedule", "communicate", "lead", "delegate", "urgency", "align"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 12;
        feedback = matches >= 2 ? "Strong display of time-management and management alignment." : "Include frameworks like the urgent-important Eisenhower matrix.";
      } else {
        final keys = ["schema", "unstructured", "join", "scale", "relational", "document", "key-value", "acid", "nosql", "mongodb", "mysql"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 8;
        feedback = matches >= 2 ? "Clear understanding of the core schemas and database models." : "Contrast horizontal scalability of NoSQL vs ACID compliance of relational DBs.";
      }
    } else if (category == 'Frontend') {
      if (index == 0) {
        final keys = ["lazy", "suspense", "bundle", "minify", "cdn", "image", "cache", "render", "webpack", "split"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Great optimization checklist (code-splitting, compression, caching)." : "Mention technical optimizations like React.lazy/Suspense and asset minification.";
      } else if (index == 1) {
        final keys = ["context", "redux", "global", "re-render", "boilerplate", "store", "slice", "dispatch", "state"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Accurate distinction between heavy global store vs light context streams." : "Detail how Redux prevents unnecessary re-renders compared to standard Context.";
      } else if (index == 2) {
        final keys = ["aria", "screen", "alt", "contrast", "keyboard", "semantic", "wcag", "a11y"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Strong alignment with accessibility criteria and ARIA standards." : "Reference semantic HTML tags and WCAG standards for screen readers.";
      } else {
        final keys = ["margin", "padding", "border", "flex", "grid", "content", "axis", "layout", "box-sizing"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Solid knowledge of CSS layouts and box geometry." : "Explain how box-sizing impacts dimension calculation, and contrast flex vs grid.";
      }
    } else if (category == 'DataScience') {
      if (index == 0) {
        final keys = ["label", "regression", "classification", "clustering", "knn", "kmeans", "supervised", "unsupervised"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Correct definition of data classification vs unsupervised grouping." : "Highlight that supervised requires labeled targets, while unsupervised finds raw patterns.";
      } else if (index == 1) {
        final keys = ["regularization", "dropout", "cross-validation", "early", "prune", "train", "test", "l1", "l2"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Excellent methods described for model regularization and hyperparameter tuning." : "Incorporate terms like L1/L2 regularization, dropout, and validation splits.";
      } else if (index == 2) {
        final keys = ["vanishing", "gradient", "relu", "sigmoid", "non-linear", "derivative", "activation", "weights"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Accurate explanation of backpropagation gradient bounds." : "Describe why ReLU solves the vanishing gradient issue compared toSigmoid.";
      } else {
        final keys = ["dense", "offset", "subquery", "limit", "max", "rank", "dense_rank", "highest", "salary"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 10;
        feedback = matches >= 2 ? "Correct query structure logic for filtering highest salaries." : "Use subqueries with MAX, or ORDER BY with LIMIT/OFFSET offsets.";
      }
    } else if (category == 'HR') {
      if (index == 0) {
        final keys = ["communicate", "listen", "compromise", "respect", "align", "collaborate", "agree", "perspective", "talk"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 12;
        feedback = matches >= 2 ? "Shows positive conflict resolution and collaborative skills." : "Emphasize active listening and aligning on project milestones.";
      } else if (index == 1) {
        final keys = ["constructive", "improve", "feedback", "discuss", "learn", "growth", "perspective", "listen"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 12;
        feedback = matches >= 2 ? "Exhibits growth mindset and willingness to receive guidance." : "Describe how you clarify critique points and develop an improvement plan.";
      } else if (index == 2) {
        final keys = ["grow", "lead", "skills", "learn", "future", "manager", "contribution", "responsibility"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 12;
        feedback = matches >= 2 ? "Great vision for technical growth and scaling contributions." : "Connect your growth path with concrete business contributions.";
      } else {
        final keys = ["culture", "mission", "values", "growth", "strengths", "innovative", "passionate", "impact"];
        matches = keys.where((k) => text.contains(k)).length;
        score += matches * 12;
        feedback = matches >= 2 ? "Clear passion for the company culture and alignment of core values." : "Identify specific tech innovations or core values that attract you to the firm.";
      }
    }

    if (rigor == 'Strict' && matches == 0) {
      score = 20;
      feedback = "Failed validation: No technical keywords matched. " + feedback;
    }

    if (score > 100) score = 100;
    return {'score': score, 'feedback': feedback};
  }

  @override
  Widget build(BuildContext context) {
    final bool isSetup = _selectedCategoryId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSetup ? "🤖 AI Mock Interview Setup" : "🤖 AI Mock: ${_categories.firstWhere((c) => c['id'] == _selectedCategoryId)['name']}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (!isSetup && !_isFinished) {
              // Confirm exit
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text("Exit Interview?"),
                  content: const Text("Your progress in this mock round will be lost."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Exit", style: TextStyle(color: AppColors.accentPink)),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: isSetup ? _buildSetupScreen() : Column(
        children: [
          // Banner indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isFinished ? "INTERVIEW COMPLETED" : "ROUND 1: TECHNICAL & BEHAVIORAL MOCK",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
                Text(
                  "${_currentQuestionIndex + 1}/${_questions.length} Questions",
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _chatMessages[index];
                if (msg['isSystem'] == true) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        msg['text'],
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                      ),
                    ),
                  );
                }

                final isBot = msg['isBot'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBot) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          child: const Icon(Icons.android, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isBot ? AppColors.surface : AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isBot ? 0 : 14),
                              bottomRight: Radius.circular(isBot ? 14 : 0),
                            ),
                            border: Border.all(color: isBot ? AppColors.border : AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'],
                                style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  msg['time'],
                                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isBot) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Scorecard display if finished
          if (_isFinished)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Column(
                children: [
                  const Text("Placement Analysis Scorecard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric("Average Rating", "${(_totalScore / _questions.length).round()}/100"),
                      _buildMetric("Completeness", "100%"),
                      _buildMetric("Recommendation", (_totalScore / _questions.length) >= 70 ? "HIRE (Level 1)" : "PRACTICE MORE"),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCategoryId = null;
                              _chatMessages.clear();
                              _isFinished = false;
                            });
                          },
                          child: const Text("Try Another Role", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Exit to Prep Hub"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Input field with simulated voice button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isListening)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic, color: AppColors.secondary, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "🎙 AI Transcribing Voice Response...",
                              style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? AppColors.accentPink : AppColors.textSecondary,
                          ),
                          onPressed: _isListening ? null : _simulateSpeechToText,
                          tooltip: "Simulate speech-to-text response",
                        ),
                        Expanded(
                          child: TextField(
                            controller: _responseController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Type response here...",
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onSubmitted: (_) => _submitResponse(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.secondary),
                          onPressed: _submitResponse,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetupScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Interview Role",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            "Choose a target path to begin your AI mock assessment.",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: AppTheme.glassBox(
                    border: Border.all(color: AppColors.border),
                  ),
                  child: InkWell(
                    onTap: () => _startInterview(cat['id'] as String),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat['icon'] as IconData, color: AppColors.secondary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['name'] as String,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "4 Questions • AI Scoring • Interview Feedback",
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
