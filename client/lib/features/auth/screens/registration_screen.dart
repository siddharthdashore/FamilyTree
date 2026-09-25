import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/civil_models.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/services/geo_service.dart';
import '../models/citizen_registration_model.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _casteController = TextEditingController();
  final _gotraController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Location Controllers
  final _addr1Controller = TextEditingController();
  final _addr2Controller = TextEditingController();
  final _pinController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  String _gender = 'Male';
  String _category = 'GEN';
  String _religion = 'Hindu';
  String _maritalStatus = 'Single';
  String? _bloodGroup;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _casteController.dispose();
    _gotraController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _addr1Controller.dispose();
    _addr2Controller.dispose();
    _pinController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _autofillLocation() async {
    setState(() => _isLoadingLocation = true);
    final result = await GeoService.fetchLiveAddress();
    setState(() => _isLoadingLocation = false);

    if (result != null) {
      setState(() {
        _addr1Controller.text = result.addressLine1;
        _addr2Controller.text = result.addressLine2;
        _pinController.text = result.pinCode;
        _districtController.text = result.district;
        _stateController.text = result.state;
        _countryController.text = result.country;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address autofetched from live GPS coordinates.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch live GPS address. Please enter manually.')),
        );
      }
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final model = CitizenRegistrationModel(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: _gender,
      dob: _dobController.text.trim(),
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      caste: _casteController.text.trim().isEmpty ? null : _casteController.text.trim(),
      category: _category,
      gotra: _gotraController.text.trim().isEmpty ? null : _gotraController.text.trim(),
      religion: _religion,
      maritalStatus: _maritalStatus,
      bloodGroup: _bloodGroup,
      addressLine1: _addr1Controller.text.trim(),
      addressLine2: _addr2Controller.text.trim().isEmpty ? null : _addr2Controller.text.trim(),
      pinCode: _pinController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    final citizen = await ref.read(authProvider.notifier).registerCitizen(model);

    if (citizen != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Registration Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Allocated 12-Digit VUID:'),
              const SizedBox(height: 8),
              SelectableText(
                citizen.formattedVuid,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(height: 12),
              Text('Citizen Name: ${citizen.fullName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(
                  context,
                  '/card',
                  arguments: {
                    'vuid': citizen.vuid,
                    'fullName': citizen.fullName,
                    'dob': _dobController.text.trim(),
                    'gender': citizen.gender,
                    'category': citizen.category,
                    'state': _stateController.text.trim(),
                  },
                );
              },
              child: const Text('View Vansha Card'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final loc = AppLocalizations(currentLocale);
    final currentLang = currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('reg_title')),
        actions: [
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.account_tree),
            tooltip: 'View Sample Tree',
            onPressed: () {
              Navigator.pushNamed(context, '/tree', arguments: '109284729102');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (authState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(38),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    authState.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              Text(loc.translate('personal_details'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: '${loc.translate('first_name')} *'),
                      validator: (v) => v!.trim().isEmpty ? loc.translate('required') : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: '${loc.translate('last_name')} *'),
                      validator: (v) => v!.trim().isEmpty ? loc.translate('required') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      isExpanded: true,
                      items: CivilGenders.all
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(CivilGenders.getLocalizedLabel(g, currentLang)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                      decoration: InputDecoration(labelText: loc.translate('gender')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: '${loc.translate('dob_label')} *',
                        hintText: '1998-05-18',
                      ),
                      validator: (v) => v!.trim().isEmpty ? loc.translate('required') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      isExpanded: true,
                      items: CivilCategories.all
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(CivilCategories.getLocalizedLabel(c, currentLang)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      decoration: InputDecoration(labelText: loc.translate('category')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _casteController,
                      decoration: InputDecoration(labelText: loc.translate('caste_optional')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: loc.translate('height_cm')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: loc.translate('weight_kg')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gotraController,
                      decoration: InputDecoration(
                        labelText: loc.translate('gotra'),
                        hintText: currentLang == 'hi' || currentLang == 'mr'
                            ? 'भारद्वाज / कश्यप'
                            : (currentLang == 'gu' ? 'ભારદ્વાજ / કશ્યપ' : 'Bharadwaj / Kashyap'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _religion,
                      isExpanded: true,
                      items: CivilReligions.all
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(CivilReligions.getLocalizedLabel(r, currentLang)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _religion = v!),
                      decoration: InputDecoration(labelText: loc.translate('religion')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _maritalStatus,
                      isExpanded: true,
                      items: CivilMaritalStatuses.all
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(CivilMaritalStatuses.getLocalizedLabel(m, currentLang)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _maritalStatus = v!),
                      decoration: InputDecoration(labelText: loc.translate('marital_status')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      isExpanded: true,
                      items: CivilBloodGroups.all
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _bloodGroup = v),
                      decoration: InputDecoration(labelText: loc.translate('blood_group')),
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.translate('residential_address'), style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _isLoadingLocation ? null : _autofillLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                    label: Text(loc.translate('autofill_gps_label')),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addr1Controller,
                decoration: InputDecoration(labelText: '${loc.translate('address_line1_label')} *'),
                validator: (v) => v!.trim().isEmpty ? loc.translate('required') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addr2Controller,
                decoration: InputDecoration(labelText: loc.translate('address_line2_label')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '${loc.translate('pin_code_req')} *'),
                      validator: (v) => v!.trim().length != 6 ? loc.translate('six_digits') : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: InputDecoration(labelText: '${loc.translate('district')} *'),
                      validator: (v) => v!.trim().isEmpty ? loc.translate('required') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(labelText: '${loc.translate('state')} *'),
                      validator: (v) => v!.trim().isEmpty ? loc.translate('required') : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: InputDecoration(labelText: loc.translate('country')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: authState.isLoading ? null : _submitRegistration,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(loc.translate('submit_registration_btn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
