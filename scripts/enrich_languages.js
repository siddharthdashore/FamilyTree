const fs = require('fs');
const path = require('path');

const jsonPath = path.join(__dirname, '../shared/civil_models.json');
const data = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

data.supported_languages = [
  { code: "en", name: "English", native_name: "English", flag: "🇬🇧" },
  { code: "hi", name: "Hindi", native_name: "हिन्दी", flag: "🇮🇳" },
  { code: "gu", name: "Gujarati", native_name: "ગુજરાતી", flag: "🇮🇳" },
  { code: "mr", name: "Marathi", native_name: "मराठी", flag: "🇮🇳" }
];

const categoryTranslations = {
  GEN: { gu: "સામાન્ય", mr: "सामान्य" },
  OBC: { gu: "અન્ય પછાત વર્ગ (OBC)", mr: "इतर मागासवर्गीय (OBC)" },
  SC: { gu: "અનુસૂચિત જાતિ (SC)", mr: "अनुसूचित जाती (SC)" },
  ST: { gu: "અનુસૂચિત જનજાતિ (ST)", mr: "अनुसूचित जमाती (ST)" },
  EWS: { gu: "આર્થિક રીતે નબળા વર્ગ (EWS)", mr: "आर्थिकदृष्ट्या दुर्बल घटक (EWS)" },
  Other: { gu: "અન્ય વર્ગ", mr: "इतर वर्ग" }
};

const religionTranslations = {
  Hindu: { gu: "હિન્દુ", mr: "हिंदू" },
  Muslim: { gu: "મુસ્લિમ", mr: "मुस्लिम" },
  Christian: { gu: "ખ્રિસ્તી", mr: "ख्रिश्चन" },
  Sikh: { gu: "શીખ", mr: "शीख" },
  Jain: { gu: "જૈન", mr: "जैन" },
  Buddhist: { gu: "બૌદ્ધ", mr: "बौद्ध" },
  Parsi: { gu: "પારસી", mr: "पारशी" },
  Jewish: { gu: "યહૂદી", mr: "ज्यू / यहुदी" },
  Other: { gu: "અન્ય ધર્મ", mr: "इतर धर्म" }
};

const maritalTranslations = {
  Single: { gu: "અવિવાહિત", mr: "अविवाहित" },
  Married: { gu: "પરણિત / વિવાહિત", mr: "विवाहित" },
  Widowed: { gu: "વિધવા / વિધુર", mr: "विधवा / विधुर" },
  Divorced: { gu: "છૂટાછેડા લીધેલ", mr: "घटस्फोटित" },
  Separated: { gu: "અલગ થયેલ", mr: "विभक्त" }
};

const bloodGroupTranslations = {
  "A+": { gu: "એ પોઝિટિવ (A+)", mr: "ए पॉझिटिव्ह (A+)" },
  "A-": { gu: "એ નેગેટિવ (A-)", mr: "ए निगेटिव्ह (A-)" },
  "B+": { gu: "બી પોઝિટિવ (B+)", mr: "बी पॉझिटिव्ह (B+)" },
  "B-": { gu: "બી નેગેટિવ (B-)", mr: "बी निगेटिव्ह (B-)" },
  "AB+": { gu: "એબી પોઝિટિવ (AB+)", mr: "एबी पॉझिटिव्ह (AB+)" },
  "AB-": { gu: "એબી નેગેટિવ (AB-)", mr: "एबी निगेटिव्ह (AB-)" },
  "O+": { gu: "ઓ પોઝિટિવ (O+)", mr: "ओ पॉझिटिव्ह (O+)" },
  "O-": { gu: "ઓ નેગેટિવ (O-)", mr: "ओ निगेटिव्ह (O-)" }
};

const genderTranslations = {
  Male: { gu: "પુરુષ", mr: "पुरुष" },
  Female: { gu: "સ્ત્રી / મહિલા", mr: "स्त्री / महिला" },
  "Non-Binary": { gu: "નોન-બાઈનરી", mr: "नॉन-बायनरी" },
  Transgender: { gu: "ટ્રાન્સજેન્ડર", mr: "तृतीयपंथी / ट्रान्सजेंडर" },
  Other: { gu: "અન્ય", mr: "इतर" }
};

