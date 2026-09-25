import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanshasetu/core/localization/locale_provider.dart';
import 'package:vanshasetu/features/auth/screens/registration_screen.dart';

void main() {
  group('RegistrationScreen Widget Tests', () {
    testWidgets('Renders all personal and residential address input fields in single language (no Hindi in brackets)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal Details'), findsOneWidget);
      expect(find.text('First Name *'), findsOneWidget);
      expect(find.text('Last Name *'), findsOneWidget);
      expect(find.text('DOB (YYYY-MM-DD) *'), findsOneWidget);
      expect(find.text('Gotra / Clan'), findsOneWidget);
      expect(find.text('Religion'), findsOneWidget);
      expect(find.text('Marital Status'), findsOneWidget);
      expect(find.text('Blood Group'), findsOneWidget);
      expect(find.text('Residential Address'), findsOneWidget);
      expect(find.text('Autofill GPS'), findsOneWidget);
      expect(find.text('Address Line 1 (House/Street) *'), findsOneWidget);
      expect(find.text('PIN Code *'), findsOneWidget);
      expect(find.text('Register & Allocate 12-Digit VUID'), findsOneWidget);

      // Verify no Hindi in brackets in English locale
      expect(find.text('Gotra / Clan (गोत्र)'), findsNothing);
      expect(find.text('Religion (धर्म)'), findsNothing);
      expect(find.text('Marital Status (वैवाहिक स्थिति)'), findsNothing);
      expect(find.text('Blood Group (रक्त समूह)'), findsNothing);
    });

    testWidgets('Translates personal details and residential details when language is changed', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch language to Hindi
      container.read(localeProvider.notifier).setLanguage(AppLanguage.hindi);
      await tester.pumpAndSettle();

      // Expect Hindi translations for personal and residential details
      expect(find.text('व्यक्तिगत विवरण'), findsOneWidget);
      expect(find.text('आवासीय पता'), findsOneWidget);
      expect(find.text('गोत्र'), findsOneWidget);
      expect(find.text('धर्म'), findsOneWidget);
      expect(find.text('वैवाहिक स्थिति'), findsOneWidget);
      expect(find.text('रक्त समूह'), findsOneWidget);
    });

    testWidgets('Triggers validation errors when required fields are empty upon submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit button without filling fields
      final submitButtonFinder = find.text('Register & Allocate 12-Digit VUID');
      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Expect 'Required' validation messages to appear
      expect(find.text('Required'), findsWidgets);
    });
  });
}

