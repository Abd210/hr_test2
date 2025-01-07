import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test_question.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Tests'),
        ),
        body: const Center(
          child: Text('User not recognized. Please login again.'),
        ),
      );
    }

    final assignedTests = adminProvider.getAssignedTestsForUser(user.id);

    return Scaffold(
      // We'll use an AppBar with the user name
      appBar: AppBar(
        title: Text('${user.username}\'s Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.94),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user.username}!',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Below are the tests assigned to you. Tap "Start" to begin any test.',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (assignedTests.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              'No tests assigned.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      if (assignedTests.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: assignedTests.length,
                            itemBuilder: (ctx, index) {
                              final test = assignedTests[index];
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
                                child: ListTile(
                                  title: Text(
                                    test.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Duration: ${test.duration} mins | Grade: ${test.grade}\n'
                                        'Status: ${test.isActive ? "Active" : "Inactive"}',
                                  ),
                                  isThreeLine: true,
                                  trailing: CustomButton(
                                    text: 'Start',
                                    icon: Icons.play_arrow,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: test.isActive
                                        ? () => _startTest(context, test.id)
                                        : null,
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
