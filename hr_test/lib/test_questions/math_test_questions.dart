import '../models/test_question.dart';
import '../models/test_question_option.dart';
import '../utils/id_generator.dart';

List<TestQuestion> mathTestQuestions = [
  // Easy Questions
  for (var i = 1; i <= 10; i++)
    TestQuestion(
      id: IDGenerator.getNextTestQuestionId(),
      testId: 2, // Math Test
      type: QuestionType.easy,
      content: 'Easy Math Question $i',
      picture: null,
      order: i,
      answerTime: 20,
      isActive: true,
      isMandatory: true,
      options: List.generate(
        4,
            (index) => TestQuestionOption(
          id: IDGenerator.getNextOptionId(),
          questionId: i,
          content: 'Option ${index + 1} for Q$i',
          order: index + 1,
          isCorrect: index == 0,
        ),
      ),
    ),
  // Medium Questions
  for (var i = 11; i <= 30; i++)
    TestQuestion(
      id: IDGenerator.getNextTestQuestionId(),
      testId: 2,
      type: QuestionType.medium,
      content: 'Medium Math Question $i',
      picture: null,
      order: i,
      answerTime: 40,
      isActive: true,
      isMandatory: true,
      options: List.generate(
        4,
            (index) => TestQuestionOption(
          id: IDGenerator.getNextOptionId(),
          questionId: i,
          content: 'Option ${index + 1} for Q$i',
          order: index + 1,
          isCorrect: index == 0,
        ),
      ),
    ),
  // Hard Questions
  for (var i = 31; i <= 40; i++)
    TestQuestion(
      id: IDGenerator.getNextTestQuestionId(),
      testId: 2,
      type: QuestionType.hard,
      content: 'Hard Math Question $i',
      picture: null,
      order: i,
      answerTime: 60,
      isActive: true,
      isMandatory: true,
      options: List.generate(
        4,
            (index) => TestQuestionOption(
          id: IDGenerator.getNextOptionId(),
          questionId: i,
          content: 'Option ${index + 1} for Q$i',
          order: index + 1,
          isCorrect: index == 0,
        ),
      ),
    ),
];
