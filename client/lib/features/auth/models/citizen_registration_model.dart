class CitizenRegistrationModel {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String gender;
  final String dob;
  final double? heightCm;
  final double? weightKg;
  final String? caste;
  final String category;
  final String addressLine1;
  final String? addressLine2;
  final String pinCode;
  final String district;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;

  CitizenRegistrationModel({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.gender,
    required this.dob,
    this.heightCm,
    this.weightKg,
    this.caste,
    this.category = 'GEN',
    required this.addressLine1,
    this.addressLine2,
    required this.pinCode,
    required this.district,
    required this.state,
    this.country = 'India',
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'gender': gender,
      'dob': dob,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'caste': caste,
      'category': category,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'pin_code': pinCode,
      'district': district,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class RegisteredCitizen {
  final String vuid;
  final String formattedVuid;
  final String fullName;
  final String gender;
  final String category;
  final String registeredAt;

  RegisteredCitizen({
    required this.vuid,
    required this.formattedVuid,
    required this.fullName,
    required this.gender,
    required this.category,
    required this.registeredAt,
  });

  factory RegisteredCitizen.fromJson(Map<String, dynamic> json) {
    return RegisteredCitizen(
      vuid: json['vuid'] ?? '',
      formattedVuid: json['formatted_vuid'] ?? json['vuid'] ?? '',
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? 'Male',
      category: json['category'] ?? 'GEN',
      registeredAt: json['registered_at'] ?? '',
    );
  }
}
