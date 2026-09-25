import 'package:flutter_test/flutter_test.dart';
import 'package:tryfit/core/models/asset.dart';
import 'package:tryfit/core/models/garment_category.dart';
import 'package:tryfit/core/utils/image_validator.dart';
import 'package:tryfit/features/try_on/data/offline_fitting_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OfflineFittingEngine synthesizes realistic try-on result in background isolate', () async {
    final person = Asset(
      id: 'person-test',
      purpose: AssetPurpose.person,
      uri: 'test://person.jpg',
      fileName: 'person.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 100,
      createdAt: DateTime.now(),
    );

    final garment = Asset(
      id: 'garment-test',
      purpose: AssetPurpose.garment,
      uri: 'test://garment.jpg',
      fileName: 'garment.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 80,
      createdAt: DateTime.now(),
    );

    final result = await OfflineFittingEngine.synthesizeTryOn(
      personAsset: person,
      garmentAsset: garment,
      category: GarmentCategory.tops,
      fabricScale: 1.05,
    );

    expect(result.id, startsWith('res-offline-'));
    expect(result.purpose, AssetPurpose.result);
    expect(result.bytes, isNotNull);
    expect(result.bytes!.length, greaterThan(10 * 1024));

    // Verify synthetic result passes ImageValidator magic bytes check asynchronously
    final validation = await ImageValidator.validateImageBytesAsync(result.bytes!);
    expect(validation.isValid, isTrue);
    expect(validation.detectedFormat, 'image/jpeg');
  });
}
