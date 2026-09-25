import 'package:flutter/material.dart';

import '../../../core/models/garment_category.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../try_on/data/mock_data_fixtures.dart';
import '../domain/wardrobe_item.dart';
import 'outfit_builder_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  GarmentCategory? _filterCategory;
  late List<WardrobeItem> _items;

  @override
  void initState() {
    super.initState();
    // Seed from catalog fixtures
    _items = MockDataFixtures.sampleGarments.map((g) {
      return WardrobeItem(
        id: g.id,
        title: g.title,
        brand: g.brand,
        category: g.category,
        color: g.color,
        season: 'All Season',
        imageUrl: g.imageUrl,
        tags: [g.color, g.category.label, 'Luxury'],
        dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      );
    }).toList();

    _loadPersistedWardrobe();
  }

  Future<void> _loadPersistedWardrobe() async {
    try {
      final storage = await LocalStorageService.getInstance();
      final persisted = storage.loadWardrobe();
      if (persisted.isNotEmpty && mounted) {
        setState(() => _items = persisted);
      }
    } catch (_) {}
  }

  void _persistWardrobe() {
    LocalStorageService.getInstance().then((storage) {
      storage.saveWardrobe(_items);
    }).catchError((_) {});
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final brandController = TextEditingController(text: 'Personal Wardrobe');
    GarmentCategory selectedCat = GarmentCategory.tops;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Garment to Wardrobe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Vintage Denim Jacket',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand / Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: GarmentCategory.values.map((cat) {
                  final isSel = cat == selectedCat;
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setModalState(() => selectedCat = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    setState(() {
                      _items.add(
                        WardrobeItem(
                          id: 'wardrobe-${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          brand: brandController.text.trim(),
                          category: selectedCat,
                          color: 'Custom',
                          season: 'All Season',
                          imageUrl: MockDataFixtures.sampleGarments[0].imageUrl,
                          tags: ['Wardrobe', selectedCat.label],
                          dateAdded: DateTime.now(),
                        ),
                      );
                    });
                    _persistWardrobe();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "$title" to your wardrobe'),
                      ),
                    );
                  },
                  child: const Text('Save to Wardrobe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filterCategory == null
        ? _items
        : _items.where((i) => i.category == _filterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Outfit Builder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => OutfitBuilderScreen(wardrobeItems: _items),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Garment',
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category filter chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('All Items'),
                      selected: _filterCategory == null,
                      onSelected: (_) => setState(() => _filterCategory = null),
                    ),
                  ),
                  ...GarmentCategory.values.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(cat.label),
                        selected: _filterCategory == cat,
                        onSelected: (val) =>
                            setState(() => _filterCategory = val ? cat : null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filteredItems.isEmpty
                  ? EmptyStateView(
                      icon: Icons.checkroom_outlined,
                      title: 'No Items in This Category',
                      description: 'Add a garment to build your personal digitized wardrobe.',
                      actionLabel: 'Add Item',
                      onAction: _showAddItemDialog,
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      cacheExtent: 600,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return RepaintBoundary(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface,
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
                                      item.imageUrl,
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
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.brand} • ${item.color}',
                                        style: const TextStyle(
                                          fontSize: 11,
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
}
