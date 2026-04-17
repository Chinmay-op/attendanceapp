class SessionModel {
  final String sessionId;
  final String classId;
  final String teacherUid;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String date;

  SessionModel({
    required this.sessionId,
    required this.classId,
    required this.teacherUid,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.date,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      sessionId: id,
      classId: map['classId'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isActive: map['isActive'] ?? false,
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'teacherUid': teacherUid,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isActive': isActive,
      'date': date,
    };
  }

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  bool get isExpired => DateTime.now().isAfter(endTime);
}
