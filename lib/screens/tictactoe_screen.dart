// lib/screens/tictactoe_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

/// ---------------------------------------------------------------
///  Entry point for the whole Tik-Tac-Toe flow
/// ---------------------------------------------------------------
class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // The game starts on the party-choice screen.
  // When a party is chosen we push the real GameScreen.
  @override
  Widget build(BuildContext context) {
    return const ChoosePartyScreen();
  }
}

/// ---------------------------------------------------------------
///  PARTY CHOICE SCREEN
/// ---------------------------------------------------------------
class ChoosePartyScreen extends StatelessWidget {
  const ChoosePartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Party',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 60),
            _buildPartyButton(
              context: context,
              label: 'Republican',
              iconPath: 'assets/images/elephant_head.png',
              color: Colors.red,
              onTap: () => _startGame(context, 'republican'),
            ),
            const SizedBox(height: 40),
            _buildPartyButton(
              context: context,
              label: 'Democrat',
              iconPath: 'assets/images/donkey_head.png',
              color: Colors.blue,
              onTap: () => _startGame(context, 'democrat'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper – pushes the real GameScreen
  static void _startGame(BuildContext context, String party) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerParty: party),
      ),
    );
  }

  // Re-used button widget
  static Widget _buildPartyButton({
    required BuildContext context,
    required String label,
    required String iconPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 60, height: 60),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
///  GAME SCREEN (your original logic, unchanged)
/// ---------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final String playerParty;
  const GameScreen({super.key, required this.playerParty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  String currentPlayer = '';
  String winner = '';
  bool isDraw = false;
  bool isThinking = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    currentPlayer = widget.playerParty;
  }

  void makeMove(int index) {
    if (board[index] != '' ||
        winner != '' ||
        currentPlayer != widget.playerParty ||
        isThinking) return;

    setState(() {
      board[index] = widget.playerParty;
      currentPlayer = _getOpponent();
    });

    if (checkWinner(widget.playerParty)) {
      setState(() => winner = '${_partyName(widget.playerParty)} (You)');
      _showResultDialog();
      return;
    }

    if (board.every((cell) => cell != '')) {
      setState(() => isDraw = true);
      _showResultDialog();
      return;
    }

    aiMove();
  }

  void aiMove() {
    setState(() => isThinking = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (winner == '' && !isDraw && mounted) {
        int move = getDumbMove();
        board[move] = _getOpponent();
        setState(() => currentPlayer = widget.playerParty);

        if (checkWinner(_getOpponent())) {
          setState(() => winner = '${_partyName(_getOpponent())} (AI)');
          _showResultDialog();
        } else if (board.every((cell) => cell != '')) {
          setState(() => isDraw = true);
          _showResultDialog();
        }
      }
      if (mounted) setState(() => isThinking = false);
    });
  }

  void _showResultDialog() {
    if (!mounted) return;

    // true when the human player gets three in a row
    final bool playerWon = winner.contains('You');

    // the party that actually placed the winning line
    final String winningParty = playerWon ? widget.playerParty : _getOpponent();

    // ---------- NEW MESSAGES ----------
    final String message;
    if (isDraw) {
      message = "It's a Draw! It doesn't matter who wins anyway...";
    } else if (playerWon) {
      // Player wins → “Even when you win you lose”
      message = '${_partyName(winningParty)} wins!\nEven when you win you lose';
    } else {
      // AI wins → “You lose!”
      message = '${_partyName(winningParty)} wins!\nYou lose!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background leader image
            Container(
              width: double.infinity,
              height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Opacity(
                opacity: 1,
                child: Image.asset(
                  _leaderImage(winningParty),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Text + buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message, // <-- NEW TEXT
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play Again
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Menu
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const ChoosePartyScreen()),
                            (r) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Menu',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helper methods (unchanged) ----------
  String _getOpponent() =>
      widget.playerParty == 'republican' ? 'democrat' : 'republican';

  String _partyName(String party) =>
      party == 'republican' ? 'Republican' : 'Democrat';

  String _iconPath(String party) => party == 'republican'
      ? 'assets/images/elephant_head.png'
      : 'assets/images/donkey_head.png';

  Color _partyColor(String party) =>
      party == 'republican' ? Colors.red : Colors.blue;

  ///String _partyEmoji(String party) =>
  ///     party == 'republican' ? 'Elephant' : 'Donkey';

  String _leaderImage(String party) => party == 'republican'
      ? 'assets/images/McConnell.jpg'
      : 'assets/images/Pelosi.jpg';

  int getDumbMove() {
    final empty = <int>[];
    for (int i = 0; i < 9; i++) if (board[i] == '') empty.add(i);
    if (empty.isEmpty) return 0;
    if (_random.nextDouble() < 0.5 && empty.contains(4)) return 4;
    return empty[_random.nextInt(empty.length)];
  }

  bool checkWinner(String player) {
    const patterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    return patterns.any((p) =>
        board[p[0]] == player &&
        board[p[1]] == player &&
        board[p[2]] == player);
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = widget.playerParty;
      winner = '';
      isDraw = false;
      isThinking = false;
    });
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_partyName(widget.playerParty)} vs ${_partyName(_getOpponent())}',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              isThinking
                  ? '${_partyName(_getOpponent())} Thinking... Brain'
                  : currentPlayer == widget.playerParty
                      ? 'Your Turn!'
                      : 'AI Turn',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: currentPlayer == widget.playerParty
                    ? _partyColor(widget.playerParty)
                    : _partyColor(_getOpponent()),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Board
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => makeMove(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: board[index].isNotEmpty
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 144,
                                  height: 144,
                                  decoration: BoxDecoration(
                                    color: _partyColor(board[index]),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  _iconPath(board[index]),
                                  width: 108,
                                  height: 108,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text(
              'New Game',
              style: TextStyle(fontSize: 26, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
