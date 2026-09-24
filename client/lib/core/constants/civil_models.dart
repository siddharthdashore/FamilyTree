// ============================================================================
// AUTO-GENERATED FROM shared/civil_models.json — DO NOT EDIT MANUALLY
// Single Source of Truth: shared/civil_models.json
// Generator: scripts/sync_models.js
// Multilingual Parity: English (en), Hindi (hi), Gujarati (gu), Marathi (mr)
// Version: 1.2.0
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

class CivilLanguages {
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
}

class CivilCategories {
  static const List<String> all = [
    'GEN',
    'OBC',
    'SC',
    'ST',
    'EWS',
    'Other',
  ];

  static const Map<String, String> labels = {
    'GEN': 'General',
    'OBC': 'Other Backward Class',
    'SC': 'Scheduled Caste',
    'ST': 'Scheduled Tribe',
    'EWS': 'Economically Weaker Section',
    'Other': 'Other Category',
  };

  static const Map<String, String> hindiLabels = {
    'GEN': 'सामान्य',
    'OBC': 'अन्य पिछड़ा वर्ग',
    'SC': 'अनुसूचित जाति',
    'ST': 'अनुसूचित जनजाति',
    'EWS': 'आर्थिक रूप से कमजोर वर्ग',
    'Other': 'अन्य वर्ग',
  };

  static const Map<String, String> gujaratiLabels = {
    'GEN': 'સામાન્ય',
    'OBC': 'અન્ય પછાત વર્ગ (OBC)',
    'SC': 'અનુસૂચિત જાતિ (SC)',
    'ST': 'અનુસૂચિત જનજાતિ (ST)',
    'EWS': 'આર્થિક રીતે નબળા વર્ગ (EWS)',
    'Other': 'અન્ય વર્ગ',
  };

  static const Map<String, String> marathiLabels = {
    'GEN': 'सामान्य',
    'OBC': 'इतर मागासवर्गीय (OBC)',
    'SC': 'अनुसूचित जाती (SC)',
    'ST': 'अनुसूचित जमाती (ST)',
    'EWS': 'आर्थिकदृष्ट्या दुर्बल घटक (EWS)',
    'Other': 'इतर वर्ग',
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
}

class CivilReligions {
  static const List<String> all = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Jain',
    'Buddhist',
    'Parsi',
    'Jewish',
    'Other',
  ];

  static const Map<String, String> labels = {
    'Hindu': 'Hinduism',
    'Muslim': 'Islam',
    'Christian': 'Christianity',
    'Sikh': 'Sikhism',
    'Jain': 'Jainism',
    'Buddhist': 'Buddhism',
    'Parsi': 'Zoroastrianism / Parsi',
    'Jewish': 'Judaism',
    'Other': 'Other Religion',
  };

  static const Map<String, String> hindiLabels = {
    'Hindu': 'हिन्दू',
    'Muslim': 'मुस्लिम',
    'Christian': 'ईसाई',
    'Sikh': 'सिख',
    'Jain': 'जैन',
    'Buddhist': 'बौद्ध',
    'Parsi': 'पारसी',
    'Jewish': 'यहूदी',
    'Other': 'अन्य धर्म',
  };

  static const Map<String, String> gujaratiLabels = {
    'Hindu': 'હિન્દુ',
    'Muslim': 'મુસ્લિમ',
    'Christian': 'ખ્રિસ્તી',
    'Sikh': 'શીખ',
    'Jain': 'જૈન',
    'Buddhist': 'બૌદ્ધ',
    'Parsi': 'પારસી',
    'Jewish': 'યહૂદી',
    'Other': 'અન્ય ધર્મ',
  };

  static const Map<String, String> marathiLabels = {
    'Hindu': 'हिंदू',
    'Muslim': 'मुस्लिम',
    'Christian': 'ख्रिश्चन',
    'Sikh': 'शीख',
    'Jain': 'जैन',
    'Buddhist': 'बौद्ध',
    'Parsi': 'पारशी',
    'Jewish': 'ज्यू / यहुदी',
    'Other': 'इतर धर्म',
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
}

class CivilMaritalStatuses {
  static const List<String> all = [
    'Single',
    'Married',
    'Widowed',
    'Divorced',
    'Separated',
  ];

  static const Map<String, String> labels = {
    'Single': 'Single / Unmarried',
    'Married': 'Married',
    'Widowed': 'Widowed',
    'Divorced': 'Divorced',
    'Separated': 'Separated',
  };

  static const Map<String, String> hindiLabels = {
    'Single': 'अविवाहित',
    'Married': 'विवाहित',
    'Widowed': 'विधवा / विधुर',
    'Divorced': 'तलाकशुदा',
    'Separated': 'अलग',
  };

  static const Map<String, String> gujaratiLabels = {
    'Single': 'અવિવાહિત',
    'Married': 'પરણિત / વિવાહિત',
    'Widowed': 'વિધવા / વિધુર',
    'Divorced': 'છૂટાછેડા લીધેલ',
    'Separated': 'અલગ થયેલ',
  };

  static const Map<String, String> marathiLabels = {
    'Single': 'अविवाहित',
    'Married': 'विवाहित',
    'Widowed': 'विधवा / विधुर',
    'Divorced': 'घटस्फोटित',
    'Separated': 'विभक्त',
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
}

class CivilBloodGroups {
  static const List<String> all = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const Map<String, String> labels = {
    'A+': 'A Positive (A+)',
    'A-': 'A Negative (A-)',
    'B+': 'B Positive (B+)',
    'B-': 'B Negative (B-)',
    'AB+': 'AB Positive (AB+)',
    'AB-': 'AB Negative (AB-)',
    'O+': 'O Positive (O+)',
    'O-': 'O Negative (O-)',
  };

  static const Map<String, String> hindiLabels = {
    'A+': 'ए पॉजिटिव',
    'A-': 'ए नेगेटिव',
    'B+': 'बी पॉजिटिव',
    'B-': 'बी नेगेटिव',
    'AB+': 'एबी पॉजिटिव',
    'AB-': 'एबी नेगेटिव',
    'O+': 'ओ पॉजिटिव',
    'O-': 'ओ नेगेटिव',
  };

  static const Map<String, String> gujaratiLabels = {
    'A+': 'એ પોઝિટિવ (A+)',
    'A-': 'એ નેગેટિવ (A-)',
    'B+': 'બી પોઝિટિવ (B+)',
    'B-': 'બી નેગેટિવ (B-)',
    'AB+': 'એબી પોઝિટિવ (AB+)',
    'AB-': 'એબી નેગેટિવ (AB-)',
    'O+': 'ઓ પોઝિટિવ (O+)',
    'O-': 'ઓ નેગેટિવ (O-)',
  };

