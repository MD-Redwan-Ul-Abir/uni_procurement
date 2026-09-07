import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_procurement/core/widgets/app_switch.dart';

void main() {
  group('AppSwitch & AppSwitchListTile Cupertino Tests', () {
    testWidgets('AppSwitch renders CupertinoSwitch and toggles value', (tester) async {
      bool switchValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppSwitch(
                  value: switchValue,
                  onChanged: (val) {
                    setState(() {
                      switchValue = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify that Apple's CupertinoSwitch is rendered
      expect(find.byType(CupertinoSwitch), findsOneWidget);

      // Tap the switch
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      // Verify toggled
      expect(switchValue, isTrue);
    });

    testWidgets('AppSwitchListTile renders CupertinoSwitch with title and subtitle', (tester) async {
      bool switchValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppSwitchListTile(
                  title: 'Require 3 Minimum Responsive Quotations',
                  subtitle: 'Comparison matrix requirement',
                  value: switchValue,
                  onChanged: (val) {
                    setState(() {
                      switchValue = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify texts and CupertinoSwitch are present
      expect(find.text('Require 3 Minimum Responsive Quotations'), findsOneWidget);
      expect(find.text('Comparison matrix requirement'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsOneWidget);

      // Tap the tile to toggle
      await tester.tap(find.text('Require 3 Minimum Responsive Quotations'));
      await tester.pumpAndSettle();

      expect(switchValue, isTrue);
    });
  });
}
