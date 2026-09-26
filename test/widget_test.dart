import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:neumorophic/app/modules/auth/bindings/auth_binding.dart';
import 'package:neumorophic/app/modules/auth/views/auth_view.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    AuthBinding().dependencies();
  });

  tearDown(Get.reset);

  testWidgets('AuthView renders keypad numerals', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: AuthView()));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('tapping numerals appends to the field', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: AuthView()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
  });
}
