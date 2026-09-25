import 'package:flutter/material.dart';

import '../../../../core/models/garment_category.dart';
import '../../../../core/theme/app_theme.dart';

class CategorySelectorView extends StatelessWidget {
  final GarmentCategory selectedCategory;
  final ValueChanged<GarmentCategory> onCategoryChanged;

  const CategorySelectorView({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Garment Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              selectedCategory.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: GarmentCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = GarmentCategory.values[index];
              final isSelected = cat == selectedCategory;
              return InkWell(
                onTap: () => onCategoryChanged(cat),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryAccent
                        : AppTheme.darkSurfaceElevated,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryAccent
                          : AppTheme.darkBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForCategory(cat),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
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
    );
  }

  IconData _getIconForCategory(GarmentCategory category) {
    switch (category) {
      case GarmentCategory.tops:
        return Icons.checkroom;
      case GarmentCategory.bottoms:
        return Icons.dry_cleaning;
      case GarmentCategory.dresses:
        return Icons.woman;
      case GarmentCategory.outerwear:
        return Icons.layers;
      case GarmentCategory.fullOutfit:
        return Icons.style;
    }
  }
}
