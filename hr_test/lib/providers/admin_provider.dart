// lib/providers/admin_provider.dart

import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/user.dart';
import '../models/test_model.dart';
import '../models/test_domain.dart';
import '../models/test_question.dart';
import '../models/role.dart';

class AdminProvider with ChangeNotifier {
  // Organizations
  List<Organization> _organizations = [
    Organization(
      id: 1,
      name: 'HR Department',
      description: 'Handles all HR related tasks.',
      createdAt: DateTime.now(),
    ),
    // Add more organizations as needed
  ];

  List<Organization> get organizations => _organizations;

  void addOrganization(String name, String description) {
    final newOrg = Organization(
      id: _organizations.length + 1,
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

  // Users
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
      id: _users.length + 1,
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

  // Test Domains
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

  // Tests
  List<TestModel> _tests = [
    // Initialize with some tests if needed
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
      id: _tests.length + 1,
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
    notifyListeners();
  }

  // Test Questions
  List<TestQuestion> _testQuestions = [
    TestQuestion(
      id: 1,
      testId: 1,
      type: QuestionType.easy,
      content: 'What is Java?',
      picture: null,
      order: 1,
      answerTime: 30,
      isActive: true,
      isMandatory: true,
      options: [
        TestQuestionOption(
          id: 1,
          questionId: 1,
          content: 'A programming language',
          order: 1,
          isCorrect: true,
        ),
        TestQuestionOption(
          id: 2,
          questionId: 1,
          content: 'A coffee brand',
          order: 2,
          isCorrect: false,
        ),
        TestQuestionOption(
          id: 3,
          questionId: 1,
          content: 'An island in Indonesia',
          order: 3,
          isCorrect: false,
        ),
        TestQuestionOption(
          id: 4,
          questionId: 1,
          content: 'A type of dance',
          order: 4,
          isCorrect: false,
        ),
      ],
    ),
    // Add more questions as needed
  ];

  List<TestQuestion> get testQuestions => _testQuestions;

  void addTestQuestion(TestQuestion question) {
    _testQuestions.add(question);
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
}
