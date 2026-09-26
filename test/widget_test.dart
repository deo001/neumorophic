import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:neumorophic/app/core/auth/auth_service.dart';
import 'package:neumorophic/app/core/bindings/app_binding.dart';
import 'package:neumorophic/app/core/neumorphic.dart';
import 'package:neumorophic/app/modules/auth/bindings/auth_binding.dart';
import 'package:neumorophic/app/modules/auth/controllers/auth_controller.dart';
import 'package:neumorophic/app/modules/auth/views/auth_view.dart';
import 'package:neumorophic/app/modules/shell/views/shell_view.dart';
import 'package:neumorophic/app/routes/app_pages.dart';

/// Taps the numeral key showing [label] on the keypad.
Future<void> tapNumeral(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
}

void main() {
  setUp(() {
    Get.testMode = true;
    AuthBinding().dependencies();
  });

  tearDown(Get.reset);

  Future<void> pumpAuth(WidgetTester tester) async {
    // Uses the real route table and app binding so navigation and the session
    // service under test match the app.
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: AppBinding(),
        initialRoute: Routes.AUTH,
        getPages: AppPages.routes,
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the PIN form with an empty slot', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Enter your 4-digit PIN to continue'), findsOneWidget);
    expect(find.byType(NeumorphicDots), findsOneWidget);
    expect(find.byType(AuthView), findsOneWidget);

    final controller = Get.find<AuthController>();
    expect(controller.pin.value, isEmpty);
  });

  testWidgets('keypad shows digits 0-9 once each', (WidgetTester tester) async {
    await pumpAuth(tester);

    for (final label in <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      expect(find.text(label), findsOneWidget, reason: 'key $label missing');
    }

    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
  });

  testWidgets('digits fill the masked dots without revealing the PIN', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    await tapNumeral(tester, '1');
    await tapNumeral(tester, '3');

    final controller = Get.find<AuthController>();
    expect(controller.pin.value, '13');

    // The entered PIN must never be rendered as readable text.
    expect(find.text('13'), findsNothing);

    final dots = tester.widget<NeumorphicDots>(find.byType(NeumorphicDots));
    expect(dots.filled, 2);
    expect(dots.total, AuthController.pinLength);
  });

  testWidgets('backspace removes the last digit', (WidgetTester tester) async {
    await pumpAuth(tester);

    await tapNumeral(tester, '2');
    await tapNumeral(tester, '5');

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(Get.find<AuthController>().pin.value, '2');
  });

  testWidgets('long press on backspace clears every digit', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    await tapNumeral(tester, '2');
    await tapNumeral(tester, '5');

    await tester.longPress(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(Get.find<AuthController>().pin.value, isEmpty);
  });

  testWidgets('a fifth digit is rejected once the PIN is full', (
    WidgetTester tester,
  ) async {
    final controller = Get.find<AuthController>();
    // Fill without triggering the auto-submit path.
    controller.inputNumber(1);
    controller.inputNumber(2);
    controller.inputNumber(3);
    controller.inputNumber(4);

    controller.inputNumber(5);
    await tester.pump();

    expect(controller.pin.value, '1234');

    // No widget tree here, so pumpAndSettle has no frames to wait on. Advance
    // past the 900ms verification, then past the 420ms reject sequence.
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('correct PIN 2580 signs in and opens the shell', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    for (final digit in AuthController.validPin.split('')) {
      await tapNumeral(tester, digit);
    }

    await tester.pumpAndSettle();

    expect(find.byType(ShellView), findsOneWidget);
    expect(find.byType(AuthView), findsNothing);
    expect(Get.find<AuthService>().isLoggedIn.value, isTrue);
  });

  testWidgets('wrong PIN shakes, shows an error and clears the field', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    final controller = Get.find<AuthController>();
    for (final digit in '1111'.split('')) {
      await tapNumeral(tester, digit);
    }

    await tester.pumpAndSettle();

    // Still on the auth screen: the PIN was refused.
    expect(find.byType(AuthView), findsOneWidget);
    expect(find.byType(ShellView), findsNothing);
    expect(find.text('Incorrect PIN, please try again'), findsOneWidget);
    expect(controller.hasError.value, isTrue);
    expect(controller.shakeToken.value, 1);
    // Entry is cleared so the next attempt starts clean.
    expect(controller.pin.value, isEmpty);
    // A refused PIN must not create a session.
    expect(Get.find<AuthService>().isLoggedIn.value, isFalse);
  });

  testWidgets('digits entered during verification are ignored', (
    WidgetTester tester,
  ) async {
    await pumpAuth(tester);

    final controller = Get.find<AuthController>();
    for (final digit in '1111'.split('')) {
      await tapNumeral(tester, digit);
    }

    // Mid-verification the pad is disabled and the controller drops input.
    controller.inputNumber(9);
    await tester.pump();

    expect(controller.isLoading.value, isTrue);
    expect(controller.pin.value, '1111');

    await tester.pumpAndSettle();
  });
}
