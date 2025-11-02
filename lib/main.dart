import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const PoliticalTicTacToe());
}

class PoliticalTicTacToe extends StatelessWidget {
  const PoliticalTicTacToe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Republican vs Democrat 🇺🇸',
      debugShowCheckedModeBanner: false,
      home: const ChoosePartyScreen(),
      theme: ThemeData(fontFamily: 'Roboto', primarySwatch: Colors.deepPurple),
    );
  }
}

// ==================== CHOOSE PARTY SCREEN ====================
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

            // Republican Button
            _buildPartyButton(
              context: context,
              label: 'Republican',
              iconPath: 'assets/icons/elephant_head.png',
              color: Colors.red,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const GameScreen(playerParty: 'republican'),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Democrat Button
            _buildPartyButton(
              context: context,
              label: 'Democrat',
              iconPath: 'assets/icons/donkey_head.png',
              color: Colors.blue,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const GameScreen(playerParty: 'democrat'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyButton({
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
              color: Colors.black.withValues(alpha: 0.2),
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

// ==================== GAME SCREEN ====================
class GameScreen extends StatefulWidget {
  final String playerParty; // 'republican' or 'democrat'

  const GameScreen({super.key, required this.playerParty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  String currentPlayer = ''; // Set in initState
  String winner = '';
  bool isDraw = false;
  bool isThinking = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    currentPlayer = widget.playerParty; // Player starts
  }

  void makeMove(int index) {
    if (board[index] != '' ||
        winner != '' ||
        currentPlayer != widget.playerParty ||
        isThinking)
      return;

    setState(() {
      board[index] = widget.playerParty;
      currentPlayer = _getOpponent();
    });

    if (checkWinner(widget.playerParty)) {
      setState(() => winner = '${_partyName(widget.playerParty)} (You)');
      return;
    }

    if (board.every((cell) => cell != '')) {
      setState(() => isDraw = true);
      return;
    }

    aiMove();
  }

  void aiMove() {
    setState(() => isThinking = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (winner == '' && !isDraw) {
        int move = getDumbMove();
        board[move] = _getOpponent();
        setState(() => currentPlayer = widget.playerParty);

        if (checkWinner(_getOpponent())) {
          setState(() => winner = '${_partyName(_getOpponent())} (AI)');
        } else if (board.every((cell) => cell != '')) {
          setState(() => isDraw = true);
        }
      }
      setState(() => isThinking = false);
    });
  }

  String _getOpponent() =>
      widget.playerParty == 'republican' ? 'democrat' : 'republican';
  String _partyName(String party) =>
      party == 'republican' ? 'Republican' : 'Democrat';
  String _iconPath(String party) => party == 'republican'
      ? 'assets/icons/elephant_head.png'
      : 'assets/icons/donkey_head.png';
  Color _partyColor(String party) =>
      party == 'republican' ? Colors.red : Colors.blue;
  String _partyEmoji(String party) => party == 'republican' ? '🐘' : '🐴';

  int getDumbMove() {
    List<int> empty = [
      for (int i = 0; i < 9; i++)
        if (board[i] == '') i,
    ];
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
    return patterns.any(
      (p) =>
          board[p[0]] == player &&
          board[p[1]] == player &&
          board[p[2]] == player,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_partyName(widget.playerParty)} vs ${_partyName(_getOpponent())}',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              winner != ''
                  ? '$winner Wins! ${_partyEmoji(winner.contains('You') ? widget.playerParty : _getOpponent())}🏆'
                  : isDraw
                  ? "It's a Draw! 🤝"
                  : isThinking
                  ? '${_partyName(_getOpponent())} Thinking... 🧠'
                  : currentPlayer == widget.playerParty
                  ? 'Your Turn! ${_partyEmoji(widget.playerParty)}'
                  : 'AI Turn ${_partyEmoji(_getOpponent())}',
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
                          color: Colors.black.withValues(alpha: 0.15),
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
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
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
