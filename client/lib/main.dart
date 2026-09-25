import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/registration_screen.dart';
import 'features/tree/screens/tree_canvas_screen.dart';
import 'features/card/screens/card_view_screen.dart';
import 'features/analytics/screens/demographics_screen.dart';
import 'features/matrimony/screens/matrimony_search_screen.dart';
import 'features/audit/screens/audit_logs_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VanshaSetuApp()));
}

class VanshaSetuApp extends ConsumerWidget {
  const VanshaSetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'VanshaSetu (वन्शसेतु)',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => const TreeCanvasScreen(rootVuid: '109284729102'),
          );
        }

        if (settings.name == '/registration') {
          return MaterialPageRoute(builder: (_) => const RegistrationScreen());
        }

        if (settings.name == '/tree') {
          final rootVuid = settings.arguments as String? ?? '109284729102';
          return MaterialPageRoute(
            builder: (_) => TreeCanvasScreen(rootVuid: rootVuid),
          );
        }

        if (settings.name == '/card') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (_) => CardViewScreen(
              vuid: args['vuid'] ?? '109284729102',
              fullName: args['fullName'] ?? 'Aarav Sharma',
              dob: args['dob'] ?? '1998-05-18',
              gender: args['gender'] ?? 'Male',
              category: args['category'] ?? 'GEN',
              state: args['state'] ?? 'Madhya Pradesh',
            ),
          );
        }

        if (settings.name == '/demographics') {
          return MaterialPageRoute(builder: (_) => const DemographicsScreen());
        }

        if (settings.name == '/matrimony') {
          return MaterialPageRoute(builder: (_) => const MatrimonySearchScreen());
        }

        if (settings.name == '/audit') {
          return MaterialPageRoute(builder: (_) => const AuditLogsScreen());
        }

        return MaterialPageRoute(
          builder: (_) => const TreeCanvasScreen(rootVuid: '109284729102'),
        );
      },
    );
  }
}
