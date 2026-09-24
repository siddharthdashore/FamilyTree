import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Citizen Registration'),
        actions: [
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
              Text('Personal Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name *'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name *'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
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
                      items: ['Male', 'Female', 'Non-Binary', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'DOB (YYYY-MM-DD) *',
                        hintText: '1998-05-18',
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
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
                      items: ['GEN', 'OBC', 'SC', 'ST', 'EWS']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _casteController,
                      decoration: const InputDecoration(labelText: 'Caste (Optional)'),
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
                      decoration: const InputDecoration(labelText: 'Height (cm)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Residential Address', style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _isLoadingLocation ? null : _autofillLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                    label: const Text('Autofill GPS'),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addr1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1 (House/Street) *'),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addr2Controller,
                decoration: const InputDecoration(labelText: 'Address Line 2 (Locality/Area)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'PIN Code *'),
                      validator: (v) => v!.trim().length != 6 ? '6 Digits' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(labelText: 'District *'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
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
                      decoration: const InputDecoration(labelText: 'State *'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Country'),
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
                      : const Text('Register & Allocate 12-Digit VUID'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
