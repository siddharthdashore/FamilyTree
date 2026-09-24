import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanshasetu/main.dart';

void main() {
  testWidgets('VanshaSetu App smoke test: Renders New Citizen Registration', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VanshaSetuApp()));
    await tester.pumpAndSettle();

    // Verify registration screen loads with title and VUID registration button
    expect(find.text('New Citizen Registration'), findsOneWidget);
    expect(find.text('Register & Allocate 12-Digit VUID'), findsOneWidget);
  });
}
