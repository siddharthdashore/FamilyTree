import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  bool _isLoading = false;
  List<dynamic> _logs = [];
  String? _errorMessage;
  bool? _isChainValid;

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
    _verifyIntegrity();
  }

  Future<void> _fetchAuditLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('${ApiEndpoints.auditLogs}?limit=40');
      setState(() {
        _logs = response['logs'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyIntegrity() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get(ApiEndpoints.auditVerifyIntegrity);
      setState(() {
        _isChainValid = response['success'] == true;
      });
    } catch (_) {
      setState(() => _isChainValid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Immutable HIPAA Audit Trail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchAuditLogs();
              _verifyIntegrity();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Integrity Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _isChainValid == true ? const Color(0xFF064E3B) : const Color(0xFF451A03),
            child: Row(
              children: [
                Icon(
                  _isChainValid == true ? Icons.verified_user : Icons.warning_amber,
                  color: _isChainValid == true ? Colors.greenAccent : Colors.amberAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isChainValid == true
                        ? 'HIPAA § 164.312(b) SHA-256 Hash Chain: INTACT (100% Tamper-Free)'
                        : 'Verifying Cryptographic Blockchain Integrity...',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                    : _logs.isEmpty
                        ? const Center(child: Text('No audit events logged yet.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _logs.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                            itemBuilder: (ctx, idx) => _buildAuditTile(_logs[idx]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTile(Map<String, dynamic> log) {
    final action = log['action'] ?? 'UNKNOWN';
    final isSuccess = log['status'] == 'SUCCESS';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getActionColor(action).withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getActionColor(action)),
                  ),
                  child: Text(
                    action,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getActionColor(action)),
                  ),
                ),
                Text(
                  log['created_at'] != null ? log['created_at'].toString().split('T').first : 'Today',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Actor: ${log['actor_vuid'] ?? 'SYSTEM'}  |  Target: ${log['resource_type']} (${log['resource_id']})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'IP Address: ${log['ip_address']}  •  Status: ${isSuccess ? 'SUCCESS' : 'DENIED'}',
              style: TextStyle(fontSize: 11, color: isSuccess ? Colors.greenAccent : Colors.redAccent),
            ),
            const SizedBox(height: 6),
            // Cryptographic Log Hash Badge
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 14, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Hash: ${log['log_hash']?.toString().substring(0, 24)}...',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'BIRTH_REGISTRATION':
        return Colors.greenAccent;
      case 'DEATH_REGISTRATION':
        return Colors.purpleAccent;
      case 'MARRIAGE_REGISTRATION':
        return const Color(0xFFF472B6);
      case 'MATRIMONY_SEARCH':
        return Colors.amberAccent;
      case 'EDUCATION_UPDATE':
        return const Color(0xFF38BDF8);
      case 'VERIFY_OCP':
        return Colors.tealAccent;
      case 'SIR_FLAG':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }
}
