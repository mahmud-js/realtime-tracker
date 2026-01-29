import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Tracker screen loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RealTimeTrackerApp());

    // Verify that the status text is present
    expect(find.textContaining('Status:'), findsOneWidget);
  });
}
