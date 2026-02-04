import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApiService {
  static const String baseUrl = 'https://afwanhaziq.vps.webdock.cloud/api';

  Future<bool> login(String password) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/login?password=${Uri.encodeComponent(password)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionList({String? topic}) async {
    try {
      String url = '$baseUrl/admin/getquestionlist';
      if (topic != null && topic.isNotEmpty) {
        url += '?topic=${Uri.encodeComponent(topic)}';
      }
      
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          return List<Map<String, dynamic>>.from(json['questions']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getQuestion(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/getquestion?id=${Uri.encodeComponent(id)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          return json['question'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createQuestion({
    required String id,
    required String question,
    required String a1,
    required String a2,
    required String a3,
    required String a4,
    required String answer,
    required String topic,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/admin/createquestion?'
        'id=${Uri.encodeComponent(id)}&'
        'question=${Uri.encodeComponent(question)}&'
        'a1=${Uri.encodeComponent(a1)}&'
        'a2=${Uri.encodeComponent(a2)}&'
        'a3=${Uri.encodeComponent(a3)}&'
        'a4=${Uri.encodeComponent(a4)}&'
        'answer=${Uri.encodeComponent(answer)}&'
        'topic=${Uri.encodeComponent(topic)}'
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'success': json['status'] == 'ok',
          'message': json['message'] ?? 'Unknown error'
        };
      }
      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> updateQuestion({
    required String id,
    required String question,
    required String a1,
    required String a2,
    required String a3,
    required String a4,
    required String answer,
    required String topic,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/admin/updatequestion?'
        'id=${Uri.encodeComponent(id)}&'
        'question=${Uri.encodeComponent(question)}&'
        'a1=${Uri.encodeComponent(a1)}&'
        'a2=${Uri.encodeComponent(a2)}&'
        'a3=${Uri.encodeComponent(a3)}&'
        'a4=${Uri.encodeComponent(a4)}&'
        'answer=${Uri.encodeComponent(answer)}&'
        'topic=${Uri.encodeComponent(topic)}'
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteQuestion(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/deletequestion?id=${Uri.encodeComponent(id)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getTopics() async {
    try {
      final uri = Uri.parse('$baseUrl/admin/gettopics');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          return List<String>.from(json['topics']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
