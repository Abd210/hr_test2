// lib/models/test_question.dart

import 'package:hr_test/models/test_question_option.dart';

enum QuestionType { easy, medium, hard }

class TestQuestion {
  final int id;
  final int testId;
  final QuestionType type;
  final String content;
  final String? picture;
  final int order;
  final int answerTime; // Time in seconds
  final bool isActive;
  final bool isMandatory;
  final List<TestQuestionOption> options;

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