const qualificationTranslations = {
  Primary: { gu: "પ્રાથમિક શિક્ષણ (1-5)", mr: "प्राथमिक शिक्षण (1-5)" },
  Secondary_10th: { gu: "માધ્યમિક (10મું / SSC)", mr: "माध्यमिक (10वी / SSC)" },
  HigherSecondary_12th: { gu: "ઉચ્ચતર માધ્યમિક (12મું / HSC)", mr: "उच्च माध्यमिक (12वी / HSC)" },
  Diploma: { gu: "ડિપ્લોમા / ટેકનિકલ", mr: "पदविका / डिप्लोमा" },
  Bachelors: { gu: "સ્નાતક (બેચલર્સ ડિગ્રી)", mr: "पदवी (ग्रॅज्युएट)" },
  Masters: { gu: "અનુસ્નાતક (માસ્ટર્સ ડિગ્રી)", mr: "व्युत्पन्न पदवी (पोस्ट ग्रॅज्युएट)" },
  Doctorate: { gu: "ડોક્ટરેટ (Ph.D.)", mr: "विद्यावाचस्पती (Ph.D.)" },
  Professional_CA_CS: { gu: "વ્યવસાયિક લાયકાત (CA, CS)", mr: "व्यावसायिक प्रमाणपत्र (CA, CS)" },
  Other: { gu: "અન્ય લાયકાત", mr: "इतर शिक्षण" }
};

const occupationTranslations = {
  Government: { gu: "સરકારી સેવા / અધિકારી", mr: "शासकीय सेवा / अधिकारी" },
  Private_IT_Corporate: { gu: "ખાનગી / આઈટી અને કોર્પોરેટ", mr: "खाजगी / आयटी व कॉर्पोरेट" },
  Healthcare: { gu: "તબીબી અને આરોગ્ય સેવા (ડોક્ટર, નર્સ)", mr: "आरोग्य व वैद्यकीय सेवा (डॉक्टर, परिचारिका)" },
  Banking_Finance: { gu: "બેંકિંગ અને નાણાકીય સેવા", mr: "बँकिंग व वित्तीय सेवा" },
  Defense_Police: { gu: "સંરક્ષણ દળ અને પોલીસ", mr: "संरक्षण व पोलीस दल" },
  Education_Research: { gu: "શિક્ષણ અને વૈજ્ઞાનિક સંશોધન", mr: "शिक्षण व वैज्ञानिक संशोधन" },
  Business_SelfEmployed: { gu: "વેપાર / સ્વરોજગાર / ઉદ્યોગ", mr: "व्यवसाय / स्वयंरोजगार / उद्योग" },
  Agriculture: { gu: "ખેતીવાડી / કૃષિ વ્યવસાય", mr: "शेती व कृषी व्यवसाय" },
  Student: { gu: "વિદ્યાર્થી / અભ્યાસ", mr: "विद्यार्थी / शिक्षणार्थी" },
  Homemaker: { gu: "ગૃહિણી / પરિવાર સંભાળ", mr: "गृहिणी / कौटुंबिक व्यवस्थापक" },
  Other: { gu: "અન્ય વ્યવસાય", mr: "इतर व्यवसाय" }
};

const docTypeTranslations = {
  AADHAAR: { gu: "આધાર કાર્ડ", mr: "आधार कार्ड" },
  PAN: { gu: "પાન કાર્ડ", mr: "पॅन कार्ड" },
  VOTER_ID: { gu: "ચૂંટણી ઓળખપત્ર (મતદાર કાર્ડ)", mr: "मतदार ओळखपत्र" },
  DRIVING_LICENSE: { gu: "ડ્રાઇવિંગ લાયસન્સ", mr: "वाहन चालक परवाना" },
  PASSPORT: { gu: "ભારતીય પાસપોર્ટ", mr: "पारपत्र / पासपोर्ट" },
  RATION_CARD: { gu: "રેશન કાર્ડ", mr: "शिधापत्रिका / रेशन कार्ड" },
  BIRTH_CERTIFICATE: { gu: "જન્મ પ્રમાણપત્ર", mr: "जन्म दाखला / प्रमाणपत्र" },
  BIOMETRIC: { gu: "બાયોમેટ્રિક રેકોર્ડ", mr: "बायोमेट्रिक नोंद" }
};

