/**
 * VanshaSetu — Single Source of Truth Synchronization Script
 * Synchronizes:
 *  1. client/lib/core/constants/civil_models.dart from shared/civil_models.json
 *  2. client/lib/core/localization/app_localizations.dart from shared/strings.json
 * 
 * Supports multilingual parity: English (en), Hindi (hi), Gujarati (gu), Marathi (mr).
 * 
 * Usage: node scripts/sync_models.js
 */

const fs = require('fs');
const path = require('path');

const modelsJsonPath = path.join(__dirname, '../shared/civil_models.json');
const stringsJsonPath = path.join(__dirname, '../shared/strings.json');
const dartModelsOutputPath = path.join(__dirname, '../client/lib/core/constants/civil_models.dart');
const dartStringsOutputPath = path.join(__dirname, '../client/lib/core/localization/app_localizations.dart');

if (!fs.existsSync(modelsJsonPath)) {
    console.error(`Error: Models JSON not found at ${modelsJsonPath}`);
    process.exit(1);
}

if (!fs.existsSync(stringsJsonPath)) {
    console.error(`Error: Strings JSON not found at ${stringsJsonPath}`);
    process.exit(1);
}

const rawModels = fs.readFileSync(modelsJsonPath, 'utf8');
const data = JSON.parse(rawModels);

const rawStrings = fs.readFileSync(stringsJsonPath, 'utf8');
const stringsData = JSON.parse(rawStrings);

