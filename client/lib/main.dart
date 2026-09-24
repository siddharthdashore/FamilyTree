import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/registration_screen.dart';
import 'features/tree/screens/tree_canvas_screen.dart';
import 'features/card/screens/card_view_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VanshaSetuApp()));
}

class VanshaSetuApp extends StatelessWidget {
  const VanshaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VanshaSetu (वन्शसेतु)',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
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

        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      },
    );
  }
}
