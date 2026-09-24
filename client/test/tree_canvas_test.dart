import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanshasetu/features/tree/screens/tree_canvas_screen.dart';
import 'package:vanshasetu/features/tree/models/tree_graph_model.dart';

void main() {
  group('TreeCanvasScreen & KinshipLinePainter Tests', () {
    testWidgets('Renders Lineage Canvas app bar, action buttons, and canvas container', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TreeCanvasScreen(rootVuid: '109284729102'),
          ),
        ),
      );

      // Verify App Bar & Actions
      expect(find.text('VanshaSetu Lineage Canvas'), findsOneWidget);
      expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    test('KinshipLinePainter: Repaint evaluates to true on layout updates', () {
      final node1 = TreeCitizenNode(
        vuid: '109284729102',
        formattedVuid: '1092 8472 9102',
        name: 'Kailash Sharma',
        gender: 'Male',
        dob: '1948-03-12',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Active',
        position: const Offset(100, 100),
      );

      final node2 = TreeCitizenNode(
        vuid: '510928340192',
        formattedVuid: '5109 2834 0192',
        name: 'Ramesh Sharma',
        gender: 'Male',
        dob: '1972-07-24',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Active',
        position: const Offset(100, 250),
      );

      final edge = KinshipEdge(
        source: '109284729102',
        target: '510928340192',
        type: 'Father',
        status: 'Mutual_Confirmed',
      );

      final painter1 = KinshipLinePainter(nodes: [node1, node2], edges: [edge]);
      final painter2 = KinshipLinePainter(nodes: [node1], edges: []);

      expect(painter1.shouldRepaint(painter2), true);
    });
  });
}
