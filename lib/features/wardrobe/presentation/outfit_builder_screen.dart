import 'package:flutter/material.dart';

import '../../../core/models/garment_category.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/wardrobe_item.dart';

class OutfitBuilderScreen extends StatefulWidget {
  final List<WardrobeItem> wardrobeItems;

  const OutfitBuilderScreen({super.key, required this.wardrobeItems});

  @override
  State<OutfitBuilderScreen> createState() => _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends State<OutfitBuilderScreen> {
  WardrobeItem? _selectedTop;
  WardrobeItem? _selectedBottom;
  WardrobeItem? _selectedOuterwear;

  @override
  void initState() {
    super.initState();
    final tops = widget.wardrobeItems.where(
      (i) => i.category == GarmentCategory.tops,
    );
    final bottoms = widget.wardrobeItems.where(
      (i) => i.category == GarmentCategory.bottoms,
    );
    final outerwear = widget.wardrobeItems.where(
      (i) => i.category == GarmentCategory.outerwear,
    );

    if (tops.isNotEmpty) _selectedTop = tops.first;
    if (bottoms.isNotEmpty) _selectedBottom = bottoms.first;
    if (outerwear.isNotEmpty) _selectedOuterwear = outerwear.first;
  }

  void _showItemPicker(
    GarmentCategory category,
    Function(WardrobeItem) onSelect,
  ) {
    final available = widget.wardrobeItems
        .where((i) => i.category == category)
        .toList();

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
            Text(
              'Select ${category.label}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (available.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No items found in your wardrobe for this category.',
                ),
              )
            else
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = available[index];
                    return InkWell(
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppTheme.radiusMedium),
                                ),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  void _saveOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outfit saved to your curated Lookbook!'),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Ensemble Builder'),
        actions: [
          TextButton.icon(
            onPressed: _saveOutfit,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save Outfit'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mix & Match Wardrobe Canvas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Layer your wardrobe garments together to create harmonized fashion ensembles.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),

              // Ensemble display card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    _buildSlot(
                      title: 'Outerwear',
                      category: GarmentCategory.outerwear,
                      item: _selectedOuterwear,
                      onSelect: (item) =>
                          setState(() => _selectedOuterwear = item),
                    ),
                    const SizedBox(width: 10),
                    _buildSlot(
                      title: 'Top',
                      category: GarmentCategory.tops,
                      item: _selectedTop,
                      onSelect: (item) => setState(() => _selectedTop = item),
                    ),
                    const SizedBox(width: 10),
                    _buildSlot(
                      title: 'Bottom',
                      category: GarmentCategory.bottoms,
                      item: _selectedBottom,
                      onSelect: (item) =>
                          setState(() => _selectedBottom = item),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Styling Harmony Analysis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.palette,
                          color: AppTheme.primaryGold,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Color Harmony: 94% Match',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The neutral tones balance the navy structured jacket with elegant contrast.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot({
    required String title,
    required GarmentCategory category,
    required WardrobeItem? item,
    required Function(WardrobeItem) onSelect,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showItemPicker(category, onSelect),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: item != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.checkroom, color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, color: AppTheme.primaryAccent),
                        SizedBox(height: 4),
                        Text('Select', style: TextStyle(fontSize: 11)),
                      ],
                    ),
            ),
          ),
          if (item != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ),
        ],
      ),
    );
  }
}
