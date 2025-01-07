// lib/utils/id_generator.dart

class IDGenerator {
  static int _currentTestQuestionId = 1;
  static int _currentOptionId = 1;

  /// Returns the next unique TestQuestion ID.
  static int getNextTestQuestionId() => _currentTestQuestionId++;

  /// Returns the next unique TestQuestionOption ID.
  static int getNextOptionId() => _currentOptionId++;
}



