// lib/models/test_model.dart

class TestModel {
  final int id;
  String code;
  String name;
  String grade;
  DateTime date;
  int duration;
  bool isActive;
  DateTime createdAt;
  int domainId;

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
