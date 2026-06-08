import 'package:flutter/material.dart';
import 'aptitude_quiz_screen.dart';
import '../../core/theme/theme.dart';

class AptitudeMenuScreen extends StatefulWidget {
  const AptitudeMenuScreen({super.key});

  @override
  State<AptitudeMenuScreen> createState() => _AptitudeMenuScreenState();
}

class _AptitudeMenuScreenState extends State<AptitudeMenuScreen> {
  String _selectedDomain = 'Quantitative'; // Quantitative, Logical, Verbal
  String _selectedTopic = 'Percentage';
  String _selectedMode = 'Practice'; // Practice, Timed, Battle, Mock

  final Map<String, List<String>> _domainTopics = {
    'Quantitative': ['Profit Loss', 'Percentage', 'Time Work', 'Speed Distance', 'Ratio'],
    'Logical': ['Blood Relations', 'Seating Arrangement', 'Coding Decoding'],
    'Verbal': ['Synonyms', 'Antonyms', 'Grammar'],
  };

  @override
  void initState() {
    super.initState();
    _selectedTopic = _domainTopics[_selectedDomain]!.first;
  }

  void _onDomainChanged(String domain) {
    setState(() {
      _selectedDomain = domain;
      _selectedTopic = _domainTopics[domain]!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Aptitude Arena', style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Banner illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassBox(
                color: AppColors.primary.withOpacity(0.15),
              ),
              child: Row(
                children: [
                  const Text("🧠", style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Aptitude Workout",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Train quantitative, logical, and verbal skills. Earn +20 XP and +10 Coins per complete.",
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Domain Tabs Selector
            const Text("1. Select Domain", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: ['Quantitative', 'Logical', 'Verbal'].map((domain) {
                final isSelected = _selectedDomain == domain;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => _onDomainChanged(domain),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            domain == 'Quantitative' ? 'Quant' : domain,
                            style: TextStyle(
                              fontSize: 14,
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

            // Topic List Grid
            const Text("2. Select Topic", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _domainTopics[_selectedDomain]!.map((topic) {
                final isSelected = _selectedTopic == topic;
                return ChoiceChip(
                  label: Text(topic),
                  selected: isSelected,
                  selectedColor: AppColors.secondary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? AppColors.secondary : AppColors.border, width: 1),
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

            // Mode Selection
            const Text("3. Select Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildModeTile(
                  mode: 'Practice',
                  title: 'Practice Mode',
                  desc: 'No time limits. Detailed step-by-step explanations shown immediately.',
                  icon: Icons.menu_book,
                  color: AppColors.secondary,
                ),
                _buildModeTile(
                  mode: 'Timed Quiz',
                  title: 'Timed Quiz',
                  desc: '20 seconds per question. Bonus points for quick answers.',
                  icon: Icons.timer,
                  color: AppColors.accentOrange,
                ),
                _buildModeTile(
                  mode: 'Battle Mode',
                  title: 'Battle Mode',
                  desc: 'Compete 1v1 against simulated rival. Solve faster to win.',
                  icon: Icons.bolt,
                  color: AppColors.accentPink,
                ),
                _buildModeTile(
                  mode: 'Mock Test',
                  title: 'Mock Test',
                  desc: 'Full mixed mock exam paper. Instant scorecard evaluation.',
                  icon: Icons.assignment_turned_in,
                  color: AppColors.accentGreen,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Start Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AptitudeQuizScreen(
                      domain: _selectedDomain,
                      topic: _selectedTopic,
                      mode: _selectedMode,
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Enter Arena", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.sports_kabaddi, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile({
    required String mode,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : AppColors.border,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          desc,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: Radio<String>(
          value: mode,
          groupValue: _selectedMode,
          activeColor: color,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedMode = val;
              });
            }
          },
        ),
      ),
    );
  }
}
