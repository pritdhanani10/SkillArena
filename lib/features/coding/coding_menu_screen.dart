import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'coding_quiz_screen.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class CodingMenuScreen extends StatefulWidget {
  const CodingMenuScreen({super.key});

  @override
  State<CodingMenuScreen> createState() => _CodingMenuScreenState();
}

class _CodingMenuScreenState extends State<CodingMenuScreen> {
  String _selectedSection = 'DSA'; // DSA, Languages
  String _selectedTopic = 'Arrays';
  String _selectedLevel = 'Beginner'; // Beginner, Intermediate, Advanced

  final Map<String, List<String>> _sectionTopics = {
    'DSA': ['Arrays', 'Strings', 'Linked List', 'Stack', 'Queue', 'Trees', 'Graph'],
    'Languages': ['C', 'C++', 'Java', 'SQL', 'DBMS', 'OS'],
  };

  final List<Map<String, dynamic>> _companyPacks = [
    {'name': 'Amazon', 'logo': '📦', 'color': Colors.orange},
    {'name': 'TCS', 'logo': '💼', 'color': Colors.blue},
    {'name': 'Infosys', 'logo': '🟦', 'color': Colors.lightBlue},
    {'name': 'Wipro', 'logo': '🌈', 'color': Colors.purple},
    {'name': 'Accenture', 'logo': '🏹', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTopic = _sectionTopics[_selectedSection]!.first;
  }

  void _onSectionChanged(String section) {
    setState(() {
      _selectedSection = section;
      _selectedTopic = _sectionTopics[section]!.first;
    });
  }

  void _onCompanySelected(Map<String, dynamic> company) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isPremium) {
      _showPremiumUpgradeRequired(company['name']);
    } else {
      // Proceed to Company Specific coding problems
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodingQuizScreen(
            topic: company['name'],
            level: 'Advanced Placement',
            isCompanyPack: true,
          ),
        ),
      );
    }
  }

  void _showPremiumUpgradeRequired(String companyName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              const Text("💎"),
              const SizedBox(width: 8),
              Text("$companyName Pack Locked"),
            ],
          ),
          content: Text(
            "Company-specific papers and advanced placement mocks are premium features. Upgrade to SkillArena Premium to unlock all placement packages.",
            style: TextStyle(color: Colors.white.withOpacity(0.85)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Maybe Later", style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/premium');
              },
              child: const Text("Unlock Now"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💻 Coding Arena', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassBox(
                color: AppColors.secondary.withOpacity(0.12),
              ),
              child: Row(
                children: [
                  const Text("💻", style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DSA & MCQs Challenges",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Test syntax comprehension and algorithm designs. Earn +30 XP and +15 Coins per completion.",
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Premium Company Packs Section
            const Row(
              children: [
                Text("💎 Company Placement Packs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 6),
                Icon(Icons.lock_outline, size: 14, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _companyPacks.length,
                itemBuilder: (context, index) {
                  final company = _companyPacks[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: InkWell(
                      onTap: () => _onCompanySelected(company),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 100,
                        decoration: AppTheme.glassBox(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(company['logo'], style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 6),
                            Text(
                              company['name'],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Select Section
            const Text("1. Select Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: ['DSA', 'Languages'].map((sec) {
                final isSelected = _selectedSection == sec;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => _onSectionChanged(sec),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.secondary : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.secondary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            sec == 'DSA' ? 'Data Structures' : 'Language MCQs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Topic Selector
            const Text("2. Select Topic", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sectionTopics[_selectedSection]!.map((topic) {
                final isSelected = _selectedTopic == topic;
                return ChoiceChip(
                  label: Text(topic),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border, width: 1),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTopic = topic;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Level Selector
            const Text("3. Choose Difficulty", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: ['Beginner', 'Intermediate', 'Advanced'].map((lvl) {
                final isSelected = _selectedLevel == lvl;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLevel = lvl;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentOrange : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.accentOrange : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            lvl,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Enter Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CodingQuizScreen(
                      topic: _selectedTopic,
                      level: _selectedLevel,
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Start Coding", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.code, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
