import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/models/asset.dart';
import '../../../core/models/garment_category.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/simulation_badge.dart';
import '../../../core/widgets/simulation_disclaimer_banner.dart';
import '../../history/presentation/history_screen.dart';
import '../data/mock_data_fixtures.dart';
import '../domain/try_on_repository.dart';
import 'processing_screen.dart';
import 'widgets/category_selector_view.dart';
import 'widgets/image_intake_card.dart';

class StudioScreen extends StatefulWidget {
  final TryOnRepository repository;

  const StudioScreen({super.key, required this.repository});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  Asset? _personAsset;
  Asset? _garmentAsset;
  GarmentCategory _category = GarmentCategory.tops;
  bool _isCreatingJob = false;

  @override
  void initState() {
    super.initState();
    // Default with first sample model & garment for instant demo exploration
    _personAsset = MockDataFixtures.sampleModels[0].toAsset();
    _garmentAsset = MockDataFixtures.sampleGarments[1].toAsset();
    _category = MockDataFixtures.sampleGarments[1].category;
  }

  void _showModelPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Sample Model',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Studio daylight & neutral backdrop samples for zero-upload demonstration.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MockDataFixtures.sampleModels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final model = MockDataFixtures.sampleModels[index];
                  return InkWell(
                    onTap: () {
                      setState(() => _personAsset = model.toAsset());
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppTheme.radiusMedium),
                              ),
                              child: Image.network(
                                model.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.person, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGarmentPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Sample Garment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Curated pieces across categories to test fitting simulations.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MockDataFixtures.sampleGarments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final garment = MockDataFixtures.sampleGarments[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _garmentAsset = garment.toAsset();
                        _category = garment.category;
                      });
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppTheme.radiusMedium),
                              ),
                              child: Image.network(
                                garment.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.checkroom,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  garment.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  garment.brand,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateUploadCustomPhoto(AssetPurpose purpose) {
    // Generate valid simulated JPEG binary header for realistic testing
    final fakeValidJpegBytes = Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      ...List.filled(24 * 1024, 0x55), // 24 KB valid test binary
    ]);

    final asset = Asset(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      purpose: purpose,
      uri: MockDataFixtures.sampleModels[1].imageUrl,
      bytes: fakeValidJpegBytes,
      fileName: purpose == AssetPurpose.person
          ? 'my_portrait.jpg'
          : 'my_garment.jpg',
      mimeType: 'image/jpeg',
      byteSize: fakeValidJpegBytes.lengthInBytes,
      createdAt: DateTime.now(),
    );

    setState(() {
      if (purpose == AssetPurpose.person) {
        _personAsset = asset;
      } else {
        _garmentAsset = asset;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${purpose == AssetPurpose.person ? "Portrait" : "Garment"} loaded (EXIF stripped • 24 KB)',
        ),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  void _showCropRotateNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crop & Orientation'),
        content: const Text(
          'Photos are aligned automatically with center-pose preservation. You can also re-center or rotate manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartSimulation() async {
    if (_personAsset == null || _garmentAsset == null) return;

    setState(() => _isCreatingJob = true);

    try {
      final job = await widget.repository.createJob(
        personAsset: _personAsset!,
        garmentAsset: _garmentAsset!,
        category: _category,
      );

      if (!mounted) return;
      setState(() => _isCreatingJob = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) =>
              ProcessingScreen(initialJob: job, repository: widget.repository),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingJob = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate simulation: $e'),
          backgroundColor: AppTheme.accentRose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGenerate =
        _personAsset != null && _garmentAsset != null && !_isCreatingJob;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text(
              'TryFit',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(width: 8),
            SimulationBadge(isDemo: true, compact: true),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Try-On History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) =>
                      HistoryScreen(repository: widget.repository),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Virtual Try-On Studio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Combine person portrait and garment to generate realistic visual simulation.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),

              // Step 1: Person Photo
              ImageIntakeCard(
                title: '1. Model / Person Photo',
                subtitle: 'Frontal or 3/4 pose with clear lighting',
                asset: _personAsset,
                onSelectFromDemo: _showModelPickerSheet,
                onUploadCustom: () =>
                    _simulateUploadCustomPhoto(AssetPurpose.person),
                onRemove: () => setState(() => _personAsset = null),
                onCropRotate: _showCropRotateNotice,
              ),

              const SizedBox(height: 16),

              // Step 2: Garment Image
              ImageIntakeCard(
                title: '2. Garment to Try-On',
                subtitle: 'Catalog photo, flat lay, or ghost mannequin',
                asset: _garmentAsset,
                onSelectFromDemo: _showGarmentPickerSheet,
                onUploadCustom: () =>
                    _simulateUploadCustomPhoto(AssetPurpose.garment),
                onRemove: () => setState(() => _garmentAsset = null),
                onCropRotate: _showCropRotateNotice,
              ),

              const SizedBox(height: 20),

              // Step 3: Category Selector
              CategorySelectorView(
                selectedCategory: _category,
                onCategoryChanged: (cat) => setState(() => _category = cat),
              ),

              const SizedBox(height: 20),
              const SimulationDisclaimerBanner(compact: true),
              const SizedBox(height: 24),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isCreatingJob
                      ? 'Initiating Pipeline...'
                      : 'Generate Simulation',
                  isLoading: _isCreatingJob,
                  onPressed: canGenerate ? _handleStartSimulation : null,
                  icon: Icons.auto_awesome,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
