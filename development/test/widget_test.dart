import 'package:flutter_test/flutter_test.dart';

import 'package:holos/config/strings.dart';
import 'package:holos/main.dart';

void main() {
<<<<<<< HEAD
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HolosApp());
=======
  testWidgets('Holos app boots into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const HolosApp());
    await tester.pumpAndSettle();
>>>>>>> 98a8bb278a9e1a0ebde90c77b8804772a13d699f

    expect(find.text(AppStrings.whatIsYourGoal), findsOneWidget);
  });
}
