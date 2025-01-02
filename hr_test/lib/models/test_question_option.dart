// lib/models/test_question_option.dart

class TestQuestionOption {
  final int id;
  final int questionId;
  final String content;
  final int order;
  final bool isCorrect;

  TestQuestionOption({
    required this.id,
    required this.questionId,
    required this.content,
    required this.order,
    required this.isCorrect,
  });
}
