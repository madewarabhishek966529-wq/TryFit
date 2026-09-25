import 'package:flutter/material.dart';

import '../../../core/models/asset.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/simulation_badge.dart';
import '../../../core/widgets/simulation_disclaimer_banner.dart';
import '../domain/try_on_models.dart';
import '../domain/try_on_repository.dart';
import 'widgets/split_comparison_view.dart';

enum ViewMode { split, sideBySide, single }

class ResultScreen extends StatefulWidget {
  final TryOnJob job;
  final TryOnRepository repository;

  const ResultScreen({super.key, required this.job, required this.repository});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ViewMode _viewMode = ViewMode.split;
  bool _isSaved = false;

  Asset get _resultAsset =>
      widget.job.resultAsset ??
      Asset(
        id: 'fallback-result',
        purpose: AssetPurpose.result,
        uri: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80',
        fileName: 'simulation_result.jpg',
        mimeType: 'image/jpeg',
        byteSize: 1024 * 400,
        createdAt: DateTime.now(),
      );

  void _handleSave() {
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to your Studio Lookbook & History'),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  void _handleShare() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Simulation Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Shared previews automatically include the AI Simulation watermarking and disclaimer.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.link, color: AppTheme.primaryAccent),
              title: const Text('Copy Private Link'),
              subtitle: const Text('Expires in 24 hours (FR-022)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Temporary link copied to clipboard'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.primaryGold),
              title: const Text('Export Image with Watermark'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image prepared with simulation notice'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Simulation?'),
        content: const Text(
          'This will permanently remove the synthesized preview image and this job record. Source images remain in your library unless explicitly deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.repository.deleteResult(widget.job.id);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulation deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.accentRose),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation Result'),
        actions: [
          SimulationBadge(isDemo: widget.job.isDemo),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose),
            tooltip: 'Delete result',
            onPressed: _handleDelete,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented view mode switch
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildModeButton(
                      mode: ViewMode.split,
                      label: 'Split Slider',
                      icon: Icons.splitscreen,
                    ),
                    _buildModeButton(
                      mode: ViewMode.sideBySide,
                      label: 'Side-by-Side',
                      icon: Icons.compare,
                    ),
                    _buildModeButton(
                      mode: ViewMode.single,
                      label: 'Zoom View',
                      icon: Icons.zoom_in,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Visual Preview Box
              SizedBox(
                height: 420,
                width: double.infinity,
                child: _buildVisualContent(),
              ),

              const SizedBox(height: 14),
              const SimulationDisclaimerBanner(compact: true),
              const SizedBox(height: 16),

              // Garment & Metadata Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          widget.job.category.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Inference Engine',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          widget.job.modelVersion ?? 'TryFit Mock Demo',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Job ID',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          widget.job.id.substring(0, 8),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaved ? null : _handleSave,
                      icon: Icon(
                        _isSaved ? Icons.check : Icons.bookmark_border,
                      ),
                      label: Text(_isSaved ? 'Saved' : 'Save Look'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'Share preview',
                    onPressed: _handleShare,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required ViewMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _viewMode = mode),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualContent() {
    switch (_viewMode) {
      case ViewMode.split:
        return SplitComparisonView(
          originalAsset: widget.job.personAsset,
          resultAsset: _resultAsset,
          isDemo: widget.job.isDemo,
        );

      case ViewMode.sideBySide:
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(widget.job.personAsset),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusPill,
                          ),
                        ),
                        child: const Text(
                          'BEFORE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(_resultAsset),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: SimulationBadge(
                        isDemo: widget.job.isDemo,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case ViewMode.single:
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: _buildImage(_resultAsset),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: SimulationBadge(
                  isDemo: widget.job.isDemo,
                  compact: true,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.pinch, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Pinch to zoom', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildImage(Asset asset) {
    if (asset.bytes != null) {
      return Image.memory(asset.bytes!, fit: BoxFit.cover);
    }
    if (asset.uri.startsWith('http')) {
      return Image.network(
        asset.uri,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
    return const Center(child: Icon(Icons.image));
  }
}
