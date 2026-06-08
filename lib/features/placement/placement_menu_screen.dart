import 'package:flutter/material.dart';
import 'resume_builder_screen.dart';
import 'mock_interview_screen.dart';
import '../../core/theme/theme.dart';

class PlacementMenuScreen extends StatefulWidget {
  const PlacementMenuScreen({super.key});

  @override
  State<PlacementMenuScreen> createState() => _PlacementMenuScreenState();
}

class _PlacementMenuScreenState extends State<PlacementMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Placement Prep Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: "Q&A & Notes"),
            Tab(text: "Flash Cards"),
            Tab(text: "Career Wizards"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQnATab(),
          const FlashCardsTab(),
          _buildWizardsTab(context),
        ],
      ),
    );
  }

  Widget _buildQnATab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HR questions list
          const Text("HR Interview Questions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          _buildQuestionTile(
            q: "Tell me about yourself.",
            a: "Summarize your academic highlights, relevant projects, technical skills, and explain how they match the job description. End with why you are excited about the role.",
          ),
          _buildQuestionTile(
            q: "Why should we hire you?",
            a: "Highlight your unique combination of skills, your quick learning ability, your interest in the company's domain, and back it up with a specific problem you solved.",
          ),
          const SizedBox(height: 24),

          // Technical Notes
          const Text("Technical Core Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          _buildNoteCard(
            title: "DBMS: Acid Properties",
            desc: "Atomicity (all-or-nothing), Consistency (integrity constraints), Isolation (concurrent safe), Durability (permanent updates after commit). Key for databases.",
            color: AppColors.primary,
          ),
          _buildNoteCard(
            title: "OS: Virtual Memory & Paging",
            desc: "Mapping process logical addresses to non-contiguous physical pages. Avoids external fragmentation and allows running processes larger than physical RAM.",
            color: AppColors.secondary,
          ),
          _buildNoteCard(
            title: "CN: OSI Reference Model Layers",
            desc: "7 Layers: Physical, Data Link, Network (routing), Transport (TCP/UDP segmentation), Session, Presentation, Application (HTTP/DNS protocols).",
            color: AppColors.accentPink,
          ),
          _buildNoteCard(
            title: "OOP: Four Core Pillars",
            desc: "Encapsulation (data hiding), Abstraction (hiding complexity), Inheritance (reusability), Polymorphism (interfaces with multiple forms).",
            color: AppColors.accentOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile({required String q, required String a}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              a,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNoteCard({required String title, required String desc, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassBox(
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardsTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWizardCard(
            context,
            title: "Interactive Resume Builder",
            desc: "Create, format, and compile your resume using structured industrial templates.",
            icon: Icons.assignment_ind_outlined,
            color: AppColors.primary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ResumeBuilderScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildWizardCard(
            context,
            title: "AI Mock Interview Chatbot",
            desc: "Practice behavioral and tech queries. Get instant keyword scores and detailed feedback.",
            icon: Icons.chat_bubble_outline,
            color: AppColors.secondary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MockInterviewScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildWizardCard(
            context,
            title: "AI Job Matching & Roadmap",
            desc: "View corporate job postings, verify level and resume criteria, and solve technical rounds to get hired.",
            icon: Icons.work_outline,
            color: AppColors.accentGreen,
            onPressed: () {
              Navigator.of(context).pushNamed("/job-matching");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWizardCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: AppTheme.glassBox(
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onPressed,
                child: const Text("Launch Wizard", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Flashcards flipping tab
class FlashCardsTab extends StatefulWidget {
  const FlashCardsTab({super.key});

  @override
  State<FlashCardsTab> createState() => _FlashCardsTabState();
}

class _FlashCardsTabState extends State<FlashCardsTab> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _flashcards = [
    {
      'question': 'What is the primary difference between Clustered and Non-Clustered Indexes?',
      'answer': 'A Clustered Index defines the physical order of data rows in a table (only 1 per table). A Non-Clustered Index contains pointers to physical rows (can have multiple per table).'
    },
    {
      'question': 'Explain the difference between TCP and UDP.',
      'answer': 'TCP is connection-oriented, reliable, guarantees order, and has error-checking (slow). UDP is connectionless, fast, has no order guarantees, and is lightweight (faster, used for streaming).'
    },
    {
      'question': 'What is the purpose of Garbage Collection in languages like Java?',
      'answer': 'It automatically reclaims memory by identifying and deleting heap objects that are no longer referenced by the application, avoiding manual memory management leaks.'
    },
    {
      'question': 'What is Mutex vs Semaphore in OS?',
      'answer': 'A Mutex is a locking mechanism used to synchronize access to a resource (1 thread at a time). A Semaphore is a signaling mechanism using counter integers to allow N threads to access resources.'
    }
  ];

  int _currentIndex = 0;
  bool _isFlipped = false;

  void _nextCard() {
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
    });
  }

  void _prevCard() {
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _flashcards[_currentIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Card ${_currentIndex + 1} of ${_flashcards.length}",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),

          // Flipping box
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isFlipped = !_isFlipped;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: AppTheme.glassBox(
                  border: Border.all(
                    color: _isFlipped ? AppColors.secondary : AppColors.primary, 
                    width: 2,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isFlipped ? "ANSWER" : "QUESTION",
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: _isFlipped ? AppColors.secondary : AppColors.primary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _isFlipped ? card['answer']! : card['question']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _isFlipped ? 14 : 18, 
                                  fontWeight: _isFlipped ? FontWeight.normal : FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isFlipped ? Icons.flip_to_front : Icons.flip_to_back, 
                                    color: AppColors.textMuted, 
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("Tap to flip card", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _prevCard,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text("Previous", style: TextStyle(color: Colors.white)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _nextCard,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text("Next", style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
