import 'package:html_unescape/html_unescape.dart';

class TriviaItem {
  final String question;
  final bool correctAnswer;
  bool revealed;

  TriviaItem({
    required this.question,
    required this.correctAnswer,
    this.revealed = false,
  });

  factory TriviaItem.fromJson(Map<String, dynamic> json) {
    var unescape = HtmlUnescape();
    return TriviaItem(
      question: unescape.convert(json['question'] ?? ''),
      correctAnswer: json['correct_answer'] == 'True',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'correct_answer': correctAnswer ? 'True' : 'False',
    };
  }
}
