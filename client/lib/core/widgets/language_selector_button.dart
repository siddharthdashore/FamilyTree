import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/locale_provider.dart';
import '../constants/app_colors.dart';

class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentLanguage = AppLanguage.fromCode(currentLocale.languageCode);

    return PopupMenuButton<AppLanguage>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryCyan.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLanguage.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              currentLanguage.nativeLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryCyan,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.primaryCyan),
          ],
        ),
      ),
      tooltip: 'Change Language / भाषा बदलें',
      onSelected: (AppLanguage selected) {
        ref.read(localeProvider.notifier).setLanguage(selected);
      },
      itemBuilder: (BuildContext context) {
        return AppLanguage.values.map((AppLanguage lang) {
          final isSelected = lang.code == currentLocale.languageCode;
          return PopupMenuItem<AppLanguage>(
            value: lang,
            child: Row(
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.nativeLabel,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryCyan : Colors.white,
                        ),
                      ),
                      Text(
                        lang.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? AppColors.primaryCyan.withOpacity(0.8) : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, size: 18, color: AppColors.primaryCyan),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
