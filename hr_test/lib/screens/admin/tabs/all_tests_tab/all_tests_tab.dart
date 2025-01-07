import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../models/test_model.dart';
import '../../../../models/test_question.dart';
import '../../../../models/test_question_option.dart';
import '../../../../models/test_domain.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class AllTestsTab extends StatefulWidget {
  const AllTestsTab({Key? key}) : super(key: key);

  @override
  State<AllTestsTab> createState() => _AllTestsTabState();
}

class _AllTestsTabState extends State<AllTestsTab> {
  final TextEditingController _searchController = TextEditingController();

  // Manage Questions subview
  bool _managingQuestions = false;
  TestModel? _selectedTest;

  // Form for adding a test with optional JSON
  final TextEditingController _testCodeController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testGradeController = TextEditingController();
  final TextEditingController _testDurationController = TextEditingController();
  final TextEditingController _questionsJsonController = TextEditingController();
  bool _newTestIsActive = true;
  int? _selectedDomainId;

  @override
  void dispose() {
    _searchController.dispose();
    _testCodeController.dispose();
    _testNameController.dispose();
    _testGradeController.dispose();
    _testDurationController.dispose();
    _questionsJsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_managingQuestions && _selectedTest != null) {
      return _ManageQuestionsSub(
        test: _selectedTest!,
        onBack: () {
          setState(() {
            _managingQuestions = false;
            _selectedTest = null;
          });
        },
      );
    } else {
      return _buildAllTestsList(context);
    }
  }

  Widget _buildAllTestsList(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: true);
    final allTests = adminProvider.tests;
    final query = _searchController.text.trim().toLowerCase();

    final filtered = allTests.where((test) {
      final domain = adminProvider.testDomains.firstWhere(
            (d) => d.id == test.domainId,
        orElse: () => TestDomain(
          id: 0,
          name: '',
          description: '',
          createdAt: DateTime.now(),
        ),
      );
      return test.code.toLowerCase().contains(query) ||
          test.name.toLowerCase().contains(query) ||
          domain.name.toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        // Left: test list
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Search Tests...',
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        hintText: 'Search by code, name, or domain',
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // List
                filtered.isEmpty
                    ? const Expanded(
                  child: Center(child: Text('No tests found.')),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final test = filtered[i];
                      final domain = adminProvider.testDomains.firstWhere(
                            (d) => d.id == test.domainId,
                        orElse: () => TestDomain(
                          id: 0,
                          name: '',
                          description: '',
                          createdAt: DateTime.now(),
                        ),
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${test.name} (Code: ${test.code})'),
                          subtitle: Text(
                            'Domain: ${domain.name}\nDuration: ${test.duration} mins | Grade: ${test.grade}',
                          ),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.question_answer,
                                      color: Colors.blue),
                                  tooltip: 'Manage Questions',
                                  onPressed: () {
                                    setState(() {
                                      _managingQuestions = true;
                                      _selectedTest = test;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    _showEditTestDialog(
                                        context, adminProvider, test);
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon:
                                  const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      context: context,
                                      title: 'Delete Test',
                                      content: 'Delete "${test.name}"?',
                                      onConfirm: () {
                                        adminProvider.deleteTest(test.id);
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
                ),
              ],
            ),
          ),
        ),

        // Right: add test form with optional JSON
        Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Add Test with Optional Questions (JSON)',
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
                      hintText: 'Enter test code',
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
                      hintText: 'Enter grade (e.g. A, B, etc.)',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Duration (mins)',
                      controller: _testDurationController,
                      hintText: 'Enter duration in minutes',
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    // Domain
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Select Domain'),
                      value: _selectedDomainId,
                      items: adminProvider.testDomains.map((dom) {
                        return DropdownMenuItem<int>(
                          value: dom.id,
                          child: Text(dom.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDomainId = val;
                        });
                      },
                      hint: const Text('Choose Domain'),
                    ),
                    const SizedBox(height: 12),
                    // JSON field
                    CustomTextField(
                      label: 'Questions JSON (Optional)',
                      controller: _questionsJsonController,
                      maxLines: 4,
                      hintText: 'Enter questions in JSON format or leave empty.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Is Active?'),
                        const Spacer(),
                        Switch(
                          value: _newTestIsActive,
                          onChanged: (val) {
                            setState(() {
                              _newTestIsActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Add Test',
                      icon: Icons.add_task,
                      onPressed: () => _addTestWithOptionalQuestions(adminProvider),
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Add Test With Optional JSON
  // --------------------------------------------------------------------------
  Future<void> _addTestWithOptionalQuestions(AdminProvider adminProvider) async {
    final code = _testCodeController.text.trim();
    final name = _testNameController.text.trim();
    final grade = _testGradeController.text.trim();
    final durationText = _testDurationController.text.trim();
    final questionsJson = _questionsJsonController.text.trim();
    final domainId = _selectedDomainId;

    if (code.isEmpty || name.isEmpty || grade.isEmpty || durationText.isEmpty || domainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields including selecting a domain.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final duration = int.tryParse(durationText) ?? 0;
    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid duration.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // parse JSON if provided
    List<Map<String, dynamic>> parsedQuestions = [];
    if (questionsJson.isNotEmpty) {
      try {
        final raw = jsonDecode(questionsJson);
        if (raw is! List) {
          throw FormatException('JSON is not a top-level list.');
        }
        for (var item in raw) {
          if (item is Map<String, dynamic>) {
            parsedQuestions.add(item);
          } else {
            throw FormatException('Each question must be an object.');
          }
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
    }

    final newTest = TestModel(
      id: adminProvider.generateTestId(),
      code: code,
      name: name,
      grade: grade,
      date: DateTime.now(),
      duration: duration,
      isActive: _newTestIsActive,
      createdAt: DateTime.now(),
      domainId: domainId,
    );

    List<TestQuestion> newQuestions = [];
    if (parsedQuestions.isNotEmpty) {
      int questionIdCounter = adminProvider.getNextQuestionId();
      int optionIdCounter = adminProvider.getNextOptionId();
      int order = 1;
      for (var qData in parsedQuestions) {
        // required fields
        if (!qData.containsKey('content') ||
            !qData.containsKey('type') ||
            !qData.containsKey('answerTime') ||
            !qData.containsKey('isActive') ||
            !qData.containsKey('isMandatory') ||
            !qData.containsKey('options')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('One question is missing required fields.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final typeStr = qData['type'].toString().toLowerCase();
        QuestionType qType = QuestionType.easy;
        if (typeStr == 'medium') qType = QuestionType.medium;
        if (typeStr == 'hard') qType = QuestionType.hard;

        final List<dynamic> opts = qData['options'];
        if (opts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A question has no options.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        List<TestQuestionOption> questionOptions = [];
        for (var o in opts) {
          if (o is! Map<String, dynamic> ||
              !o.containsKey('content') ||
              !o.containsKey('isCorrect')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('One option is missing content/isCorrect.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          questionOptions.add(
            TestQuestionOption(
              id: optionIdCounter++,
              questionId: questionIdCounter,
              content: o['content'],
              order: questionOptions.length + 1,
              isCorrect: o['isCorrect'],
            ),
          );
        }

        newQuestions.add(
          TestQuestion(
            id: questionIdCounter++,
            testId: newTest.id,
            type: qType,
            content: qData['content'],
            picture: qData['picture'], // optional
            order: order++,
            answerTime: qData['answerTime'],
            isActive: qData['isActive'],
            isMandatory: qData['isMandatory'],
            options: questionOptions,
          ),
        );
      }
    }

    // Add test with optional questions
    await adminProvider.addTestWithQuestions(newTest, newQuestions);

    // Clear form
    _testCodeController.clear();
    _testNameController.clear();
    _testGradeController.clear();
    _testDurationController.clear();
    _questionsJsonController.clear();
    setState(() {
      _newTestIsActive = true;
      _selectedDomainId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test added successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

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
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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

  void _showEditTestDialog(BuildContext context, AdminProvider adminProvider, TestModel test) {
    final _editCodeController = TextEditingController(text: test.code);
    final _editNameController = TextEditingController(text: test.name);
    final _editGradeController = TextEditingController(text: test.grade);
    final _editDurationController = TextEditingController(text: '${test.duration}');
    bool isActive = test.isActive;
    int selectedDomainId = test.domainId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Test', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(label: 'Test Code', controller: _editCodeController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Test Name', controller: _editNameController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Grade', controller: _editGradeController),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Duration (mins)',
                  controller: _editDurationController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Domain'),
                  value: selectedDomainId,
                  items: adminProvider.testDomains.map((d) {
                    return DropdownMenuItem<int>(
                      value: d.id,
                      child: Text(d.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      selectedDomainId = val;
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Is Active'),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      onChanged: (sw) {
                        isActive = sw;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                final code = _editCodeController.text.trim();
                final name = _editNameController.text.trim();
                final grade = _editGradeController.text.trim();
                final durationText = _editDurationController.text.trim();
                final duration = int.tryParse(durationText) ?? 0;

                if (code.isEmpty || name.isEmpty || grade.isEmpty || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields properly.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                test.code = code;
                test.name = name;
                test.grade = grade;
                test.duration = duration;
                test.domainId = selectedDomainId;
                test.isActive = isActive;

                adminProvider.updateTest(test);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test updated'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// --------------------------------------------------------------------------
// SUBVIEW: Manage Questions (like old code)
// --------------------------------------------------------------------------
class _ManageQuestionsSub extends StatefulWidget {
  final TestModel test;
  final VoidCallback onBack;

  const _ManageQuestionsSub({
    Key? key,
    required this.test,
    required this.onBack,
  }) : super(key: key);

  @override
  State<_ManageQuestionsSub> createState() => _ManageQuestionsSubState();
}

class _ManageQuestionsSubState extends State<_ManageQuestionsSub> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();

  String _selectedDifficulty = 'Easy';
  List<int> _correctOptions = [];

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final questions = adminProvider.getQuestionsByTestId(widget.test.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // top row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Manage Questions for ${widget.test.name}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            CustomButton(
              text: 'Back to Tests',
              icon: Icons.arrow_back,
              isOutlined: true,
              color: Theme.of(context).primaryColor,
              onPressed: widget.onBack,
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Row(
            children: [
              // Left: questions list
              Expanded(
                flex: 2,
                child: questions.isEmpty
                    ? const Center(child: Text('No questions found.'))
                    : SingleChildScrollView(
                  child: Column(
                    children: questions.map((question) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${question.order}: ${question.content}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children:
                                question.options.map((option) {
                                  return Row(
                                    children: [
                                      Icon(
                                        option.isCorrect
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: option.isCorrect
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(option.content),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    text: 'Edit',
                                    icon: Icons.edit,
                                    color: Colors.orange,
                                    onPressed: () {
                                      _editQuestionDialog(
                                          context,
                                          question,
                                          adminProvider);
                                    },
                                    width: 100,
                                  ),
                                  const SizedBox(width: 8),
                                  CustomButton(
                                    text: 'Delete',
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    onPressed: () {
                                      _confirmDeletion(
                                        context,
                                        'Delete Question',
                                        'Are you sure you want to delete this question?',
                                            () {
                                          adminProvider.deleteTestQuestion(
                                              question.id);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                              Text('Question deleted'),
                                              backgroundColor:
                                              Colors.green,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    width: 100,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right: add question
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Add Question',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Question Content',
                            controller: _questionController,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Please enter question'
                                : null,
                            hintText: 'Enter question content',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration:
                            const InputDecoration(labelText: 'Difficulty'),
                            value: _selectedDifficulty,
                            items: const ['Easy', 'Medium', 'Hard']
                                .map((level) => DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value ?? 'Easy';
                              });
                            },
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Please select difficulty'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Option 1',
                            controller: _option1Controller,
                            validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter option 1'
                                : null,
                            hintText: 'Enter option 1',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Option 2',
                            controller: _option2Controller,
                            validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter option 2'
                                : null,
                            hintText: 'Enter option 2',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Option 3',
                            controller: _option3Controller,
                            validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter option 3'
                                : null,
                            hintText: 'Enter option 3',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Option 4',
                            controller: _option4Controller,
                            validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter option 4'
                                : null,
                            hintText: 'Enter option 4',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Select Correct Option(s)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 10.0,
                            children: List<Widget>.generate(4, (index) {
                              return FilterChip(
                                label: Text('Option ${index + 1}'),
                                selected: _correctOptions.contains(index + 1),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _correctOptions.add(index + 1);
                                    } else {
                                      _correctOptions.remove(index + 1);
                                    }
                                  });
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Add Question',
                            icon: Icons.add_task,
                            onPressed: () => _addQuestion(adminProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addQuestion(AdminProvider adminProvider) {
    if (_formKey.currentState!.validate()) {
      if (_correctOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one correct option.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final questionContent = _questionController.text.trim();
      final option1 = _option1Controller.text.trim();
      final option2 = _option2Controller.text.trim();
      final option3 = _option3Controller.text.trim();
      final option4 = _option4Controller.text.trim();

      QuestionType qType = QuestionType.easy;
      if (_selectedDifficulty == 'Medium') qType = QuestionType.medium;
      if (_selectedDifficulty == 'Hard') qType = QuestionType.hard;

      final newQId = adminProvider.getNextQuestionId();
      final existingCount = adminProvider.getQuestionsByTestId(widget.test.id).length;

      final newQuestion = TestQuestion(
        id: newQId,
        testId: widget.test.id,
        type: qType,
        content: questionContent,
        picture: null,
        order: existingCount + 1,
        answerTime: 30,
        isActive: true,
        isMandatory: true,
        options: [
          TestQuestionOption(
            id: adminProvider.getNextOptionId(),
            questionId: newQId,
            content: option1,
            order: 1,
            isCorrect: _correctOptions.contains(1),
          ),
          TestQuestionOption(
            id: adminProvider.getNextOptionId(),
            questionId: newQId,
            content: option2,
            order: 2,
            isCorrect: _correctOptions.contains(2),
          ),
          TestQuestionOption(
            id: adminProvider.getNextOptionId(),
            questionId: newQId,
            content: option3,
            order: 3,
            isCorrect: _correctOptions.contains(3),
          ),
          TestQuestionOption(
            id: adminProvider.getNextOptionId(),
            questionId: newQId,
            content: option4,
            order: 4,
            isCorrect: _correctOptions.contains(4),
          ),
        ],
      );

      adminProvider.addTestQuestion(newQuestion);

      _questionController.clear();
      _option1Controller.clear();
      _option2Controller.clear();
      _option3Controller.clear();
      _option4Controller.clear();
      setState(() {
        _selectedDifficulty = 'Easy';
        _correctOptions = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editQuestionDialog(
      BuildContext context, TestQuestion question, AdminProvider adminProvider) {
    final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
    final _editQuestionController = TextEditingController(text: question.content);
    final _editOption1Controller = TextEditingController(text: question.options[0].content);
    final _editOption2Controller = TextEditingController(text: question.options[1].content);
    final _editOption3Controller = TextEditingController(text: question.options[2].content);
    final _editOption4Controller = TextEditingController(text: question.options[3].content);

    String difficultyStr = 'Easy';
    if (question.type == QuestionType.medium) difficultyStr = 'Medium';
    if (question.type == QuestionType.hard) difficultyStr = 'Hard';

    List<int> _editCorrectOptions = [];
    for (var opt in question.options) {
      if (opt.isCorrect) {
        _editCorrectOptions.add(opt.order);
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Edit Question',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _editFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Question Content',
                        controller: _editQuestionController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please enter a question'
                            : null,
                        hintText: 'Enter question content',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Difficulty'),
                        value: difficultyStr,
                        items: const ['Easy', 'Medium', 'Hard']
                            .map((level) => DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            difficultyStr = value ?? 'Easy';
                          });
                        },
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please select difficulty'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 1',
                        controller: _editOption1Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter option 1'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'Option 2',
                        controller: _editOption2Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter option 2'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'Option 3',
                        controller: _editOption3Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter option 3'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'Option 4',
                        controller: _editOption4Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter option 4'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select Correct Option(s)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 10.0,
                        children: List<Widget>.generate(4, (index) {
                          return FilterChip(
                            label: Text('Option ${index + 1}'),
                            selected: _editCorrectOptions.contains(index + 1),
                            onSelected: (bool selected) {
                              setStateDialog(() {
                                if (selected) {
                                  _editCorrectOptions.add(index + 1);
                                } else {
                                  _editCorrectOptions.remove(index + 1);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    final formState = _editFormKey.currentState;
                    if (formState == null || !formState.validate()) {
                      return;
                    }
                    if (_editCorrectOptions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one correct option.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    QuestionType updatedType = QuestionType.easy;
                    if (difficultyStr == 'Medium') updatedType = QuestionType.medium;
                    if (difficultyStr == 'Hard') updatedType = QuestionType.hard;

                    final updatedQ = TestQuestion(
                      id: question.id,
                      testId: question.testId,
                      type: updatedType,
                      content: _editQuestionController.text.trim(),
                      picture: question.picture,
                      order: question.order,
                      answerTime: question.answerTime,
                      isActive: question.isActive,
                      isMandatory: question.isMandatory,
                      options: [
                        TestQuestionOption(
                          id: question.options[0].id,
                          questionId: question.id,
                          content: _editOption1Controller.text.trim(),
                          order: 1,
                          isCorrect: _editCorrectOptions.contains(1),
                        ),
                        TestQuestionOption(
                          id: question.options[1].id,
                          questionId: question.id,
                          content: _editOption2Controller.text.trim(),
                          order: 2,
                          isCorrect: _editCorrectOptions.contains(2),
                        ),
                        TestQuestionOption(
                          id: question.options[2].id,
                          questionId: question.id,
                          content: _editOption3Controller.text.trim(),
                          order: 3,
                          isCorrect: _editCorrectOptions.contains(3),
                        ),
                        TestQuestionOption(
                          id: question.options[3].id,
                          questionId: question.id,
                          content: _editOption4Controller.text.trim(),
                          order: 4,
                          isCorrect: _editCorrectOptions.contains(4),
                        ),
                      ],
                    );

                    adminProvider.updateTestQuestion(updatedQ);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Question updated successfully'),
                        backgroundColor: Colors.green,
                      ),
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

  void _confirmDeletion(
      BuildContext context,
      String title,
      String content,
      VoidCallback onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }
}
