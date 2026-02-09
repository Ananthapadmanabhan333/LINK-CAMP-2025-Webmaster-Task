import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/three_rings_widget.dart';
import '../../features/training/training_screen.dart';
import '../../features/nutrition/nutrition_screen.dart';
import '../../features/coach/coach_screen.dart';
import '../../features/recovery/recovery_screen.dart';
import '../../features/dashboard/profile_screen.dart';
import '../../services/ai_trainer_service.dart';
import '../../features/training/workout_execution_screen.dart';
import 'daily_tasks_widget.dart';
import 'morning_briefing_widget.dart';
import 'context_banner_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final AITrainerService _aiService = AITrainerService();
  Map<String, dynamic>? _dailyWorkout;
  bool _isLoadingWorkout = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyWorkout();
  }

  Future<void> _fetchDailyWorkout() async {
    // FORCE PROFESSIONAL PARAMS FOR DEMO
    // This ensures the user sees the new "Pro Split" logic immediately
    final workout = await _aiService.generateDailyWorkout(60, ["dumbbells", "barbell", "pullup_bar"], "Strength", "Advanced");
    if (mounted) {
      setState(() {
        _dailyWorkout = workout;
        _isLoadingWorkout = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeView(),
      const TrainingScreen(),
      const NutritionScreen(),
      const RecoveryScreen(),
      const CoachScreen(),
    ];

    return Scaffold(
      extendBody: true, // For transparency behind navbar
      backgroundColor: AppTheme.backgroundColor,
      appBar: _currentIndex == 0 ? AppBar(
        title: Text("HYBRID ATHLETE AI", style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Profile placeholder
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ).animate().scale(duration: 500.ms),
          const SizedBox(width: 8),
        ],
      ) : null,
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: _buildGlassNavBar(),
    );
  }

  Widget _buildGlassNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent, // Transparent to show container color
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 28).animate().scale(duration: 200.ms), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded, size: 28), label: 'Train'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded, size: 28), label: 'Eat'),
          BottomNavigationBarItem(icon: Icon(Icons.bed_rounded, size: 28), label: 'Recover'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded, size: 28), label: 'Coach'),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Context Aware Banner (Dynamic in real app)
          const ContextBannerWidget(
            message: "Recovery Priority: Training load reduced by 20% due to sleep.",
            type: ContextBannerType.warning,
            actionLabel: "Details",
          ),
          const SizedBox(height: 24),

          // Replaced static header with Smart Briefing
          const MorningBriefingWidget(
            userName: "Champion",
            sleepHours: 7, // In real app, fetch from DailyLog
            recoveryScore: 85, // In real app, fetch from AthleteState
            primaryGoal: "Hypertrophy",
          ),
          
          const SizedBox(height: 32),
          
          Center(
            child: const ThreeRingsWidget(
              workProgress: 0.7, 
              trainProgress: 0.4, 
              recoverProgress: 0.85, 
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          ),
          
          const SizedBox(height: 40),
          
          Text("WEEKLY PERFORMANCE", style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          
          // Strain Chart
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 5),
                      const FlSpot(2, 4),
                      const FlSpot(3, 7),
                      const FlSpot(4, 6),
                      const FlSpot(5, 8),
                      const FlSpot(6, 9),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

          const SizedBox(height: 32),
          
          const DailyTasksWidget(),

          const SizedBox(height: 32),
          
          _buildDailyWorkoutCard(),

          const SizedBox(height: 32),
          
          Text("TODAY'S METRICS", style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildStatCard("Workload", "1,240", "kcal", AppTheme.accentColor, 1)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Recovery", "85", "%", AppTheme.primaryColor, 2)),
            ],
          ),
          const SizedBox(height: 16),
           Row(
            children: [
              Expanded(child: _buildStatCard("Training", "45", "min", Colors.orangeAccent, 3)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Sleep", "7.5", "hrs", Colors.purpleAccent, 4)),
            ],
          ),
          
          const SizedBox(height: 100), // Bottom padding for navbar
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department, color: AppTheme.secondaryColor, size: 20),
          SizedBox(width: 4),
          Text("12 Day Streak", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, Color color, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: Theme.of(context).textTheme.displayMedium),
                TextSpan(text: " $unit", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (800 + (index * 100)).ms).slideX();
  }

  Widget _buildDailyWorkoutCard() {
    if (_dailyWorkout == null) {
      if (_isLoadingWorkout) return const Center(child: CircularProgressIndicator());
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "AI RECOMMENDED", 
                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)
                ),
              ),
              const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _dailyWorkout!['title'] ?? "Adaptive Session", 
            style: Theme.of(context).textTheme.displayMedium
          ),
          const SizedBox(height: 8),
          Text(
            _dailyWorkout!['reasoning'] ?? "Based on your recent activity.", 
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetricBadge(Icons.timer, "${_dailyWorkout!['duration']} min"),
              const SizedBox(width: 16),
              _buildMetricBadge(Icons.flash_on, _dailyWorkout!['intensity'] ?? "Moderate"),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutExecutionScreen(
                      workoutType: _dailyWorkout!['title'],
                      difficulty: "Intermediate",
                    ),
                  ),
                );
              },
              child: const Text("START ADAPTIVE SESSION"),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildMetricBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
