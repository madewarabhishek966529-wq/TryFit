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

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String,
      title: json['title'] as String,
      brand: json['brand'] as String? ?? 'Custom',
      category: GarmentCategory.fromId(json['category'] as String),
      color: json['color'] as String? ?? 'Mixed',
      season: json['season'] as String? ?? 'All Season',
      imageUrl: json['image_url'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'] as String)
          : DateTime.now(),
    );
  }
}
