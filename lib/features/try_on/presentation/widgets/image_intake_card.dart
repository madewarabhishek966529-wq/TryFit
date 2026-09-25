import 'package:flutter/material.dart';

import '../../../../core/models/asset.dart';
import '../../../../core/theme/app_theme.dart';

class ImageIntakeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Asset? asset;
  final VoidCallback onSelectFromDemo;
  final VoidCallback onUploadCustom;
  final VoidCallback onRemove;
  final VoidCallback? onCropRotate;

  const ImageIntakeCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset,
    required this.onSelectFromDemo,
    required this.onUploadCustom,
    required this.onRemove,
    this.onCropRotate,
  });

  @override
  Widget build(BuildContext context) {
    final hasAsset = asset != null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: hasAsset
              ? AppTheme.primaryAccent.withOpacity(0.5)
              : AppTheme.darkBorder,
          width: hasAsset ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAsset)
                  Row(
                    children: [
                      if (onCropRotate != null)
                        IconButton(
                          icon: const Icon(Icons.crop_rotate, size: 20),
                          tooltip: 'Crop / Rotate preview',
                          color: const Color(0xFF94A3B8),
                          onPressed: onCropRotate,
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Remove',
                        color: AppTheme.accentRose,
                        onPressed: onRemove,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(),
          if (!hasAsset)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No photo selected',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPEG, PNG or WebP • Max 15MB • EXIF scrubbed',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSelectFromDemo,
                          icon: const Icon(
                            Icons.collections_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Pick Sample',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onUploadCustom,
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text(
                            'Upload / Test',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: Container(
                      width: 90,
                      height: 110,
                      color: AppTheme.darkSurfaceElevated,
                      child: _buildImageThumbnail(asset!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset!.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(asset!.byteSize / 1024).toStringAsFixed(1)} KB • ${asset!.mimeType}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: onSelectFromDemo,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(Asset asset) {
    if (asset.bytes != null) {
      return Image.memory(
        asset.bytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: AppTheme.accentRose),
        ),
      );
    }

    if (asset.uri.startsWith('http')) {
      return Image.network(
        asset.uri,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.person, color: AppTheme.primaryAccent),
        ),
      );
    }

    return const Center(
      child: Icon(Icons.image, color: AppTheme.primaryAccent),
    );
  }
}