  static const Map<String, String> marathiLabels = {
    'A+': 'ए पॉझिटिव्ह (A+)',
    'A-': 'ए निगेटिव्ह (A-)',
    'B+': 'बी पॉझिटिव्ह (B+)',
    'B-': 'बी निगेटिव्ह (B-)',
    'AB+': 'एबी पॉझिटिव्ह (AB+)',
    'AB-': 'एबी निगेटिव्ह (AB-)',
    'O+': 'ओ पॉझिटिव्ह (O+)',
    'O-': 'ओ निगेटिव्ह (O-)',
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
}

class CivilGenders {
  static const List<String> all = [
    'Male',
    'Female',
    'Non-Binary',
    'Transgender',
    'Other',
  ];

  static const Map<String, String> labels = {
    'Male': 'Male',
    'Female': 'Female',
    'Non-Binary': 'Non-Binary',
    'Transgender': 'Transgender',
    'Other': 'Other',
  };

  static const Map<String, String> hindiLabels = {
    'Male': 'पुरुष',
    'Female': 'महिला',
    'Non-Binary': 'गैर-द्विआधारी',
    'Transgender': 'ट्रांसजेंडर',
    'Other': 'अन्य',
  };

  static const Map<String, String> gujaratiLabels = {
    'Male': 'પુરુષ',
    'Female': 'સ્ત્રી / મહિલા',
    'Non-Binary': 'નોન-બાઈનરી',
    'Transgender': 'ટ્રાન્સજેન્ડર',
    'Other': 'અન્ય',
  };

  static const Map<String, String> marathiLabels = {
    'Male': 'पुरुष',
    'Female': 'स्त्री / महिला',
    'Non-Binary': 'नॉन-बायनरी',
    'Transgender': 'तृतीयपंथी / ट्रान्सजेंडर',
    'Other': 'इतर',
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
}

class CivilQualifications {
  static const List<String> all = [
    'Primary',
    'Secondary_10th',
    'HigherSecondary_12th',
    'Diploma',
    'Bachelors',
    'Masters',
    'Doctorate',
    'Professional_CA_CS',
    'Other',
  ];

  static const Map<String, String> labels = {
    'Primary': 'Primary School (Class 1-5)',
    'Secondary_10th': 'Secondary School (10th / Matric)',
    'HigherSecondary_12th': 'Higher Secondary (12th / Intermediate)',
    'Diploma': 'Vocational / Technical Diploma',
    'Bachelors': 'Bachelor\'s Degree (Undergraduate)',
    'Masters': 'Master\'s Degree (Postgraduate)',
    'Doctorate': 'Doctorate / Ph.D.',
    'Professional_CA_CS': 'Professional Certification (CA, CS, ICWA)',
    'Other': 'Other Qualification',
  };

  static const Map<String, String> hindiLabels = {
    'Primary': 'प्राथमिक शिक्षा',
    'Secondary_10th': 'माध्यमिक (10वीं)',
    'HigherSecondary_12th': 'उच्चतर माध्यमिक (12वीं)',
    'Diploma': 'डिप्लोमा',
    'Bachelors': 'स्नातक',
    'Masters': 'स्नातकोत्तर',
    'Doctorate': 'डॉक्टरेट (पीएच.डी.)',
    'Professional_CA_CS': 'व्यावसायिक योग्यता',
    'Other': 'अन्य',
  };

  static const Map<String, String> gujaratiLabels = {
    'Primary': 'પ્રાથમિક શિક્ષણ (1-5)',
    'Secondary_10th': 'માધ્યમિક (10મું / SSC)',
    'HigherSecondary_12th': 'ઉચ્ચતર માધ્યમિક (12મું / HSC)',
    'Diploma': 'ડિપ્લોમા / ટેકનિકલ',
    'Bachelors': 'સ્નાતક (બેચલર્સ ડિગ્રી)',
    'Masters': 'અનુસ્નાતક (માસ્ટર્સ ડિગ્રી)',
    'Doctorate': 'ડોક્ટરેટ (Ph.D.)',
    'Professional_CA_CS': 'વ્યવસાયિક લાયકાત (CA, CS)',
    'Other': 'અન્ય લાયકાત',
  };

  static const Map<String, String> marathiLabels = {
    'Primary': 'प्राथमिक शिक्षण (1-5)',
    'Secondary_10th': 'माध्यमिक (10वी / SSC)',
    'HigherSecondary_12th': 'उच्च माध्यमिक (12वी / HSC)',
    'Diploma': 'पदविका / डिप्लोमा',
    'Bachelors': 'पदवी (ग्रॅज्युएट)',
    'Masters': 'व्युत्पन्न पदवी (पोस्ट ग्रॅज्युएट)',
    'Doctorate': 'विद्यावाचस्पती (Ph.D.)',
    'Professional_CA_CS': 'व्यावसायिक प्रमाणपत्र (CA, CS)',
    'Other': 'इतर शिक्षण',
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
}

class CivilOccupations {
  static const List<String> all = [
    'Government',
    'Private_IT_Corporate',
    'Healthcare',
    'Banking_Finance',
    'Defense_Police',
    'Education_Research',
    'Business_SelfEmployed',
    'Agriculture',
    'Student',
    'Homemaker',
    'Other',
  ];

  static const Map<String, String> labels = {
    'Government': 'Government & Civil Services',
    'Private_IT_Corporate': 'Private Sector, IT & Corporate',
    'Healthcare': 'Healthcare, Medicine & Doctors',
    'Banking_Finance': 'Banking & Financial Services',
    'Defense_Police': 'Armed Forces, Defense & Police',
    'Education_Research': 'Education, Teaching & Research',
    'Business_SelfEmployed': 'Business, Trade & Self Employed',
    'Agriculture': 'Agriculture, Farming & Agro-Business',
    'Student': 'Student / Scholar',
    'Homemaker': 'Homemaker / Domestic Manager',
    'Other': 'Other Occupation',
  };

  static const Map<String, String> hindiLabels = {
    'Government': 'शासकीय सेवा',
    'Private_IT_Corporate': 'निजी / कॉर्पोरेट क्षेत्र',
    'Healthcare': 'चिकित्सा एवं स्वास्थ्य',
    'Banking_Finance': 'बैंकिंग एवं वित्त',
    'Defense_Police': 'रक्षा एवं पुलिस बल',
    'Education_Research': 'शिक्षा एवं अनुसंधान',
    'Business_SelfEmployed': 'व्यवसाय / स्वरोजगार',
    'Agriculture': 'कृषि एवं बागवानी',
    'Student': 'विद्यार्थी',
    'Homemaker': 'गृहणी',
    'Other': 'अन्य व्यवसाय',
  };

