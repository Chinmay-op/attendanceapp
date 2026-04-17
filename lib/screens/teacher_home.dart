import 'package:flutter/material.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/teacher/start_session_screen.dart';
import '../screens/teacher/attendance_history_screen.dart';
import '../screens/common/settings_screen.dart';
import '../widgets/bottom_nav.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TeacherDashboard(),
    StartSessionScreen(),
    AttendanceHistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        isTeacher: true,
      ),
    );
  }
}
