import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryfit/app/app.dart';
import 'package:tryfit/features/try_on/data/mock_try_on_repository.dart';

void main() {
  testWidgets('TryFit full app onboarding and studio navigation smoke test', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockTryOnRepository();

    // Pump TryFitApp with larger test surface to accommodate mobile viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(TryFitApp(repository: mockRepo));
    await tester.pump();

    // Verify Onboarding is displayed initially
    expect(find.text('AI Virtual Try-On Studio'), findsOneWidget);
    expect(find.text('Skip to Demo'), findsOneWidget);

    // Tap Skip to Demo to enter the main app directly
    await tester.tap(find.text('Skip to Demo'));
    await tester.pumpAndSettle();

    // Verify Main Studio screen is displayed
    expect(find.text('TryFit'), findsOneWidget);
    expect(find.text('1. Model / Person Photo'), findsOneWidget);
    expect(find.text('2. Garment to Try-On'), findsOneWidget);
    expect(find.text('Garment Category'), findsOneWidget);
    expect(find.text('Generate Simulation'), findsOneWidget);

    // Verify Bottom Navigation items
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Wardrobe'), findsOneWidget);
    expect(find.text('Stylist'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Navigate to Wardrobe tab
    await tester.tap(find.byIcon(Icons.checkroom_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Digital Wardrobe'), findsOneWidget);

    // Navigate to Stylist tab
    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();
    expect(find.text('AI Personal Stylist'), findsOneWidget);
    expect(find.text('Curate Style Looks'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Settings & Privacy'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Export My Data'), findsOneWidget);
  });

  testWidgets('TryFit Studio generation opens processing screen', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockTryOnRepository();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Start directly at Studio
    await tester.pumpWidget(
      TryFitApp(repository: mockRepo, startAtStudio: true),
    );
    await tester.pumpAndSettle();

    final generateBtnFinder = find.text('Generate Simulation');
    expect(generateBtnFinder, findsOneWidget);

    await tester.ensureVisible(generateBtnFinder);
    await tester.pumpAndSettle();

    // Tap Generate Simulation
    await tester.tap(generateBtnFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Processing Screen appeared
    expect(find.text('Synthesizing Try-On'), findsOneWidget);
    expect(find.text('Cancel Simulation'), findsOneWidget);
  });
}
