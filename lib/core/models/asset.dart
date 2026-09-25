import 'dart:typed_data';

enum AssetPurpose { person, garment, result }

/// Represents an uploaded or local media asset (person photo, garment, or result).
class Asset {
  final String id;
  final AssetPurpose purpose;
  final String uri;
  final Uint8List? bytes;
  final String fileName;
  final String mimeType;
  final int byteSize;
  final int? width;
  final int? height;
  final DateTime createdAt;

  const Asset({
    required this.id,
    required this.purpose,
    required this.uri,
    this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.byteSize,
    this.width,
    this.height,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purpose': purpose.name,
      'uri': uri,
      'file_name': fileName,
      'mime_type': mimeType,
      'byte_size': byteSize,
      'width': width,
      'height': height,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      purpose: AssetPurpose.values.firstWhere(
        (p) => p.name == json['purpose'],
        orElse: () => AssetPurpose.person,
      ),
      uri: json['uri'] as String,
      fileName: json['file_name'] as String? ?? 'asset.jpg',
      mimeType: json['mime_type'] as String? ?? 'image/jpeg',
      byteSize: json['byte_size'] as int? ?? 0,
      width: json['width'] as int?,
      height: json['height'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
