import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admin_api_service.dart';
import '../utils/ui_widgets.dart';
import '../utils/animated_widgets.dart';

class AdminQuestionFormPage extends StatefulWidget {
  final String? questionId;

  const AdminQuestionFormPage({super.key, this.questionId});

  @override
  State<AdminQuestionFormPage> createState() => _AdminQuestionFormPageState();
}

class _AdminQuestionFormPageState extends State<AdminQuestionFormPage> {
  final AdminApiService _adminApi = AdminApiService();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _a1Controller = TextEditingController();
  final TextEditingController _a2Controller = TextEditingController();
  final TextEditingController _a3Controller = TextEditingController();
  final TextEditingController _a4Controller = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  String? _selectedAnswer;
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _suggestedNextId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (widget.questionId != null) {
      _isEditMode = true;
      _loadQuestion();
    } else {
      _loadSuggestedId();
    }
  }

  Future<void> _loadSuggestedId() async {
    final questions = await _adminApi.getQuestionList();
    if (questions.isNotEmpty && mounted) {
      // Find the highest numeric ID
      int maxNum = 0;
      for (var q in questions) {
        final id = q['id'] as String?;
        if (id != null) {
          final numStr = id.replaceAll(RegExp(r'[^0-9]'), '');
          if (numStr.isNotEmpty) {
            final num = int.tryParse(numStr) ?? 0;
            if (num > maxNum) maxNum = num;
          }
        }
      }
      setState(() {
        _suggestedNextId = '${maxNum + 1}';
      });
    }
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
    });

    final question = await _adminApi.getQuestion(widget.questionId!);

    if (mounted && question != null) {
      setState(() {
        _idController.text = question['id'] ?? '';
        _questionController.text = question['question'] ?? '';
        _a1Controller.text = question['a1'] ?? '';
        _a2Controller.text = question['a2'] ?? '';
        _a3Controller.text = question['a3'] ?? '';
        _a4Controller.text = question['a4'] ?? '';
        _topicController.text = question['topic'] ?? '';
        _selectedAnswer = question['answer'];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveQuestion() async {
    // Validation
    if (_idController.text.isEmpty) {
      _showError('Please enter Question ID');
      return;
    }
    if (_questionController.text.isEmpty) {
      _showError('Please enter Question');
      return;
    }
    if (_a1Controller.text.isEmpty ||
        _a2Controller.text.isEmpty ||
        _a3Controller.text.isEmpty ||
        _a4Controller.text.isEmpty) {
      _showError('Please fill all answer options');
      return;
    }
    if (_selectedAnswer == null) {
      _showError('Please select the correct answer');
      return;
    }
    if (_topicController.text.isEmpty) {
      _showError('Please enter Topic');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    dynamic result;
    if (_isEditMode) {
      result = await _adminApi.updateQuestion(
        id: _idController.text,
        question: _questionController.text,
        a1: _a1Controller.text,
        a2: _a2Controller.text,
        a3: _a3Controller.text,
        a4: _a4Controller.text,
        answer: _selectedAnswer!,
        topic: _topicController.text,
      );
    } else {
      result = await _adminApi.createQuestion(
        id: _idController.text,
        question: _questionController.text,
        a1: _a1Controller.text,
        a2: _a2Controller.text,
        a3: _a3Controller.text,
        a4: _a4Controller.text,
        answer: _selectedAnswer!,
        topic: _topicController.text,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      final success = result is Map ? result['success'] == true : result == true;
      final message = result is Map ? result['message'] : null;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? (_isEditMode
                ? 'Question updated successfully'
                : 'Question created successfully')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showError(message ?? (_isEditMode
            ? 'Failed to update question'
            : 'Failed to create question'));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildAnswerOption(String label, String value, TextEditingController controller) {
    final isSelected = _selectedAnswer == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Radio button
          Radio<String>(
            value: value,
            groupValue: _selectedAnswer,
            onChanged: (val) {
              setState(() {
                _selectedAnswer = val;
              });
            },
          ),
          // Label
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter answer option $label',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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

            // Form content
            Positioned(
              top: 70,
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isLoading && _isEditMode
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: buildBoldTitle(
                                text: _isEditMode ? 'EDIT QUESTION' : 'CREATE NEW QUESTION',
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Question ID
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _idController,
                                  enabled: !_isEditMode,
                                  decoration: InputDecoration(
                                    labelText: 'Question ID *',
                                    labelStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: _suggestedNextId != null
                                        ? 'Suggested: $_suggestedNextId'
                                        : 'e.g., 1, 2, 3, etc.',
                                  ),
                                ),
                                if (_suggestedNextId != null && !_isEditMode)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, left: 12),
                                    child: Text(
                                      'Last ID found: ${int.parse(_suggestedNextId!) - 1}. Suggested next: $_suggestedNextId',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            // Topic
                            TextField(
                              controller: _topicController,
                              decoration: InputDecoration(
                                labelText: 'Topic *',
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Question
                            TextField(
                              controller: _questionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Question *',
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Answer options section
                            const Text(
                              'Answer Options (Select the correct answer):',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildAnswerOption('A', 'a1', _a1Controller),
                            _buildAnswerOption('B', 'a2', _a2Controller),
                            _buildAnswerOption('C', 'a3', _a3Controller),
                            _buildAnswerOption('D', 'a4', _a4Controller),

                            const SizedBox(height: 30),

                            // Save button
                            Center(
                              child: SizedBox(
                                width: 200,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isEditMode ? 'UPDATE' : 'CREATE',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _questionController.dispose();
    _a1Controller.dispose();
    _a2Controller.dispose();
    _a3Controller.dispose();
    _a4Controller.dispose();
    _topicController.dispose();
    super.dispose();
  }
}
