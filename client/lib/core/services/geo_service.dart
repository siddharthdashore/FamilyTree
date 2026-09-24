import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddressAutofillResult {
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String district;
  final String state;
  final String country;
  final double latitude;
  final double longitude;

  AddressAutofillResult({
    required this.addressLine1,
    required this.addressLine2,
    required this.pinCode,
    required this.district,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class GeoService {
  static Future<AddressAutofillResult?> fetchLiveAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return null;
    final place = placemarks.first;

    return AddressAutofillResult(
      addressLine1: '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim(),
      addressLine2: place.subLocality ?? place.locality ?? '',
      pinCode: place.postalCode ?? '',
      district: place.subAdministrativeArea ?? place.locality ?? '',
      state: place.administrativeArea ?? '',
      country: place.country ?? 'India',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
