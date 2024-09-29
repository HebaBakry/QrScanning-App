import 'answer_model.dart';

class Question {
  final String questionText;
  final List<String> options;
  List<Answer>? answers;

  Question({required this.questionText, required this.options, this.answers});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      answers: json['answers'] != null
          ? (json['answers'] as List)
          .map((answerJson) => Answer.fromJson(answerJson))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'answers': answers?.map((answer) => answer.toJson()).toList(),
    };
  }
}
