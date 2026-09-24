import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vanshasetu/features/card/widgets/vansha_card_widget.dart';

void main() {
  group('VanshaCardWidget Component Tests', () {
    testWidgets('Renders ISO/IEC 7810 ID-1 Card with formatted VUID, QR code, and OCP Verified chip', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                child: VanshaCardWidget(
                  vuid: '109284729102',
                  fullName: 'Kailash Sharma',
                  dob: '1948-03-12',
                  gender: 'Male',
                  category: 'GEN',
                  state: 'Madhya Pradesh',
                ),
              ),
            ),
          ),
        ),
      );

      // Verify Header and Titles
      expect(find.text('VANSHACARD • वन्श कार्ड'), findsOneWidget);
      expect(find.text('1092 8472 9102'), findsOneWidget);
      expect(find.text('OCP VERIFIED'), findsOneWidget);

      // Verify Citizen Details
      expect(find.text('KAILASH SHARMA'), findsOneWidget);
      expect(find.text('DOB: 1948-03-12  |  Gender: Male'), findsOneWidget);
      expect(find.text('Category: GEN  |  State: Madhya Pradesh'), findsOneWidget);

      // Verify QR Code image is present
      expect(find.byType(QrImageView), findsOneWidget);

      // Verify Aspect Ratio
      final aspectRatioFinder = find.byType(AspectRatio);
      expect(aspectRatioFinder, findsOneWidget);
      final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder);
      expect(aspectRatioWidget.aspectRatio, closeTo(1.586, 0.001));
    });
  });
}
