import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';

class LudoScreen extends StatefulWidget {
  const LudoScreen({super.key});

  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  // Game variables
  int _playerPawnPosition = 0; // 0 to 15 (15 is home)
  int _opponentPawnPosition = 0;

  int _diceVal = 1;
  bool _isPlayerTurn = true;
  bool _isRolling = false;
  String _status = "Roll the dice to start!";
  bool _isGameOver = false;

  late ConfettiController _confettiController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _rollDice() async {
    if (_isRolling || _isGameOver) return;

    setState(() {
      _isRolling = true;
      _status = "Rolling...";
    });

    // Simulate rolling animation cycling numbers
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        _diceVal = _random.nextInt(6) + 1;
      });
    }

    setState(() {
      _isRolling = false;
    });

    if (_isPlayerTurn) {
      _movePlayer();
    } else {
      _moveOpponent();
    }
  }

  void _movePlayer() async {
    int roll = _diceVal;
    int target = _playerPawnPosition + roll;

    setState(() {
      _status = "Rolled a $roll! Moving pawn...";
    });

    // Animate stepping
    for (int i = _playerPawnPosition + 1; i <= min(target, 15); i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _playerPawnPosition = i;
      });
    }

    if (_playerPawnPosition >= 15) {
      _endGame(true);
      return;
    }

    setState(() {
      _isPlayerTurn = false;
      _status = "Opponent's turn. Rolling...";
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    _rollOpponentDice();
  }

  void _rollOpponentDice() async {
    if (_isGameOver) return;
    
    // Simulate opponent roll
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        _diceVal = _random.nextInt(6) + 1;
      });
    }

    int roll = _diceVal;
    int target = _opponentPawnPosition + roll;

    setState(() {
      _status = "Opponent rolled a $roll! Moving...";
    });

    for (int i = _opponentPawnPosition + 1; i <= min(target, 15); i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _opponentPawnPosition = i;
      });
    }

    if (_opponentPawnPosition >= 15) {
      _endGame(false);
      return;
    }

    setState(() {
      _isPlayerTurn = true;
      _status = "Your turn. Roll the dice!";
    });
  }

  void _moveOpponent() {
    // handled synchronously above
  }

  void _endGame(bool playerWon) {
    setState(() {
      _isGameOver = true;
      _status = playerWon ? "Victory! You reached Home!" : "Defeat! Opponent reached Home first.";
    });

    if (playerWon) {
      _confettiController.play();
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addCoins(25);
      appState.addXp(30);
      appState.recordGameWon();
    }
  }

  void _resetGame() {
    setState(() {
      _playerPawnPosition = 0;
      _opponentPawnPosition = 0;
      _diceVal = 1;
      _isPlayerTurn = true;
      _isRolling = false;
      _status = "Roll the dice to start!";
      _isGameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎮 Ludo Online"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isGameOver)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _resetGame,
            )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Opponent HUD (Green Zone)
                _buildPlayerHUD(
                  name: "Sneha_32",
                  color: AppColors.accentPink,
                  position: _opponentPawnPosition,
                  isActive: !_isPlayerTurn,
                ),

                // Ludo mini track board
                _buildLudoBoard(),

                // Player HUD (Red Zone)
                _buildPlayerHUD(
                  name: "You",
                  color: AppColors.secondary,
                  position: _playerPawnPosition,
                  isActive: _isPlayerTurn,
                ),

                // Dice Controller
                _buildDiceController(),
              ],
            ),
          ),

          if (_isGameOver) _buildGameOverlay(),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerHUD({
    required String name,
    required Color color,
    required int position,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: AppTheme.glassBox(
        border: Border.all(color: isActive ? color : AppColors.border, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Text(
            position >= 15 ? "HOME 🏠" : "Step $position / 15",
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLudoBoard() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: AppTheme.glassBox(),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Simplified Track Display: horizontal chain of boxes
          const Text(
            "RACE TO HOME TRACK",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double cellWidth = (constraints.maxWidth - 30) / 8;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Opponent Row (Green)
                    _buildTrackRow(
                      startIdx: 0,
                      endIdx: 7,
                      pawnPos: _opponentPawnPosition,
                      color: AppColors.accentPink,
                      cellWidth: cellWidth,
                    ),
                    const SizedBox(height: 12),
                    // Player Row (Blue)
                    _buildTrackRow(
                      startIdx: 0,
                      endIdx: 7,
                      pawnPos: _playerPawnPosition,
                      color: AppColors.secondary,
                      cellWidth: cellWidth,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackRow({
    required int startIdx,
    required int endIdx,
    required int pawnPos,
    required Color color,
    required double cellWidth,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(8, (index) {
        // Steps are 0 to 15. The first 7 columns represent steps 0-7, and 8-14 are simulated.
        int stepValue = index * 2;
        bool hasPawn = pawnPos >= stepValue && pawnPos < stepValue + 2;
        if (index == 7 && pawnPos >= 14) hasPawn = true; // home checker

        return Container(
          width: cellWidth,
          height: 38,
          decoration: BoxDecoration(
            color: index == 7 ? color.withOpacity(0.2) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: index == 7 ? color : AppColors.border,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: hasPawn
              ? Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.person, size: 12, color: Colors.white),
                )
              : Text(
                  index == 7 ? "🏠" : "$stepValue",
                  style: TextStyle(fontSize: 10, color: index == 7 ? color : AppColors.textMuted),
                ),
        );
      }),
    );
  }

  Widget _buildDiceController() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(_status, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dice Visual
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isPlayerTurn ? AppColors.secondary : AppColors.border, width: 2),
                  boxShadow: _isPlayerTurn ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 8)] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "$_diceVal",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (_isRolling || !_isPlayerTurn || _isGameOver) ? null : _rollDice,
                child: const Text("ROLL DICE", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverlay() {
    final playerWon = _playerPawnPosition >= 15;
    return Positioned.fill(
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
                Text(
                  playerWon ? "👑 MATCH WON" : "❌ MATCH LOST",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w900, 
                    color: playerWon ? AppColors.accentGreen : AppColors.accentPink,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  playerWon 
                      ? "You reached the home zone first. Match database transactions completed." 
                      : "Sneha_32 token reached home zone. Play again to challenge.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                if (playerWon) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("🪙 +25", style: TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold)),
                            Text("Coins Won", style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("⚡ +30", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                            Text("XP Awarded", style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: playerWon ? AppColors.accentGreen : AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: () {
                    MockAdWidgets.showInterstitialAd(context, onClosed: () {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text("Return to Lobby"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
