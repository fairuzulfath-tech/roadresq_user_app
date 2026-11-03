import 'package:flutter_test/flutter_test.dart';
import 'package:roadresq_user/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RoadResQApp());
    expect(find.byType(RoadResQApp), findsOneWidget);
    // Advance past splash 2.5s navigation timer and 500ms auth check
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
