import 'package:flutter/material.dart';
import '../services/game_api_service.dart';
import '../utils/ui_widgets.dart';
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
  
  String _selectedTopic = 'biologi';
  bool _isLoading = false;
  String _statusMessage = '';

  final List<String> _topics = [
    'biologi',
    'fizik',
    'kimia',
    'sains',
    'matematik',
  ];

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_playerNameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your player name';
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
        topic: _selectedTopic,
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
    return Scaffold(
      body: Container(
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
                      const Text(
                        'Create Room',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Show selected color
                      Image.asset(
                        'assets/images/${widget.colorImage}',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
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
                      DropdownButtonFormField<String>(
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
                          onPressed: _isLoading ? null : _createRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
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
      ),
    );
  }
}
