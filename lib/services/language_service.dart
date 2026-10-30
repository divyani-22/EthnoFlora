import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();
  factory LanguageService() => instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  String _currentLanguage = _defaultLanguage;

  String get currentLanguageCode => _currentLanguage;
  bool get isHindi => _currentLanguage == 'hi';
  String get currentLanguageName => isHindi ? 'Hindi (हिंदी)' : 'English';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_languageKey);
      if (saved != null) {
        if (saved == 'hi' || saved.toLowerCase().contains('hindi')) {
          _currentLanguage = 'hi';
        } else {
          _currentLanguage = 'en';
        }
      }
      notifyListeners();
    } catch (e) {
      _currentLanguage = _defaultLanguage;
    }
  }

  Future<String> getCurrentLanguage() async {
    return currentLanguageName;
  }

  Future<void> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final normalized = (language == 'hi' || language.toLowerCase().contains('hindi')) ? 'hi' : 'en';
      _currentLanguage = normalized;
      await prefs.setString(_languageKey, normalized);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleLanguage() async {
    final next = isHindi ? 'en' : 'hi';
    await setLanguage(next);
  }

  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi (हिंदी)', 'native': 'हिंदी'},
    ];
  }

  String tr(String key) {
    if (!isHindi) return key;
    return _hindiTranslations[key] ?? key;
  }

  static String t(String key) => instance.tr(key);

  static final Map<String, String> _hindiTranslations = {
    // Navigation
    'Home': 'होम',
    'EthnoCollab': 'एथ्नोकोलैब',
    'BioRepository': 'बायोरेपॉजिटरी',
    'EthnoRadar': 'एथ्नोरडार',
    'PhytoIntel': 'फाइटोइंटेक्स',
    'PhytoDoc AI': 'फाइटोदॉक एआई',
    'Flora Coins': 'फ्लोरा कॉइन्स',

    // App Branding & Headers
    'EthnoFlora AI': 'एथ्नोफ्लोरा एआई',
    'ETHNORADAR': 'एथ्नोरडार',
    'ETHNORADAR RADAR': 'एथ्नोरडार',
    'ETHNORADAR PROOF': 'एथ्नोरडार सत्यापन',
    'EthnoRadar Radar': 'एथ्नोरडार',
    'Campus Action Radar': 'कैंपस एक्शन रडार',
    'Daily Quizzes': 'दैनिक क्विज़',
    'Leaderboard': 'लीडरबोर्ड',
    'Eco Quests': 'इको खोज',
    'Flora Coins': 'फ्लोरा कॉइन्स',
    'Flora Coins Pool': 'फ्लोरा कॉइन्स पूल',
    'Weekly Target': 'साप्ताहिक लक्ष्य',
    'Kg CO₂ Saved': 'किग्रा CO₂ बचत',
    'Total Impact Score': 'कुल प्रभाव स्कोर',
    'Active Hubs': 'सक्रिय केंद्र',
    'Active Zones': 'सक्रिय ज़ोन',
    'Active Today': 'आज सक्रिय',
    'REAL-TIME ECO-ZONES': 'रीयल-टाइम इको-ज़ोन',
    'Tap to Conquer': 'जीतने के लिए टैप करें',
    'Campus Community Activity': 'कैंपस समुदाय गतिविधि',
    'Connect, share & compete': 'जुड़ें, साझा करें और आगे बढ़ें',
    'Take 15-min eco quiz': '15 मिनट का इको क्विज़ खेलें',
    'Earn +100 Coins': '+100 क्रेडिट्स अर्जित करें',
    'Earn +100 Credits': '+100 क्रेडिट्स अर्जित करें',
    'Explore Campus Action Hubs': 'कैंपस एक्शन हब्स देखें',
    '5 Active Hubs': '5 सक्रिय केंद्र',
    'BioRepository Market': 'बायोरेपॉजिटरी बाज़ार',
    'Exchange eco gear & items': 'वानस्पतिक पौधे और सामग्री बदलें',
    'Free Campus Swap': 'मुफ़्त बायो स्वैप',
    'PhytoDoc AI Tutor': 'फाइटोदॉक एआई ट्यूटर',
    'PhytoDoc AI AI Tutor': 'फाइटोदॉक एआई ट्यूटर',
    'Ask anything about climate': 'पौधों और जलवायु के बारे में कुछ भी पूछें',
    'Ask anything about flora & remedies': 'वानस्पतिक प्रजातियों और पारंपरिक उपयोगों के बारे में पूछें',
    '24/7 Green AI': '24/7 फाइटोदॉक एआई',
    '24/7 PhytoDoc AI': '24/7 फाइटोदॉक एआई',

    // Greetings
    'Hey, ': 'नमस्ते, ',
    'Hey': 'नमस्ते',
    'Welcome back': 'वापसी पर स्वागत है',

    // Settings
    'Settings': 'सेटिंग्स',
    'APP PREFERENCES': 'ऐप प्राथमिकताएं',
    'Language': 'भाषा',
    'Select Language': 'भाषा चुनें',
    'Dark Mode': 'डार्क मोड',
    'Push Notifications': 'पुश सूचनाएं',
    'Sound Effects': 'ध्वनि प्रभाव',
    'ACCOUNT & PRIVACY': 'खाता और गोपनीयता',
    'Edit Profile': 'प्रोफ़ाइल संपादित करें',
    'Privacy & Permissions': 'गोपनीयता और अनुमतियां',
    'Data usage and location sharing preferences': 'डेटा उपयोग और स्थान साझाकरण प्राथमिकताएं',
    'COMMUNITY & VERIFICATION': 'समुदाय और सत्यापन',
    'Verification History': 'सत्यापन इतिहास',
    'Track campus action proofs and review logs': 'कैंपस कार्रवाई प्रमाण और समीक्षा लॉग ट्रैक करें',
    'Impact Badges': 'प्रभाव बैज',
    'View earned sustainability accolades': 'अर्जित स्थिरता पुरस्कार देखें',
    'SUPPORT & LEGAL': 'सहायता और कानूनी',
    'Help & FAQs': 'सहायता और अक्सर पूछे जाने वाले प्रश्न',
    'Terms of Service': 'सेवा की शर्तें',
    'Privacy Policy': 'गोपनीयता नीति',
    'Log Out': 'लॉग आउट',
    'Delete Account': 'खाता हटाएं',
    'Are you sure you want to log out?': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
    'English': 'English',
    'Hindi (हिंदी)': 'हिंदी (Hindi)',

    // Actions & Buttons
    'Complete': 'पूर्ण',
    'Verify 📸': 'सत्यापित करें 📸',
    'Verify': 'सत्यापित करें',
    'Open Camera 📸': 'कैमरा खोलें 📸',
    'Choose from Gallery 🖼️': 'गैलरी से चुनें 🖼️',
    'Submit Proof for AI Verification': 'एआई सत्यापन के लिए प्रमाण भेजें',
    'Retake Photo': 'फिर से फ़ोटो लें',
    'Dismiss Hub': 'हब बंद करें',
    'Back to EthnoRadar': 'एथ्नोरडार पर लौटें',
    'Back to EthnoRadar Radar': 'एथ्नोरडार पर लौटें',
    'Confirm': 'पुष्टि करें',
    'Cancel': 'रद्द करें',
    'Save': 'सहेजें',
    'Take Action': 'कार्यवाही करें',
    'View Full Map': 'पूरा नक्शा देखें',
    'Start Quiz': 'क्विज़ शुरू करें',
    'Submit': 'जमा करें',
    'Share': 'साझा करें',
    'Like': 'पसंद करें',
    'Comment': 'टिप्पणी करें',
    'Search': 'खोजें',

    // Verification steps & Modals
    'MISSION VERIFIED!': 'मिशन सत्यापित!',
    'ACTION QUEST': 'कार्रवाई खोज',
    'VERIFICATION REQUIRED': 'सत्यापन आवश्यक',
    'Camera Proof & AI Verification': 'कैमरा प्रमाण और एआई सत्यापन',
    'Capture live photo proof of this action at': 'इस कार्रवाई का लाइव फ़ोटो प्रमाण लें:',
    'Verifying mission coordinates & time stamps...': 'मिशन निर्देशांक और समय टिकट सत्यापित किए जा रहे हैं...',
    'Analyzing botanical fidelity with EthnoFlora AI...': 'एथ्नोफ्लोरा एआई द्वारा वानस्पतिक प्रामाणिकता का विश्लेषण...',
    'Analyzing ecological fidelity with EthnoFlora AI AI...': 'एथ्नोफ्लोरा एआई द्वारा वानस्पतिक प्रामाणिकता का विश्लेषण...',
    'Scanning for verified campus sustainability markers...': 'सत्यापित कैंपस वानस्पतिक चिह्नों की जांच...',
    'Botanical Action Validated! +50 Flora Coins': 'वानस्पतिक कार्रवाई मान्य! +50 फ्लोरा कॉइन्स',
    'Climate Action Validated! +50 Flora Coins': 'वानस्पतिक कार्रवाई मान्य! +50 फ्लोरा कॉइन्स',

    // Language Toggles
    'Switch to Hindi': 'हिंदी में बदलें',
    'Switch to English': 'अंग्रेजी में बदलें',
    'Language switched to Hindi': 'भाषा बदलकर हिंदी कर दी गई है 🇮🇳',
    'Language switched to English': 'Language switched to English 🌿',

    // Profile & Levels
    'Level': 'स्तर',
    'Eco Warrior': 'पर्यावरण योद्धा',
    'Flora Champion': 'फ्लोरा चैंपियन',
    'Rank': 'रैंक',
    'Points': 'अंक',
    'Badges': 'बैज',
    'Missions': 'मिशन',
    'Streak': 'लगातार दिन',
    'Days': 'दिन',
  };
}

extension LanguageExtension on String {
  String get tr => LanguageService.instance.tr(this);
}
