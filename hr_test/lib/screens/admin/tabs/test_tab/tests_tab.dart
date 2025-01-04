// lib/screens/admin/tabs/tests_tab.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/test_domain.dart';
import '../../../../models/test_question.dart';
import '../../../../models/test_question_option.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../models/test_model.dart';
import 'manage_questions_tab.dart';

class TestsTab extends StatefulWidget {
  final bool showManageQuestions;
  final TestModel? selectedTestForQuestions;
  final Function(TestModel) onManageQuestions;
  final VoidCallback onCloseManageQuestions;

  const TestsTab({
    Key? key,
    required this.showManageQuestions,
    required this.selectedTestForQuestions,
    required this.onManageQuestions,
    required this.onCloseManageQuestions,
  }) : super(key: key);

  @override
  State<TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<TestsTab> {
  // Controllers for Tests
  final TextEditingController _testSearchController = TextEditingController();
  final TextEditingController _testCodeController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testGradeController = TextEditingController();
  final TextEditingController _testDurationController = TextEditingController();
  final TextEditingController _questionsJsonController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    _testSearchController.dispose();
    _testCodeController.dispose();
    _testNameController.dispose();
    _testGradeController.dispose();
    _testDurationController.dispose();
    _questionsJsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showManageQuestions && widget.selectedTestForQuestions != null) {
      // Show inline ManageQuestionsTab
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ManageQuestionTab(
          test: widget.selectedTestForQuestions!,
          onBack: widget.onCloseManageQuestions,
        ),
      );
    }

    final adminProvider = Provider.of<AdminProvider>(context);
    final filtered = adminProvider.tests.where((t) {
      final query = _testSearchController.text.trim().toLowerCase();
      return t.name.toLowerCase().contains(query) ||
          t.code.toLowerCase().contains(query) ||
          t.grade.toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Search Tests...',
                        controller: _testSearchController,
                        onChanged: (_) => setState(() {}),
                        hintText: 'Search by name, code, or grade',
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() {}),
                      tooltip: 'Search',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                filtered.isEmpty
                    ? const Center(child: Text('No tests found.'))
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final t = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${t.name} (Code: ${t.code})',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Grade: ${t.grade}\n'
                                'Duration: ${t.duration} mins\n'
                                'Status: ${t.isActive ? "Active" : "Inactive"}',
                          ),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 220, // Increased width to accommodate the new button
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Generate Test Key Button
                                IconButton(
                                  icon: const Icon(Icons.key,
                                      color: Colors.purple),
                                  tooltip: 'Generate Test Key',
                                  onPressed: () {
                                    _generateTestKeyDialog(t, adminProvider);
                                  },
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.question_answer,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Manage Questions',
                                  onPressed: () {
                                    widget.onManageQuestions(t);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () {
                                    _showEditTestDialog(t, adminProvider);
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      context: context,
                                      title: 'Delete Test',
                                      content:
                                      'Delete "${t.name}"?',
                                      onConfirm: () {
                                        adminProvider.deleteTest(t.id);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        // Right: add test form
        Container(
          width: 350,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Add Test with Questions via JSON',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Test Code',
                      controller: _testCodeController,
                      hintText: 'Enter unique test code',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Test Name',
                      controller: _testNameController,
                      hintText: 'Enter test name',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Grade',
                      controller: _testGradeController,
                      hintText: 'Enter grade level',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Duration (minutes)',
                      controller: _testDurationController,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter duration in minutes',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: 'Select Domain'),
                            value: null,
                            items: [
                              ...adminProvider.testDomains.map(
                                    (dom) => DropdownMenuItem<int>(
                                  value: dom.id,
                                  child: Text(dom.name),
                                ),
                              ),
                              const DropdownMenuItem<int>(
                                value: -1,
                                child: Text('Add New Domain'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == -1) {
                                _showAddDomainDialog(adminProvider);
                              }
                            },
                            hint: const Text('Choose Domain'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Questions JSON (Optional)',
                      controller: _questionsJsonController,
                      maxLines: 4,
                      hintText:
                      'Enter questions in JSON format or leave empty.',
                      // Example:
                      // [
                      //   {
                      //     "content": "Question 1",
                      //     "type": "easy",
                      //     "answerTime": 30,
                      //     "isActive": true,
                      //     "isMandatory": true,
                      //     "options": [
                      //       {"content": "Option 1", "isCorrect": true},
                      //       {"content": "Option 2", "isCorrect": false},
                      //       {"content": "Option 3", "isCorrect": false},
                      //       {"content": "Option 4", "isCorrect": false}
                      //     ]
                      //   }
                      // ]
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Is Active'),
                        const Spacer(),
                        Switch(
                          value: true,
                          onChanged: (val) {
                            // Handle switch if needed
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Add Test',
                      icon: Icons.add_task,
                      onPressed: () => _addTestWithQuestions(adminProvider),
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  // ----------------------------------------------------------------------
  // GENERATE TEST KEY DIALOG
  // ----------------------------------------------------------------------
  void _generateTestKeyDialog(TestModel test, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate Test Key'),
          content: const Text(
              'Do you want to generate a test key for this test? This will select 10 random MCQs (4 Easy, 3 Medium, 3 Hard).'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Generate',style: TextStyle(color: Colors.white),),
              onPressed: () {
                try {
                  final key = adminProvider.generateTestKey(test.id);
                  Navigator.pop(ctx);
                  _showTestKeyResultDialog(key);
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays the generated test key in a dialog.
  void _showTestKeyResultDialog(String key) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Key'),
        content: SelectableText('Generated Key: $key'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // ADD TEST WITH QUESTIONS LOGIC
  // ----------------------------------------------------------------------
  Future<void> _addTestWithQuestions(AdminProvider adminProvider) async {
    final code = _testCodeController.text.trim();
    final name = _testNameController.text.trim();
    final grade = _testGradeController.text.trim();
    final durationText = _testDurationController.text.trim();
    final domainId = _getSelectedDomainId(adminProvider);
    final questionsJson = _questionsJsonController.text.trim();

    if (code.isEmpty ||
        name.isEmpty ||
        grade.isEmpty ||
        durationText.isEmpty ||
        domainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Please fill all fields including selecting a domain.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid duration.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse JSON if provided
    List<dynamic> questionsList = [];
    if (questionsJson.isNotEmpty) {
      try {
        questionsList = json.decode(questionsJson);
        if (questionsList is! List) {
          throw FormatException('JSON is not a list.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid JSON format: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate and convert questions
      List<Map<String, dynamic>> validQuestions = [];
      for (var q in questionsList) {
        if (q is! Map<String, dynamic>) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Each question must be a JSON object.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Required fields
        if (!q.containsKey('content') ||
            !q.containsKey('type') ||
            !q.containsKey('answerTime') ||
            !q.containsKey('isActive') ||
            !q.containsKey('isMandatory') ||
            !q.containsKey('options')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
              Text('Missing required fields in one of the questions.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validate options
        var options = q['options'];
        if (options is! List || options.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
              Text('Each question must have at least two options.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        for (var opt in options) {
          if (opt is! Map<String, dynamic> ||
              !opt.containsKey('content') ||
              !opt.containsKey('isCorrect')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Each option must have "content" and "isCorrect" fields.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        validQuestions.add(q);
      }
    }

    // Create TestModel
    final newTest = TestModel(
      id: adminProvider.generateTestId(),
      code: code,
      name: name,
      grade: grade,
      date: DateTime.now(),
      duration: duration,
      isActive: true, // Assuming default as true
      createdAt: DateTime.now(),
      domainId: domainId,
    );

    // Create TestQuestions and TestQuestionOptions if JSON was provided
    List<TestQuestion> testQuestions = [];
    if (questionsList.isNotEmpty) {
      int questionIdCounter = adminProvider.getNextQuestionId();
      int optionIdCounter = adminProvider.getNextOptionId();

      int order = 1;
      for (var q in questionsList) {
        String typeStr = q['type'].toString().toLowerCase();
        QuestionType type;
        switch (typeStr) {
          case 'easy':
            type = QuestionType.easy;
            break;
          case 'medium':
            type = QuestionType.medium;
            break;
          case 'hard':
            type = QuestionType.hard;
            break;
          default:
            type = QuestionType.easy;
        }

        List<dynamic> options = q['options'];
        List<TestQuestionOption> questionOptions = [];
        for (var opt in options) {
          questionOptions.add(TestQuestionOption(
            id: optionIdCounter++,
            questionId: questionIdCounter,
            content: opt['content'],
            order: questionOptions.length + 1,
            isCorrect: opt['isCorrect'],
          ));
        }

        testQuestions.add(TestQuestion(
          id: questionIdCounter++,
          testId: newTest.id,
          type: type,
          content: q['content'],
          picture: null, // Assuming no picture
          order: order++,
          answerTime: q['answerTime'],
          isActive: q['isActive'],
          isMandatory: q['isMandatory'],
          options: questionOptions,
        ));
      }
    }

    // Add Test and Questions via AdminProvider
    try {
      await adminProvider.addTestWithQuestions(newTest, testQuestions);
      // Clear the form
      _testCodeController.clear();
      _testNameController.clear();
      _testGradeController.clear();
      _testDurationController.clear();
      _questionsJsonController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test added successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding test: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ----------------------------------------------------------------------
  // Helper to get selected domain ID
  // ----------------------------------------------------------------------
  int? _getSelectedDomainId(AdminProvider adminProvider) {
    // Implement logic to retrieve selected domain ID from dropdown
    // This can be managed using a separate state variable
    // For simplicity, assuming the first domain is selected
    if (adminProvider.testDomains.isNotEmpty) {
      return adminProvider.testDomains.first.id;
    }
    return null;
  }

  // ----------------------------------------------------------------------
  // ADD NEW DOMAIN DIALOG
  // ----------------------------------------------------------------------
  void _showAddDomainDialog(AdminProvider adminProvider) {
    final TextEditingController _domainNameController = TextEditingController();
    final TextEditingController _domainDescController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add New Domain',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Domain Name',
                  controller: _domainNameController,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter domain name'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Description',
                  controller: _domainDescController,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter description'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child:
              const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newDomain = TestDomain(
                    id: adminProvider.testDomains.isEmpty
                        ? 1
                        : adminProvider.testDomains
                        .map((dom) => dom.id)
                        .reduce((a, b) => a > b ? a : b) +
                        1,
                    name: _domainNameController.text.trim(),
                    description: _domainDescController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  adminProvider.addTestDomain(newDomain);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Domain added successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // CONFIRM DELETION HELPER
  // ----------------------------------------------------------------------
  void _confirmDeletion({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // EDIT TEST DIALOG
  // ----------------------------------------------------------------------
  void _showEditTestDialog(TestModel test, AdminProvider adminProvider) {
    final _editCodeController = TextEditingController(text: test.code);
    final _editNameController = TextEditingController(text: test.name);
    final _editGradeController = TextEditingController(text: test.grade);
    final _editDurationController =
    TextEditingController(text: test.duration.toString());
    int selectedDomainId = test.domainId;
    bool isActive = test.isActive;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Test',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                        label: 'Test Code',
                        controller: _editCodeController,
                        hintText: 'Enter unique test code',
                        maxLines: 1),
                    const SizedBox(height: 12),
                    CustomTextField(
                        label: 'Test Name',
                        controller: _editNameController,
                        hintText: 'Enter test name',
                        maxLines: 1),
                    const SizedBox(height: 12),
                    CustomTextField(
                        label: 'Grade',
                        controller: _editGradeController,
                        hintText: 'Enter grade level',
                        maxLines: 1),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Duration (minutes)',
                      controller: _editDurationController,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter duration in minutes',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: 'Select Domain'),
                            value: selectedDomainId,
                            items: [
                              ...adminProvider.testDomains.map(
                                    (dom) => DropdownMenuItem<int>(
                                  value: dom.id,
                                  child: Text(dom.name),
                                ),
                              ),
                              const DropdownMenuItem<int>(
                                value: -1,
                                child: Text('Add New Domain'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == -1) {
                                _showAddDomainDialog(adminProvider);
                              } else if (val != null) {
                                setStateDialog(() {
                                  selectedDomainId = val;
                                });
                              }
                            },
                            hint: const Text('Choose Domain'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Is Active'),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          onChanged: (sw) {
                            setStateDialog(() {
                              isActive = sw;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Save',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (_editCodeController.text.trim().isEmpty ||
                        _editNameController.text.trim().isEmpty ||
                        _editGradeController.text.trim().isEmpty ||
                        _editDurationController.text.trim().isEmpty ||
                        selectedDomainId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Fill all fields including domain'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final parsedDuration =
                    int.tryParse(_editDurationController.text.trim());
                    if (parsedDuration == null || parsedDuration <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invalid duration'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }

                    test.code = _editCodeController.text.trim();
                    test.name = _editNameController.text.trim();
                    test.grade = _editGradeController.text.trim();
                    test.duration = parsedDuration;
                    test.domainId = selectedDomainId;
                    test.isActive = isActive;

                    adminProvider.updateTest(test);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Test updated'),
                          backgroundColor: Colors.green),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
