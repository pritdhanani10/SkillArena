import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/mock_ad_widgets.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  bool _searching = true;
  String _opponentName = "Sneha_32";
  int _opponentLevel = 4;

  // Board state
  List<String> _board = List.generate(9, (_) => "");
  bool _isPlayerTurn = true;
  String _gameStatus = "Your Turn (X)";
  bool _isMatchOver = false;
  String _winner = "";

  // Floating emoticons state
  String? _playerChatEmoji;
  String? _opponentChatEmoji;

  late ConfettiController _confettiController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _startMatchmaking();
  }

  void _startMatchmaking() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() {
        _searching = false;
      });
    }
  }

  void _makeBotMove() async {
    if (_isMatchOver || _isPlayerTurn) return;

    setState(() {
      _gameStatus = "$_opponentName is thinking...";
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Simple bot algorithm: find empty spot
    final emptyIndices = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == "") emptyIndices.add(i);
    }

    if (emptyIndices.isNotEmpty) {
      int move = emptyIndices[_random.nextInt(emptyIndices.length)];
      
      // Basic AI block check: if player is about to win, try to block
      final winningLines = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
        [0, 4, 8], [2, 4, 6]             // Diagonals
      ];
      
      for (var line in winningLines) {
        int playerMarkCount = line.where((idx) => _board[idx] == "X").length;
        int emptyMarkCount = line.where((idx) => _board[idx] == "").length;
        if (playerMarkCount == 2 && emptyMarkCount == 1) {
          // Block this empty cell!
          move = line.firstWhere((idx) => _board[idx] == "");
          break;
        }
      }

      setState(() {
        _board[move] = "O";
        _isPlayerTurn = true;
        _gameStatus = "Your Turn (X)";
      });
      _checkWinner();

      // Bot randomly sends an emoji after their turn
      if (_random.nextDouble() > 0.6) {
        final botEmojis = ["👍", "🔥", "😲", "😎"];
        _triggerChat(botEmojis[_random.nextInt(botEmojis.length)], isBot: true);
      }
    }
  }

  void _onCellTapped(int index) {
    if (_board[index] != "" || !_isPlayerTurn || _isMatchOver) return;

    setState(() {
      _board[index] = "X";
      _isPlayerTurn = false;
      _gameStatus = "$_opponentName's Turn (O)";
    });

    _checkWinner();
    
    if (!_isMatchOver) {
      _makeBotMove();
    }
  }

  void _checkWinner() {
    final winningLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var line in winningLines) {
      if (_board[line[0]] != "" &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[0]] == _board[line[2]]) {
        _endGame(_board[line[0]]);
        return;
      }
    }

    if (!_board.contains("")) {
      _endGame("Draw");
    }
  }

  void _endGame(String result) {
    setState(() {
      _isMatchOver = true;
      _winner = result;
      if (result == "X") {
        _gameStatus = "Victory! You Won!";
        _confettiController.play();
        
        final appState = Provider.of<AppState>(context, listen: false);
        appState.addXp(40);
        appState.addCoins(20);
        appState.recordGameWon();
      } else if (result == "O") {
        _gameStatus = "$_opponentName Won!";
      } else {
        _gameStatus = "Match Drawn!";
      }
    });
  }

  void _triggerChat(String emoji, {required bool isBot}) {
    setState(() {
      if (isBot) {
        _opponentChatEmoji = emoji;
      } else {
        _playerChatEmoji = emoji;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (isBot) {
            _opponentChatEmoji = null;
          } else {
            _playerChatEmoji = null;
          }
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(9, (_) => "");
      _isPlayerTurn = true;
      _gameStatus = "Your Turn (X)";
      _isMatchOver = false;
      _winner = "";
      _playerChatEmoji = null;
      _opponentChatEmoji = null;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      return _buildMatchmaker();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎮 Tic Tac Toe Online"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isMatchOver)
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top HUD: Profiles & Chat Emojis
                _buildPlayersHud(),

                // Board Status
                Text(
                  _gameStatus,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: _winner == "X" ? AppColors.accentGreen : (_winner == "O" ? AppColors.accentPink : Colors.white),
                  ),
                ),

                // 3x3 Neon Grid
                _buildGridBoard(),

                // Interactive Emoji chats
                _buildEmoticonBar(),
              ],
            ),
          ),

          // Victory / Defeat scorecard overlay
          if (_isMatchOver) _buildGameOverlay(),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchmaker() {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Search radars
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                    ),
                  ),
                  const Icon(Icons.wifi_find, size: 36, color: Colors.white),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "Searching for Online Opponents...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                "Querying matchmaking lobby path `/multiplayer_rooms`...",
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Courier New'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersHud() {
    final username = Provider.of<AppState>(context, listen: false).username;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.glassBox(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player info
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const Text("X", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  const SizedBox(height: 2),
                  Text(username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              if (_playerChatEmoji != null)
                Positioned(
                  top: -30,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text(_playerChatEmoji!, style: const TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
          
          const Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),

          // Opponent info
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const Text("O", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentPink)),
                  const SizedBox(height: 2),
                  Text(_opponentName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              if (_opponentChatEmoji != null)
                Positioned(
                  top: -30,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text(_opponentChatEmoji!, style: const TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.glassBox(),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final mark = _board[index];
            Color textCol = Colors.white;
            if (mark == "X") textCol = AppColors.secondary;
            if (mark == "O") textCol = AppColors.accentPink;

            return GestureDetector(
              onTap: () => _onCellTapped(index),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    mark,
                    style: TextStyle(
                      fontSize: 42, 
                      fontWeight: FontWeight.bold, 
                      color: textCol,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmoticonBar() {
    final list = ["👍", "🔥", "😲", "😎", "😂", "😢"];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          const Text("Send Emoticon reaction:", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: list.map((emoji) {
              return InkWell(
                onTap: _isMatchOver ? null : () => _triggerChat(emoji, isBot: false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverlay() {
    final isWin = _winner == "X";
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
                  isWin ? "👑 MATCH WON" : (_winner == "O" ? "❌ MATCH LOST" : "🤝 MATCH DRAWN"),
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w900, 
                    color: isWin ? AppColors.accentGreen : (_winner == "O" ? AppColors.accentPink : Colors.amber),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isWin 
                      ? "You outperformed Sneha_32. High-speed placement calculations synchronized." 
                      : "Sneha_32 claimed the matrix victory. Review tactics.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                if (isWin) ...[
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
                            Text("⚡ +40", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
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
                    backgroundColor: isWin ? AppColors.accentGreen : AppColors.primary,
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
