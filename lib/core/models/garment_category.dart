/// Supported garment categories for virtual try-on.
enum GarmentCategory {
  tops(
    id: 'tops',
    label: 'Tops & Shirts',
    description: 'T-shirts, shirts, blouses, crop tops, knitwear',
    iconName: 'checkroom',
  ),
  bottoms(
    id: 'bottoms',
    label: 'Pants & Skirts',
    description: 'Jeans, trousers, skirts, shorts',
    iconName: 'dry_cleaning',
  ),
  dresses(
    id: 'dresses',
    label: 'Dresses',
    description: 'One-piece dresses, midi, maxi, cocktail',
    iconName: 'woman',
  ),
  outerwear(
    id: 'outerwear',
    label: 'Jackets & Coats',
    description: 'Jackets, blazers, trench coats, outerwear',
    iconName: 'layers',
  ),
  fullOutfit(
    id: 'full_outfit',
    label: 'Full Outfits',
    description: 'Coordinated sets, jumpsuits, two-pieces',
    iconName: 'style',
  );

  final String id;
  final String label;
  final String description;
  final String iconName;

  const GarmentCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.iconName,
  });

  static GarmentCategory fromId(String id) {
    return GarmentCategory.values.firstWhere(
      (cat) => cat.id == id,
      orElse: () => GarmentCategory.tops,
    );
  }
}
