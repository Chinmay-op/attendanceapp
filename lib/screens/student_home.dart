import 'package:flutter/material.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/mark_attendance_screen.dart';
import '../screens/student/student_calendar_screen.dart';
import '../screens/student/student_query_screen.dart';
import '../screens/common/settings_screen.dart';
import '../widgets/bottom_nav.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudentDashboard(),
    MarkAttendanceScreen(),
    StudentCalendarScreen(),
    StudentQueryScreen(),
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
        isTeacher: false,
      ),
    );
  }
}