  static const Map<String, String> gujaratiLabels = {
    'Government': 'સરકારી સેવા / અધિકારી',
    'Private_IT_Corporate': 'ખાનગી / આઈટી અને કોર્પોરેટ',
    'Healthcare': 'તબીબી અને આરોગ્ય સેવા (ડોક્ટર, નર્સ)',
    'Banking_Finance': 'બેંકિંગ અને નાણાકીય સેવા',
    'Defense_Police': 'સંરક્ષણ દળ અને પોલીસ',
    'Education_Research': 'શિક્ષણ અને વૈજ્ઞાનિક સંશોધન',
    'Business_SelfEmployed': 'વેપાર / સ્વરોજગાર / ઉદ્યોગ',
    'Agriculture': 'ખેતીવાડી / કૃષિ વ્યવસાય',
    'Student': 'વિદ્યાર્થી / અભ્યાસ',
    'Homemaker': 'ગૃહિણી / પરિવાર સંભાળ',
    'Other': 'અન્ય વ્યવસાય',
  };

  static const Map<String, String> marathiLabels = {
    'Government': 'शासकीय सेवा / अधिकारी',
    'Private_IT_Corporate': 'खाजगी / आयटी व कॉर्पोरेट',
    'Healthcare': 'आरोग्य व वैद्यकीय सेवा (डॉक्टर, परिचारिका)',
    'Banking_Finance': 'बँकिंग व वित्तीय सेवा',
    'Defense_Police': 'संरक्षण व पोलीस दल',
    'Education_Research': 'शिक्षण व वैज्ञानिक संशोधन',
    'Business_SelfEmployed': 'व्यवसाय / स्वयंरोजगार / उद्योग',
    'Agriculture': 'शेती व कृषी व्यवसाय',
    'Student': 'विद्यार्थी / शिक्षणार्थी',
    'Homemaker': 'गृहिणी / कौटुंबिक व्यवस्थापक',
    'Other': 'इतर व्यवसाय',
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
}

class CivilDocumentTypes {
  static const List<String> all = [
    'AADHAAR',
    'PAN',
    'VOTER_ID',
    'DRIVING_LICENSE',
    'PASSPORT',
    'RATION_CARD',
    'BIRTH_CERTIFICATE',
    'BIOMETRIC',
  ];

  static const Map<String, String> labels = {
    'AADHAAR': 'Aadhaar Card (UIDAI)',
    'PAN': 'Permanent Account Number (PAN)',
    'VOTER_ID': 'Voter ID Card (EPIC)',
    'DRIVING_LICENSE': 'Motor Vehicle Driving License',
    'PASSPORT': 'Indian Passport',
    'RATION_CARD': 'Public Distribution Ration Card',
    'BIRTH_CERTIFICATE': 'Municipal Birth Certificate',
    'BIOMETRIC': 'Biometric Verification Record',
  };

  static const Map<String, String> hindiLabels = {
    'AADHAAR': 'आधार कार्ड',
    'PAN': 'पैन कार्ड',
    'VOTER_ID': 'मतदाता पहचान पत्र',
    'DRIVING_LICENSE': 'ड्राइविंग लाइसेंस',
    'PASSPORT': 'पासपोर्ट',
    'RATION_CARD': 'राशन कार्ड',
    'BIRTH_CERTIFICATE': 'जन्म प्रमाण पत्र',
    'BIOMETRIC': 'बायोमेट्रिक प्रमाणीकरण',
  };

  static const Map<String, String> gujaratiLabels = {
    'AADHAAR': 'આધાર કાર્ડ',
    'PAN': 'પાન કાર્ડ',
    'VOTER_ID': 'ચૂંટણી ઓળખપત્ર (મતદાર કાર્ડ)',
    'DRIVING_LICENSE': 'ડ્રાઇવિંગ લાયસન્સ',
    'PASSPORT': 'ભારતીય પાસપોર્ટ',
    'RATION_CARD': 'રેશન કાર્ડ',
    'BIRTH_CERTIFICATE': 'જન્મ પ્રમાણપત્ર',
    'BIOMETRIC': 'બાયોમેટ્રિક રેકોર્ડ',
  };

  static const Map<String, String> marathiLabels = {
    'AADHAAR': 'आधार कार्ड',
    'PAN': 'पॅन कार्ड',
    'VOTER_ID': 'मतदार ओळखपत्र',
    'DRIVING_LICENSE': 'वाहन चालक परवाना',
    'PASSPORT': 'पारपत्र / पासपोर्ट',
    'RATION_CARD': 'शिधापत्रिका / रेशन कार्ड',
    'BIRTH_CERTIFICATE': 'जन्म दाखला / प्रमाणपत्र',
    'BIOMETRIC': 'बायोमेट्रिक नोंद',
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
}

class CivilRelationships {
  static const List<String> all = [
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Sibling',
    'Spouse',
    'Husband',
    'Wife',
    'Paternal_Grandfather',
    'Paternal_Grandmother',
    'Maternal_Grandfather',
    'Maternal_Grandmother',
    'Great_Grandfather',
    'Great_Grandmother',
    'Grandson',
    'Granddaughter',
    'Great_Grandson',
    'Great_Granddaughter',
    'Paternal_Uncle_Elder',
    'Paternal_Aunt_Elder',
    'Paternal_Uncle_Younger',
    'Paternal_Aunt_Younger',
    'Paternal_Aunt',
    'Paternal_Aunt_Husband',
    'Maternal_Uncle',
    'Maternal_Uncle_Wife',
    'Maternal_Aunt',
    'Maternal_Aunt_Husband',
    'Uncle',
    'Aunt',
    'Cousin_Brother',
    'Cousin_Sister',
    'Cousin',
    'Nephew_Brother_Son',
    'Niece_Brother_Daughter',
    'Nephew_Sister_Son',
    'Niece_Sister_Daughter',
    'Nephew',
    'Niece',
    'Father_In_Law',
    'Mother_In_Law',
    'Son_In_Law',
    'Daughter_In_Law',
    'Brother_In_Law_Wife_Brother',
    'Sister_In_Law_Wife_Sister',
    'Brother_In_Law_Husband_Elder',
    'Sister_In_Law_Husband_Elder_Wife',
    'Brother_In_Law_Husband_Younger',
    'Sister_In_Law_Husband_Younger_Wife',
    'Sister_In_Law_Husband_Sister',
    'Brother_In_Law_Husband_Sister_Husband',
    'Brother_In_Law_Sister_Husband',
    'Sister_In_Law_Brother_Wife',
    'Co_Father_In_Law',
    'Co_Mother_In_Law',
    'Brother_In_Law',
    'Sister_In_Law',
    'Step_Father',
    'Step_Mother',
    'Step_Son',
    'Step_Daughter',
    'Step_Brother',
    'Step_Sister',
    'Adoptive_Father',
    'Adoptive_Mother',
    'Adopted_Son',
    'Adopted_Daughter',
    'Guardian',
    'Ward',
    'Other',
  ];

