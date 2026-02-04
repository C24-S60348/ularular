import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_api_service.dart';
import '../services/admin_api_service.dart';
import '../utils/ui_widgets.dart';
import '../utils/animated_widgets.dart';
import 'game_board_page.dart';

class CreateRoomFormPage extends StatefulWidget {
  final String selectedColor;
  final String colorImage;

  const CreateRoomFormPage({
    super.key,
    required this.selectedColor,
    required this.colorImage,
  });

  @override
  State<CreateRoomFormPage> createState() => _CreateRoomFormPageState();
}

class _CreateRoomFormPageState extends State<CreateRoomFormPage> {
  final TextEditingController _playerNameController = TextEditingController();
  final GameApiService _apiService = GameApiService();
  final AdminApiService _adminApi = AdminApiService();
  
  String? _selectedTopic;
  bool _isLoading = false;
  bool _isLoadingTopics = true;
  String _statusMessage = '';
  List<String> _topics = [];
  Timer? _retryTimer;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoadingTopics = true;
      _statusMessage = '';
    });

    try {
      final topics = await _adminApi.getTopics();
      
      if (mounted) {
        if (topics.isNotEmpty) {
          setState(() {
            _topics = topics;
            _selectedTopic = topics.first;
            _isLoadingTopics = false;
            _retryCount = 0;
            _retryTimer?.cancel();
          });
        } else {
          _scheduleRetry();
        }
      }
    } catch (e) {
      if (mounted) {
        _scheduleRetry();
      }
    }
  }

  void _scheduleRetry() {
    _retryCount++;
    setState(() {
      _statusMessage = 'Loading topics... (Retry $_retryCount)';
    });
    
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _loadTopics();
      }
    });
  }

  Future<void> _createRoom() async {
    if (_playerNameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your player name';
      });
      return;
    }

    if (_selectedTopic == null) {
      setState(() {
        _statusMessage = 'Please wait for topics to load';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating room...';
    });

    try {
      final response = await _apiService.createRoom(
        player: _playerNameController.text.trim(),
        color: widget.selectedColor,
        topic: _selectedTopic!,
      );

      if (response.status == 'ok') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            createSlideRoute(
              GameBoardPage(
                gameCode: response.code,
                playerName: response.player,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1280,
      height: 600,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundsplashscreen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Back button at top left
            buildBackButton(context),
            // Form content
            Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildBoldTitle(text: 'CREATE ROOM'),
                      const SizedBox(height: 30),
                      // Show selected color
                      Image.asset(
                        'assets/images/${widget.colorImage}',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      // Player Name input
                      TextField(
                        controller: _playerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Player Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Topic selection
                      _isLoadingTopics
                          ? Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.book, color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _statusMessage.isEmpty
                                          ? 'Loading topics...'
                                          : _statusMessage,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 20),
                                    onPressed: _loadTopics,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedTopic,
                              decoration: const InputDecoration(
                                labelText: 'Choose Topic',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.book),
                              ),
                              items: _topics.map((topic) {
                                return DropdownMenuItem(
                                  value: topic,
                                  child: Text(topic.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTopic = value;
                                  });
                                }
                              },
                            ),
                      const SizedBox(height: 30),
                      // Create button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isLoadingTopics) ? null : _createRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Create Room',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _statusMessage.contains('Error')
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _statusMessage.contains('Error')
                                  ? Colors.red.shade900
                                  : Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
