import 'package:offline_task/Models/questions_model.dart';

class Data {
  final List<Question> questions;

  Data({required this.questions});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      questions: (json['questions'] as List)
          .map((i) => Question.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}