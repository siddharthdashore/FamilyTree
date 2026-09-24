import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VanshaCardWidget extends StatelessWidget {
  final String vuid; // Strict 12-digit numeric identifier
  final String fullName;
  final String dob;
  final String gender;
  final String category;
  final String state;

  const VanshaCardWidget({
    super.key,
    required this.vuid,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.category,
    required this.state,
  });

  String get formattedVuid {
    if (vuid.length == 12) {
      return '${vuid.substring(0, 4)} ${vuid.substring(4, 8)} ${vuid.substring(8, 12)}';
    }
    return vuid;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586, // ISO/IEC 7810 ID-1 standard ratio
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VANSHACARD • वन्श कार्ड',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        formattedVuid,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(51),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: const Text(
                    'OCP VERIFIED',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('DOB: $dob  |  Gender: $gender', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      Text('Category: $category  |  State: $state', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: QrImageView(
                    data: 'https://vanshasetu.in/tree/$vuid',
                    version: QrVersions.auto,
                    size: 52.0,
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Unified Kinship Infrastructure',
                    style: TextStyle(color: Colors.white38, fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Scan to Trace Lineage',
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VanshaCardSharer {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> captureAndShareWhatsApp({
    required BuildContext context,
    required Widget cardWidget,
    required String vuid,
    required String fullName,
  }) async {
    try {
      final imageBytes = await screenshotController.captureFromWidget(
        Material(child: cardWidget),
        delay: const Duration(milliseconds: 100),
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/VanshaCard_$vuid.png').create();
      await file.writeAsBytes(imageBytes);

      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Namaste! Here is my official Vansha Card for $fullName (VUID: $vuid). Scan the QR code or visit https://vanshasetu.in/tree/$vuid to trace our complete family tree.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share Vansha Card: $e')),
        );
      }
    }
  }
}
