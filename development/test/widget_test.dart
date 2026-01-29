import 'package:flutter_test/flutter_test.dart';

import 'package:holos/config/strings.dart';
import 'package:holos/main.dart';

void main() {
  testWidgets('Holos app boots into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const HolosApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.whatIsYourGoal), findsOneWidget);
  });
}