  static const Map<String, String> labels = {
    'Father': 'Father (पिता)',
    'Mother': 'Mother (माता)',
    'Son': 'Son (पुत्र / बेटा)',
    'Daughter': 'Daughter (पुत्री / बेटी)',
    'Brother': 'Brother (भाई)',
    'Sister': 'Sister (बहन)',
    'Sibling': 'Sibling (सहोदर भाई/बहन)',
    'Spouse': 'Spouse (पति/पत्नी)',
    'Husband': 'Husband (पति)',
    'Wife': 'Wife (पत्नी)',
    'Paternal_Grandfather': 'Paternal Grandfather (दादा)',
    'Paternal_Grandmother': 'Paternal Grandmother (दादी)',
    'Maternal_Grandfather': 'Maternal Grandfather (नाना)',
    'Maternal_Grandmother': 'Maternal Grandmother (नानी)',
    'Great_Grandfather': 'Great Grandfather (परदादा/परनाना)',
    'Great_Grandmother': 'Great Grandmother (परदादी/परनानी)',
    'Grandson': 'Grandson (पोता / नाती)',
    'Granddaughter': 'Granddaughter (पोती / नातिन)',
    'Great_Grandson': 'Great Grandson (परपोता)',
    'Great_Granddaughter': 'Great Granddaughter (परपोती)',
    'Paternal_Uncle_Elder': 'Paternal Uncle (Elder) (ताऊ)',
    'Paternal_Aunt_Elder': 'Paternal Aunt (Elder) (ताई)',
    'Paternal_Uncle_Younger': 'Paternal Uncle (Younger) (चाचा)',
    'Paternal_Aunt_Younger': 'Paternal Aunt (Younger) (चाची)',
    'Paternal_Aunt': 'Paternal Aunt (बुआ / फूफी)',
    'Paternal_Aunt_Husband': 'Paternal Aunt\'s Husband (फूफा)',
    'Maternal_Uncle': 'Maternal Uncle (मामा)',
    'Maternal_Uncle_Wife': 'Maternal Aunt (मामी)',
    'Maternal_Aunt': 'Maternal Aunt (मौसी)',
    'Maternal_Aunt_Husband': 'Maternal Aunt\'s Husband (मौसा)',
    'Uncle': 'Uncle (सामान्य चाचा/मामा)',
    'Aunt': 'Aunt (सामान्य चाची/मौसी/बुआ/मामी)',
    'Cousin_Brother': 'Cousin Brother (चचेरा/ममेरा भाई)',
    'Cousin_Sister': 'Cousin Sister (चचेरी/ममेरी बहन)',
    'Cousin': 'Cousin (कजिन)',
    'Nephew_Brother_Son': 'Nephew (Brother\'s Son) (भतीजा)',
    'Niece_Brother_Daughter': 'Niece (Brother\'s Daughter) (भतीजी)',
    'Nephew_Sister_Son': 'Nephew (Sister\'s Son) (भांजा)',
    'Niece_Sister_Daughter': 'Niece (Sister\'s Daughter) (भांजी)',
    'Nephew': 'Nephew (सामान्य भतीजा/भांजा)',
    'Niece': 'Niece (सामान्य भतीजी/भांजी)',
    'Father_In_Law': 'Father-in-Law (ससुर)',
    'Mother_In_Law': 'Mother-in-Law (सास)',
    'Son_In_Law': 'Son-in-Law (दामाद / जंवाई)',
    'Daughter_In_Law': 'Daughter-in-Law (बहू / पुत्रवधू)',
    'Brother_In_Law_Wife_Brother': 'Brother-in-Law (Wife\'s Brother) (साला)',
    'Sister_In_Law_Wife_Sister': 'Sister-in-Law (Wife\'s Sister) (साली)',
    'Brother_In_Law_Husband_Elder': 'Brother-in-Law (Husband\'s Elder Brother) (जेठ)',
    'Sister_In_Law_Husband_Elder_Wife': 'Sister-in-Law (Jeth\'s Wife) (जेठानी)',
    'Brother_In_Law_Husband_Younger': 'Brother-in-Law (Husband\'s Younger Brother) (देवर)',
    'Sister_In_Law_Husband_Younger_Wife': 'Sister-in-Law (Devar\'s Wife) (देवराणी)',
    'Sister_In_Law_Husband_Sister': 'Sister-in-Law (Husband\'s Sister) (ननद)',
    'Brother_In_Law_Husband_Sister_Husband': 'Brother-in-Law (Nanad\'s Husband) (नंदोई)',
    'Brother_In_Law_Sister_Husband': 'Brother-in-Law (Sister\'s Husband) (जीजा / बहनोई)',
    'Sister_In_Law_Brother_Wife': 'Sister-in-Law (Brother\'s Wife) (भाभी)',
    'Co_Father_In_Law': 'Co-Father-in-Law (समधी)',
    'Co_Mother_In_Law': 'Co-Mother-in-Law (समधन)',
    'Brother_In_Law': 'Brother-in-Law (सामान्य साला/जीजा/देवर)',
    'Sister_In_Law': 'Sister-in-Law (सामान्य साली/भाभी/ननद)',
    'Step_Father': 'Stepfather (सौतेला पिता)',
    'Step_Mother': 'Stepmother (सौतेली माता)',
    'Step_Son': 'Stepson (सौतेला बेटा)',
    'Step_Daughter': 'Stepdaughter (सौतेली बेटी)',
    'Step_Brother': 'Stepbrother (सौतेला भाई)',
    'Step_Sister': 'Stepsister (सौतेली बहन)',
    'Adoptive_Father': 'Adoptive Father (दत्तक पिता)',
    'Adoptive_Mother': 'Adoptive Mother (दत्तक माता)',
    'Adopted_Son': 'Adopted Son (दत्तक पुत्र)',
    'Adopted_Daughter': 'Adopted Daughter (दत्तक पुत्री)',
    'Guardian': 'Legal Guardian (संरक्षक)',
    'Ward': 'Ward (प्रतिपाल्य)',
    'Other': 'Other Relative (अन्य सम्बन्धी)',
  };

