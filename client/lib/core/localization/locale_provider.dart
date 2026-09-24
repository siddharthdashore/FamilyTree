import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported application language codes.
enum AppLanguage {
  english('en', 'English', 'English', '🇬🇧'),
  hindi('hi', 'Hindi', 'हिन्दी', '🇮🇳'),
  gujarati('gu', 'Gujarati', 'ગુજરાતી', '🇮🇳'),
  marathi('mr', 'Marathi', 'मराठी', '🇮🇳');

  final String code;
  final String label;
  final String nativeLabel;
  final String flag;

  const AppLanguage(this.code, this.label, this.nativeLabel, this.flag);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }
}

/// StateNotifier to manage application-wide active locale.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale newLocale) {
    if (['en', 'hi', 'gu', 'mr'].contains(newLocale.languageCode)) {
      state = newLocale;
    }
  }

  void setLanguage(AppLanguage language) {
    state = language.locale;
  }
}

/// Global provider for the active application Locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
