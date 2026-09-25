import '../../../core/models/asset.dart';
import '../../../core/models/garment_category.dart';

/// Curated sample models and demo garments for instant, zero-upload experimentation.
class DemoCatalogItem {
  final String id;
  final String title;
  final String brand;
  final GarmentCategory category;
  final String color;
  final String imageUrl;
  final String description;

  const DemoCatalogItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.category,
    required this.color,
    required this.imageUrl,
    required this.description,
  });

  Asset toAsset() {
    return Asset(
      id: id,
      purpose: AssetPurpose.garment,
      uri: imageUrl,
      fileName: '$id.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 350,
      createdAt: DateTime.now(),
    );
  }
}

class DemoModelPerson {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const DemoModelPerson({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  Asset toAsset() {
    return Asset(
      id: id,
      purpose: AssetPurpose.person,
      uri: imageUrl,
      fileName: '$id.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 480,
      createdAt: DateTime.now(),
    );
  }
}

class MockDataFixtures {
  MockDataFixtures._();

  static final List<DemoModelPerson> sampleModels = [
    const DemoModelPerson(
      id: 'model-sophia',
      name: 'Sophia L.',
      description: 'Studio Frontal • Warm Editorial Light',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    ),
    const DemoModelPerson(
      id: 'model-elena',
      name: 'Elena R.',
      description: 'Clean Minimalist Pose • Neutral Backdrop',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    ),
    const DemoModelPerson(
      id: 'model-david',
      name: 'Marcus K.',
      description: 'Athletic Casual Pose • Studio Daylight',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
    ),
    const DemoModelPerson(
      id: 'model-kai',
      name: 'Kai Chen',
      description: 'Urban Streetwear Silhouette',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  static final List<DemoCatalogItem> sampleGarments = [
    const DemoCatalogItem(
      id: 'garment-blazer-navy',
      title: 'Midnight Wool Blazer',
      brand: 'Couture Lab',
      category: GarmentCategory.outerwear,
      color: 'Navy Blue',
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=800&q=80',
      description: 'Structured double-breasted blazer with sharp lapels and horn buttons.',
    ),
    const DemoCatalogItem(
      id: 'garment-dress-emerald',
      title: 'Emerald Silk Slip Dress',
      brand: 'Atelier Noir',
      category: GarmentCategory.dresses,
      color: 'Emerald Green',
      imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80',
      description:
          'Fluid bias-cut silk dress with delicate straps and draped neckline.',
    ),
    const DemoCatalogItem(
      id: 'garment-top-linen',
      title: 'Relaxed Oversized Shirt',
      brand: 'Studio Élan',
      category: GarmentCategory.tops,
      color: 'Crisp White',
      imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=800&q=80',
      description: 'Breathable organic cotton and linen blend shirt with mother-of-pearl buttons.',
    ),
    const DemoCatalogItem(
      id: 'garment-pants-pleated',
      title: 'High-Rise Pleated Trousers',
      brand: 'Maison Luxe',
      category: GarmentCategory.bottoms,
      color: 'Sand Beige',
      imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
      description:
          'Wide-leg tailored trousers with deep pleats and clean waistband.',
    ),
    const DemoCatalogItem(
      id: 'garment-coord-tweed',
      title: 'Pastel Tweed Co-ord Suit',
      brand: 'Lumière Paris',
      category: GarmentCategory.fullOutfit,
      color: 'Lilac Multi',
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80',
      description: 'Cropped tailored tweed jacket paired with matching high-waist mini skirt.',
    ),
  ];

  /// Realistic high-quality simulation result images corresponding to sample try-ons
  static const String fallbackResultImage =
      'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80';
}
