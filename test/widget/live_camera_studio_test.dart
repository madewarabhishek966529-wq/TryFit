import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryfit/app/app.dart';
import 'package:tryfit/features/try_on/data/mock_try_on_repository.dart';
import 'package:tryfit/features/try_on/presentation/live_camera_studio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Studio allows instant switching to Live AR Camera and back', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockTryOnRepository();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      TryFitApp(repository: mockRepo, startAtStudio: true),
    );
    await tester.pumpAndSettle();

    // Verify initial Photo Studio
    expect(find.text('AI Virtual Try-On Studio'), findsOneWidget);
    expect(find.text('📸 Live AR Camera'), findsOneWidget);

    // Tap to switch to Live AR Camera
    await tester.tap(find.text('📸 Live AR Camera'));
    await tester.pumpAndSettle();

    // Verify Live Camera Studio components are displayed
    expect(find.byType(LiveCameraStudio), findsOneWidget);
    expect(find.text('Photo Mode'), findsOneWidget);
    expect(find.text('TAP SHUTTER TO CAPTURE & FIT OFFLINE'), findsOneWidget);
    expect(find.text('Pose Aligned • Hold Steady'), findsOneWidget);

    // Verify category chips in the live dock
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Tops & Shirts'), findsOneWidget);
    expect(find.text('Dresses'), findsOneWidget);

    // Switch category filter in the live dock
    await tester.tap(find.text('Dresses'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Switch back to Photo Mode
    await tester.tap(find.text('Photo Mode'));
    await tester.pumpAndSettle();

    // Verify back in Photo Studio
    expect(find.text('AI Virtual Try-On Studio'), findsOneWidget);
  });

  testWidgets('Live Camera Studio shutter button triggers processing screen', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockTryOnRepository();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: LiveCameraStudio(
          repository: mockRepo,
          onSwitchToPhotoMode: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap shutter button (camera icon)
    final shutterFinder = find.byIcon(Icons.camera_alt);
    expect(shutterFinder, findsOneWidget);

    await tester.tap(shutterFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Processing Screen appeared
    expect(find.text('Synthesizing Try-On'), findsOneWidget);
  });
}
