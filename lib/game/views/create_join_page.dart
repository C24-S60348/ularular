import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_api_service.dart';
import 'game_board_page.dart';

class CreateJoinPage extends StatefulWidget {
  const CreateJoinPage({super.key});

  @override
  State<CreateJoinPage> createState() => _CreateJoinPageState();
}

class _CreateJoinPageState extends State<CreateJoinPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GameApiService _apiService = GameApiService();

  // Create room fields
  final TextEditingController _createPlayerNameController =
      TextEditingController();
  String _selectedColor = 'color1';
  String _selectedTopic = 'biologi';

  // Join room fields
  final TextEditingController _joinCodeController = TextEditingController();
  final TextEditingController _joinPlayerNameController =
      TextEditingController();
  String _joinSelectedColor = 'color1';

  bool _isLoading = false;
  String _statusMessage = '';

  final List<String> _topics = [
    'biologi',
    'fizik',
    'kimia',
    'sains',
    'matematik',
  ];

  // TODO: Replace with actual asset paths when user provides them
  final List<String> _colors = [
    'color1',
    'color2',
    'color3',
    'color4',
    'color5',
    'color6',
    'color7',
    'color8',
    'color9',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _createPlayerNameController.dispose();
    _joinCodeController.dispose();
    _joinPlayerNameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_createPlayerNameController.text.trim().isEmpty) {
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
        player: _createPlayerNameController.text.trim(),
        color: _selectedColor,
        topic: _selectedTopic,
      );

      if (response.status == 'ok') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameBoardPage(
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

  Future<void> _joinRoom() async {
    if (_joinCodeController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Please enter game code';
      });
      return;
    }
    if (_joinPlayerNameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your player name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Joining room...';
    });

    try {
      final response = await _apiService.joinRoom(
        code: _joinCodeController.text.trim().toUpperCase(),
        player: _joinPlayerNameController.text.trim(),
        color: _joinSelectedColor,
      );

      if (response.status == 'ok') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameBoardPage(
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

  Widget _buildColorSelector(String selectedColor, Function(String) onChanged) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final color = _colors[index];
          final isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () => onChanged(color),
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(30),
                color: _getColorFromName(color),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    // Temporary colors until user provides assets
    // TODO: Replace with actual asset images
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];
    final index = _colors.indexOf(colorName);
    return colors[index >= 0 && index < colors.length ? index : 0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create or Join Game'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Create Game'),
            Tab(text: 'Join Game'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Create Game Tab
          _buildCreateTab(),
          // Join Game Tab
          _buildJoinTab(),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _createPlayerNameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select Color:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildColorSelector(_selectedColor, (color) {
                setState(() {
                  _selectedColor = color;
                });
              }),
              const SizedBox(height: 12),
              const Text(
                'Select Topic:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTopic,
                decoration: const InputDecoration(
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('error')
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('Error') ||
                              _statusMessage.contains('error')
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
    );
  }

  Widget _buildJoinTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _joinCodeController,
              decoration: const InputDecoration(
                labelText: 'Game Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
                hintText: 'Enter 4-character code',
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _joinPlayerNameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select Color:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildColorSelector(_joinSelectedColor, (color) {
              setState(() {
                _joinSelectedColor = color;
              });
            }),
            const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _joinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Join Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('error')
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('Error') ||
                              _statusMessage.contains('error')
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
    );
  }
}

