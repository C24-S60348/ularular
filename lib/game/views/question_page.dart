import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_api_service.dart';
import '../models/game_models.dart';
import '../utils/ui_widgets.dart';

class QuestionPage extends StatefulWidget {
  final String gameCode;
  final String playerName;
  final Question question;
  final String? answererName; // The player who needs to answer
  final String? answererColor; // The player's color

  const QuestionPage({
    super.key,
    required this.gameCode,
    required this.playerName,
    required this.question,
    this.answererName,
    this.answererColor,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final GameApiService _apiService = GameApiService();
  bool _isSubmitting = false;
  String? _selectedAnswer;
  String? _answererColor;
  String? _answererName;
  bool? _isAnswerCorrect; // null = not submitted, true = correct, false = wrong
  bool _hasSubmitted = false;
  Timer? _pollTimer;
  String? _currentQuestionId;
  bool _isClosing = false; // Prevent polling from interfering with manual close

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Use provided answerer info
    _answererName = widget.answererName;
    _answererColor = widget.answererColor;
    _currentQuestionId = widget.question.id;
    
    // Start polling to see other players' selections and answers
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      await _checkQuestionState();
    });
  }

  Future<void> _checkQuestionState() async {
    // Don't poll if we're already closing
    if (_isClosing) return;
    
    try {
      final state = await _apiService.getState(widget.gameCode);
      
      // Check if question is still active
      if (state.questionid != _currentQuestionId || state.question.isEmpty) {
        // Question changed or ended, go back after showing result
        _isClosing = true;
        _pollTimer?.cancel();
        
        if (mounted && _hasSubmitted) {
          await Future.delayed(const Duration(milliseconds: 2000));
        }
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
        return;
      }

      // Update UI with server state (selected answer and correctness)
      if (mounted) {
        setState(() {
          // If we're not the answerer, show what the answerer selected
          if (widget.playerName != widget.answererName && state.selectedanswer != null && state.selectedanswer!.isNotEmpty) {
            _selectedAnswer = state.selectedanswer;
          }
          
          // If answer was submitted, show the result
          if (state.answercorrect != null && state.answercorrect!.isNotEmpty) {
            _isAnswerCorrect = state.answercorrect == "true";
            _hasSubmitted = true;
          }
        });
      }
    } catch (e) {
      // Continue polling on error
    }
  }

  Future<void> _submitAnswer() async {
    if (_isSubmitting || _selectedAnswer == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.submitAnswer(
        code: widget.gameCode,
        player: widget.playerName,
        answer: _selectedAnswer!,
      );

      if (mounted) {
        setState(() {
          _isAnswerCorrect = response.answer;
          _hasSubmitted = true;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.answer ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Wait longer to see the result
        _isClosing = true;
        _pollTimer?.cancel();
        await Future.delayed(const Duration(milliseconds: 3000));
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
      child: Stack(
        children: [
          // Back button
          buildBackButton(context),
          
          // Answerer info - top right (player who needs to answer)
          if (_answererColor != null && _answererName != null)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    // "Answerer" label
                    Text(
                      'ANSWERER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Player color image with border and glow
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/player $_answererColor.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Player name
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _answererName!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Centered content (70% width)
          Center(
            child: Container(
              width: kGameWidth * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Question text
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.question.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Answer options
                  _buildAnswerOption('A', 'a1', widget.question.a1),
                  const SizedBox(height: 12),
                  _buildAnswerOption('B', 'a2', widget.question.a2),
                  const SizedBox(height: 12),
                  _buildAnswerOption('C', 'a3', widget.question.a3),
                  const SizedBox(height: 12),
                  _buildAnswerOption('D', 'a4', widget.question.a4),
                  
                  const SizedBox(height: 30),
                  
                  // Submit button (only for answerer)
                  if (widget.playerName == widget.answererName)
                    ElevatedButton(
                      onPressed: _selectedAnswer == null || _isSubmitting || _hasSubmitted
                          ? null
                          : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                  else
                    // For non-answerers, show waiting message
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hourglass_empty,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Waiting for ${widget.answererName} to answer...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
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

  Widget _buildAnswerOption(String label, String value, String text) {
    final isSelected = _selectedAnswer == value;
    final isCorrect = _hasSubmitted && _isAnswerCorrect == true && isSelected;
    final isWrong = _hasSubmitted && _isAnswerCorrect == false && isSelected;
    final isNotAnswerer = widget.playerName != widget.answererName;
    
    // Determine colors based on submission state
    Color backgroundColor;
    Color borderColor;
    Color labelColor;
    Color textColor;
    
    if (isCorrect) {
      backgroundColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green;
      labelColor = Colors.green;
      textColor = Colors.black87;
    } else if (isWrong) {
      backgroundColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red;
      labelColor = Colors.red;
      textColor = Colors.black87;
    } else if (isSelected) {
      backgroundColor = Colors.blue.withOpacity(0.3);
      borderColor = Colors.blue;
      labelColor = Colors.blue;
      textColor = Colors.black87;
    } else {
      backgroundColor = Colors.white.withOpacity(0.9);
      borderColor = Colors.grey.shade300;
      labelColor = Colors.grey.shade200;
      textColor = Colors.black87;
    }
    
    return GestureDetector(
      onTap: (_isSubmitting || _hasSubmitted || isNotAnswerer)
          ? null
          : () async {
              setState(() {
                _selectedAnswer = value;
              });
              
              // Send selection to server
              await _apiService.selectAnswer(
                code: widget.gameCode,
                player: widget.playerName,
                answer: value,
              );
            },
      child: Opacity(
        opacity: isNotAnswerer && !_hasSubmitted ? 0.9 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: (isSelected || isCorrect || isWrong) ? 3 : 1,
            ),
            boxShadow: [
              if (isSelected || isCorrect || isWrong)
                BoxShadow(
                  color: borderColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
          children: [
            // Label circle with check/cross
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isSelected && !_hasSubmitted) ? Colors.blue : labelColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCorrect
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : isWrong
                        ? const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          )
                        : Text(
                            label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: (isSelected && !_hasSubmitted)
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 15),
            // Answer text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