const relationshipTranslations = {
  Father: { gu: "પિતા / બાપુજી", mr: "वडील / बाबा" },
  Mother: { gu: "માતા / બા", mr: "आई" },
  Son: { gu: "પુત્ર / દીકરો", mr: "मुलगा / पुत्र" },
  Daughter: { gu: "પુત્રી / દીકરી", mr: "मुलगी / कन्या" },
  Brother: { gu: "ભાઈ", mr: "भाऊ" },
  Sister: { gu: "બહેન", mr: "बहीण" },
  Sibling: { gu: "સહોદર (ભાઈ/બહેન)", mr: "सहोदर (भाऊ/बहीण)" },
  Spouse: { gu: "જીવનસાથી", mr: "जोडीदार / पती-पत्नी" },
  Husband: { gu: "પતિ", mr: "पती / नवरा" },
  Wife: { gu: "પત્ની", mr: "पत्नी / बायको" },

  Paternal_Grandfather: { gu: "દાદા (પિતાના પિતા)", mr: "आजोबा (वडिलांचे वडील)" },
  Paternal_Grandmother: { gu: "દાદી (પિતાના માતા)", mr: "आजी (वडिलांची आई)" },
  Maternal_Grandfather: { gu: "નાના (માતાના પિતા)", mr: "आजोबा (आईचे वडील)" },
  Maternal_Grandmother: { gu: "નાની (માતાના માતા)", mr: "आजी (आईची आई)" },
  Great_Grandfather: { gu: "પરદાદા / વડદાદા", mr: "पणजोबा" },
  Great_Grandmother: { gu: "પરદાદી / વડદાદી", mr: "पणजी" },

  Grandson: { gu: "પૌત્ર / દોહિત્ર", mr: "नातू" },
  Granddaughter: { gu: "પૌત્રી / દોહિત્રી", mr: "नात" },
  Great_Grandson: { gu: "પરપૌત્ર", mr: "पणतू" },
  Great_Granddaughter: { gu: "પરપૌત્રી", mr: "पणती" },

  Paternal_Uncle_Elder: { gu: "મોટા પપ્પા / મોટા બાપુ (તાઉ)", mr: "मोठे काका" },
  Paternal_Aunt_Elder: { gu: "મોટી મમ્મી / મોટી બા (તાઈ)", mr: "मोठ्या काकू" },
  Paternal_Uncle_Younger: { gu: "કાકા", mr: "काका" },
  Paternal_Aunt_Younger: { gu: "કાકી", mr: "काकू" },
  Paternal_Aunt: { gu: "ફોઈ", mr: "आत्या" },
  Paternal_Aunt_Husband: { gu: "ફૂવા", mr: "मामा (आत्याचे पती)" },

  Maternal_Uncle: { gu: "મામા", mr: "मामा" },
  Maternal_Uncle_Wife: { gu: "મામી", mr: "मामी" },
  Maternal_Aunt: { gu: "માસી", mr: "मावशी" },
  Maternal_Aunt_Husband: { gu: "માસા", mr: "मावसा" },

  Uncle: { gu: "કાકા / મામા / ફૂવા / માસા", mr: "काका / मामा / मावसा" },
  Aunt: { gu: "કાકી / મામી / ફોઈ / માસી", mr: "काकू / मामी / आत्या / मावशी" },

  Cousin_Brother: { gu: "પિતરાઈ ભાઈ", mr: "चुलत/मामे/मावस भाऊ" },
  Cousin_Sister: { gu: "પિતરાઈ બહેન", mr: "चुलत/मामे/मावस बहीण" },
  Cousin: { gu: "પિતરાઈ (કઝીન)", mr: "चुलतबहीण/भाऊ" },

  Nephew_Brother_Son: { gu: "ભત્રીજો", mr: "पुतण्या" },
  Niece_Brother_Daughter: { gu: "ભત્રીજી", mr: "पुतणी" },
  Nephew_Sister_Son: { gu: "ભાણો", mr: "भाचा" },
  Niece_Sister_Daughter: { gu: "ભાણી", mr: "भाची" },
  Nephew: { gu: "ભત્રીજો / ભાણો", mr: "पुतण्या / भाचा" },
  Niece: { gu: "ભત્રીજી / ભાણી", mr: "पुतणी / भाची" },

  Father_In_Law: { gu: "સસરા", mr: "सासरे" },
  Mother_In_Law: { gu: "સાસુ", mr: "सासू" },
  Son_In_Law: { gu: "જમાઈ", mr: "जावई" },
  Daughter_In_Law: { gu: "પુત્રવધૂ / વહુ", mr: "सून" },
  Brother_In_Law_Wife_Brother: { gu: "સાળો (પત્નીનો ભાઈ)", mr: "मेहुणा (बायकोचा भाऊ)" },
  Sister_In_Law_Wife_Sister: { gu: "સાળી (પત્નીની બહેન)", mr: "मेहुणी (बायकोची बहीण)" },
  Brother_In_Law_Husband_Elder: { gu: "જેઠ (પતિના મોટા ભાઈ)", mr: "दीर / जेठ (मोठे)" },
  Sister_In_Law_Husband_Elder_Wife: { gu: "જેઠાણી", mr: "जाऊ (जेठाणी)" },
  Brother_In_Law_Husband_Younger: { gu: "દિયર (પતિના નાના ભાઈ)", mr: "दीर (लहान)" },
  Sister_In_Law_Husband_Younger_Wife: { gu: "દેરાણી", mr: "जाऊ (देवराणी)" },
  Sister_In_Law_Husband_Sister: { gu: "નણંદ (પતિની બહેન)", mr: "नणंद" },
  Brother_In_Law_Husband_Sister_Husband: { gu: "નણદોઈ (નણંદના પતિ)", mr: "नणंदोई" },
  Brother_In_Law_Sister_Husband: { gu: "બનેવી / જીજાજી", mr: "मेहुणा / दाजी" },
  Sister_In_Law_Brother_Wife: { gu: "ભાભી", mr: "वहिनी" },
  Co_Father_In_Law: { gu: "વેવાઈ", mr: "व्याही" },
  Co_Mother_In_Law: { gu: "વેવાણ", mr: "विहीण" },
  Brother_In_Law: { gu: "સાળો / બનેવી / દિયર / જેઠ", mr: "मेहुणा / दीर / दाजी" },
  Sister_In_Law: { gu: "સાળી / ભાભી / નણંદ / જેઠાણી", mr: "मेहुणी / वहिनी / नणंद / जाऊ" },

  Step_Father: { gu: "સાવકા પિતા", mr: "सावत्र वडील" },
  Step_Mother: { gu: "સાવકી માતા", mr: "सावत्र आई" },
  Step_Son: { gu: "સાવકો દીકરો", mr: "सावत्र मुलगा" },
  Step_Daughter: { gu: "સાવકી દીકરી", mr: "सावत्र मुलगी" },
  Step_Brother: { gu: "સાવકો ભાઈ", mr: "सावत्र भाऊ" },
  Step_Sister: { gu: "સાવકી બહેન", mr: "सावत्र बहीण" },
  Adoptive_Father: { gu: "દત્તક પિતા", mr: "दत्तक वडील" },
  Adoptive_Mother: { gu: "દત્તક માતા", mr: "दत्तक आई" },
  Adopted_Son: { gu: "દત્તક પુત્ર", mr: "दत्तक मुलगा" },
  Adopted_Daughter: { gu: "દત્તક પુત્રી", mr: "दत्तक मुलगी" },

  Guardian: { gu: "વાલી / કાનૂની સંરક્ષક", mr: "पालक / कायदेशीर संरक्षक" },
  Ward: { gu: "આશ્રિત / સંરક્ષિત વ્યક્તિ", mr: "पाल्य" },
  Other: { gu: "અન્ય સંબંધી", mr: "इतर नातेवाईक" }
};

function enrichList(list, translations) {
  for (const item of list) {
    const t = translations[item.code] || { gu: item.label, mr: item.label };
    item.gujarati_label = t.gu;
    item.marathi_label = t.mr;
  }
}

enrichList(data.categories, categoryTranslations);
enrichList(data.religions, religionTranslations);
enrichList(data.marital_statuses, maritalTranslations);
enrichList(data.blood_groups, bloodGroupTranslations);
enrichList(data.genders, genderTranslations);
enrichList(data.qualifications, qualificationTranslations);
enrichList(data.occupations, occupationTranslations);
enrichList(data.document_types, docTypeTranslations);
enrichList(data.relationships, relationshipTranslations);

fs.writeFileSync(jsonPath, JSON.stringify(data, null, 2), 'utf8');
console.log('✅ Successfully enriched shared/civil_models.json with English, Hindi, Gujarati, and Marathi translations!');
