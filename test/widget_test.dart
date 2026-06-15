import 'package:flutter_test/flutter_test.dart';

import 'package:one_social_suite/app.dart';

void main() {
  testWidgets('App boots to the 5-tab shell', (WidgetTester tester) async {
    await tester.pumpWidget(const OneSocialSuiteApp());
    await tester.pumpAndSettle();

    // Each label appears at least once (tab bar; some also as screen titles).
    expect(find.text('Compose'), findsWidgets);
    expect(find.text('Connections'), findsWidgets);
    expect(find.text('Drafts'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Privacy'), findsWidgets);
  });
}
