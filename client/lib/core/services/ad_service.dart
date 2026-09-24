import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  // Monetization is disabled initially for a clean, completely free DPI launch
  bool isMonetizationEnabled = false;

  Future<void> initialize() async {
    if (isMonetizationEnabled) {
      try {
        await MobileAds.instance.initialize();
      } catch (_) {}
    }
  }

  void toggleMonetization(bool enable) {
    isMonetizationEnabled = enable;
    if (enable) {
      try {
        MobileAds.instance.initialize();
      } catch (_) {}
    }
  }
}
