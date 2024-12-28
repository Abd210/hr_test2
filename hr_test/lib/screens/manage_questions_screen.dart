// lib/screens/manage_questions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/test_model.dart';
import '../models/test_question.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final TestModel test;

  const ManageQuestionsScreen({Key? key, required this.test}) : super(key: key);

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
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

  void _addQuestion(AdminProvider adminProvider) {
    if (_formKey.currentState!.validate()) {
      String questionContent = _questionController.text.trim();
      String option1 = _option1Controller.text.trim();
      String option2 = _option2Controller.text.trim();
      String option3 = _option3Controller.text.trim();
      String option4 = _option4Controller.text.trim();

      if (_correctOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one correct option.')),
        );
        return;
      }

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

      // Determine the new question's id
      int newQuestionId = adminProvider.testQuestions.isNotEmpty
          ? adminProvider.testQuestions.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1
          : 1;

      TestQuestion newQuestion = TestQuestion(
        id: newQuestionId,
        testId: widget.test.id,
        type: type,
        content: questionContent,
        picture: null,
        order: adminProvider.testQuestions.length + 1,
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
        SnackBar(content: Text('Question added successfully'), backgroundColor: Colors.green),
      );
    }
  }

  void _editQuestionDialog(TestQuestion question, AdminProvider adminProvider) {
    final TextEditingController _editQuestionController =
    TextEditingController(text: question.content);
    final TextEditingController _editOption1Controller =
    TextEditingController(text: question.options[0].content);
    final TextEditingController _editOption2Controller =
    TextEditingController(text: question.options[1].content);
    final TextEditingController _editOption3Controller =
    TextEditingController(text: question.options[2].content);
    final TextEditingController _editOption4Controller =
    TextEditingController(text: question.options[3].content);
    String _editSelectedDifficulty =
        question.type.toString().split('.').last;
    List<int> _editCorrectOptions = [];
    for (var option in question.options) {
      if (option.isCorrect) {
        _editCorrectOptions.add(option.order);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Edit Question",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Form(
                key: GlobalKey<FormState>(), // Added form key for validation
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Question Content',
                      controller: _editQuestionController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter question' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Difficulty',
                      ),
                      value: _editSelectedDifficulty,
                      items: ['Easy', 'Medium', 'Hard']
                          .map((level) => DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          _editSelectedDifficulty = value!;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select difficulty'
                          : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Option 1',
                      controller: _editOption1Controller,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter option 1' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Option 2',
                      controller: _editOption2Controller,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter option 2' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Option 3',
                      controller: _editOption3Controller,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter option 3' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Option 4',
                      controller: _editOption4Controller,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter option 4' : null,
                    ),
                    SizedBox(height: 16),
                    Text(
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
                child: Text("Cancel",
                    style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  // Validate the form inside the dialog
                  final formState = Form.of(context);
                  if (formState != null && !formState.validate()) {
                    return;
                  }

                  if (_editCorrectOptions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select at least one correct option.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  QuestionType type;
                  switch (_editSelectedDifficulty) {
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

                  TestQuestion updatedQuestion = TestQuestion(
                    id: question.id,
                    testId: question.testId,
                    type: type,
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Question updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _confirmDeletion(BuildContext context, String title, String content,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    List<TestQuestion> questions =
    adminProvider.getQuestionsByTestId(widget.test.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions for ${widget.test.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Question Form
            Card(
              elevation: 4,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add Question',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Question Content',
                        controller: _questionController,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter question' : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Difficulty',
                        ),
                        value: _selectedDifficulty,
                        items: ['Easy', 'Medium', 'Hard']
                            .map((level) => DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select difficulty'
                            : null,
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 1',
                        controller: _option1Controller,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter option 1' : null,
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 2',
                        controller: _option2Controller,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter option 2' : null,
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 3',
                        controller: _option3Controller,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter option 3' : null,
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Option 4',
                        controller: _option4Controller,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter option 4' : null,
                      ),
                      SizedBox(height: 16),
                      Text(
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
                      SizedBox(height: 16),
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
            SizedBox(height: 24),
            // List of Questions
            Expanded(
              child: questions.isEmpty
                  ? Center(child: Text('No questions found.'))
                  : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${question.order}: ${question.content}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: question.options.map((option) {
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
                                  SizedBox(width: 8),
                                  Text(option.content),
                                ],
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomButton(
                                text: 'Edit',
                                icon: Icons.edit,
                                color: Colors.orange,
                                onPressed: () {
                                  _editQuestionDialog(
                                      question, adminProvider);
                                },
                                width: 100,
                              ),
                              SizedBox(width: 8),
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
                                      Provider.of<AdminProvider>(context,
                                          listen: false)
                                          .deleteTestQuestion(question.id);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
