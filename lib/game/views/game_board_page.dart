import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/game_api_service.dart';
import '../models/game_models.dart';
import '../utils/ui_widgets.dart';
import '../utils/animated_widgets.dart';
import 'question_page.dart';
import 'main_menu_page.dart';

class GameBoardPage extends StatefulWidget {
  final String gameCode;
  final String playerName;

  const GameBoardPage({
    super.key,
    required this.gameCode,
    required this.playerName,
  });

  @override
  State<GameBoardPage> createState() => _GameBoardPageState();
}

class _GameBoardPageState extends State<GameBoardPage> {
  final GameApiService _apiService = GameApiService();
  Timer? _pollTimer;
  GameState? _currentState;
  bool _isRollingDice = false;
  int? _diceResult;
  String? _lastAnsweredQuestionId;
  String? _currentQuestionId;
  bool _isShowingQuestion = false;
  bool _isAnimatingMovement = false;
  bool _gameEndDialogShown = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _refreshGameState();
    });
    _refreshGameState();
  }

  Future<void> _refreshGameState() async {
    try {
      final state = await _apiService.getState(widget.gameCode);
      if (mounted) {
        // Don't update state if we're animating movement
        if (!_isAnimatingMovement) {
          setState(() {
            _currentState = state;
          });
        }

        // Check if game ended (only show dialog once)
        if ((state.ended == true || state.state == 'ended') && !_gameEndDialogShown) {
          _pollTimer?.cancel();
          _gameEndDialogShown = true;
          _showGameEndDialog();
        }

        // Check if there's a question
        if (state.question.isNotEmpty && 
            state.questionid.isNotEmpty &&
            state.questionid != _lastAnsweredQuestionId &&
            state.questionid != _currentQuestionId &&
            !_isShowingQuestion) {
          _currentQuestionId = state.questionid;
          _isShowingQuestion = true;
          _pollTimer?.cancel();
          
          if (mounted) {
            final result = await Navigator.push(
              context,
              createSlideRoute(
                QuestionPage(
                  gameCode: widget.gameCode,
                  playerName: widget.playerName,
                  question: state.question.first,
                ),
              ),
            );
            if (mounted) {
              _isShowingQuestion = false;
              if (result == true) {
                _lastAnsweredQuestionId = state.questionid;
              }
              _currentQuestionId = null;
              await _refreshGameState();
              _startPolling();
            }
          }
        }
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _startGame() async {
    try {
      final state = await _apiService.startGame(widget.gameCode);
      if (mounted) {
        setState(() {
          _currentState = state;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting game: $e')),
        );
      }
    }
  }

  Future<void> _rollDice() async {
    if (_isRollingDice) return;

    setState(() {
      _isRollingDice = true;
      _diceResult = null;
    });

    try {
      final state = await _apiService.rollDice(
        code: widget.gameCode,
        player: widget.playerName,
      );

      if (mounted) {
        // Update dice result and current state immediately so dice shows
        setState(() {
          _diceResult = state.dice;
          _currentState = state;
        });

        // Animate step-by-step movement if steps are provided
        if (state.steps != null && state.steps!.isNotEmpty) {
          _isAnimatingMovement = true;
          await _animatePlayerMovement(widget.playerName, state.steps!);
          _isAnimatingMovement = false;
        }

        if (mounted) {
          setState(() {
            _isRollingDice = false;
          });

          await _refreshGameState();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRollingDice = false;
          _isAnimatingMovement = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Animate player movement step by step
  Future<void> _animatePlayerMovement(String playerName, List<int> steps) async {
    if (_currentState == null) return;

    for (int step in steps) {
      if (!mounted) break;

      // Update the player's position in the current state
      setState(() {
        _currentState = GameState(
          code: _currentState!.code,
          state: _currentState!.state,
          turn: _currentState!.turn,
          message: _currentState!.message,
          players: _currentState!.players.map((player) {
            if (player.player == playerName) {
              return Player(
                player: player.player,
                pos: step,
                color: player.color,
              );
            }
            return player;
          }).toList(),
          question: _currentState!.question,
          questionid: _currentState!.questionid,
          dice: _currentState!.dice,
          beforepos: _currentState!.beforepos,
          pos: _currentState!.pos,
          steps: _currentState!.steps,
          ended: _currentState!.ended,
        );
      });

      // Wait for animation to complete before next step
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Game?'),
          content: const Text('Are you sure you want to leave this game? You can return later using the game code.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  createSlideRoute(const MainMenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,  // Allow dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Ended!'),
          content: Text(_currentState?.message ?? 'The game has ended.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Just dismiss the dialog
              },
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  createSlideRoute(const MainMenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Main Menu'),
            ),
          ],
        );
      },
    );
  }

  // Calculate position on board for a given square number (0-28)
  Offset _getBoardPosition(int position, double boardWidth, double boardHeight) {
    // Board is 7 columns x 4 rows
    // Position 0: Starting position (below/left of position 1)
    // Row 1 (1-7): left to right at bottom
    // Row 2 (8-14): right to left, second from bottom
    // Row 3 (15-21): left to right, second from top
    // Row 4 (22-28): right to left at top
    
    // Adjust for board image padding (the actual playable area is smaller)
    final double topPadding = boardHeight * 0.12; // 12% top padding
    final double bottomPadding = boardHeight * 0.12; // 12% bottom padding
    final double playableHeight = boardHeight - topPadding - bottomPadding;
    
    final double cellWidth = boardWidth / 7; // Board width divided by 7 columns
    final double cellHeight = playableHeight / 4; // Board height divided by 4 rows
    
    int row;
    int col;
    
    if (position == 0) {
      // Starting position: below position 1 (off the board)
      row = 3; // Bottom row
      col = -1; // Left of first column
    } else if (position >= 1 && position <= 7) {
      // Row 1: positions 1-7, left to right
      row = 3; // Bottom row
      col = position - 1;
    } else if (position >= 8 && position <= 14) {
      // Row 2: positions 8-14, right to left
      row = 2;
      col = 6 - (position - 8);
    } else if (position >= 15 && position <= 21) {
      // Row 3: positions 15-21, left to right
      row = 1;
      col = position - 15;
    } else {
      // Row 4: positions 22-28, right to left
      row = 0; // Top row
      col = 6 - (position - 22);
    }
    
    // Center the piece in the cell with padding offset
    double x = col * cellWidth + cellWidth / 2 - 15; // 15 is half of piece size
    double y = topPadding + row * cellHeight + cellHeight / 2 - 15;
    
    return Offset(x, y);
  }

  // Build player pieces on the board with animation
  List<Widget> _buildPlayerPieces(double boardWidth, double boardHeight) {
    if (_currentState == null) return [];
    
    return _currentState!.players.map((player) {
      final position = player.pos;
      // Show players at position 0 (starting) through 28
      if (position < 0 || position > 28) return const SizedBox.shrink();
      
      final offset = _getBoardPosition(position, boardWidth, boardHeight);
      
      return AnimatedPositioned(
        key: ValueKey('player_${player.player}'),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        left: offset.dx,
        top: offset.dy,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/player ${player.color}.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: Center(
                    child: Text(
                      player.player[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kGameWidth,
      height: kGameHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/backgroundsplashscreen.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: _currentState == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Game board image - centered
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Center(
                    child: SizedBox(
                      width: 700,
                      height: 540,
                      child: Stack(
                        children: [
                          // Board image
                          Image.asset(
                            'assets/images/board with snake.png',
                            fit: BoxFit.contain,
                            width: 700,
                            height: 540,
                          ),
                          // Player pieces on board
                          ..._buildPlayerPieces(700, 540),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Back button
                buildBackButton(context, onTap: _showExitConfirmation),
                
                // Game Code and Status - Top Center (side by side)
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Game Code
                          const Icon(Icons.vpn_key, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Code: ${_currentState!.code}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            height: 30,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 20),
                          // Status
                          Text(
                            _currentState!.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: _currentState!.state == 'waiting' 
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Players list - Left side (smaller)
                Positioned(
                  top: 100,
                  left: 15,
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Players',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._currentState!.players.map((player) {
                          final isCurrentPlayer = player.player == widget.playerName;
                          final isTurn = player.player == _currentState!.turn;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isTurn
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isCurrentPlayer ? Colors.blue : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/player ${player.color}.png',
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${player.player}: ${player.pos}',
                                    style: TextStyle(
                                      fontWeight: isCurrentPlayer
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isTurn)
                                  const Icon(
                                    Icons.play_arrow,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        
                        // Start game button
                        if (_currentState!.state == 'waiting')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'Start',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Dice display and Roll button - Right side, centered vertically
                Positioned(
                  right: 30,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dice display - show current dice from state
                        if (_currentState?.dice != null && _currentState!.dice! > 0)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/dice ${_currentState!.dice}.png',
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  '${_currentState!.dice}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Roll dice button
                        if (_currentState!.state == 'playing' &&
                            _currentState!.turn == widget.playerName &&
                            _currentState!.question.isEmpty)
                          ElevatedButton(
                            onPressed: _isRollingDice ? null : _rollDice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                            ),
                            child: _isRollingDice
                                ? const SizedBox(
                                    width: 80,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Rolling',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Text(
                                    '🎲 Roll',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
