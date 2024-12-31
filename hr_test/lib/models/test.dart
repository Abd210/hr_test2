//test.dart
class TestModel {
  final int id;
  final String code;
  final String name;
  final String grade;
  final DateTime date;
  final int duration; // in minutes
  final bool isActive;
  final DateTime createdAt;
  final int domainId;

  TestModel({
    required this.id,
    required this.code,
    required this.name,
    required this.grade,
    required this.date,
    required this.duration,
    required this.isActive,
    required this.createdAt,
    required this.domainId,
  });
}
