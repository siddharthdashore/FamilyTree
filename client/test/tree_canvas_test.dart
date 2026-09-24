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

    test('Leaf Node Color Logic: Blue for male, pink for female, gray if died, purple for others', () {
      final maleNode = TreeCitizenNode(
        vuid: '100000000001',
        formattedVuid: '1000 0000 0001',
        name: 'Amit Sharma',
        gender: 'Male',
        dob: '1990-01-01',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Active',
      );

      final femaleNode = TreeCitizenNode(
        vuid: '100000000002',
        formattedVuid: '1000 0000 0002',
        name: 'Priya Sharma',
        gender: 'Female',
        dob: '1992-05-15',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Active',
      );

      final deceasedMaleNode = TreeCitizenNode(
        vuid: '100000000003',
        formattedVuid: '1000 0000 0003',
        name: 'Kailash Sharma',
        gender: 'Male',
        dob: '1945-03-12',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Deceased',
      );

      final deceasedFemaleNode = TreeCitizenNode(
        vuid: '100000000004',
        formattedVuid: '1000 0000 0004',
        name: 'Savitri Sharma',
        gender: 'Female',
        dob: '1948-07-20',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Deceased',
      );

      final nonBinaryNode = TreeCitizenNode(
        vuid: '100000000005',
        formattedVuid: '1000 0000 0005',
        name: 'Alex Sharma',
        gender: 'Non-Binary',
        dob: '1998-11-30',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Active',
      );

      final transgenderNode = TreeCitizenNode(
        vuid: '100000000006',
        formattedVuid: '1000 0000 0006',
        name: 'Sam Sharma',
        gender: 'Transgender',
        dob: '1995-04-10',
        category: 'GEN',
        isVerified: true,
        isClaimed: true,
        status: 'Active',
      );

      // Verify Color Rules
      expect(TreeCanvasScreen.getNodeColor(maleNode), const Color(0xFF2563EB), reason: 'Male must be blue');
      expect(TreeCanvasScreen.getNodeColor(femaleNode), const Color(0xFFEC4899), reason: 'Female must be pink');
      expect(TreeCanvasScreen.getNodeColor(deceasedMaleNode), const Color(0xFF6B7280), reason: 'Died must be gray');
      expect(TreeCanvasScreen.getNodeColor(deceasedFemaleNode), const Color(0xFF6B7280), reason: 'Died must be gray');
      expect(TreeCanvasScreen.getNodeColor(nonBinaryNode), const Color(0xFFA855F7), reason: 'Other genders must be purple');
      expect(TreeCanvasScreen.getNodeColor(transgenderNode), const Color(0xFFA855F7), reason: 'Other genders must be purple');

      // Verify Avatar Assets
      expect(TreeCanvasScreen.getAvatarAsset(maleNode), 'assets/images/male_avatar.jpg');
      expect(TreeCanvasScreen.getAvatarAsset(femaleNode), 'assets/images/female_avatar.jpg');
      expect(TreeCanvasScreen.getAvatarAsset(deceasedMaleNode), 'assets/images/deceased_avatar.jpg');
      expect(TreeCanvasScreen.getAvatarAsset(nonBinaryNode), 'assets/images/other_avatar.jpg');
    });
  });
}
