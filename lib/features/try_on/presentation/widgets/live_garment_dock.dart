import 'package:flutter/material.dart';
import '../../../../core/models/garment_category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_data_fixtures.dart';

/// Floating live clothing selector dock over the live camera stream.
/// Isolated inside a RepaintBoundary for smooth 120 FPS carousel interactions.
class LiveGarmentDock extends StatelessWidget {
  final List<DemoCatalogItem> garments;
  final DemoCatalogItem? selectedGarment;
  final ValueChanged<DemoCatalogItem> onSelectGarment;
  final GarmentCategory? selectedCategory;
  final ValueChanged<GarmentCategory?> onSelectCategory;
  final VoidCallback onSnapFit;
  final VoidCallback onToggleControls;
  final bool isCapturing;

  const LiveGarmentDock({
    super.key,
    required this.garments,
    required this.selectedGarment,
    required this.onSelectGarment,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.onSnapFit,
    required this.onToggleControls,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    final filteredGarments = selectedCategory == null
        ? garments
        : garments.where((g) => g.category == selectedCategory).toList();

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.92),
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.75, 1.0],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Filter Pills & Fine-Tuning Action Button
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildCategoryChip('All', null),
                        ...GarmentCategory.values.map(
                          (cat) => _buildCategoryChip(cat.label, cat),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onToggleControls,
                  icon: const Icon(Icons.tune, color: Colors.white70, size: 20),
                  tooltip: 'Fabric Blend & Fit Controls',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white10,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Live Clothing Carousel
            SizedBox(
              height: 94,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredGarments.length,
                itemExtent: 80, // Fixed extent for maximum 120 FPS scroll performance
                itemBuilder: (context, index) {
                  final garment = filteredGarments[index];
                  final isSelected = garment.id == selectedGarment?.id;

                  return GestureDetector(
                    onTap: () => onSelectGarment(garment),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryAccent.withOpacity(0.25)
                            : AppTheme.darkSurfaceElevated.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGold
                              : Colors.white12,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppTheme.radiusMedium - 2),
                              ),
                              child: Image.network(
                                garment.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.checkroom,
                                  color: Colors.white54,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Text(
                              garment.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.primaryGold
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Live Shutter & Fit Action Button
            Center(
              child: GestureDetector(
                onTap: isCapturing ? null : onSnapFit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: isCapturing
                        ? AppTheme.accentEmerald
                        : AppTheme.primaryAccent,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryAccent.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isCapturing
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'TAP SHUTTER TO CAPTURE & FIT OFFLINE',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, GarmentCategory? category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelectCategory(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryAccent
                : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: isSelected ? AppTheme.primaryAccent : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
