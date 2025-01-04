// lib/screens/test_screen.dart

import 'dart:async';
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

  // Current question index
  int _currentQuestionIndex = 0;

  // Timer related
  Timer? _timer;
  int _remainingTime = 0; // in seconds

  @override
  void initState() {
    super.initState();
    _startTimerForCurrentQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerForCurrentQuestion() {
    _timer?.cancel();
    final currentQuestion = widget.questions[_currentQuestionIndex];
    setState(() {
      _remainingTime = currentQuestion.answerTime;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime <= 1) {
        timer.cancel();
        _nextQuestion(auto: true);
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _nextQuestion({bool auto = false}) {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _startTimerForCurrentQuestion();
    } else {
      _submitTest();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _startTimerForCurrentQuestion();
    }
  }

  void _submitTest() {
    _timer?.cancel();
    int correct = 0;
    int total = widget.questions.length;

    for (var question in widget.questions) {
      final selectedOptionId = _answers[question.id];
      if (selectedOptionId != null) {
        final selectedOption = question.options
            .firstWhere((option) => option.id == selectedOptionId,
            orElse: () => TestQuestionOption(
              id: -1,
              questionId: question.id,
              content: '',
              order: 0,
              isCorrect: false,
            ));
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
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1} of ${widget.questions.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer and Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Remaining: $_remainingTime sec',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Progress: ${_currentQuestionIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.content,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (currentQuestion.picture != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Image.network(currentQuestion.picture!),
                      ),
                    const SizedBox(height: 10),
                    // Options
                    ...currentQuestion.options.map(
                          (option) => RadioListTile<int>(
                        title: Text(option.content),
                        value: option.id,
                        groupValue: _answers[currentQuestion.id],
                        onChanged: (val) {
                          setState(() {
                            _answers[currentQuestion.id] = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                ElevatedButton.icon(
                  onPressed:
                  _currentQuestionIndex > 0 ? _previousQuestion : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                // Next or Submit Button
                ElevatedButton.icon(
                  onPressed: () => _nextQuestion(),
                  icon: Icon(
                    _currentQuestionIndex < widget.questions.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    _currentQuestionIndex < widget.questions.length - 1
                        ? 'Next'
                        : 'Submit',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
