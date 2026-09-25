import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanshasetu/main.dart';

void main() {
  testWidgets('VanshaSetu App smoke test: Default launch renders Lineage Canvas', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: VanshaSetuApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Lineage Canvas loads by default on launch
    expect(find.text('VanshaSetu Lineage Canvas'), findsOneWidget);
    expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
  });
}

