import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';
import 'package:uni_procurement/core/utils/app_toast.dart';

void main() {
  group('AppToast Toastification 3.2.0 Tests', () {
    testWidgets('AppToast renders Toastification notifications properly', (tester) async {
      await tester.pumpWidget(
        ToastificationWrapper(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          AppToast.success(
                            title: 'Operation Success',
                            description: 'Everything went smoothly.',
                            context: context,
                          );
                        },
                        child: const Text('Show Success'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          AppToast.error(
                            title: 'Operation Failed',
                            description: 'An error occurred.',
                            context: context,
                          );
                        },
                        child: const Text('Show Error'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Trigger success toast
      final item = AppToast.success(
        title: 'Operation Success',
        description: 'Everything went smoothly.',
        context: tester.element(find.text('Show Success')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(toastification.findToastificationItem(item.id), isNotNull);
      expect(item.id.isNotEmpty, isTrue);

      // Trigger error toast
      final errorItem = AppToast.error(
        title: 'Operation Failed',
        description: 'An error occurred.',
        context: tester.element(find.text('Show Error')),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(toastification.findToastificationItem(errorItem.id), isNotNull);
      expect(errorItem.id.isNotEmpty, isTrue);

      // Clean up toastification timers
      toastification.dismissAll(delayForAnimation: false);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
