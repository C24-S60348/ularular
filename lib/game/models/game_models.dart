class Player {
  final String player;
  final int pos;
  final String color;

  Player({
    required this.player,
    required this.pos,
    required this.color,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      player: json['player'] ?? '',
      pos: int.tryParse(json['pos'].toString()) ?? 0,
      color: json['color'] ?? 'black',
    );
  }
}

class GameState {
  final String code;
  final String state; // waiting, playing, ended
  final String turn;
  final String message;
  final List<Player> players;
  final List<Question> question;
  final String questionid;
  final int? dice;
  final int? beforepos;
  final int? pos;
  final List<int>? steps;
  final bool? ended;

  GameState({
    required this.code,
    required this.state,
    required this.turn,
    required this.message,
    required this.players,
    required this.question,
    required this.questionid,
    this.dice,
    this.beforepos,
    this.pos,
    this.steps,
    this.ended,
  });

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      code: json['code'] ?? '',
      state: json['state'] ?? 'waiting',
      turn: json['turn'] ?? '',
      message: json['message'] ?? '',
      players: (json['players'] as List<dynamic>?)
              ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      question: (json['question'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      questionid: json['questionid'] ?? '',
      dice: json['dice'] != null ? int.tryParse(json['dice'].toString()) : null,
      beforepos: json['beforepos'] != null
          ? int.tryParse(json['beforepos'].toString())
          : null,
      pos: json['pos'] != null ? int.tryParse(json['pos'].toString()) : null,
      steps: json['steps'] != null
          ? (json['steps'] as List<dynamic>)
              .map((s) => int.tryParse(s.toString()) ?? 0)
              .toList()
          : null,
      ended: json['ended'] ?? false,
    );
  }
}

class Question {
  final String id;
  final String question;
  final String a1;
  final String a2;
  final String a3;
  final String a4;
  final String? answer; // The correct answer (a1, a2, a3, or a4)

  Question({
    required this.id,
    required this.question,
    required this.a1,
    required this.a2,
    required this.a3,
    required this.a4,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      a1: json['a1'] ?? '',
      a2: json['a2'] ?? '',
      a3: json['a3'] ?? '',
      a4: json['a4'] ?? '',
      answer: json['answer'],
    );
  }
  
  // Get the correct answer label (A, B, C, or D)
  String? get correctAnswerLabel {
    if (answer == null) return null;
    if (answer == a1) return 'A';
    if (answer == a2) return 'B';
    if (answer == a3) return 'C';
    if (answer == a4) return 'D';
    return null;
  }
  
  // Check if an answer is correct
  bool isCorrectAnswer(String answerValue) {
    return answer != null && answer == answerValue;
  }
}

class CreateRoomResponse {
  final String status;
  final String code;
  final String player;
  final String color;
  final String state;
  final int pos;
  final String message;

  CreateRoomResponse({
    required this.status,
    required this.code,
    required this.player,
    required this.color,
    required this.state,
    required this.pos,
    required this.message,
  });

  factory CreateRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateRoomResponse(
      status: json['status'] ?? 'error',
      code: json['code'] ?? '',
      player: json['player'] ?? '',
      color: json['color'] ?? 'black',
      state: json['state'] ?? 'waiting',
      pos: int.tryParse(json['pos'].toString()) ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class JoinRoomResponse {
  final String status;
  final String code;
  final String player;
  final String message;
  final String? state;

  JoinRoomResponse({
    required this.status,
    required this.code,
    required this.player,
    required this.message,
    this.state,
  });

  factory JoinRoomResponse.fromJson(Map<String, dynamic> json) {
    return JoinRoomResponse(
      status: json['status'] ?? 'error',
      code: json['code'] ?? '',
      player: json['player'] ?? '',
      message: json['message'] ?? '',
      state: json['state'],
    );
  }
}

class SubmitAnswerResponse {
  final String status;
  final String message;
  final bool answer;
  final int pos;
  final String? ladderorsnake;
  final List<Player> players;
  final String state;
  final bool? ended;

  SubmitAnswerResponse({
    required this.status,
    required this.message,
    required this.answer,
    required this.pos,
    this.ladderorsnake,
    required this.players,
    required this.state,
    this.ended,
  });

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      answer: json['answer'] ?? false,
      pos: int.tryParse(json['pos'].toString()) ?? 0,
      ladderorsnake: json['ladderorsnake'],
      players: (json['players'] as List<dynamic>?)
              ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      state: json['state'] ?? 'playing',
      ended: json['ended'] ?? false,
    );
  }
}

