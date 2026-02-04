import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admin_api_service.dart';
import '../utils/ui_widgets.dart';
import '../utils/animated_widgets.dart';
import 'admin_question_form_page.dart';

class AdminQuestionListPage extends StatefulWidget {
  const AdminQuestionListPage({super.key});

  @override
  State<AdminQuestionListPage> createState() => _AdminQuestionListPageState();
}

class _AdminQuestionListPageState extends State<AdminQuestionListPage> {
  final AdminApiService _adminApi = AdminApiService();
  List<Map<String, dynamic>> _questions = [];
  List<String> _topics = [];
  String? _selectedTopic;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadTopics();
    _loadQuestions();
  }

  Future<void> _loadTopics() async {
    final topics = await _adminApi.getTopics();
    if (mounted) {
      setState(() {
        _topics = topics;
      });
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    final questions = await _adminApi.getQuestionList(topic: _selectedTopic);

    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuestion(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _adminApi.deleteQuestion(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuestions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete question'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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

            // Content
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
                child: Column(
                  children: [
                    // Title and Create button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildBoldTitle(text: 'QUESTION MANAGEMENT', fontSize: 28),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              createSlideRoute(const AdminQuestionFormPage()),
                            );
                            if (result == true) {
                              _loadTopics();
                              _loadQuestions();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('CREATE NEW'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Topic filter
                    Row(
                      children: [
                        const Text(
                          'Filter by Topic:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedTopic,
                          hint: const Text('All Topics'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Topics'),
                            ),
                            ..._topics.map((topic) => DropdownMenuItem<String>(
                                  value: topic,
                                  child: Text(topic),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTopic = value;
                            });
                            _loadQuestions();
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadQuestions,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Questions list
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _questions.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No questions found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _questions.length,
                                  itemBuilder: (context, index) {
                                    final question = _questions[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(
                                          question['question'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            question['id'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  question['topic'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              color: Colors.blue,
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  createSlideRoute(
                                                    AdminQuestionFormPage(
                                                      questionId: question['id'],
                                                    ),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _loadTopics();
                                                  _loadQuestions();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                              onPressed: () =>
                                                  _deleteQuestion(question['id']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
