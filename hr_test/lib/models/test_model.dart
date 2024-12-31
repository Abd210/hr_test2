//test_model.dart  i have it twice but lazy to delete
class TestModel {
  final int id;
  String code;
  String name;
  String grade;
  DateTime date;
  int duration; // in minutes
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
