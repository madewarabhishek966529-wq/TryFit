import 'package:flutter/material.dart';

import '../../../../core/models/asset.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/simulation_badge.dart';

/// Interactive Split Comparison View allowing user to slide between
/// the original person photo and the synthesized simulation.
class SplitComparisonView extends StatefulWidget {
  final Asset originalAsset;
  final Asset resultAsset;
  final bool isDemo;

  const SplitComparisonView({
    super.key,
    required this.originalAsset,
    required this.resultAsset,
    this.isDemo = true,
  });

  @override
  State<SplitComparisonView> createState() => _SplitComparisonViewState();
}

class _SplitComparisonViewState extends State<SplitComparisonView> {
  double _splitFraction = 0.5; // Center split

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Stack(
            children: [
              // Result Image (Full background)
              Positioned.fill(child: _buildImage(widget.resultAsset)),

              // Original Image (Clipped to split fraction)
              Positioned.fill(
                child: ClipRect(
                  clipper: _HorizontalSplitClipper(_splitFraction),
                  child: _buildImage(widget.originalAsset),
                ),
              ),

              // Divider Line
              Positioned(
                left: (width * _splitFraction) - 1.5,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: Colors.white),
              ),

              // Divider Handle
              Positioned(
                left: (width * _splitFraction) - 18,
                top: (height / 2) - 18,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _splitFraction =
                          (_splitFraction + (details.delta.dx / width)).clamp(
                            0.05,
                            0.95,
                          );
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.code,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // Labels
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: const Text(
                    'ORIGINAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 14,
                right: 14,
                child: SimulationBadge(isDemo: widget.isDemo, compact: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(Asset asset) {
    if (asset.bytes != null) {
      return Image.memory(
        asset.bytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
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

class _HorizontalSplitClipper extends CustomClipper<Rect> {
  final double fraction;

  _HorizontalSplitClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_HorizontalSplitClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