  static const Map<String, String> hindiLabels = {
    'Father': 'पिता',
    'Mother': 'माता',
    'Son': 'पुत्र',
    'Daughter': 'पुत्री',
    'Brother': 'भाई',
    'Sister': 'बहन',
    'Sibling': 'सहोदर',
    'Spouse': 'जीवनसाथी',
    'Husband': 'पति',
    'Wife': 'पत्नी',
    'Paternal_Grandfather': 'दादा',
    'Paternal_Grandmother': 'दादी',
    'Maternal_Grandfather': 'नाना',
    'Maternal_Grandmother': 'नानी',
    'Great_Grandfather': 'परदादा',
    'Great_Grandmother': 'परदादी',
    'Grandson': 'पोता',
    'Granddaughter': 'पोती',
    'Great_Grandson': 'परपोता',
    'Great_Granddaughter': 'परपोती',
    'Paternal_Uncle_Elder': 'ताऊ',
    'Paternal_Aunt_Elder': 'ताई',
    'Paternal_Uncle_Younger': 'चाचा',
    'Paternal_Aunt_Younger': 'चाची',
    'Paternal_Aunt': 'बुआ',
    'Paternal_Aunt_Husband': 'फूफा',
    'Maternal_Uncle': 'मामा',
    'Maternal_Uncle_Wife': 'मामी',
    'Maternal_Aunt': 'मौसी',
    'Maternal_Aunt_Husband': 'मौसा',
    'Uncle': 'चाचा / मामा',
    'Aunt': 'चाची / मौसी / बुआ',
    'Cousin_Brother': 'चचेरा / ममेरा भाई',
    'Cousin_Sister': 'चचेरी / ममेरी बहन',
    'Cousin': 'कजिन',
    'Nephew_Brother_Son': 'भतीजा',
    'Niece_Brother_Daughter': 'भतीजी',
    'Nephew_Sister_Son': 'भांजा',
    'Niece_Sister_Daughter': 'भांजी',
    'Nephew': 'भतीजा / भांजा',
    'Niece': 'भतीजी / भांजी',
    'Father_In_Law': 'ससुर',
    'Mother_In_Law': 'सास',
    'Son_In_Law': 'दामाद',
    'Daughter_In_Law': 'बहू',
    'Brother_In_Law_Wife_Brother': 'साला',
    'Sister_In_Law_Wife_Sister': 'साली',
    'Brother_In_Law_Husband_Elder': 'जेठ',
    'Sister_In_Law_Husband_Elder_Wife': 'जेठानी',
    'Brother_In_Law_Husband_Younger': 'देवर',
    'Sister_In_Law_Husband_Younger_Wife': 'देवराणी',
    'Sister_In_Law_Husband_Sister': 'ननद',
    'Brother_In_Law_Husband_Sister_Husband': 'नंदोई',
    'Brother_In_Law_Sister_Husband': 'जीजा',
    'Sister_In_Law_Brother_Wife': 'भाभी',
    'Co_Father_In_Law': 'समधी',
    'Co_Mother_In_Law': 'समधन',
    'Brother_In_Law': 'साला / जीजा / देवर',
    'Sister_In_Law': 'साली / भाभी / ननद',
    'Step_Father': 'सौतेला पिता',
    'Step_Mother': 'सौतेली माता',
    'Step_Son': 'सौतेला बेटा',
    'Step_Daughter': 'सौतेली बेटी',
    'Step_Brother': 'सौतेला भाई',
    'Step_Sister': 'सौतेली बहन',
    'Adoptive_Father': 'दत्तक पिता',
    'Adoptive_Mother': 'दत्तक माता',
    'Adopted_Son': 'दत्तक पुत्र',
    'Adopted_Daughter': 'दत्तक पुत्री',
    'Guardian': 'संरक्षक',
    'Ward': 'प्रतिपाल्य',
    'Other': 'अन्य सम्बन्धी',
  };

  static const Map<String, String> gujaratiLabels = {
    'Father': 'પિતા / બાપુજી',
    'Mother': 'માતા / બા',
    'Son': 'પુત્ર / દીકરો',
    'Daughter': 'પુત્રી / દીકરી',
    'Brother': 'ભાઈ',
    'Sister': 'બહેન',
    'Sibling': 'સહોદર (ભાઈ/બહેન)',
    'Spouse': 'જીવનસાથી',
    'Husband': 'પતિ',
    'Wife': 'પત્ની',
    'Paternal_Grandfather': 'દાદા (પિતાના પિતા)',
    'Paternal_Grandmother': 'દાદી (પિતાના માતા)',
    'Maternal_Grandfather': 'નાના (માતાના પિતા)',
    'Maternal_Grandmother': 'નાની (માતાના માતા)',
    'Great_Grandfather': 'પરદાદા / વડદાદા',
    'Great_Grandmother': 'પરદાદી / વડદાદી',
    'Grandson': 'પૌત્ર / દોહિત્ર',
    'Granddaughter': 'પૌત્રી / દોહિત્રી',
    'Great_Grandson': 'પરપૌત્ર',
    'Great_Granddaughter': 'પરપૌત્રી',
    'Paternal_Uncle_Elder': 'મોટા પપ્પા / મોટા બાપુ (તાઉ)',
    'Paternal_Aunt_Elder': 'મોટી મમ્મી / મોટી બા (તાઈ)',
    'Paternal_Uncle_Younger': 'કાકા',
    'Paternal_Aunt_Younger': 'કાકી',
    'Paternal_Aunt': 'ફોઈ',
    'Paternal_Aunt_Husband': 'ફૂવા',
    'Maternal_Uncle': 'મામા',
    'Maternal_Uncle_Wife': 'મામી',
    'Maternal_Aunt': 'માસી',
    'Maternal_Aunt_Husband': 'માસા',
    'Uncle': 'કાકા / મામા / ફૂવા / માસા',
    'Aunt': 'કાકી / મામી / ફોઈ / માસી',
    'Cousin_Brother': 'પિતરાઈ ભાઈ',
    'Cousin_Sister': 'પિતરાઈ બહેન',
    'Cousin': 'પિતરાઈ (કઝીન)',
    'Nephew_Brother_Son': 'ભત્રીજો',
    'Niece_Brother_Daughter': 'ભત્રીજી',
    'Nephew_Sister_Son': 'ભાણો',
    'Niece_Sister_Daughter': 'ભાણી',
    'Nephew': 'ભત્રીજો / ભાણો',
    'Niece': 'ભત્રીજી / ભાણી',
    'Father_In_Law': 'સસરા',
    'Mother_In_Law': 'સાસુ',
    'Son_In_Law': 'જમાઈ',
    'Daughter_In_Law': 'પુત્રવધૂ / વહુ',
    'Brother_In_Law_Wife_Brother': 'સાળો (પત્નીનો ભાઈ)',
    'Sister_In_Law_Wife_Sister': 'સાળી (પત્નીની બહેન)',
    'Brother_In_Law_Husband_Elder': 'જેઠ (પતિના મોટા ભાઈ)',
    'Sister_In_Law_Husband_Elder_Wife': 'જેઠાણી',
    'Brother_In_Law_Husband_Younger': 'દિયર (પતિના નાના ભાઈ)',
    'Sister_In_Law_Husband_Younger_Wife': 'દેરાણી',
    'Sister_In_Law_Husband_Sister': 'નણંદ (પતિની બહેન)',
    'Brother_In_Law_Husband_Sister_Husband': 'નણદોઈ (નણંદના પતિ)',
    'Brother_In_Law_Sister_Husband': 'બનેવી / જીજાજી',
    'Sister_In_Law_Brother_Wife': 'ભાભી',
    'Co_Father_In_Law': 'વેવાઈ',
    'Co_Mother_In_Law': 'વેવાણ',
    'Brother_In_Law': 'સાળો / બનેવી / દિયર / જેઠ',
    'Sister_In_Law': 'સાળી / ભાભી / નણંદ / જેઠાણી',
    'Step_Father': 'સાવકા પિતા',
    'Step_Mother': 'સાવકી માતા',
    'Step_Son': 'સાવકો દીકરો',
    'Step_Daughter': 'સાવકી દીકરી',
    'Step_Brother': 'સાવકો ભાઈ',
    'Step_Sister': 'સાવકી બહેન',
    'Adoptive_Father': 'દત્તક પિતા',
    'Adoptive_Mother': 'દત્તક માતા',
    'Adopted_Son': 'દત્તક પુત્ર',
    'Adopted_Daughter': 'દત્તક પુત્રી',
    'Guardian': 'વાલી / કાનૂની સંરક્ષક',
    'Ward': 'આશ્રિત / સંરક્ષિત વ્યક્તિ',
    'Other': 'અન્ય સંબંધી',
  };

