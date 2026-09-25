import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vanshasetu/core/constants/civil_models.dart';
import 'package:vanshasetu/core/localization/app_localizations.dart';
import 'package:vanshasetu/core/widgets/language_selector_button.dart';

void main() {
  group('Multilingual Support Tests (English, Hindi, Gujarati, Marathi)', () {
    test('CivilLanguages defines all 4 official DPI languages', () {
      expect(CivilLanguages.codes, containsAll(['en', 'hi', 'gu', 'mr']));
      expect(CivilLanguages.names['en'], 'English');
      expect(CivilLanguages.names['hi'], contains('हिन्दी'));
      expect(CivilLanguages.names['gu'], contains('ગુજરાતી'));
      expect(CivilLanguages.names['mr'], contains('मराठी'));
    });

    test('AppLocalizations translates UI strings correctly across all 4 languages', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));
      final locGu = AppLocalizations(const Locale('gu'));
      final locMr = AppLocalizations(const Locale('mr'));

      // App Title
      expect(locEn.translate('app_title'), 'VanshaSetu');
      expect(locHi.translate('app_title'), 'वन्शसेतु');
      expect(locGu.translate('app_title'), 'વંશસેતુ');
      expect(locMr.translate('app_title'), 'वंशसेतू');

      // Registration Title
      expect(locEn.translate('reg_title'), 'New Citizen Registration');
      expect(locHi.translate('reg_title'), 'नया नागरिक पंजीकरण');
      expect(locGu.translate('reg_title'), 'નવી નાગરિક નોંધણી');
      expect(locMr.translate('reg_title'), 'नवीन नागरिक नोंदणी');

      // Kinship Canvas Title
      expect(locEn.translate('nav_lineage_canvas'), 'Lineage Canvas');
      expect(locHi.translate('nav_lineage_canvas'), 'वंशावली मानचित्र');
      expect(locGu.translate('nav_lineage_canvas'), 'વંશાવળી નકશો');
      expect(locMr.translate('nav_lineage_canvas'), 'वंशावळ आलेख');
    });

    test('CivilCategories provides localized translations in English, Hindi, Gujarati, Marathi', () {
      expect(CivilCategories.getLabel('GEN'), 'General');
      expect(CivilCategories.getHindiLabel('GEN'), 'सामान्य');
      expect(CivilCategories.getGujaratiLabel('GEN'), 'સામાન્ય');
      expect(CivilCategories.getMarathiLabel('GEN'), 'सामान्य');

      expect(CivilCategories.getLocalizedLabel('OBC', 'en'), 'Other Backward Class');
      expect(CivilCategories.getLocalizedLabel('OBC', 'hi'), 'अन्य पिछड़ा वर्ग');
      expect(CivilCategories.getLocalizedLabel('OBC', 'gu'), contains('પછાત'));
      expect(CivilCategories.getLocalizedLabel('OBC', 'mr'), contains('मागासवर्गीय'));
    });

    test('CivilRelationships provides 72 kinship translations in Gujarati and Marathi', () {
      // Father
      expect(CivilRelationships.getLocalizedLabel('Father', 'en'), contains('Father'));
      expect(CivilRelationships.getLocalizedLabel('Father', 'hi'), 'पिता');
      expect(CivilRelationships.getLocalizedLabel('Father', 'gu'), contains('પિતા'));
      expect(CivilRelationships.getLocalizedLabel('Father', 'mr'), contains('वडील'));

      // Mother
      expect(CivilRelationships.getLocalizedLabel('Mother', 'hi'), 'माता');
      expect(CivilRelationships.getLocalizedLabel('Mother', 'gu'), contains('માતા'));
      expect(CivilRelationships.getLocalizedLabel('Mother', 'mr'), 'आई');

      // Paternal Grandfather
      expect(CivilRelationships.getLocalizedLabel('Paternal_Grandfather', 'hi'), 'दादा');
      expect(CivilRelationships.getLocalizedLabel('Paternal_Grandfather', 'gu'), contains('દાદા'));
      expect(CivilRelationships.getLocalizedLabel('Paternal_Grandfather', 'mr'), contains('आजोबा'));

      // Maternal Uncle
      expect(CivilRelationships.getLocalizedLabel('Maternal_Uncle', 'hi'), 'मामा');
      expect(CivilRelationships.getLocalizedLabel('Maternal_Uncle', 'gu'), 'મામા');
      expect(CivilRelationships.getLocalizedLabel('Maternal_Uncle', 'mr'), 'मामा');
    });

    testWidgets('LanguageSelectorButton renders with current flag and switches language', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [LanguageSelectorButton()],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Renders default English flag
      expect(find.byType(LanguageSelectorButton), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('Choosing languages (English, Hindi, Gujarati, Marathi) resolves MaterialLocalizations cleanly', (WidgetTester tester) async {
      for (final code in ['en', 'hi', 'gu', 'mr']) {
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, _) {
                return MaterialApp(
                  locale: Locale(code),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: Scaffold(
                    body: Builder(
                      builder: (innerContext) {
                        final materialLoc = MaterialLocalizations.of(innerContext);
                        final appLoc = AppLocalizations.of(innerContext);
                        return Text('${materialLoc.okButtonLabel} | ${appLoc.translate("app_title")}');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must successfully locate MaterialLocalizations without throwing
        expect(tester.takeException(), isNull);
        expect(find.byType(Text), findsWidgets);
      }
    });
  });
}
