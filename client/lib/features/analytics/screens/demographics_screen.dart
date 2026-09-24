import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';

class DemographicsScreen extends ConsumerStatefulWidget {
  const DemographicsScreen({super.key});

  @override
  ConsumerState<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends ConsumerState<DemographicsScreen> {
  String _selectedState = 'Madhya Pradesh';
  String _selectedCategory = 'All';
  String _selectedGender = 'All';
  String _selectedMaritalStatus = 'All';

  bool _isLoading = false;
  Map<String, dynamic>? _analyticsData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDemographics();
  }

  Future<void> _fetchDemographics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final queryParams = <String, String>{};
      if (_selectedState != 'All') queryParams['state'] = _selectedState;
      if (_selectedCategory != 'All') queryParams['category'] = _selectedCategory;
      if (_selectedGender != 'All') queryParams['gender'] = _selectedGender;
      if (_selectedMaritalStatus != 'All') queryParams['marital_status'] = _selectedMaritalStatus;

      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final url = '${ApiEndpoints.analyticsDemographics}${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await client.get(url);
      setState(() {
        _analyticsData = response;
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
        title: const Text('National Demographic & Census Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Analytics',
            onPressed: _fetchDemographics,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterCard(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _fetchDemographics, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_analyticsData != null)
              _buildAnalyticsDashboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_alt, size: 20, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Text('Demographic Filter Criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(labelText: 'State / Territory', isDense: true),
                    items: ['All', 'Madhya Pradesh', 'Karnataka', 'Maharashtra', 'Delhi', 'Uttar Pradesh']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedState = v!);
                      _fetchDemographics();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', isDense: true),
                    items: ['All', 'GEN', 'OBC', 'SC', 'ST', 'EWS']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedCategory = v!);
                      _fetchDemographics();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender', isDense: true),
                    items: ['All', 'Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedGender = v!);
                      _fetchDemographics();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMaritalStatus,
                    decoration: const InputDecoration(labelText: 'Marital Status', isDense: true),
                    items: ['All', 'Single', 'Married', 'Widowed', 'Divorced']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedMaritalStatus = v!);
                      _fetchDemographics();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    final total = _analyticsData!['total_population'] ?? 0;
    final gender = _analyticsData!['gender_distribution'] ?? {};
    final agePyramid = _analyticsData!['age_distribution'] ?? {};
    final categories = _analyticsData!['social_categories'] ?? {};
    final adoption = _analyticsData!['digital_adoption'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Population Hero Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL FILTERED POPULATION', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              Text(
                '$total Citizens',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.verified, size: 16, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    '${adoption['claimed_percentage'] ?? 0}% Claimed & OCP Verified',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Gender Distribution Card
        Text('Gender Ratio Distribution', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Male (पुरुष)',
                count: '${gender['male'] ?? 0}',
                icon: Icons.male,
                color: const Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Female (महिला)',
                count: '${gender['female'] ?? 0}',
                icon: Icons.female,
                color: const Color(0xFFF472B6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Age Pyramid
        Text('Age Demographics Pyramid', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBarRow('Children (0 - 14 yrs)', agePyramid['children_0_14'] ?? 0, total, Colors.amber),
                const SizedBox(height: 10),
                _buildBarRow('Youth (15 - 24 yrs)', agePyramid['youth_15_24'] ?? 0, total, Colors.blueAccent),
                const SizedBox(height: 10),
                _buildBarRow('Working Age (25 - 59 yrs)', agePyramid['adults_25_59'] ?? 0, total, Colors.greenAccent),
                const SizedBox(height: 10),
                _buildBarRow('Seniors (60+ yrs)', agePyramid['seniors_60_plus'] ?? 0, total, Colors.purpleAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Social Categories
        Text('Social Category Breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBarRow('General (GEN)', categories['GEN'] ?? 0, total, Colors.teal),
                const SizedBox(height: 10),
                _buildBarRow('Other Backward Classes (OBC)', categories['OBC'] ?? 0, total, Colors.cyan),
                const SizedBox(height: 10),
                _buildBarRow('Scheduled Castes (SC)', categories['SC'] ?? 0, total, Colors.deepOrangeAccent),
                const SizedBox(height: 10),
                _buildBarRow('Scheduled Tribes (ST)', categories['ST'] ?? 0, total, Colors.indigoAccent),
                const SizedBox(height: 10),
                _buildBarRow('Economically Weaker Section (EWS)', categories['EWS'] ?? 0, total, Colors.pinkAccent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({required String title, required String count, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withAlpha(40), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBarRow(String label, int count, int total, Color color) {
    final double ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('$count (${(ratio * 100).toStringAsFixed(1)}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
