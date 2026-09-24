import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';

class MatrimonySearchScreen extends ConsumerStatefulWidget {
  const MatrimonySearchScreen({super.key});

  @override
  ConsumerState<MatrimonySearchScreen> createState() => _MatrimonySearchScreenState();
}

class _MatrimonySearchScreenState extends ConsumerState<MatrimonySearchScreen> {
  String _lookingForGender = 'Female'; // Bride (वधू) or Groom (वर)
  RangeValues _ageRange = const RangeValues(21, 35);
  final _gotraController = TextEditingController(text: 'Bharadwaj');
  String _selectedState = 'Madhya Pradesh';
  String _selectedCategory = 'All';

  bool _isLoading = false;
  List<dynamic> _candidates = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _gotraController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final payload = {
        'looking_for_gender': _lookingForGender,
        'min_age': _ageRange.start.round(),
        'max_age': _ageRange.end.round(),
        'seeker_gotra': _gotraController.text.trim(),
        'state': _selectedState == 'All' ? null : _selectedState,
        'category': _selectedCategory == 'All' ? null : _selectedCategory,
      };

      final response = await client.post(ApiEndpoints.matrimonySearch, body: payload);
      setState(() {
        _candidates = response['candidates'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VanshaSetu Matrimony & Lineage Match', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _performSearch,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                    : _candidates.isEmpty
                        ? const Center(child: Text('No matching candidate profiles found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _candidates.length,
                            itemBuilder: (ctx, idx) => _buildCandidateCard(_candidates[idx]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender Segmented Buttons
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Female', label: Text('Bride (वधू)'), icon: Icon(Icons.female)),
                    ButtonSegment(value: 'Male', label: Text('Groom (वर)'), icon: Icon(Icons.male)),
                  ],
                  selected: {_lookingForGender},
                  onSelectionChanged: (val) {
                    setState(() => _lookingForGender = val.first);
                    _performSearch();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Age Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Age: ${_ageRange.start.round()} - ${_ageRange.end.round()} yrs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Gotra: ${_gotraController.text.trim()} (Exogamy Check)', style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
            ],
          ),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 55,
            divisions: 37,
            labels: RangeLabels('${_ageRange.start.round()}', '${_ageRange.end.round()}'),
            onChanged: (vals) => setState(() => _ageRange = vals),
            onChangeEnd: (_) => _performSearch(),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final bool isSagotra = candidate['is_sagotra'] == true;
    final edu = candidate['education'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSagotra ? Colors.amber.withAlpha(120) : const Color(0xFF38BDF8).withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: candidate['gender'] == 'Female' ? const Color(0xFFF472B6) : const Color(0xFF38BDF8),
                  child: Text(
                    candidate['full_name'] != null && candidate['full_name'].toString().isNotEmpty
                        ? candidate['full_name'][0]
                        : 'V',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              candidate['full_name'] ?? 'Candidate',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (candidate['is_ocp_verified'] == true)
                            const Chip(
                              label: Text('VERIFIED', style: TextStyle(fontSize: 9, color: Colors.greenAccent)),
                              backgroundColor: Color(0xFF064E3B),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${candidate['age']} Yrs • ${candidate['height_cm'] ?? 165} cm • ${candidate['marital_status']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'VUID: ${candidate['formatted_vuid']}',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Gotra & Community Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  avatar: const Icon(Icons.account_tree, size: 14),
                  label: Text('Gotra: ${candidate['gotra'] ?? 'N/A'}', style: const TextStyle(fontSize: 11)),
                ),
                Chip(
                  avatar: const Icon(Icons.group, size: 14),
                  label: Text('${candidate['caste']} (${candidate['category']})', style: const TextStyle(fontSize: 11)),
                ),
                Chip(
                  avatar: const Icon(Icons.location_on, size: 14),
                  label: Text('${candidate['district']}, ${candidate['state']}', style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Education & Profession Info
            if (edu != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 18, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${edu['degree_name']} • ${edu['profession_title'] ?? 'Professional'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Gotra Exogamy Badge & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSagotra ? Colors.amber.withAlpha(30) : Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSagotra ? Colors.amber : Colors.greenAccent),
                  ),
                  child: Text(
                    isSagotra ? '⚠️ Sagotra Alert (सगोत्र)' : '✅ Exogamous Match (विवाह योग्य)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSagotra ? Colors.amber : Colors.greenAccent,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/tree', arguments: candidate['vuid']);
                  },
                  icon: const Icon(Icons.account_tree, size: 16),
                  label: const Text('Trace Lineage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
