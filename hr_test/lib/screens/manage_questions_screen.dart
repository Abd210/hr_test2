// lib/screens/manage_questions_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/test_model.dart';
import '../models/test_question.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ManageQuestionsWidget extends StatefulWidget {
  final TestModel test;
  final VoidCallback onBack;

  const ManageQuestionsWidget({
    Key? key,
    required this.test,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ManageQuestionsWidget> createState() => _ManageQuestionsWidgetState();
}

class _ManageQuestionsWidgetState extends State<ManageQuestionsWidget> {
  final _formKey = GlobalKey<FormState>();

  // Add Question form controllers
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

  // --------------------------------------------------------------------------
  // ADD QUESTION LOGIC
  // --------------------------------------------------------------------------
  void _addQuestion(AdminProvider adminProvider) {
    if (_formKey.currentState!.validate()) {
      final questionContent = _questionController.text.trim();
      final option1 = _option1Controller.text.trim();
      final option2 = _option2Controller.text.trim();
      final option3 = _option3Controller.text.trim();
      final option4 = _option4Controller.text.trim();

      if (_correctOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one correct option.'),
          ),
        );
        return;
      }

      // Convert difficulty string to enum
      QuestionType type;
      switch (_selectedDifficulty) {
        case 'Easy':
          type = QuestionType.easy;
          break;
        case 'Medium':
          type = QuestionType.medium;
          break;
        case 'Hard':
          type = QuestionType.hard;
          break;
        default:
          type = QuestionType.easy;
      }

      final existingQuestions = adminProvider.testQuestions;
      final newQuestionId = existingQuestions.isNotEmpty
          ? existingQuestions.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1
          : 1;

      final newQuestion = TestQuestion(
        id: newQuestionId,
        testId: widget.test.id,
        type: type,
        content: questionContent,
        picture: null,
        order: existingQuestions.length + 1,
        answerTime: 30,
        isActive: true,
        isMandatory: true,
        options: [
          TestQuestionOption(
            id: 1,
            questionId: newQuestionId,
            content: option1,
            order: 1,
            isCorrect: _correctOptions.contains(1),
          ),
          TestQuestionOption(
            id: 2,
            questionId: newQuestionId,
            content: option2,
            order: 2,
            isCorrect: _correctOptions.contains(2),
          ),
          TestQuestionOption(
            id: 3,
            questionId: newQuestionId,
            content: option3,
            order: 3,
            isCorrect: _correctOptions.contains(3),
          ),
          TestQuestionOption(
            id: 4,
            questionId: newQuestionId,
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

  // --------------------------------------------------------------------------
  // EDIT QUESTION LOGIC
  // --------------------------------------------------------------------------
  void _editQuestionDialog(TestQuestion question, AdminProvider adminProvider) {
    // We’ll use a separate form key for the dialog
    final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

    final _editQuestionController = TextEditingController(text: question.content);
    final _editOption1Controller = TextEditingController(text: question.options[0].content);
    final _editOption2Controller = TextEditingController(text: question.options[1].content);
    final _editOption3Controller = TextEditingController(text: question.options[2].content);
    final _editOption4Controller = TextEditingController(text: question.options[3].content);

    // Convert the question’s existing difficulty to a string:
    String _editSelectedDifficulty = question.type.toString().split('.').last;
    // e.g. 'easy' -> 'Easy', etc. We can just set to 'Easy'/'Medium'/'Hard' below

    // Mark correct options
    final List<int> _editCorrectOptions = [];
    for (var opt in question.options) {
      if (opt.isCorrect) {
        _editCorrectOptions.add(opt.order);
      }
    }

    // Convert enum name to a capitalized label if needed
    if (_editSelectedDifficulty.toLowerCase() == 'easy') {
      _editSelectedDifficulty = 'Easy';
    } else if (_editSelectedDifficulty.toLowerCase() == 'medium') {
      _editSelectedDifficulty = 'Medium';
    } else if (_editSelectedDifficulty.toLowerCase() == 'hard') {
      _editSelectedDifficulty = 'Hard';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, setStateDialog) {
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
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter a question' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Difficulty'),
                        value: _editSelectedDifficulty,
                        items: ['Easy', 'Medium', 'Hard']
                            .map(
                              (level) => DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            _editSelectedDifficulty = value ?? 'Easy';
                          });
                        },
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select difficulty' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 1',
                        controller: _editOption1Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter option 1' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 2',
                        controller: _editOption2Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter option 2' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 3',
                        controller: _editOption3Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter option 3' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 4',
                        controller: _editOption4Controller,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter option 4' : null,
                      ),
                      const SizedBox(height: 16),
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

                    // Convert updated difficulty to enum
                    QuestionType updatedType = QuestionType.easy;
                    if (_editSelectedDifficulty == 'Medium') {
                      updatedType = QuestionType.medium;
                    } else if (_editSelectedDifficulty == 'Hard') {
                      updatedType = QuestionType.hard;
                    }

                    final updatedQuestion = TestQuestion(
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
                          id: 1,
                          questionId: question.id,
                          content: _editOption1Controller.text.trim(),
                          order: 1,
                          isCorrect: _editCorrectOptions.contains(1),
                        ),
                        TestQuestionOption(
                          id: 2,
                          questionId: question.id,
                          content: _editOption2Controller.text.trim(),
                          order: 2,
                          isCorrect: _editCorrectOptions.contains(2),
                        ),
                        TestQuestionOption(
                          id: 3,
                          questionId: question.id,
                          content: _editOption3Controller.text.trim(),
                          order: 3,
                          isCorrect: _editCorrectOptions.contains(3),
                        ),
                        TestQuestionOption(
                          id: 4,
                          questionId: question.id,
                          content: _editOption4Controller.text.trim(),
                          order: 4,
                          isCorrect: _editCorrectOptions.contains(4),
                        ),
                      ],
                    );

                    adminProvider.updateTestQuestion(updatedQuestion);
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

  // --------------------------------------------------------------------------
  // CONFIRM DELETION HELPER
  // --------------------------------------------------------------------------
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
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: true);
    final questions = adminProvider.getQuestionsByTestId(widget.test.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top row with "Back to Tests"
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

        // Main layout: Left side = list of questions, Right side = add question
        Expanded(
          child: Row(
            children: [
              // List of questions
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: question.options.map((option) {
                                  return Row(
                                    children: [
                                      Icon(
                                        option.isCorrect
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color:
                                        option.isCorrect ? Colors.green : Colors.grey,
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
                                      _editQuestionDialog(question, adminProvider);
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
                                          adminProvider.deleteTestQuestion(question.id);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Question deleted'),
                                              backgroundColor: Colors.green,
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

              // Add Question form (with smaller spacing)
              Container(
                width: 330,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add Question',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Question Content',
                          controller: _questionController,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Please enter question' : null,
                          verticalPadding: 10,
                          horizontalPadding: 12,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Difficulty'),
                          value: _selectedDifficulty,
                          items: ['Easy', 'Medium', 'Hard'].map((level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value ?? 'Easy';
                            });
                          },
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Please select difficulty' : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Option 1',
                          controller: _option1Controller,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Enter option 1' : null,
                          verticalPadding: 10,
                          horizontalPadding: 12,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Option 2',
                          controller: _option2Controller,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Enter option 2' : null,
                          verticalPadding: 10,
                          horizontalPadding: 12,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Option 3',
                          controller: _option3Controller,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Enter option 3' : null,
                          verticalPadding: 10,
                          horizontalPadding: 12,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Option 4',
                          controller: _option4Controller,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Enter option 4' : null,
                          verticalPadding: 10,
                          horizontalPadding: 12,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Select Correct Option(s)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
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
            ],
          ),
        ),
      ],
    );
  }
}
