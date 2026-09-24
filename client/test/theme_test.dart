import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanshasetu/core/constants/app_colors.dart';
import 'package:vanshasetu/core/theme/app_theme.dart';

void main() {
  group('Theme & Design System Tests', () {
    test('AppColors: Constants have correct hexadecimal definitions', () {
      expect(AppColors.backgroundDark, const Color(0xFF0F172A));
      expect(AppColors.primaryCyan, const Color(0xFF38BDF8));
      expect(AppColors.maleNode, const Color(0xFF1E3A8A));
      expect(AppColors.femaleNode, const Color(0xFFBE185D));
      expect(AppColors.spouseEdge, const Color(0xFF9333EA));
      expect(AppColors.verifiedGreen, const Color(0xFF10B981));
      expect(AppColors.conflictRed, const Color(0xFFEF4444));
    });

    test('AppTheme: darkTheme has correct Dark brightness and Material 3 enabled', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(theme.colorScheme.primary, AppColors.primaryCyan);
      expect(theme.cardTheme.color, AppColors.surfaceDark);
    });

    test('AppTheme: lightTheme has correct Light brightness and Material 3 enabled', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(theme.colorScheme.primary, AppColors.primaryBlue);
      expect(theme.cardTheme.color, AppColors.surfaceLight);
    });
  });
}
