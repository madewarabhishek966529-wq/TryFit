import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryfit/core/models/asset.dart';
import 'package:tryfit/core/models/garment_category.dart';
import 'package:tryfit/core/models/job_status.dart';
import 'package:tryfit/core/services/local_storage_service.dart';
import 'package:tryfit/features/try_on/domain/try_on_models.dart';
import 'package:tryfit/features/wardrobe/domain/wardrobe_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('LocalStorageService persists and retrieves try-on simulation jobs', () async {
    final storage = await LocalStorageService.getInstance();

    final dummyPerson = Asset(
      id: 'person-test-1',
      purpose: AssetPurpose.person,
      uri: 'test://person.jpg',
      fileName: 'person.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 100,
      createdAt: DateTime.now(),
    );

    final dummyGarment = Asset(
      id: 'garment-test-1',
      purpose: AssetPurpose.garment,
      uri: 'test://garment.jpg',
      fileName: 'garment.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 80,
      createdAt: DateTime.now(),
    );

    final job = TryOnJob(
      id: 'job-101',
      personAsset: dummyPerson,
      garmentAsset: dummyGarment,
      category: GarmentCategory.tops,
      status: JobStatus.succeeded,
      progressMessage: 'Done',
      createdAt: DateTime.now(),
    );

    await storage.saveJobs([job]);

    final loaded = storage.loadJobs();
    expect(loaded.length, 1);
    expect(loaded.first.id, 'job-101');
    expect(loaded.first.category, GarmentCategory.tops);
    expect(loaded.first.status, JobStatus.succeeded);
  });

  test('LocalStorageService persists and retrieves custom wardrobe items', () async {
    final storage = await LocalStorageService.getInstance();

    final item = WardrobeItem(
      id: 'item-202',
      title: 'Silk Bomber Jacket',
      brand: 'Tokyo Atelier',
      category: GarmentCategory.outerwear,
      color: 'Midnight Black',
      season: 'Autumn/Winter',
      imageUrl: 'https://example.com/jacket.jpg',
      tags: ['Outerwear', 'Silk'],
      dateAdded: DateTime.now(),
    );

    await storage.saveWardrobe([item]);

    final loaded = storage.loadWardrobe();
    expect(loaded.length, 1);
    expect(loaded.first.id, 'item-202');
    expect(loaded.first.title, 'Silk Bomber Jacket');
    expect(loaded.first.category, GarmentCategory.outerwear);
  });

  test('LocalStorageService handles preferences and data clear', () async {
    final storage = await LocalStorageService.getInstance();

    await storage.saveDarkMode(true);
    expect(storage.loadDarkMode(), isTrue);

    await storage.saveMirrorCamera(false);
    expect(storage.loadMirrorCamera(), isFalse);

    await storage.clearAll();
    expect(storage.loadJobs(), isEmpty);
    expect(storage.loadWardrobe(), isEmpty);
  });
}
