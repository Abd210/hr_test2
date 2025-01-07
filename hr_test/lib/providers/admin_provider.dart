import 'dart:math';
import 'package:flutter/material.dart';
// Models
import '../models/organization.dart';
import '../models/test_model.dart';
import '../models/test_domain.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../models/permission.dart';
import '../models/test_question.dart';
import '../models/test_question_option.dart';
// Some folks also had references to "javaTestQuestions" or "mathTestQuestions"
// but typically that's in static_data or separate test_questions files

// Your static data reference
import '../static/static_data.dart'; // Must define initialOrganizations, etc.

// For ID generation
import '../utils/id_generator.dart';

class AdminProvider with ChangeNotifier {
  // -------------------------------------------------
  // 1) Organizations
  // -------------------------------------------------
  // Pull from static data:
  List<Organization> _organizations = List.from(initialOrganizations);
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
    final idx = _organizations.indexWhere((org) => org.id == id);
    if (idx != -1) {
      _organizations[idx].name = name;
      _organizations[idx].description = description;
      notifyListeners();
    }
  }

  void deleteOrganization(int id) {
    _organizations.removeWhere((org) => org.id == id);
    notifyListeners();
  }

  // Generate unique org ID by scanning existing
  int generateOrganizationId() {
    if (_organizations.isEmpty) return 1;
    return _organizations.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // -------------------------------------------------
  // 2) Users
  // -------------------------------------------------
  List<User> _users = List.from(initialUsers);
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
    final userIndex = _users.indexWhere((u) => u.id == id);
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
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  int generateUserId() {
    if (_users.isEmpty) return 1;
    return _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // -------------------------------------------------
  // 3) Test Domains
  // -------------------------------------------------
  List<TestDomain> _testDomains = List.from(initialDomains);
  List<TestDomain> get testDomains => _testDomains;

  void addTestDomain(TestDomain domain) {
    _testDomains.add(domain);
    notifyListeners();
  }

  void updateTestDomain(TestDomain updatedDomain) {
    final idx = _testDomains.indexWhere((d) => d.id == updatedDomain.id);
    if (idx != -1) {
      _testDomains[idx] = updatedDomain;
      notifyListeners();
    }
  }

  void deleteTestDomain(int id) {
    _testDomains.removeWhere((dom) => dom.id == id);
    notifyListeners();
  }

  // -------------------------------------------------
  // 4) Tests
  // -------------------------------------------------
  List<TestModel> _tests = List.from(initialTests);
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
    final idx = _tests.indexWhere((t) => t.id == updatedTest.id);
    if (idx != -1) {
      _tests[idx] = updatedTest;
      notifyListeners();
    }
  }

  void deleteTest(int id) {
    _tests.removeWhere((t) => t.id == id);
    // also remove associated questions
    _testQuestions.removeWhere((q) => q.testId == id);
    notifyListeners();
  }

  int generateTestId() {
    if (_tests.isEmpty) return 1;
    return _tests.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // -------------------------------------------------
  // 5) Test Questions
  // -------------------------------------------------
  // Start with the initial questions from static_data
  List<TestQuestion> _testQuestions = List.from(initialQuestions);
  List<TestQuestion> get testQuestions => _testQuestions;

  void addTestQuestion(TestQuestion question) {
    _testQuestions.add(question);
    notifyListeners();
  }

  void updateTestQuestion(TestQuestion updatedQuestion) {
    final idx = _testQuestions.indexWhere((q) => q.id == updatedQuestion.id);
    if (idx != -1) {
      _testQuestions[idx] = updatedQuestion;
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

  Future<void> addTestWithQuestions(TestModel test, List<TestQuestion> questions) async {
    _tests.add(test);
    _testQuestions.addAll(questions);
    notifyListeners();
  }

  // ID generator helpers for questions & options
  int getNextQuestionId() {
    if (_testQuestions.isEmpty) return 1;
    return _testQuestions.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  int getNextOptionId() {
    int maxId = 0;
    for (var q in _testQuestions) {
      for (var o in q.options) {
        if (o.id > maxId) maxId = o.id;
      }
    }
    return maxId + 1;
  }

  // -------------------------------------------------
  // 6) Assign Tests to Users
  // -------------------------------------------------
  final Map<int, List<int>> _userAssignedTests = {};

  void assignTestsToUser(int userId, List<int> testIds) {
    final existing = _userAssignedTests[userId] ?? [];
    final updated = [...existing];
    for (var tId in testIds) {
      if (!updated.contains(tId)) {
        updated.add(tId);
      }
    }
    _userAssignedTests[userId] = updated;
    notifyListeners();
  }

  List<int> getAssignedTestIdsForUser(int userId) {
    return _userAssignedTests[userId] ?? [];
  }

  List<TestModel> getAssignedTestsForUser(int userId) {
    final assignedIds = getAssignedTestIdsForUser(userId);
    return _tests.where((t) => assignedIds.contains(t.id)).toList();
  }

  // -------------------------------------------------
  // 7) Generate Test Key Logic (if you use that)
  // -------------------------------------------------
  final Map<String, List<TestQuestion>> _testKeys = {};

  String generateTestKey(int testId) {
    final questions = getQuestionsByTestId(testId);
    final easy = questions.where((q) => q.type == QuestionType.easy).toList();
    final medium = questions.where((q) => q.type == QuestionType.medium).toList();
    final hard = questions.where((q) => q.type == QuestionType.hard).toList();

    if (easy.length < 4 || medium.length < 3 || hard.length < 3) {
      throw Exception("Insufficient questions to generate the test.");
    }

    // shuffle and pick
    easy.shuffle();
    medium.shuffle();
    hard.shuffle();

    final selected = [
      ...easy.sublist(0, 4),
      ...medium.sublist(0, 3),
      ...hard.sublist(0, 3),
    ];

    // generate unique key
    String key;
    do {
      key = Random().nextInt(1000000).toString().padLeft(6, '0');
    } while (_testKeys.containsKey(key));

    _testKeys[key] = selected;
    notifyListeners();
    return key;
  }

  List<TestQuestion>? getTestByKey(String key) => _testKeys[key];
}
