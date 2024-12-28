// lib/models/test_domain.dart

class TestDomain {
  final int id;
  String name;
  String description;
  DateTime createdAt;

  TestDomain({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });
}
