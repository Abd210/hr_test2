import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/test_domain.dart';
import '../models/test_model.dart';
import '../models/test_question.dart';
import '../models/test_question_option.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../utils/constants.dart';
import '../test_questions/java_test_questions.dart';
import '../test_questions/math_test_questions.dart';

final Role superAdminRole = Role(
  id: 1,
  roleName: Constants.superAdminRole,
  description: 'Super Administrator with full access',
);
final Role adminRole = Role(
  id: 2,
  roleName: Constants.adminRole,
  description: 'Administrator with limited access',
);
final Role userRole = Role(
  id: 3,
  roleName: Constants.userRole,
  description: 'Regular user',
);

/// --------------------
/// 1) Organizations
/// --------------------
final List<Organization> initialOrganizations = [
  Organization(
    id: 1,
    name: 'HR Department',
    description: 'Handles all HR-related tasks.',
    createdAt: DateTime.now(),
  ),
  Organization(
    id: 2,
    name: 'IT Department',
    description: 'Handles all IT-related tasks.',
    createdAt: DateTime.now(),
  ),
  Organization(
    id: 3,
    name: 'Marketing Department',
    description: 'Handles marketing tasks.',
    createdAt: DateTime.now(),
  ),
  Organization(
    id: 4,
    name: 'Sales Department',
    description: 'Handles sales and client outreach.',
    createdAt: DateTime.now(),
  ),
];

/// --------------------
/// 2) Users
/// --------------------
final List<User> initialUsers = [
  // Some admins
  User(
    id: 1,
    username: 'superadmin',
    email: 'superadmin@example.com',
    password: 'admin123',
    phoneNumber: '1234567890',
    createdAt: DateTime.now(),
    roles: [superAdminRole],
    organization: initialOrganizations[0], // HR
  ),
  User(
    id: 2,
    username: 'admin_it',
    email: 'admin.it@example.com',
    password: 'admin123',
    phoneNumber: '0987654321',
    createdAt: DateTime.now(),
    roles: [adminRole],
    organization: initialOrganizations[1], // IT
  ),

  // Normal users
  User(
    id: 3,
    username: 'john_hr',
    email: 'john.hr@example.com',
    password: '',
    phoneNumber: '5551112222',
    createdAt: DateTime.now(),
    roles: [userRole],
    organization: initialOrganizations[0],
  ),
  User(
    id: 4,
    username: 'alice_mkt',
    email: 'alice.mkt@example.com',
    password: '',
    phoneNumber: '5553334444',
    createdAt: DateTime.now(),
    roles: [userRole],
    organization: initialOrganizations[2],
  ),
  User(
    id: 5,
    username: 'sam_sales',
    email: 'sam.sales@example.com',
    password: '',
    phoneNumber: '5552221111',
    createdAt: DateTime.now(),
    roles: [userRole],
    organization: initialOrganizations[3],
  ),
];

/// --------------------
/// 3) Domains
/// --------------------
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

/// --------------------
/// 4) Tests
/// --------------------
/// Add more tests for each domain
final List<TestModel> initialTests = [
  // Domain 1 => IT Software
  TestModel(
    id: 1,
    code: 'JAVA',
    name: 'Java Test',
    grade: 'A',
    date: DateTime.now(),
    duration: 60,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 1,
  ),
  TestModel(
    id: 2,
    code: 'PY',
    name: 'Python Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 45,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 1,
  ),
  TestModel(
    id: 3,
    code: 'JS',
    name: 'JavaScript Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 40,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 1,
  ),

  // Domain 2 => IT Hardware
  TestModel(
    id: 4,
    code: 'NET',
    name: 'Networking Basics',
    grade: 'A',
    date: DateTime.now(),
    duration: 50,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 2,
  ),
  TestModel(
    id: 5,
    code: 'HARD',
    name: 'Computer Hardware',
    grade: 'B',
    date: DateTime.now(),
    duration: 45,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 2,
  ),
  TestModel(
    id: 6,
    code: 'OPSYS',
    name: 'Operating Systems',
    grade: 'C',
    date: DateTime.now(),
    duration: 55,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 2,
  ),

  // Domain 3 => Secretary
  TestModel(
    id: 7,
    code: 'ENG',
    name: 'English Test',
    grade: 'A',
    date: DateTime.now(),
    duration: 60,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3,
  ),
  TestModel(
    id: 8,
    code: 'WORD',
    name: 'MS Word Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 30,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3,
  ),
  TestModel(
    id: 9,
    code: 'EXCEL',
    name: 'Excel Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 45,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 3,
  ),

  // Domain 4 => Accountant
  TestModel(
    id: 10,
    code: 'MATH',
    name: 'Math Test',
    grade: 'B',
    date: DateTime.now(),
    duration: 60,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 4,
  ),
  TestModel(
    id: 11,
    code: 'FIN',
    name: 'Finance 101',
    grade: 'B',
    date: DateTime.now(),
    duration: 40,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 4,
  ),
  TestModel(
    id: 12,
    code: 'TAX',
    name: 'Tax Basics',
    grade: 'A',
    date: DateTime.now(),
    duration: 55,
    isActive: true,
    createdAt: DateTime.now(),
    domainId: 4,
  ),
];

/// --------------------
/// 5) Questions
/// --------------------
final List<TestQuestion> initialQuestions = [
  ...javaTestQuestions,
  ...mathTestQuestions,
];
