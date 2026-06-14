import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';
import '../../core/services/dynamic_data_service.dart';
import '../../shared/widgets/premium_data_loader.dart';

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  late List<List<String>> _grid;
  late List<String> _wordsToFind;
  final Set<String> _foundWords = {};

  // Selected cell positions
  final List<Offset> _selectedCells = [];
  String _currentSelectionText = "";

  late ConfettiController _confettiController;
  bool _isGameOver = false;

  late Future<Map<String, dynamic>> _puzzleFuture;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _puzzleFuture = DynamicDataService.getWordSearchPuzzle().then((puzzle) {
      if (mounted) {
        setState(() {
          final List<dynamic> rawGrid = puzzle['grid'];
          _grid = rawGrid.map((row) => (row as String).split('').toList()).toList();
          _wordsToFind = List<String>.from(puzzle['wordsToFind']);
        });
      }
      return puzzle;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onCellTapped(int row, int col) {
    if (_isGameOver) return;

    final cellPos = Offset(row.toDouble(), col.toDouble());
    
    setState(() {
      if (_selectedCells.contains(cellPos)) {
        // Remove cell and all selected after it (undo)
        final index = _selectedCells.indexOf(cellPos);
        _selectedCells.removeRange(index, _selectedCells.length);
      } else {
        // Add to selection
        _selectedCells.add(cellPos);
      }

      // Rebuild typed string
      _currentSelectionText = _selectedCells.map((pos) => _grid[pos.dx.toInt()][pos.dy.toInt()]).join("");
    });
  }

  void _checkSelection() {
    if (_wordsToFind.contains(_currentSelectionText) && !_foundWords.contains(_currentSelectionText)) {
      setState(() {
        _foundWords.add(_currentSelectionText);
        _selectedCells.clear();
        _currentSelectionText = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You found: $_foundWords! 🎉"),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(milliseconds: 800),
        ),
      );

      if (_foundWords.length == _wordsToFind.length) {
        _finishGame();
      }
    } else {
      // Flash incorrect selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Not a hidden word, or already found!"),
          backgroundColor: AppColors.accentPink,
          duration: const Duration(milliseconds: 600),
        ),
      );
      setState(() {
        _selectedCells.clear();
        _currentSelectionText = "";
      });
    }
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addCoins(20);
    appState.addXp(20);
    appState.completeDailyWord();
    
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔤 Word Search"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumDataLoader<Map<String, dynamic>>(
        loader: () => _puzzleFuture,
        loadingText: "Constructing Letter Matrix...",
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  // Header description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                    child: Column(
                      children: [
                        const Text(
                          "Tap grid letters in order to build target words. Tap Submit to verify.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        // Selected text bar
                        Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F121E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _currentSelectionText.isNotEmpty ? AppColors.accentGreen : AppColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _currentSelectionText.isNotEmpty ? _currentSelectionText : "Select letters...",
                                style: TextStyle(
                                  color: _currentSelectionText.isNotEmpty ? Colors.white : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (_currentSelectionText.isNotEmpty)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: _checkSelection,
                                    child: const Text("Submit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Interactive Grid
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: AppTheme.glassBox(),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: 64,
                          itemBuilder: (context, index) {
                            int row = index ~/ 8;
                            int col = index % 8;
                            final char = _grid[row][col];
                            final pos = Offset(row.toDouble(), col.toDouble());
                            final isSelected = _selectedCells.contains(pos);

                            return GestureDetector(
                              onTap: () => _onCellTapped(row, col),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.accentGreen.withOpacity(0.3) 
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accentGreen : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    char,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Targets Checklist
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Target Words Checklist",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _wordsToFind.map((word) {
                              final isFound = _foundWords.contains(word);
                              return Chip(
                                avatar: isFound ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                label: Text(word),
                                backgroundColor: isFound ? AppColors.accentGreen : AppColors.surfaceLight,
                                labelStyle: TextStyle(
                                  color: isFound ? Colors.white : AppColors.textSecondary,
                                  decoration: isFound ? TextDecoration.lineThrough : null,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Scorecard Overlay
              if (_isGameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    child: Center(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.glassBox(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🎉", style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              "WORDS DISCOVERED!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentGreen, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "You found all target computer science terms inside the letter matrix.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text("🪙 +20", style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold)),
                                      Text("Coins Won", style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("⚡ +20", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                      Text("XP Gained", style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 44),
                              ),
                              onPressed: () {
                                MockAdWidgets.showInterstitialAd(context, onClosed: () {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text("Return to Menu"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
