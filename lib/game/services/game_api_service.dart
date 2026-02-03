import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_models.dart';

class GameApiService {
  static const String baseUrl = 'https://afwanhaziq.vps.webdock.cloud/api/ular';

  Future<CreateRoomResponse> createRoom({
    required String player,
    required String color,
    required String topic,
    int maxbox = 28,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/createroom?player=${Uri.encodeComponent(player)}&color=${Uri.encodeComponent(color)}&maxbox=$maxbox&topic=${Uri.encodeComponent(topic)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return CreateRoomResponse.fromJson(json);
      } else {
        throw Exception('Failed to create room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating room: $e');
    }
  }

  Future<JoinRoomResponse> joinRoom({
    required String code,
    required String player,
    required String color,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/joinroom?code=${Uri.encodeComponent(code)}&player=${Uri.encodeComponent(player)}&color=${Uri.encodeComponent(color)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return JoinRoomResponse.fromJson(json);
      } else {
        throw Exception('Failed to join room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error joining room: $e');
    }
  }

  Future<GameState> getState(String code) async {
    try {
      final uri = Uri.parse('$baseUrl/state?code=${Uri.encodeComponent(code)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GameState.fromJson(json);
      } else {
        throw Exception('Failed to get state: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting state: $e');
    }
  }

  Future<GameState> startGame(String code) async {
    try {
      final uri = Uri.parse('$baseUrl/startgame?code=${Uri.encodeComponent(code)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GameState.fromJson(json);
      } else {
        throw Exception('Failed to start game: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting game: $e');
    }
  }

  Future<GameState> rollDice({
    required String code,
    required String player,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/rolldice?code=${Uri.encodeComponent(code)}&player=${Uri.encodeComponent(player)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GameState.fromJson(json);
      } else {
        throw Exception('Failed to roll dice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rolling dice: $e');
    }
  }

  Future<void> selectAnswer({
    required String code,
    required String player,
    required String answer,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/selectanswer?code=${Uri.encodeComponent(code)}&player=${Uri.encodeComponent(player)}&answer=${Uri.encodeComponent(answer)}');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to select answer: ${response.statusCode}');
      }
    } catch (e) {
      // Silently fail - this is just for visual feedback
    }
  }

  Future<SubmitAnswerResponse> submitAnswer({
    required String code,
    required String player,
    required String answer,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/submitanswer?code=${Uri.encodeComponent(code)}&player=${Uri.encodeComponent(player)}&answer=${Uri.encodeComponent(answer)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SubmitAnswerResponse.fromJson(json);
      } else {
        throw Exception('Failed to submit answer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting answer: $e');
    }
  }
}

