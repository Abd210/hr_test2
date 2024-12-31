
//test_question.dart
enum QuestionType { easy, medium, hard }

class TestQuestion {
  final int id;
  final int testId;
  QuestionType type;
  String content;
  String? picture; // URL or base64
  int order;
  int answerTime; // in seconds
  bool isActive;
  bool isMandatory;
  List<TestQuestionOption> options;

  TestQuestion({
    required this.id,
    required this.testId,
    required this.type,
    required this.content,
    this.picture,
    required this.order,
    required this.answerTime,
    required this.isActive,
    required this.isMandatory,
    required this.options,
  });
}

class TestQuestionOption {
  final int id;
  final int questionId;
  String content;
  int order;
  bool isCorrect;

  TestQuestionOption({
    required this.id,
    required this.questionId,
    required this.content,
    required this.order,
    required this.isCorrect,
  });
}
