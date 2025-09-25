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
    return TriviaItem(
      question: json['question'] ?? '',
      correctAnswer: json['correct_answer'] == 'True',
    );
  }
}