  static const Map<String, String> marathiLabels = {
    'Father': 'वडील / बाबा',
    'Mother': 'आई',
    'Son': 'मुलगा / पुत्र',
    'Daughter': 'मुलगी / कन्या',
    'Brother': 'भाऊ',
    'Sister': 'बहीण',
    'Sibling': 'सहोदर (भाऊ/बहीण)',
    'Spouse': 'जोडीदार / पती-पत्नी',
    'Husband': 'पती / नवरा',
    'Wife': 'पत्नी / बायको',
    'Paternal_Grandfather': 'आजोबा (वडिलांचे वडील)',
    'Paternal_Grandmother': 'आजी (वडिलांची आई)',
    'Maternal_Grandfather': 'आजोबा (आईचे वडील)',
    'Maternal_Grandmother': 'आजी (आईची आई)',
    'Great_Grandfather': 'पणजोबा',
    'Great_Grandmother': 'पणजी',
    'Grandson': 'नातू',
    'Granddaughter': 'नात',
    'Great_Grandson': 'पणतू',
    'Great_Granddaughter': 'पणती',
    'Paternal_Uncle_Elder': 'मोठे काका',
    'Paternal_Aunt_Elder': 'मोठ्या काकू',
    'Paternal_Uncle_Younger': 'काका',
    'Paternal_Aunt_Younger': 'काकू',
    'Paternal_Aunt': 'आत्या',
    'Paternal_Aunt_Husband': 'मामा (आत्याचे पती)',
    'Maternal_Uncle': 'मामा',
    'Maternal_Uncle_Wife': 'मामी',
    'Maternal_Aunt': 'मावशी',
    'Maternal_Aunt_Husband': 'मावसा',
    'Uncle': 'काका / मामा / मावसा',
    'Aunt': 'काकू / मामी / आत्या / मावशी',
    'Cousin_Brother': 'चुलत/मामे/मावस भाऊ',
    'Cousin_Sister': 'चुलत/मामे/मावस बहीण',
    'Cousin': 'चुलतबहीण/भाऊ',
    'Nephew_Brother_Son': 'पुतण्या',
    'Niece_Brother_Daughter': 'पुतणी',
    'Nephew_Sister_Son': 'भाचा',
    'Niece_Sister_Daughter': 'भाची',
    'Nephew': 'पुतण्या / भाचा',
    'Niece': 'पुतणी / भाची',
    'Father_In_Law': 'सासरे',
    'Mother_In_Law': 'सासू',
    'Son_In_Law': 'जावई',
    'Daughter_In_Law': 'सून',
    'Brother_In_Law_Wife_Brother': 'मेहुणा (बायकोचा भाऊ)',
    'Sister_In_Law_Wife_Sister': 'मेहुणी (बायकोची बहीण)',
    'Brother_In_Law_Husband_Elder': 'दीर / जेठ (मोठे)',
    'Sister_In_Law_Husband_Elder_Wife': 'जाऊ (जेठाणी)',
    'Brother_In_Law_Husband_Younger': 'दीर (लहान)',
    'Sister_In_Law_Husband_Younger_Wife': 'जाऊ (देवराणी)',
    'Sister_In_Law_Husband_Sister': 'नणंद',
    'Brother_In_Law_Husband_Sister_Husband': 'नणंदोई',
    'Brother_In_Law_Sister_Husband': 'मेहुणा / दाजी',
    'Sister_In_Law_Brother_Wife': 'वहिनी',
    'Co_Father_In_Law': 'व्याही',
    'Co_Mother_In_Law': 'विहीण',
    'Brother_In_Law': 'मेहुणा / दीर / दाजी',
    'Sister_In_Law': 'मेहुणी / वहिनी / नणंद / जाऊ',
    'Step_Father': 'सावत्र वडील',
    'Step_Mother': 'सावत्र आई',
    'Step_Son': 'सावत्र मुलगा',
    'Step_Daughter': 'सावत्र मुलगी',
    'Step_Brother': 'सावत्र भाऊ',
    'Step_Sister': 'सावत्र बहीण',
    'Adoptive_Father': 'दत्तक वडील',
    'Adoptive_Mother': 'दत्तक आई',
    'Adopted_Son': 'दत्तक मुलगा',
    'Adopted_Daughter': 'दत्तक मुलगी',
    'Guardian': 'पालक / कायदेशीर संरक्षक',
    'Ward': 'पाल्य',
    'Other': 'इतर नातेवाईक',
  };

