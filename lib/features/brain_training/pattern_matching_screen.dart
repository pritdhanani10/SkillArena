import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';

class PatternMatchingScreen extends StatefulWidget {
  const PatternMatchingScreen({super.key});

  @override
  State<PatternMatchingScreen> createState() => _PatternMatchingScreenState();
}

class _PatternMatchingScreenState extends State<PatternMatchingScreen> {
  final List<Color> _padColors = [
    AppColors.secondary,
    AppColors.accentPink,
    AppColors.accentOrange,
    AppColors.primary,
  ];

  final List<int> _sequence = [];
  final List<int> _playerSequence = [];
  
  int _activePadIndex = -1;
  bool _isPlayingSequence = false;
  int _level = 1;
  bool _isGameOver = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _sequence.clear();
      _playerSequence.clear();
      _level = 1;
      _isGameOver = false;
    });
    _addNewStep();
  }

  void _addNewStep() {
    setState(() {
      _sequence.add(_random.nextInt(4));
      _playerSequence.clear();
    });
    _playSequence();
  }

  void _playSequence() async {
    setState(() {
      _isPlayingSequence = true;
    });

    for (int pad in _sequence) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _activePadIndex = pad;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _activePadIndex = -1;
      });
    }

    setState(() {
      _isPlayingSequence = false;
    });
  }

  void _onPadTapped(int index) {
    if (_isPlayingSequence || _isGameOver) return;

    setState(() {
      _activePadIndex = index;
    });
    
    // reset active after short release
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _activePadIndex = -1;
        });
      }
    });

    _playerSequence.add(index);
    
    // Check if correct so far
    final checkIndex = _playerSequence.length - 1;
    if (_playerSequence[checkIndex] != _sequence[checkIndex]) {
      _finishGame();
      return;
    }

    // Check if sequence completed
    if (_playerSequence.length == _sequence.length) {
      setState(() {
        _level++;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _addNewStep();
        }
      });
    }
  }

  void _finishGame() {
    setState(() {
      _isGameOver = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    
    // Reward based on levels reached
    int rewardCoins = _level * 3;
    int rewardXp = _level * 5;
    
    appState.addCoins(rewardCoins);
    appState.addXp(rewardXp);
    appState.completeDailyMemory(); // Sync daily challenge
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Simon Pattern Match"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Level $_level",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                _isPlayingSequence ? "Watch closely!" : "Repeat the pattern!",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),

              // 2x2 Simon Matrix
              SizedBox(
                width: 280,
                height: 280,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(4, (index) {
                    final isActive = _activePadIndex == index;
                    final baseColor = _padColors[index];

                    return GestureDetector(
                      onTap: () => _onPadTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: isActive ? baseColor : baseColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? Colors.white : Colors.white10,
                            width: 2,
                          ),
                          boxShadow: isActive ? [
                            BoxShadow(color: baseColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 4),
                          ] : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),

              if (_isGameOver) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassBox(),
                  child: Column(
                    children: [
                      const Text(
                        "GAME OVER",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentPink),
                      ),
                      const SizedBox(height: 6),
                      Text("You reached Level $_level.", style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("🪙 +${_level * 3} Coins", style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold)),
                          Text("⚡ +${_level * 5} XP", style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                        child: const Text("Return to Gym"),
                      ),
                    ],
                  ),
                ),
              ] else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: _isPlayingSequence ? null : _playSequence,
                  child: const Text("Replay Sequence", style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
