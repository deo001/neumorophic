import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:neumorophic/app/core/auth/auth_service.dart';
import 'package:neumorophic/app/core/bindings/app_binding.dart';
import 'package:neumorophic/app/modules/auth/views/auth_view.dart';
import 'package:neumorophic/app/modules/home/views/home_view.dart';
import 'package:neumorophic/app/modules/more_services/views/more_services_view.dart';
import 'package:neumorophic/app/modules/shell/controllers/shell_controller.dart';
import 'package:neumorophic/app/modules/shell/views/shell_view.dart';
import 'package:neumorophic/app/modules/validate_receipt/views/validate_receipt_view.dart';
import 'package:neumorophic/app/routes/app_pages.dart';
import 'package:neumorophic/app/widgets/neumorphic_bottom_nav.dart';

void main() {
  setUp(() => Get.testMode = true);

  tearDown(Get.reset);

  /// Pumps the app at [route], optionally signed in.
  Future<void> pumpApp(
    WidgetTester tester, {
    String route = Routes.SHELL,
    bool signedIn = false,
  }) async {
    // The session has to exist before the first frame, otherwise the initial
    // route is resolved against the wrong state.
    AppBinding().dependencies();
    if (signedIn) Get.find<AuthService>().login();

    await tester.pumpWidget(
      GetMaterialApp(
        // A varying key forces a fresh element tree, otherwise an identical
        // widget is reused and initialRoute is never re-evaluated.
        key: ValueKey<String>('$route-$signedIn'),
        initialBinding: AppBinding(),
        initialRoute: route,
        getPages: AppPages.routes,
      ),
    );

    await tester.pumpAndSettle();
  }

  /// Finds [label] inside the navigation bar only.
  ///
  /// Scoped because labels like "Transfer" and "Services" also appear in the
  /// services grid, so a bare text finder is ambiguous once both are on screen.
  Finder navLabel(String label) => find.descendant(
    of: find.byType(NeumorphicBottomNav),
    matching: find.text(label),
  );

  /// Finds [label] inside the services grid only.
  Finder inServices(String label) => find.descendant(
    of: find.byType(MoreServicesView),
    matching: find.text(label),
  );

  /// The bar position currently highlighted.
  int activePosition(WidgetTester tester) =>
      tester
          .widget<NeumorphicBottomNav>(find.byType(NeumorphicBottomNav))
          .currentIndex;

  /// Labels currently rendered in the navigation bar, in order.
  List<String> visibleLabels(WidgetTester tester) => tester
      .widgetList<NeumorphicBottomNav>(find.byType(NeumorphicBottomNav))
      .first
      .items
      .map((item) => item.label)
      .toList();

  group('signed out', () {
    testWidgets('opens on the login form with the signed-out menu', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(ShellView), findsOneWidget);
      expect(find.byType(AuthView), findsOneWidget);
      expect(
        visibleLabels(tester),
        <String>['Home', 'Receipt', 'Locations', 'Services'],
      );
      expect(activePosition(tester), 0);
    });

    testWidgets('Receipt opens the scanner without a login', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(navLabel('Receipt'));
      await tester.pumpAndSettle();

      expect(find.byType(ValidateReceiptView), findsOneWidget);
      expect(find.byType(AuthView), findsNothing);
      expect(
        Get.find<ShellController>().currentIndex.value,
        ShellController.receiptTab,
      );
      expect(activePosition(tester), 1);
    });

    testWidgets('Services opens the grid without a login', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(navLabel('Services'));
      await tester.pumpAndSettle();

      expect(find.byType(MoreServicesView), findsOneWidget);
      expect(find.byType(AuthView), findsNothing);
      expect(
        Get.find<ShellController>().currentIndex.value,
        ShellController.servicesTab,
      );
      expect(inServices('Transfer'), findsOneWidget);
      expect(activePosition(tester), 3);
    });

    testWidgets('Locations opens its screen without a login', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(navLabel('Locations'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.text('This screen has not been built yet.'), findsOneWidget);
      expect(
        Get.find<ShellController>().currentIndex.value,
        ShellController.locationsTab,
      );
      expect(activePosition(tester), 2);
    });

    testWidgets('a public destination survives a deep link', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, route: Routes.VALIDATE_RECEIPT);

      // No redirect: the scanner is reachable directly.
      expect(find.byType(ValidateReceiptView), findsOneWidget);
      expect(find.byType(AuthView), findsNothing);
    });

    testWidgets('the services route is reachable directly too', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, route: Routes.MORE_SERVICES);

      expect(find.byType(MoreServicesView), findsOneWidget);
      expect(inServices('Balance'), findsOneWidget);
    });
  });

  group('signed in', () {
    testWidgets('the menu switches to the signed-in destinations', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, signedIn: true);

      expect(find.byType(AuthView), findsNothing);
      expect(find.byType(HomeView), findsOneWidget);
      expect(
        visibleLabels(tester),
        <String>['Home', 'Transfer', 'Services', 'Profile'],
      );
    });

    testWidgets('Transfer shows a coming soon screen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, signedIn: true);

      await tester.tap(navLabel('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
      expect(
        Get.find<ShellController>().currentIndex.value,
        ShellController.transferTab,
      );
    });

    testWidgets('Profile shows a coming soon screen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, signedIn: true);

      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
      expect(
        Get.find<ShellController>().currentIndex.value,
        ShellController.profileTab,
      );
    });

    testWidgets('Services still opens the grid', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, signedIn: true);

      await tester.tap(navLabel('Services'));
      await tester.pumpAndSettle();

      expect(
        Get.find<ShellController>().currentIndex.value,
        ShellController.servicesTab,
      );
      expect(inServices('Transfer'), findsOneWidget);
      expect(activePosition(tester), 2);
    });

    testWidgets('the scanner is not in the signed-in menu', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, signedIn: true);

      expect(navLabel('Receipt'), findsNothing);
    });

    testWidgets('a scanner deep link falls back to Home', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, route: Routes.VALIDATE_RECEIPT, signedIn: true);

      // The bar cannot represent the scanner, so it must not pretend to.
      expect(find.byType(HomeView), findsOneWidget);
      expect(activePosition(tester), 0);
    });

    testWidgets('signing out returns to the login form and menu', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, signedIn: true);
      expect(find.text('Transfer'), findsOneWidget);

      Get.find<AuthService>().logout();
      await tester.pumpAndSettle();

      expect(
        visibleLabels(tester),
        <String>['Home', 'Receipt', 'Locations', 'Services'],
      );
      expect(find.byType(AuthView), findsOneWidget);
    });
  });

  testWidgets('both menus map onto the shared content slots', (
    WidgetTester tester,
  ) async {
    expect(ShellView.slotsFor(isSignedIn: false), <int>[
      ShellController.overviewTab,
      ShellController.receiptTab,
      ShellController.locationsTab,
      ShellController.servicesTab,
    ]);
    expect(ShellView.slotsFor(isSignedIn: true), <int>[
      ShellController.overviewTab,
      ShellController.transferTab,
      ShellController.servicesTab,
      ShellController.profileTab,
    ]);

    for (final isSignedIn in <bool>[false, true]) {
      final slots = ShellView.slotsFor(isSignedIn: isSignedIn);
      // A repeated slot would make the active indicator always pick the first.
      expect(slots.toSet().length, slots.length, reason: 'duplicate slot');
      expect(
        ShellView.buildTabs(isSignedIn: isSignedIn).length,
        ShellController.tabCount,
      );
    }
  });

  testWidgets('an unbuilt destination titles itself from the bar label', (
    WidgetTester tester,
  ) async {
    expect(
      ShellView.labelForSlot(ShellController.locationsTab, isSignedIn: false),
      'Locations',
    );
    expect(
      ShellView.labelForSlot(ShellController.transferTab, isSignedIn: true),
      'Transfer',
    );
    expect(
      ShellView.labelForSlot(ShellController.profileTab, isSignedIn: true),
      'Profile',
    );
  });

  testWidgets('only the overview slot depends on the session', (
    WidgetTester tester,
  ) async {
    // The other slots are identical either way, which is what makes Receipt,
    // Locations and Services public.
    final signedOut = ShellView.buildTabs(isSignedIn: false);
    final signedIn = ShellView.buildTabs(isSignedIn: true);

    expect(
      signedOut[ShellController.receiptTab].runtimeType,
      ValidateReceiptView,
    );
    expect(
      signedOut[ShellController.servicesTab].runtimeType,
      MoreServicesView,
    );
    expect(
      signedIn[ShellController.receiptTab].runtimeType,
      ValidateReceiptView,
    );
    expect(
      signedIn[ShellController.servicesTab].runtimeType,
      MoreServicesView,
    );

    // The overview is the one that swaps.
    expect(signedOut[ShellController.overviewTab].runtimeType, AuthView);
    expect(signedIn[ShellController.overviewTab].runtimeType, HomeView);
  });

  testWidgets('every tab slot is mounted even while off screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, signedIn: true);

    // IndexedStack keeps inactive tabs alive; finders skip offstage widgets by
    // default, so the lookup has to opt in.
    expect(find.byType(HomeView, skipOffstage: false), findsOneWidget);
    expect(
      find.byType(ValidateReceiptView, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(MoreServicesView, skipOffstage: false), findsOneWidget);
  });

  testWidgets('tapping the active destination changes nothing', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, signedIn: true);

    await tester.tap(navLabel('Home'));
    await tester.pumpAndSettle();

    expect(
      Get.find<ShellController>().currentIndex.value,
      ShellController.overviewTab,
    );
  });
}
