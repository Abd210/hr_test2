// lib/screens/test_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/test_question.dart';
import '../models/test_question_option.dart';
import '../widgets/custom_button.dart';
import '../widgets/background_animation.dart';

/// TestScreen presents the test to the user.
/// It displays one question at a time with animations and a timer based on difficulty.
class TestScreen extends StatefulWidget {
  /// List of questions to be presented in the test.
  final List<TestQuestion> questions;

  const TestScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen>
    with TickerProviderStateMixin {
  // ---------------------------
  // State Variables
  // ---------------------------

  /// Index of the current question being displayed.
  int _currentQuestionIndex = 0;

  /// Stores the user's selected options. Key: questionId, Value: optionId.
  Map<int, int> _userAnswers = {};

  /// Timer for the current question.
  Timer? _questionTimer;

  /// Remaining time in seconds for the current question.
  int _remainingTime = 0;

  /// Animation controller for question transitions.
  late AnimationController _transitionController;

  /// Animation for fading in/out questions.
  late Animation<double> _fadeAnimation;

  /// Animation for sliding questions.
  late Animation<Offset> _slideAnimation;

  /// Controller for the PageView to navigate between questions.
  final PageController _pageController = PageController();

  /// Flag indicating whether the test is completed.
  bool _isTestCompleted = false;

  // ---------------------------
  // Initialization
  // ---------------------------

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
  }

  /// Sets up the animation controllers and animations.
  void _setupAnimations() {
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _transitionController, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
  }

  // ---------------------------
  // Timer Management
  // ---------------------------

  /// Starts the timer based on the current question's answerTime.
  void _startTimer() {
    _cancelTimer(); // Ensure no existing timer is running.

    final currentQuestion = widget.questions[_currentQuestionIndex];
    setState(() {
      _remainingTime = currentQuestion.answerTime;
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime <= 1) {
        _cancelTimer();
        _nextQuestion(auto: true);
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  /// Cancels the current timer if active.
  void _cancelTimer() {
    if (_questionTimer != null && _questionTimer!.isActive) {
      _questionTimer!.cancel();
    }
  }

  // ---------------------------
  // Navigation Methods
  // ---------------------------

  /// Navigates to the next question or completes the test if on the last question.
  void _nextQuestion({bool auto = false}) {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      _transitionController.forward().then((_) {
        setState(() {
          _currentQuestionIndex++;
        });
        _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        _startTimer();
        _transitionController.reverse();
      });
    } else {
      _completeTest();
    }
  }

  /// Navigates to the previous question.
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _transitionController.forward().then((_) {
        setState(() {
          _currentQuestionIndex--;
        });
        _pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        _startTimer();
        _transitionController.reverse();
      });
    }
  }

  /// Completes the test, stops the timer, and shows the summary.
  void _completeTest() {
    _cancelTimer();
    setState(() {
      _isTestCompleted = true;
    });
    _showTestSummary();
  }

  // ---------------------------
  // User Interaction Methods
  // ---------------------------

  /// Handles the selection of an option by the user.
  void _selectOption(int optionId) {
    setState(() {
      _userAnswers[widget.questions[_currentQuestionIndex].id] = optionId;
    });
  }

  /// Submits the test and shows the summary dialog.
  void _submitTest() {
    _cancelTimer();

    int correctAnswers = 0;
    for (var question in widget.questions) {
      final selectedOptionId = _userAnswers[question.id];
      if (selectedOptionId != null) {
        final selectedOption = question.options.firstWhere(
                (option) => option.id == selectedOptionId,
            orElse: () => TestQuestionOption(
                id: -1,
                questionId: question.id,
                content: '',
                order: 0,
                isCorrect: false));
        if (selectedOption.isCorrect) {
          correctAnswers++;
        }
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Completed'),
        content:
        Text('You answered $correctAnswers out of ${widget.questions.length} correctly.'),
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

  /// Shows a summary dialog after test completion.
  void _showTestSummary() {
    int correctAnswers = 0;
    for (var question in widget.questions) {
      final selectedOptionId = _userAnswers[question.id];
      if (selectedOptionId != null) {
        final selectedOption = question.options.firstWhere(
                (option) => option.id == selectedOptionId,
            orElse: () => TestQuestionOption(
                id: -1,
                questionId: question.id,
                content: '',
                order: 0,
                isCorrect: false));
        if (selectedOption.isCorrect) {
          correctAnswers++;
        }
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Summary'),
        content: Text(
            'You answered $correctAnswers out of ${widget.questions.length} correctly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Navigate back
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Build Methods
  // ---------------------------

  /// Builds the entire test screen UI.
  @override
  Widget build(BuildContext context) {
    // Fetch theme colors or define your own
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundAnimation(), // Animated background
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildQuestionArea(),
                      const SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header containing the progress bar and timer.
  Widget _buildHeader() {
    double progress =
        (_currentQuestionIndex + 1) / widget.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 10),
        _buildTimer(),
      ],
    );
  }

  /// Builds the timer widget displaying remaining time.
  Widget _buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.timer, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          '$_remainingTime sec',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the main question area with animations.
  Widget _buildQuestionArea() {
    final currentQuestion = widget.questions[_currentQuestionIndex];

    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          return _buildAnimatedQuestion(question);
        },
      ),
    );
  }

  /// Builds an individual question card with slide and fade animations.
  Widget _buildAnimatedQuestion(TestQuestion question) {
    final selectedOptionId = _userAnswers[question.id];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: QuestionWidget(
        key: ValueKey<int>(question.id),
        question: question,
        selectedOptionId: selectedOptionId,
        onOptionSelected: _selectOption,
      ),
    );
  }

  /// Builds the footer containing navigation buttons.
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        CustomButton(
          text: 'Previous',
          icon: Icons.arrow_back,
          onPressed: _currentQuestionIndex > 0 ? _previousQuestion : () {},
          color: _currentQuestionIndex > 0 ? Colors.blueGrey : Colors.grey,
          width: MediaQuery.of(context).size.width * 0.1,
        ),
        // Next or Submit Button
        CustomButton(
          text: _currentQuestionIndex < widget.questions.length - 1
              ? 'Next'
              : 'Submit',
          icon: _currentQuestionIndex < widget.questions.length - 1
              ? Icons.arrow_forward
              : Icons.check,
          onPressed: () => _nextQuestion(),
          color: Colors.green,
          width: MediaQuery.of(context).size.width * 0.1,
        ),
      ],
    );
  }
}

// ---------------------------
// Modular and Reusable Widgets
// ---------------------------

/// A widget representing a single question with its options.
class QuestionWidget extends StatelessWidget {
  final TestQuestion question;
  final int? selectedOptionId;
  final Function(int) onOptionSelected;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQuestionContent(),
        const SizedBox(height: 10),
        _buildOptionsList(),
      ],
    );
  }

  /// Builds the question content, including text and optional image.
  Widget _buildQuestionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.content,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (question.picture != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(question.picture!),
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the list of options for the current question.
  Widget _buildOptionsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: question.options.length,
        itemBuilder: (context, index) {
          final option = question.options[index];
          return OptionTile(
            option: option,
            isSelected: selectedOptionId == option.id,
            onTap: () => onOptionSelected(option.id),
          );
        },
      ),
    );
  }
}

/// A widget representing a single option tile with selection capability.
class OptionTile extends StatelessWidget {
  final TestQuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTile({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color:
          isSelected ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade400,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Radio<int>(
              value: option.id,
              groupValue: isSelected ? option.id : null,
              onChanged: (val) => onTap(),
              activeColor: Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.content,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
