import 'package:flutter/material.dart';
import '../widgets/vansha_card_widget.dart';

class CardViewScreen extends StatelessWidget {
  final String vuid;
  final String fullName;
  final String dob;
  final String gender;
  final String category;
  final String state;

  const CardViewScreen({
    super.key,
    required this.vuid,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.category,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = VanshaCardWidget(
      vuid: vuid,
      fullName: fullName,
      dob: dob,
      gender: gender,
      category: category,
      state: state,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vansha Card Credential'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Card',
            onPressed: () {
              VanshaCardSharer().captureAndShareWhatsApp(
                context: context,
                cardWidget: cardWidget,
                vuid: vuid,
                fullName: fullName,
              );
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              cardWidget,
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share Card via WhatsApp'),
                onPressed: () {
                  VanshaCardSharer().captureAndShareWhatsApp(
                    context: context,
                    cardWidget: cardWidget,
                    vuid: vuid,
                    fullName: fullName,
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.account_tree),
                label: const Text('View Lineage Canvas'),
                onPressed: () {
                  Navigator.pushNamed(context, '/tree', arguments: vuid);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
