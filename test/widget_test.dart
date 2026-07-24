// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_system/main.dart';
import 'package:attendance_system/services/local_storage_service.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Initialize local storage for test
    final localStorageService = LocalStorageService();
    await localStorageService.init();

    // Build our app and trigger a frame.
    await tester
        .pumpWidget(AttendanceApp(localStorageService: localStorageService));

    // Verify that the app builds without error
    expect(find.byType(AttendanceApp), findsOneWidget);
  });
}
