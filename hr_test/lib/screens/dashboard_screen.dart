//dashboard_Screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_button.dart';
// Removed import of persistent_navbar.dart because we no longer use it here
import '../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  final int currentIndex;
  const DashboardScreen({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// Use TickerProviderStateMixin because we have multiple AnimationControllers
class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // ------------------------------------------------------------
  // 1) Animation Controllers & States
  // ------------------------------------------------------------
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _chartExpandController;
  late Animation<double> _chartExpandAnimation;

  // For advanced radial progress
  double _radialValue = 0.7; // example 70%

  // Toggles
  bool _showExtraStats = false;
  bool _showTasks = false; // toggles "My Tasks" panel

  // Tasks list example
  final List<String> _tasks = [
    'Redesign login form UI',
    'Implement new survey feature',
    'Fix null safety warnings',
    'Test new HR flow',
    'Review code PR #234',
    'Analyze monthly usage data',
  ];

  // Example line chart data
  final List<FlSpot> _lineSpots = const [
    FlSpot(0, 2),
    FlSpot(1, 3),
    FlSpot(2, 3.5),
    FlSpot(3, 4.2),
    FlSpot(4, 5),
    FlSpot(5, 4.5),
    FlSpot(6, 6),
  ];

  // Example bar chart data
  final List<BarChartGroupData> _barGroups = [
    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: secondaryGreen)]),
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: accentColor)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6, color: Colors.orange)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 11, color: primaryDarkGreen)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.blueGrey)]),
  ];

  // Example pie chart data
  final List<PieChartSectionData> _pieSections = [
    PieChartSectionData(
      color: secondaryGreen,
      value: 35,
      title: '35%',
      radius: 32,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      color: accentColor,
      value: 30,
      title: '30%',
      radius: 32,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      color: Colors.orange,
      value: 20,
      title: '20%',
      radius: 32,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      color: Colors.blueGrey,
      value: 15,
      title: '15%',
      radius: 32,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ];

  // Example recent activities
  final List<String> _recentActivities = [
    'New user: JohnDoe joined Org A.',
    'Survey #56 completed by 45 users.',
    'Feedback: "Loving the new dashboard!"',
    'Revenue: \$1,234 from signups this week.',
    'Test #99 concluded with 88% pass rate.',
  ];

  // Additional stats (shown if _showExtraStats == true)
  final List<_ExtraStat> _extraStats = [
    _ExtraStat(title: 'Active Admins', value: 15),
    _ExtraStat(title: 'Pending Surveys', value: 8),
    _ExtraStat(title: 'Open Tickets', value: 23),
    _ExtraStat(title: 'Employee Retention', value: 96),
  ];

  // For bounce-like animation in charts
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // For wave-like background painter
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Basic fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Expand animation for charts
    _chartExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartExpandAnimation = CurvedAnimation(
      parent: _chartExpandController,
      curve: Curves.elasticOut,
    );
    _chartExpandController.forward();

    // Bounce animation for radial progress
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Wave background
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _chartExpandController.dispose();
    _bounceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Painted wave background
      body: AnimatedBuilder(
        animation: _waveController,
        builder: (ctx, child) {
          return CustomPaint(
            painter: _WavePainter(_waveAnimation.value),
            // We remove any top or left nav here — just the core content
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildMainContent(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Removed the header row, so no top bar here
        _buildStatsAndRadial(context),
        const SizedBox(height: 16),
        // Animated expand for bar+pie
        SizeTransition(
          sizeFactor: _chartExpandAnimation,
          axisAlignment: 0.0,
          child: _buildChartsRow(context),
        ),
        const SizedBox(height: 16),
        _buildRecentActivitiesAndTasks(context),
        const SizedBox(height: 16),
        if (_showExtraStats) _buildExtraStatsSection(context),
        const SizedBox(height: 16),
        // Button to toggle extra stats
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: _showExtraStats ? 'Hide Extra Stats' : 'Show Extra Stats',
              icon: Icons.analytics,
              onPressed: () {
                setState(() {
                  _showExtraStats = !_showExtraStats;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Stats row + radial progress
  // --------------------------------------------------------------------------
  Widget _buildStatsAndRadial(BuildContext context) {
    final stats = [
      _MiniStatData('Users', '1,232', Icons.people, Colors.green),
      _MiniStatData('Active Tests', '27', Icons.assessment, Colors.blue),
      _MiniStatData('Feedback', '99+', Icons.feedback, Colors.orange),
      _MiniStatData('Revenue', '\$12,345', Icons.attach_money, Colors.red),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        Expanded(
          flex: 3,
          child: GridView.builder(
            itemCount: stats.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (ctx, i) {
              final e = stats[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECD7),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(e.icon, color: e.color, size: 26),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                        Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: e.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Radial progress
        Expanded(
          flex: 2,
          child: _buildRadialProgressSection(context),
        ),
      ],
    );
  }

  Widget _buildRadialProgressSection(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECD7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (ctx, child) {
          final bounceVal = 1.0 + _bounceAnimation.value * 0.05;
          return Transform.scale(
            scale: bounceVal,
            child: CustomPaint(
              painter: _RadialPainter(_radialValue),
              child: Center(
                child: Text(
                  '${(_radialValue * 100).toInt()}%',
                  style: TextStyle(
                    color: primaryDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Bar + Pie row
  // --------------------------------------------------------------------------
  Widget _buildChartsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildBarChartCard(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildPieChartCard2(context),
        ),
      ],
    );
  }

  Widget _buildBarChartCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Stats', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                          if (val >= 0 && val < names.length) {
                            return Text(names[val.toInt()]);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard2(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _pieSections,
                  centerSpaceRadius: 28,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Recent Activities + My Tasks side by side
  // --------------------------------------------------------------------------
  Widget _buildRecentActivitiesAndTasks(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildRecentActivitiesCard(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildTasksCard(context),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _recentActivities.length,
                itemBuilder: (ctx, i) {
                  final activity = _recentActivities[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications, color: Colors.blueGrey),
                    title: Text(activity),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        height: _showTasks ? 200 : 60,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _showTasks = !_showTasks;
                });
              },
              child: Row(
                children: [
                  const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(
                    _showTasks ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_showTasks)
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (ctx, i) {
                    final task = _tasks[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_box_outline_blank),
                      title: Text(task),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Extra Stats Section (only shows if _showExtraStats == true)
  // --------------------------------------------------------------------------
  Widget _buildExtraStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECD7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Extra Stats',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _extraStats.map((e) {
              return Container(
                width: 130,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.title, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '${e.value}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Radial painter for the radial progress
// --------------------------------------------------------------------------
class _RadialPainter extends CustomPainter {
  final double progress;
  _RadialPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;

    // background circle
    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // progress circle
    final progressPaint = Paint()
      ..color = primaryDarkGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --------------------------------------------------------------------------
// Wave painter for background
// --------------------------------------------------------------------------
class _WavePainter extends CustomPainter {
  final double animationValue;
  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);

    const waveHeight = 40.0;
    final waveLength = size.width / 1.5;
    final offset = animationValue * waveLength;
    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double x = -waveLength + offset; x <= size.width + waveLength; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength / 4, size.height / 2 - waveHeight,
        x + waveLength / 2, size.height / 2,
      );
      path.quadraticBezierTo(
        x + 3 * waveLength / 4, size.height / 2 + waveHeight,
        x + waveLength, size.height / 2,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}

// --------------------------------------------------------------------------
// Extra data classes
// --------------------------------------------------------------------------
class _ExtraStat {
  final String title;
  final int value;
  _ExtraStat({required this.title, required this.value});
}

class _MiniStatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _MiniStatData(this.title, this.value, this.icon, this.color);
}
