import 'package:flutter_test/flutter_test.dart';
import 'package:vanshasetu/core/services/ad_service.dart';
import 'package:vanshasetu/core/services/geo_service.dart';

void main() {
  group('Core Services Tests', () {
    test('AdService: Defaults to monetization disabled for clean DPI launch', () {
      final adService = AdService.instance;
      expect(adService.isMonetizationEnabled, false);

      // Toggle enable and verify
      adService.toggleMonetization(true);
      expect(adService.isMonetizationEnabled, true);

      // Toggle back to disabled
      adService.toggleMonetization(false);
      expect(adService.isMonetizationEnabled, false);
    });

    test('AddressAutofillResult: Instantiates and retains all geographic properties', () {
      final address = AddressAutofillResult(
        addressLine1: '42 Heritage Enclave',
        addressLine2: 'Civil Lines',
        pinCode: '452001',
        district: 'Indore',
        state: 'Madhya Pradesh',
        country: 'India',
        latitude: 22.7196,
        longitude: 75.8577,
      );

      expect(address.addressLine1, '42 Heritage Enclave');
      expect(address.addressLine2, 'Civil Lines');
      expect(address.pinCode, '452001');
      expect(address.district, 'Indore');
      expect(address.state, 'Madhya Pradesh');
      expect(address.country, 'India');
      expect(address.latitude, 22.7196);
      expect(address.longitude, 75.8577);
    });
  });
}