function escape(str) {
    if (!str) return '';
    return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

function generateDartClass(className, items) {
    const codes = items.map(i => `    '${i.code}',`).join('\n');
    const labelEntries = items.map(i => `    '${i.code}': '${escape(i.label)}',`).join('\n');
    const hindiEntries = items.map(i => `    '${i.code}': '${escape(i.hindi_label)}',`).join('\n');
    const gujaratiEntries = items.map(i => `    '${i.code}': '${escape(i.gujarati_label || i.label)}',`).join('\n');
    const marathiEntries = items.map(i => `    '${i.code}': '${escape(i.marathi_label || i.label)}',`).join('\n');

    return `class ${className} {
  static const List<String> all = [
${codes}
  ];

  static const Map<String, String> labels = {
${labelEntries}
  };

  static const Map<String, String> hindiLabels = {
${hindiEntries}
  };

  static const Map<String, String> gujaratiLabels = {
${gujaratiEntries}
  };

  static const Map<String, String> marathiLabels = {
${marathiEntries}
  };

  static String getLabel(String code) => labels[code] ?? code;
  static String getHindiLabel(String code) => hindiLabels[code] ?? code;
  static String getGujaratiLabel(String code) => gujaratiLabels[code] ?? code;
  static String getMarathiLabel(String code) => marathiLabels[code] ?? code;

  static String getLocalizedLabel(String code, [String lang = 'en']) {
    switch (lang.toLowerCase()) {
      case 'hi':
        return getHindiLabel(code);
      case 'gu':
        return getGujaratiLabel(code);
      case 'mr':
        return getMarathiLabel(code);
      case 'en':
      default:
        return getLabel(code);
    }
  }
}`;
}

function generateRelationshipClass(items) {
    const codes = items.map(i => `    '${i.code}',`).join('\n');
    const labelEntries = items.map(i => `    '${i.code}': '${escape(i.label)}',`).join('\n');
    const hindiEntries = items.map(i => `    '${i.code}': '${escape(i.hindi_label)}',`).join('\n');
    const gujaratiEntries = items.map(i => `    '${i.code}': '${escape(i.gujarati_label || i.label)}',`).join('\n');
    const marathiEntries = items.map(i => `    '${i.code}': '${escape(i.marathi_label || i.label)}',`).join('\n');
    const westernEntries = items.map(i => `    '${i.code}': '${escape(i.western)}',`).join('\n');
    const indianEntries = items.map(i => `    '${i.code}': '${escape(i.indian)}',`).join('\n');
    const categoryEntries = items.map(i => `    '${i.code}': '${escape(i.category)}',`).join('\n');

    return `class CivilRelationships {
  static const List<String> all = [
${codes}
  ];

  static const Map<String, String> labels = {
${labelEntries}
  };

  static const Map<String, String> hindiLabels = {
${hindiEntries}
  };

  static const Map<String, String> gujaratiLabels = {
${gujaratiEntries}
  };

  static const Map<String, String> marathiLabels = {
${marathiEntries}
  };

  static const Map<String, String> western = {
${westernEntries}
  };

  static const Map<String, String> indian = {
${indianEntries}
  };

  static const Map<String, String> categories = {
${categoryEntries}
  };

  static String getLabel(String code) => labels[code] ?? code;
  static String getHindiLabel(String code) => hindiLabels[code] ?? code;
  static String getGujaratiLabel(String code) => gujaratiLabels[code] ?? code;
  static String getMarathiLabel(String code) => marathiLabels[code] ?? code;
  static String getWestern(String code) => western[code] ?? code;
  static String getIndian(String code) => indian[code] ?? code;
  static String getCategory(String code) => categories[code] ?? 'Other';

  static String getLocalizedLabel(String code, [String lang = 'en']) {
    switch (lang.toLowerCase()) {
      case 'hi':
        return getHindiLabel(code);
      case 'gu':
        return getGujaratiLabel(code);
      case 'mr':
        return getMarathiLabel(code);
      case 'en':
      default:
        return getLabel(code);
    }
  }
}`;
}

const languagesClass = `class CivilLanguages {
  static const List<String> codes = ['en', 'hi', 'gu', 'mr'];

  static const Map<String, String> names = {
    'en': 'English',
    'hi': 'Hindi (हिन्दी)',
    'gu': 'Gujarati (ગુજરાતી)',
    'mr': 'Marathi (मराठी)',
  };

  static const Map<String, String> nativeNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
  };

  static const Map<String, String> flags = {
    'en': '🇬🇧',
    'hi': '🇮🇳',
    'gu': '🇮🇳',
    'mr': '🇮🇳',
  };
}`;

const dartModelsContent = `// ============================================================================
// AUTO-GENERATED FROM shared/civil_models.json — DO NOT EDIT MANUALLY
// Single Source of Truth: shared/civil_models.json
// Generator: scripts/sync_models.js
// Multilingual Parity: English (en), Hindi (hi), Gujarati (gu), Marathi (mr)
// Version: ${data.version}
// ============================================================================

/// Canonical Civil Domain Model item with machine code and multilingual display values.
class CivilItem {
  final String code;
  final String label;
  final String hindiLabel;
  final String gujaratiLabel;
  final String marathiLabel;
  final String? description;

  const CivilItem({
    required this.code,
    required this.label,
    required this.hindiLabel,
    required this.gujaratiLabel,
    required this.marathiLabel,
    this.description,
  });

  String getLocalized(String lang) {
    switch (lang.toLowerCase()) {
      case 'hi':
        return hindiLabel;
      case 'gu':
        return gujaratiLabel;
      case 'mr':
        return marathiLabel;
      case 'en':
      default:
        return label;
    }
  }
}

/// Canonical Kinship Relationship item covering Indian and Western ontologies.
class CivilRelationshipItem extends CivilItem {
  final String western;
  final String indian;
  final String category;

  const CivilRelationshipItem({
    required super.code,
    required super.label,
    required super.hindiLabel,
    required super.gujaratiLabel,
    required super.marathiLabel,
    required this.western,
    required this.indian,
    required this.category,
    super.description,
  });
}

${languagesClass}

${generateDartClass('CivilCategories', data.categories)}

${generateDartClass('CivilReligions', data.religions)}

${generateDartClass('CivilMaritalStatuses', data.marital_statuses)}

${generateDartClass('CivilBloodGroups', data.blood_groups)}

${generateDartClass('CivilGenders', data.genders)}

${generateDartClass('CivilQualifications', data.qualifications)}

${generateDartClass('CivilOccupations', data.occupations)}

${generateDartClass('CivilDocumentTypes', data.document_types)}

${generateRelationshipClass(data.relationships)}
`;

fs.writeFileSync(dartModelsOutputPath, dartModelsContent, 'utf8');
console.log(`✅ [1/2] Successfully generated ${dartModelsOutputPath} from ${modelsJsonPath}`);

// ============================================================================
// PART 2: Generate AppLocalizations from shared/strings.json
// ============================================================================
function generateLocalizedMap(langCode) {
    const entries = [];
    for (const [key, translations] of Object.entries(stringsData.strings)) {
        const val = translations[langCode] || translations['en'] || key;
        entries.push(`      '${key}': '${escape(val)}',`);
    }
    return entries.join('\n');
}

const dartStringsContent = `// ============================================================================
// AUTO-GENERATED FROM shared/strings.json — DO NOT EDIT MANUALLY
// Single Source of Truth: shared/strings.json
// Generator: scripts/sync_models.js
// Multilingual Parity: English (en), Hindi (hi), Gujarati (gu), Marathi (mr)
// Version: ${stringsData.version}
// ============================================================================

import 'package:flutter/material.dart';

/// VanshaSetu — Sovereign Multilingual Public Infrastructure Localizations
/// Languages Supported: English (en), Hindi (hi), Gujarati (gu), Marathi (mr).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // हिन्दी
    Locale('gu'), // ગુજરાતી
    Locale('mr'), // मराठी
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
${generateLocalizedMap('en')}
    },
    'hi': {
${generateLocalizedMap('hi')}
    },
    'gu': {
${generateLocalizedMap('gu')}
    },
    'mr': {
${generateLocalizedMap('mr')}
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'gu', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
`;

fs.writeFileSync(dartStringsOutputPath, dartStringsContent, 'utf8');
console.log(`✅ [2/2] Successfully generated ${dartStringsOutputPath} from ${stringsJsonPath}`);
console.log(`   - Total Strings: ${Object.keys(stringsData.strings).length}`);
console.log(`   - Languages: English (en), Hindi (hi), Gujarati (gu), Marathi (mr)`);
