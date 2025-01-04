// lib/providers/admin_provider.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/test_model.dart';
import '../models/test_domain.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../models/permission.dart';
import '../models/test_question.dart';
import '../test_questions/java_test_questions.dart';
import '../test_questions/math_test_questions.dart';
import '../utils/id_generator.dart';

class AdminProvider with ChangeNotifier {
  // ---------------------------
  // Organizations
  // ---------------------------
  List<Organization> _organizations = [
    Organization(
      id: 1,
      name: 'HR Department',
      description: 'Handles all HR related tasks.',
      createdAt: DateTime.now(),
    ),
    Organization(
      id: 2,
      name: 'IT Department',
      description: 'Handles all IT related tasks.',
      createdAt: DateTime.now(),
    ),
    // Add more organizations as needed
  ];

  List<Organization> get organizations => _organizations;

  void addOrganization(String name, String description) {
    final newOrg = Organization(
      id: generateOrganizationId(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    _organizations.add(newOrg);
    notifyListeners();
  }

  void updateOrganization(int id, String name, String description) {
    final orgIndex = _organizations.indexWhere((org) => org.id == id);
    if (orgIndex != -1) {
      _organizations[orgIndex].name = name;
      _organizations[orgIndex].description = description;
      notifyListeners();
    }
  }

  void deleteOrganization(int id) {
    _organizations.removeWhere((org) => org.id == id);
    notifyListeners();
  }

  // ---------------------------
  // Users
  // ---------------------------
  List<User> _users = [
    // Initialize with some users if needed
  ];

  List<User> get users => _users;

  void addUser({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    required List<Role> roles,
    required Organization organization,
  }) {
    final newUser = User(
      id: generateUserId(),
      username: username,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      roles: roles,
      organization: organization,
    );
    _users.add(newUser);
    notifyListeners();
  }

  void updateUser({
    required int id,
    required String username,
    required String email,
    required String phoneNumber,
    required List<Role> roles,
    required Organization organization,
  }) {
    final userIndex = _users.indexWhere((user) => user.id == id);
    if (userIndex != -1) {
      _users[userIndex].username = username;
      _users[userIndex].email = email;
      _users[userIndex].phoneNumber = phoneNumber;
      _users[userIndex].roles = roles;
      _users[userIndex].organization = organization;
      notifyListeners();
    }
  }

  void deleteUser(int id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  // ---------------------------
  // Test Domains
  // ---------------------------
  List<TestDomain> _testDomains = [
    TestDomain(
      id: 1,
      name: 'Software Engineering',
      description: 'All software related tests.',
      createdAt: DateTime.now(),
    ),
    TestDomain(
      id: 2,
      name: 'Human Resources',
      description: 'HR related tests and assessments.',
      createdAt: DateTime.now(),
    ),
    // Add more domains as needed
  ];

  List<TestDomain> get testDomains => _testDomains;

  void addTestDomain(TestDomain domain) {
    _testDomains.add(domain);
    notifyListeners();
  }

  void updateTestDomain(TestDomain updatedDomain) {
    final domainIndex =
    _testDomains.indexWhere((domain) => domain.id == updatedDomain.id);
    if (domainIndex != -1) {
      _testDomains[domainIndex] = updatedDomain;
      notifyListeners();
    }
  }

  void deleteTestDomain(int id) {
    _testDomains.removeWhere((domain) => domain.id == id);
    notifyListeners();
  }

  // ---------------------------
  // Tests
  // ---------------------------
  List<TestModel> _tests = [
    // Adding static tests "Java" and "Math" with comprehensive questions
    TestModel(
      id: 1,
      code: 'JAVA',
      name: 'Java Programming Test',
      grade: 'A',
      date: DateTime.now(),
      duration: 60,
      isActive: true,
      createdAt: DateTime.now(),
      domainId: 1, // Assuming 'Software Engineering'
    ),
    TestModel(
      id: 2,
      code: 'MATH',
      name: 'Mathematics Test',
      grade: 'B',
      date: DateTime.now(),
      duration: 45,
      isActive: true,
      createdAt: DateTime.now(),
      domainId: 1, // Assuming 'Software Engineering'
    ),
    // Add more tests as needed
  ];

  List<TestModel> get tests => _tests;

  void addTest({
    required String code,
    required String name,
    required String grade,
    required DateTime date,
    required int duration,
    required bool isActive,
    required int domainId,
  }) {
    final newTest = TestModel(
      id: generateTestId(),
      code: code,
      name: name,
      grade: grade,
      date: date,
      duration: duration,
      isActive: isActive,
      createdAt: DateTime.now(),
      domainId: domainId,
    );
    _tests.add(newTest);
    notifyListeners();
  }

  void updateTest(TestModel updatedTest) {
    final testIndex = _tests.indexWhere((test) => test.id == updatedTest.id);
    if (testIndex != -1) {
      _tests[testIndex] = updatedTest;
      notifyListeners();
    }
  }

  void deleteTest(int id) {
    _tests.removeWhere((test) => test.id == id);
    // Also remove associated questions
    _testQuestions.removeWhere((q) => q.testId == id);
    notifyListeners();
  }

  // ---------------------------
  // Test Questions
  // ---------------------------
  List<TestQuestion> _testQuestions = [
    // Import and add questions from separate files
    ...javaTestQuestions,
    ...mathTestQuestions,
  ];

  List<TestQuestion> get testQuestions => _testQuestions;

  void addTestQuestion(TestQuestion question) {
    _testQuestions.add(question);
    // Since options are part of the question, no need to add them separately
    notifyListeners();
  }

  void updateTestQuestion(TestQuestion updatedQuestion) {
    final questionIndex =
    _testQuestions.indexWhere((q) => q.id == updatedQuestion.id);
    if (questionIndex != -1) {
      _testQuestions[questionIndex] = updatedQuestion;
      notifyListeners();
    }
  }

  void deleteTestQuestion(int id) {
    _testQuestions.removeWhere((q) => q.id == id);
    notifyListeners();
  }

  List<TestQuestion> getQuestionsByTestId(int testId) {
    return _testQuestions.where((q) => q.testId == testId).toList();
  }

  // ---------------------------
  // Unique ID Generators
  // ---------------------------
  int generateOrganizationId() {
    if (_organizations.isEmpty) return 1;
    return _organizations.map((org) => org.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  int generateUserId() {
    if (_users.isEmpty) return 1;
    return _users.map((user) => user.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  int generateTestId() {
    if (_tests.isEmpty) return 1;
    return _tests.map((test) => test.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // These methods ensure unique IDs by scanning existing questions and options
  int getNextQuestionId() {
    if (_testQuestions.isEmpty) return 1;
    return _testQuestions.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  int getNextOptionId() {
    // Find the maximum option ID across all questions
    int maxId = 0;
    for (var question in _testQuestions) {
      for (var option in question.options) {
        if (option.id > maxId) {
          maxId = option.id;
        }
      }
    }
    return maxId + 1;
  }

  // ---------------------------
  // Add Test with Questions via JSON
  // ---------------------------
  Future<void> addTestWithQuestions(TestModel test, List<TestQuestion> questions) async {
    // Add Test
    _tests.add(test);

    // Add Questions
    for (var question in questions) {
      _testQuestions.add(question);
    }

    notifyListeners();
  }

  // ---------------------------
  // Generate Test Key Methods
  // ---------------------------

  final Map<String, List<TestQuestion>> _testKeys = {};

  /// Generates a unique test key for a given test ID.
  /// Selects 10 MCQs: 4 Easy, 3 Medium, 3 Hard.
  /// Throws an exception if insufficient questions are available.
  String generateTestKey(int testId) {
    final testQuestions = getQuestionsByTestId(testId);
    final easy = testQuestions.where((q) => q.type == QuestionType.easy).toList();
    final medium = testQuestions.where((q) => q.type == QuestionType.medium).toList();
    final hard = testQuestions.where((q) => q.type == QuestionType.hard).toList();

    if (easy.length < 4 || medium.length < 3 || hard.length < 3) {
      throw Exception("Insufficient questions to generate the test.");
    }

    // Shuffle and select required number of questions
    easy.shuffle();
    medium.shuffle();
    hard.shuffle();

    final selectedQuestions = [
      ...easy.sublist(0, 4),
      ...medium.sublist(0, 3),
      ...hard.sublist(0, 3),
    ];

    // Generate a unique 6-digit key
    String key;
    do {
      key = Random().nextInt(1000000).toString().padLeft(6, '0');
    } while (_testKeys.containsKey(key)); // Ensure uniqueness

    _testKeys[key] = selectedQuestions;
    notifyListeners();

    return key;
  }

  /// Retrieves the list of questions associated with a given test key.
  List<TestQuestion>? getTestByKey(String key) => _testKeys[key];
}
