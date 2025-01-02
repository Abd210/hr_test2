// lib/screens/admin/tabs/tests_tab.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                            width: 170,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    DropdownButtonFormField<int>(
                      decoration:
                      const InputDecoration(labelText: 'Select Domain'),
                      items: adminProvider.testDomains
                          .map(
                            (dom) => DropdownMenuItem<int>(
                          value: dom.id,
                          child: Text(dom.name),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        // Handle domain selection if needed
                      },
                      hint: const Text('Choose Domain'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Questions JSON',
                      controller: _questionsJsonController,
                      maxLines: 2,
                      hintText:
                      'Enter questions in JSON format.',
                      //Example:\n[\n  {\n    "content": "Question 1",\n    "type": "easy",\n    "answerTime": 30,\n    "isActive": true,\n    "isMandatory": true,\n    "options": [\n      {"content": "Option 1", "isCorrect": true},\n      {"content": "Option 2", "isCorrect": false},\n      {"content": "Option 3", "isCorrect": false},\n      {"content": "Option 4", "isCorrect": false}\n    ]\n  }\n]
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
  // ADD TEST WITH QUESTIONS LOGIC
  // ----------------------------------------------------------------------
  Future<void> _addTestWithQuestions(AdminProvider adminProvider) async {
    final code = _testCodeController.text.trim();
    final name = _testNameController.text.trim();
    final grade = _testGradeController.text.trim();
    final durationText = _testDurationController.text.trim();
    final domainId = adminProvider.testDomains.isNotEmpty
        ? adminProvider.testDomains.first.id
        : null;
    final questionsJson = _questionsJsonController.text.trim();

    if (code.isEmpty ||
        name.isEmpty ||
        grade.isEmpty ||
        durationText.isEmpty ||
        questionsJson.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields including Questions JSON.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (domainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No domain available.'),
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

    // Parse JSON
    List<dynamic> questionsList;
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
            content: Text('Missing required fields in one of the questions.'),
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
            content: Text('Each question must have at least two options.'),
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

    // Create TestQuestions and TestQuestionOptions
    List<TestQuestion> testQuestions = [];
    int questionIdCounter = adminProvider.getNextQuestionId();
    int optionIdCounter = adminProvider.getNextOptionId();

    int order = 1;
    for (var q in validQuestions) {
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
          content: Text('Test and questions added successfully.'),
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
  // CONFIRM DELETION HELPER
  // ----------------------------------------------------------------------
  void _confirmDeletion({
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
                        label: 'Test Code', controller: _editCodeController,
                        hintText: 'Enter unique test code',
                        maxLines: 1),
                    const SizedBox(height: 12),
                    CustomTextField(
                        label: 'Test Name', controller: _editNameController,
                        hintText: 'Enter test name',
                        maxLines: 1),
                    const SizedBox(height: 12),
                    CustomTextField(
                        label: 'Grade', controller: _editGradeController,
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
                    DropdownButtonFormField<int>(
                      decoration:
                      const InputDecoration(labelText: 'Select Domain'),
                      value: selectedDomainId,
                      items: adminProvider.testDomains
                          .map(
                            (dom) => DropdownMenuItem<int>(
                          value: dom.id,
                          child: Text(dom.name),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedDomainId = val;
                          });
                        }
                      },
                      hint: const Text('Choose Domain'),
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
                  child: const Text('Save'),
                  onPressed: () {
                    if (_editCodeController.text.trim().isEmpty ||
                        _editNameController.text.trim().isEmpty ||
                        _editGradeController.text.trim().isEmpty ||
                        _editDurationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Fill all fields'),
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
