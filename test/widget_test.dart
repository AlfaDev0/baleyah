import 'package:baleyah/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Baleyah boots: splash then onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BaleyahApp());

    await tester.pump();
    expect(find.text('بلية'), findsOneWidget);
    expect(find.text('كشري على أصوله'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('أقوى كشري في مصر'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);
  });
}
