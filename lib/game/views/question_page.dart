import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_api_service.dart';
import '../models/game_models.dart';

class QuestionPage extends StatefulWidget {
  final String gameCode;
  final String playerName;
  final Question question;

  const QuestionPage({
    super.key,
    required this.gameCode,
    required this.playerName,
    required this.question,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin {
  final GameApiService _apiService = GameApiService();
  bool _isSubmitting = false;
  String? _selectedAnswer;
  bool? _isAnswerCorrect; // null = not submitted, true = correct, false = wrong
  String? _correctAnswerValue; // The correct answer value
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Ensure landscape orientation for question page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Keep landscape when leaving question page (going back to game board)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _submitAnswer(String answer) async {
    if (_isSubmitting || _selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = answer;
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.submitAnswer(
        code: widget.gameCode,
        player: widget.playerName,
        answer: answer,
      );

      if (mounted) {
        // Determine correct answer from question or response
        String? correctAnswer;
        
        // First, try to get from question's answer field
        if (widget.question.answer != null) {
          correctAnswer = widget.question.answer;
        } 
        // If user's answer was correct, then their answer is the correct one
        else if (response.answer == true) {
          correctAnswer = answer;
        }
        // If wrong, we can't determine the correct answer unless question has answer field
        // But we'll still show the user's wrong answer
        
        setState(() {
          _isAnswerCorrect = response.answer;
          _correctAnswerValue = correctAnswer;
          _isSubmitting = false;
        });

        // Show result message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.answer ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a bit then navigate back
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _selectedAnswer = null;
          _isAnswerCorrect = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Answerer: ${widget.playerName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildAnswerButton(
                        'A',
                        'a1',  // Send 'a1' instead of the full answer text
                        widget.question.a1,
                      ),
                      const SizedBox(height: 8),
                      _buildAnswerButton(
                        'B',
                        'a2',  // Send 'a2' instead of the full answer text
                        widget.question.a2,
                      ),
                      const SizedBox(height: 8),
                      _buildAnswerButton(
                        'C',
                        'a3',  // Send 'a3' instead of the full answer text
                        widget.question.a3,
                      ),
                      const SizedBox(height: 8),
                      _buildAnswerButton(
                        'D',
                        'a4',  // Send 'a4' instead of the full answer text
                        widget.question.a4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String label, String answer, String displayText) {
    final isSelected = _selectedAnswer == answer;
    
    // Only show correct answer AFTER submission
    // Don't reveal the answer before the user submits
    bool isCorrectAnswer = false;
    if (_isAnswerCorrect != null) {
      // Only check for correct answer after submission
      if (_correctAnswerValue != null) {
        isCorrectAnswer = _correctAnswerValue == answer;
      } else if (widget.question.answer != null) {
        isCorrectAnswer = widget.question.isCorrectAnswer(answer);
      } else if (_isAnswerCorrect == true && isSelected) {
        // If user's answer was correct, then this selected answer is correct
        isCorrectAnswer = true;
      }
    }
    
    final isWrongAnswer = isSelected && _isAnswerCorrect == false;
    
    // Determine button color
    Color? backgroundColor;
    Color? foregroundColor;
    if (_isSubmitting || _isAnswerCorrect != null) {
      // After submission, show results
      if (isCorrectAnswer) {
        backgroundColor = Colors.green;
        foregroundColor = Colors.white;
      } else if (isWrongAnswer) {
        backgroundColor = Colors.red.shade300;
        foregroundColor = Colors.white;
      } else {
        backgroundColor = Colors.grey.shade200;
        foregroundColor = Colors.black;
      }
    } else {
      // Before submission
      backgroundColor = isSelected ? Colors.blue : Colors.white;
      foregroundColor = isSelected ? Colors.white : Colors.black;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isSubmitting || _isAnswerCorrect != null) ? null : () => _submitAnswer(answer),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: (_isAnswerCorrect != null && isCorrectAnswer)
                  ? Colors.green.shade700 
                  : (isWrongAnswer 
                      ? Colors.red.shade700 
                      : (isSelected ? Colors.blue : Colors.grey.shade300)),
              width: ((_isAnswerCorrect != null && isCorrectAnswer) || isWrongAnswer || isSelected) ? 3 : 1,
            ),
          ),
          elevation: ((_isAnswerCorrect != null && isCorrectAnswer) || isWrongAnswer || isSelected) ? 8 : 2,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (_isAnswerCorrect != null && isCorrectAnswer)
                    ? Colors.green.shade700
                    : (isWrongAnswer 
                        ? Colors.red.shade700
                        : (isSelected ? Colors.white : Colors.blue.shade100)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: (_isAnswerCorrect != null && isCorrectAnswer)
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? ((_isAnswerCorrect != null && isCorrectAnswer) ? Colors.white : Colors.blue)
                              : Colors.blue.shade900,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: (isSelected || (_isAnswerCorrect != null && isCorrectAnswer)) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (_isSubmitting && isSelected && _isAnswerCorrect == null)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            if (_isAnswerCorrect != null && isCorrectAnswer && !isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

