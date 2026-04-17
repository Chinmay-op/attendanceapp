import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CalendarWidget extends StatefulWidget {
  final Map<String, String> attendanceData; // date -> status
  final Function(DateTime)? onDayTap;

  const CalendarWidget({
    super.key,
    required this.attendanceData,
    this.onDayTap,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late int _currentYear;
  late int _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now().year;
    _currentMonth = DateTime.now().month;
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  Color _getDayColor(DateTime date) {
    final dateStr = Helpers.formatDate(date);

    if (AppConstants.isHoliday(dateStr)) {
      return AppConstants.holidayColor;
    }
    if (AppConstants.isWeekend(date)) {
      return AppTheme.textSecondary.withOpacity(0.3);
    }

    final status = widget.attendanceData[dateStr];
    if (status == 'present') return AppConstants.presentColor;
    if (status == 'absent') return AppConstants.absentColor;

    // Future date or no data
    if (date.isAfter(DateTime.now())) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = Helpers.daysInMonth(_currentYear, _currentMonth);
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final startWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

    final monthName = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_currentMonth];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: _prevMonth,
                color: AppTheme.textPrimary,
              ),
              Text(
                '$monthName $_currentYear',
                style: AppTheme.headingSmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: _nextMonth,
                color: AppTheme.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: AppTheme.labelStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }

              final day = index - startWeekday + 1;
              final date = DateTime(_currentYear, _currentMonth, day);
              final color = _getDayColor(date);
              final isToday = Helpers.formatDate(date) == Helpers.todayDate();

              return GestureDetector(
                onTap: () => widget.onDayTap?.call(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color.withOpacity(color == Colors.transparent ? 0 : 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: AppTheme.accentPurple, width: 2)
                        : color != Colors.transparent
                            ? Border.all(color: color.withOpacity(0.5))
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: color != Colors.transparent
                            ? color
                            : AppTheme.textPrimary.withOpacity(0.7),
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('Present', AppConstants.presentColor),
              const SizedBox(width: 16),
              _legendItem('Absent', AppConstants.absentColor),
              const SizedBox(width: 16),
              _legendItem('Holiday', AppConstants.holidayColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.labelStyle),
      ],
    );
  }
}
