// lib/screens/test_screen.dart

import 'package:flutter/material.dart';
import '../models/test_question.dart';
import '../models/test_question_option.dart';
import '../widgets/custom_button.dart';

class TestScreen extends StatefulWidget {
  final List<TestQuestion> questions;

  const TestScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // To store user's answers
  Map<int, int> _answers = {}; // questionId -> optionId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildQuestionsList()),
            CustomButton(
              text: 'Submit Test',
              icon: Icons.check,
              onPressed: _submitTest,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return ListView.builder(
      itemCount: widget.questions.length,
      itemBuilder: (ctx, index) {
        final question = widget.questions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${question.content}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...question.options.map(
                      (option) => RadioListTile<int>(
                    title: Text(option.content),
                    value: option.id,
                    groupValue: _answers[question.id],
                    onChanged: (val) {
                      setState(() {
                        _answers[question.id] = val!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitTest() {
    // You can process the answers here.
    // For demonstration, we'll just show a summary.

    int correct = 0;
    int total = widget.questions.length;

    for (var question in widget.questions) {
      final selectedOptionId = _answers[question.id];
      if (selectedOptionId != null) {
        final selectedOption = question.options
            .firstWhere((option) => option.id == selectedOptionId, orElse: () => TestQuestionOption(id: -1, questionId: question.id, content: '', order: 0, isCorrect: false));
        if (selectedOption.isCorrect) {
          correct++;
        }
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Result'),
        content: Text('You answered $correct out of $total correctly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to login screen or home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
