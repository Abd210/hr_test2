import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/test_model.dart';
import '../test_screen.dart';
import '../../widgets/background_animation.dart';
import '../../widgets/custom_button.dart';

class UserTestsScreen extends StatefulWidget {
  const UserTestsScreen({Key? key}) : super(key: key);

  @override
  State<UserTestsScreen> createState() => _UserTestsScreenState();
}

class _UserTestsScreenState extends State<UserTestsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    final assignedTests = adminProvider.getAssignedTestsForUser(user.id);

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundAnimation(),
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
                    children: [
                      Text(
                        '${user.username}\'s Assigned Tests',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (assignedTests.isEmpty)
                        const Text('No tests assigned.'),
                      if (assignedTests.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: assignedTests.length,
                            itemBuilder: (ctx, index) {
                              final test = assignedTests[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8),
                                child: ListTile(
                                  title: Text(test.name),
                                  subtitle: Text(
                                      'Duration: ${test.duration} mins\nGrade: ${test.grade}'),
                                  isThreeLine: true,
                                  trailing: CustomButton(
                                    text: 'Start',
                                    icon: Icons.play_arrow,
                                    onPressed: () {
                                      _startTest(context, test.id);
                                    },
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
            ),
          ),
        ],
      ),
    );
  }

  void _startTest(BuildContext context, int testId) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final questions = adminProvider.getQuestionsByTestId(testId);
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No questions found for this test.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TestScreen(questions: questions)),
    );
  }
}
