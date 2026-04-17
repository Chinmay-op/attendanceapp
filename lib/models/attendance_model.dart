import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 0)
class AttendanceRecord {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String classId;

  @HiveField(3)
  final String date; // yyyy-MM-dd

  @HiveField(4)
  final String timestamp;

  @HiveField(5)
  final String status; // 'present', 'absent'

  @HiveField(6)
  final String markedVia; // 'biometric', 'manual'

  @HiveField(7)
  bool isSynced;

  AttendanceRecord({
    required this.uid,
    required this.name,
    required this.classId,
    required this.date,
    required this.timestamp,
    required this.status,
    required this.markedVia,
    this.isSynced = false,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      classId: map['classId'] ?? '',
      date: map['date'] ?? '',
      timestamp: map['timestamp'] ?? '',
      status: map['status'] ?? 'present',
      markedVia: map['markedVia'] ?? 'biometric',
      isSynced: map['isSynced'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'classId': classId,
      'date': date,
      'timestamp': timestamp,
      'status': status,
      'markedVia': markedVia,
    };
  }

  String get key => '${classId}_${date}_$uid';
}
