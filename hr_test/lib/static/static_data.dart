import '../models/organization.dart';
import '../models/test_domain.dart';
import '../models/test_model.dart';
import '../models/test_question.dart';
import '../models/test_question_option.dart';
import '../test_questions/java_test_questions.dart';
import '../test_questions/math_test_questions.dart';

/// Initial Organizations
final List<Organization> initialOrganizations = [
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
  Organization(
    id: 3,
    name: 'Marketing Department',
    description: 'Handles all marketing and advertising tasks.',
    createdAt: DateTime.now(),
  ),
];

/// Initial Domains
final List<TestDomain> initialDomains = [
  TestDomain(
    id: 1,
    name: 'IT Software',
    description: 'Software-related jobs.',
    createdAt: DateTime.now(),
  ),
  TestDomain(
    id: 2,
    name: 'IT Hardware',
    description: 'Hardware-related jobs.',
    createdAt: DateTime.now(),
  ),
  TestDomain(
    id: 3,
    name: 'Secretary',
    description: 'Secretary-related jobs.',
    createdAt: DateTime.now(),
  ),
  TestDomain(
    id: 4,
    name: 'Accountant',
    description: 'Accounting-related jobs.',
    createdAt: DateTime.now(),
  ),
];

/// Initial Tests
final List<TestModel> initialTests = [
  TestModel(
    id: 1,
    code: 'ENG',
    name: 'English Test',
    grade: 'A',
    date: DateTime.now(),
    duration: 60,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3, // Secretary
  ),
  TestModel(
    id: 2,
    code: 'WORD',
    name: 'MS Word Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 30,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3, // Secretary
  ),
  TestModel(
    id: 3,
    code: 'EXCEL',
    name: 'Excel Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 45,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3, // Secretary
  ),
  TestModel(
    id: 4,
    code: 'ALL',
    name: 'All-in-One Secretary Test',
    grade: 'A',
    date: DateTime.now(),
    duration: 90,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3, // Secretary
  ),
  TestModel(
    id: 5,
    code: 'MATH',
    name: 'Math Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 60,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 4, // Accountant
  ),
];

/// Initial Questions (merging Java & Math from your test_questions)
final List<TestQuestion> initialQuestions = [
  ...javaTestQuestions,
  ...mathTestQuestions,
];