  static const Map<String, String> western = {
    'Father': 'Father',
    'Mother': 'Mother',
    'Son': 'Son',
    'Daughter': 'Daughter',
    'Brother': 'Brother',
    'Sister': 'Sister',
    'Sibling': 'Sibling',
    'Spouse': 'Spouse',
    'Husband': 'Husband',
    'Wife': 'Wife',
    'Paternal_Grandfather': 'Paternal Grandfather',
    'Paternal_Grandmother': 'Paternal Grandmother',
    'Maternal_Grandfather': 'Maternal Grandfather',
    'Maternal_Grandmother': 'Maternal Grandmother',
    'Great_Grandfather': 'Great Grandfather',
    'Great_Grandmother': 'Great Grandmother',
    'Grandson': 'Grandson',
    'Granddaughter': 'Granddaughter',
    'Great_Grandson': 'Great Grandson',
    'Great_Granddaughter': 'Great Granddaughter',
    'Paternal_Uncle_Elder': 'Paternal Uncle (Elder)',
    'Paternal_Aunt_Elder': 'Paternal Aunt (Elder)',
    'Paternal_Uncle_Younger': 'Paternal Uncle (Younger)',
    'Paternal_Aunt_Younger': 'Paternal Aunt (Younger)',
    'Paternal_Aunt': 'Paternal Aunt',
    'Paternal_Aunt_Husband': 'Paternal Uncle-in-Law',
    'Maternal_Uncle': 'Maternal Uncle',
    'Maternal_Uncle_Wife': 'Maternal Aunt-in-Law',
    'Maternal_Aunt': 'Maternal Aunt',
    'Maternal_Aunt_Husband': 'Maternal Uncle-in-Law',
    'Uncle': 'Uncle',
    'Aunt': 'Aunt',
    'Cousin_Brother': 'Male Cousin',
    'Cousin_Sister': 'Female Cousin',
    'Cousin': 'Cousin',
    'Nephew_Brother_Son': 'Nephew (Fraternal)',
    'Niece_Brother_Daughter': 'Niece (Fraternal)',
    'Nephew_Sister_Son': 'Nephew (Sororal)',
    'Niece_Sister_Daughter': 'Niece (Sororal)',
    'Nephew': 'Nephew',
    'Niece': 'Niece',
    'Father_In_Law': 'Father-in-Law',
    'Mother_In_Law': 'Mother-in-Law',
    'Son_In_Law': 'Son-in-Law',
    'Daughter_In_Law': 'Daughter-in-Law',
    'Brother_In_Law_Wife_Brother': 'Brother-in-Law (Wife\'s Brother)',
    'Sister_In_Law_Wife_Sister': 'Sister-in-Law (Wife\'s Sister)',
    'Brother_In_Law_Husband_Elder': 'Brother-in-Law (Husband\'s Elder Brother)',
    'Sister_In_Law_Husband_Elder_Wife': 'Sister-in-Law (Jethani)',
    'Brother_In_Law_Husband_Younger': 'Brother-in-Law (Husband\'s Younger Brother)',
    'Sister_In_Law_Husband_Younger_Wife': 'Sister-in-Law (Devrani)',
    'Sister_In_Law_Husband_Sister': 'Sister-in-Law (Husband\'s Sister)',
    'Brother_In_Law_Husband_Sister_Husband': 'Brother-in-Law (Nandoi)',
    'Brother_In_Law_Sister_Husband': 'Brother-in-Law (Sister\'s Husband)',
    'Sister_In_Law_Brother_Wife': 'Sister-in-Law (Brother\'s Wife)',
    'Co_Father_In_Law': 'Co-Father-in-Law',
    'Co_Mother_In_Law': 'Co-Mother-in-Law',
    'Brother_In_Law': 'Brother-in-Law',
    'Sister_In_Law': 'Sister-in-Law',
    'Step_Father': 'Stepfather',
    'Step_Mother': 'Stepmother',
    'Step_Son': 'Stepson',
    'Step_Daughter': 'Stepdaughter',
    'Step_Brother': 'Stepbrother',
    'Step_Sister': 'Stepsister',
    'Adoptive_Father': 'Adoptive Father',
    'Adoptive_Mother': 'Adoptive Mother',
    'Adopted_Son': 'Adopted Son',
    'Adopted_Daughter': 'Adopted Daughter',
    'Guardian': 'Legal Guardian',
    'Ward': 'Ward',
    'Other': 'Other Relative',
  };

