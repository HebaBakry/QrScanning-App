class Answer {
  String user;
  String answer;
  DateTime timestamp;

  Answer({
    required this.user,
    required this.answer,
    required this.timestamp,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      user: json['user'],
      answer: json['answer'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}