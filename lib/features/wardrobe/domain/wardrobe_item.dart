import '../../../core/models/garment_category.dart';

class WardrobeItem {
  final String id;
  final String title;
  final String brand;
  final GarmentCategory category;
  final String color;
  final String season; // All, Spring/Summer, Autumn/Winter
  final String imageUrl;
  final List<String> tags;
  final DateTime dateAdded;

  const WardrobeItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.category,
    required this.color,
    required this.season,
    required this.imageUrl,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'category': category.id,
      'color': color,
      'season': season,
      'image_url': imageUrl,
      'tags': tags,
      'date_added': dateAdded.toIso8601String(),
    };
  }
}