  static const Map<String, String> indian = {
    'Father': 'पिता (Pita)',
    'Mother': 'माता (Mata)',
    'Son': 'पुत्र (Putra)',
    'Daughter': 'पुत्री (Putri)',
    'Brother': 'भाई (Bhai)',
    'Sister': 'बहन (Behan)',
    'Sibling': 'सहोदर (Sibling)',
    'Spouse': 'जीवनसाथी (Spouse)',
    'Husband': 'पति (Pati)',
    'Wife': 'पत्नी (Patni)',
    'Paternal_Grandfather': 'दादा (Dada)',
    'Paternal_Grandmother': 'दादी (Dadi)',
    'Maternal_Grandfather': 'नाना (Nana)',
    'Maternal_Grandmother': 'नानी (Nani)',
    'Great_Grandfather': 'परदादा (Pardada)',
    'Great_Grandmother': 'परदादी (Pardadi)',
    'Grandson': 'पोता / नाती (Grandson)',
    'Granddaughter': 'पोती / नातिन (Granddaughter)',
    'Great_Grandson': 'परपोता (Parpota)',
    'Great_Granddaughter': 'परपोती (Parpoti)',
    'Paternal_Uncle_Elder': 'ताऊ (Tau)',
    'Paternal_Aunt_Elder': 'ताई (Tai)',
    'Paternal_Uncle_Younger': 'चाचा (Chacha)',
    'Paternal_Aunt_Younger': 'चाची (Chachi)',
    'Paternal_Aunt': 'बुआ (Bua)',
    'Paternal_Aunt_Husband': 'फूफा (Phupha)',
    'Maternal_Uncle': 'मामा (Mama)',
    'Maternal_Uncle_Wife': 'मामी (Mami)',
    'Maternal_Aunt': 'मौसी (Mausi)',
    'Maternal_Aunt_Husband': 'मौसा (Mausa)',
    'Uncle': 'चाचा / मामा (Uncle)',
    'Aunt': 'चाची / मौसी / बुआ (Aunt)',
    'Cousin_Brother': 'चचेरा / ममेरा भाई (Cousin Brother)',
    'Cousin_Sister': 'चचेरी / ममेरी बहन (Cousin Sister)',
    'Cousin': 'कजिन (Cousin)',
    'Nephew_Brother_Son': 'भतीजा (Bhatija)',
    'Niece_Brother_Daughter': 'भतीजी (Bhatiji)',
    'Nephew_Sister_Son': 'भांजा (Bhanja)',
    'Niece_Sister_Daughter': 'भांजी (Bhanji)',
    'Nephew': 'भतीजा / भांजा (Nephew)',
    'Niece': 'भतीजी / भांजी (Niece)',
    'Father_In_Law': 'ससुर (Sasur)',
    'Mother_In_Law': 'सास (Saas)',
    'Son_In_Law': 'दामाद (Damad)',
    'Daughter_In_Law': 'बहू / पुत्रवधू (Bahu)',
    'Brother_In_Law_Wife_Brother': 'साला (Sala)',
    'Sister_In_Law_Wife_Sister': 'साली (Sali)',
    'Brother_In_Law_Husband_Elder': 'जेठ (Jeth)',
    'Sister_In_Law_Husband_Elder_Wife': 'जेठानी (Jethani)',
    'Brother_In_Law_Husband_Younger': 'देवर (Devar)',
    'Sister_In_Law_Husband_Younger_Wife': 'देवराणी (Devrani)',
    'Sister_In_Law_Husband_Sister': 'ननद (Nanad)',
    'Brother_In_Law_Husband_Sister_Husband': 'नंदोई (Nandoi)',
    'Brother_In_Law_Sister_Husband': 'जीजा / बहनोई (Jija)',
    'Sister_In_Law_Brother_Wife': 'भाभी (Bhabhi)',
    'Co_Father_In_Law': 'समधी (Samdhi)',
    'Co_Mother_In_Law': 'समधन (Samdhan)',
    'Brother_In_Law': 'साला / जीजा / देवर (Brother-in-Law)',
    'Sister_In_Law': 'साली / भाभी / ननद (Sister-in-Law)',
    'Step_Father': 'सौतेला पिता (Step Father)',
    'Step_Mother': 'सौतेली माता (Step Mother)',
    'Step_Son': 'सौतेला बेटा (Step Son)',
    'Step_Daughter': 'सौतेली बेटी (Step Daughter)',
    'Step_Brother': 'सौतेला भाई (Step Brother)',
    'Step_Sister': 'सौतेली बहन (Step Sister)',
    'Adoptive_Father': 'दत्तक पिता (Adoptive Father)',
    'Adoptive_Mother': 'दत्तक माता (Adoptive Mother)',
    'Adopted_Son': 'दत्तक पुत्र (Adopted Son)',
    'Adopted_Daughter': 'दत्तक पुत्री (Adopted Daughter)',
    'Guardian': 'संरक्षक (Guardian)',
    'Ward': 'प्रतिपाल्य (Ward)',
    'Other': 'अन्य सम्बन्धी (Other)',
  };

  static const Map<String, String> categories = {
    'Father': 'Nuclear',
    'Mother': 'Nuclear',
    'Son': 'Nuclear',
    'Daughter': 'Nuclear',
    'Brother': 'Nuclear',
    'Sister': 'Nuclear',
    'Sibling': 'Nuclear',
    'Spouse': 'Spousal',
    'Husband': 'Spousal',
    'Wife': 'Spousal',
    'Paternal_Grandfather': 'Ancestral',
    'Paternal_Grandmother': 'Ancestral',
    'Maternal_Grandfather': 'Ancestral',
    'Maternal_Grandmother': 'Ancestral',
    'Great_Grandfather': 'Ancestral',
    'Great_Grandmother': 'Ancestral',
    'Grandson': 'Descendant',
    'Granddaughter': 'Descendant',
    'Great_Grandson': 'Descendant',
    'Great_Granddaughter': 'Descendant',
    'Paternal_Uncle_Elder': 'Paternal_Extended',
    'Paternal_Aunt_Elder': 'Paternal_Extended',
    'Paternal_Uncle_Younger': 'Paternal_Extended',
    'Paternal_Aunt_Younger': 'Paternal_Extended',
    'Paternal_Aunt': 'Paternal_Extended',
    'Paternal_Aunt_Husband': 'Paternal_Extended',
    'Maternal_Uncle': 'Maternal_Extended',
    'Maternal_Uncle_Wife': 'Maternal_Extended',
    'Maternal_Aunt': 'Maternal_Extended',
    'Maternal_Aunt_Husband': 'Maternal_Extended',
    'Uncle': 'Extended_General',
    'Aunt': 'Extended_General',
    'Cousin_Brother': 'Extended_General',
    'Cousin_Sister': 'Extended_General',
    'Cousin': 'Extended_General',
    'Nephew_Brother_Son': 'Descendant_Extended',
    'Niece_Brother_Daughter': 'Descendant_Extended',
    'Nephew_Sister_Son': 'Descendant_Extended',
    'Niece_Sister_Daughter': 'Descendant_Extended',
    'Nephew': 'Descendant_Extended',
    'Niece': 'Descendant_Extended',
    'Father_In_Law': 'In_Laws',
    'Mother_In_Law': 'In_Laws',
    'Son_In_Law': 'In_Laws',
    'Daughter_In_Law': 'In_Laws',
    'Brother_In_Law_Wife_Brother': 'In_Laws',
    'Sister_In_Law_Wife_Sister': 'In_Laws',
    'Brother_In_Law_Husband_Elder': 'In_Laws',
    'Sister_In_Law_Husband_Elder_Wife': 'In_Laws',
    'Brother_In_Law_Husband_Younger': 'In_Laws',
    'Sister_In_Law_Husband_Younger_Wife': 'In_Laws',
    'Sister_In_Law_Husband_Sister': 'In_Laws',
    'Brother_In_Law_Husband_Sister_Husband': 'In_Laws',
    'Brother_In_Law_Sister_Husband': 'In_Laws',
    'Sister_In_Law_Brother_Wife': 'In_Laws',
    'Co_Father_In_Law': 'In_Laws',
    'Co_Mother_In_Law': 'In_Laws',
    'Brother_In_Law': 'In_Laws',
    'Sister_In_Law': 'In_Laws',
    'Step_Father': 'Step_Adoptive',
    'Step_Mother': 'Step_Adoptive',
    'Step_Son': 'Step_Adoptive',
    'Step_Daughter': 'Step_Adoptive',
    'Step_Brother': 'Step_Adoptive',
    'Step_Sister': 'Step_Adoptive',
    'Adoptive_Father': 'Step_Adoptive',
    'Adoptive_Mother': 'Step_Adoptive',
    'Adopted_Son': 'Step_Adoptive',
    'Adopted_Daughter': 'Step_Adoptive',
    'Guardian': 'Guardian',
    'Ward': 'Guardian',
    'Other': 'Other',
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
}
