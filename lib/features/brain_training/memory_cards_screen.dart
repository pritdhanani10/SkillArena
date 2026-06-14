import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';
import '../../core/services/dynamic_data_service.dart';
import '../../shared/widgets/premium_data_loader.dart';

class MemoryCardsScreen extends StatefulWidget {
  const MemoryCardsScreen({super.key});

  @override
  State<MemoryCardsScreen> createState() => _MemoryCardsScreenState();
}

class _MemoryCardsScreenState extends State<MemoryCardsScreen> {
  late List<String> _emojis;
  late List<bool> _cardFlipped;
  late List<bool> _cardMatched;
  
  int? _firstSelectedIndex;
  int _moves = 0;
  int _matches = 0;
  bool _busy = false;

  late ConfettiController _confettiController;
  bool _isGameOver = false;

  late Future<List<String>> _emojisFuture;
  late List<String> _loadedEmojis;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _emojisFuture = DynamicDataService.getMemoryCardEmojis().then((emojis) {
      if (mounted) {
        _loadedEmojis = emojis;
        _initializeGame(emojis);
      }
      return emojis;
    });
  }

  void _initializeGame(List<String> loadedEmojis) {
    setState(() {
      final uniqueList = List<String>.from(loadedEmojis)..shuffle();
      final selected = uniqueList.take(6).toList();
      _emojis = [...selected, ...selected];
      _emojis.shuffle();

      _cardFlipped = List.generate(12, (_) => false);
      _cardMatched = List.generate(12, (_) => false);
      _firstSelectedIndex = null;
      _moves = 0;
      _matches = 0;
      _busy = false;
      _isGameOver = false;
    });
  }

  void _resetGame() {
    _initializeGame(_loadedEmojis);
  }

  void _onCardTapped(int index) async {
    if (_busy || _cardFlipped[index] || _cardMatched[index]) return;

    setState(() {
      _cardFlipped[index] = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _moves++;
      final firstIdx = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (_emojis[firstIdx] == _emojis[index]) {
        // Match!
        setState(() {
          _cardMatched[firstIdx] = true;
          _cardMatched[index] = true;
          _matches++;
        });

        if (_matches == 6) {
          _finishGame();
        }
      } else {
        // No Match. Flip back after brief delay.
        setState(() {
          _busy = true;
        });

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          setState(() {
            _cardFlipped[firstIdx] = false;
            _cardFlipped[index] = false;
            _busy = false;
          });
        }
      }
    }
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addCoins(20);
    appState.addXp(20);
    appState.completeDailyMemory();
    appState.recordGameWon(); // increment general wins
    
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Memory Match"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetGame,
          )
        ],
      ),
      body: PremiumDataLoader<List<String>>(
        loader: () => _emojisFuture,
        loadingText: "Initializing Card Grid...",
        builder: (context, _) {
          return Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top HUD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: AppTheme.glassBox(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("$_moves", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          const Text("Moves Made", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("$_matches / 6", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentPink)),
                          const Text("Pairs Cleared", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cards Grid (4 columns, 3 rows)
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final isFlipped = _cardFlipped[index] || _cardMatched[index];
                      final isMatched = _cardMatched[index];

                      return GestureDetector(
                        onTap: () => _onCardTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: isFlipped 
                                ? (isMatched ? AppColors.greenGradient : AppColors.pinkGradient)
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFlipped ? Colors.white70 : Colors.white12,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isFlipped ? _emojis[index] : "❓",
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Game Over overlay scorecard
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
                        const Text("🏆", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          "MATCHING SUCCESS!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentPink, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Cleared all cards in $_moves total moves.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                                  Text("Coins Earned", style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
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
                            backgroundColor: AppColors.accentPink,
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
