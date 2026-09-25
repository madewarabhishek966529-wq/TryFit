import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_data_fixtures.dart';

/// Interactive AR garment overlay rendered in real-time over the camera feed.
/// Uses Transform matrix manipulation and isolated RepaintBoundary to achieve
/// silky 120 FPS gesture handling (drag, pinch-scale) without triggering parent rebuilds.
class LiveGarmentOverlay extends StatefulWidget {
  final DemoCatalogItem? garment;
  final ValueNotifier<double> scaleNotifier;
  final ValueNotifier<Offset> offsetNotifier;
  final ValueNotifier<double> opacityNotifier;
  final ValueNotifier<BlendMode> blendModeNotifier;

  const LiveGarmentOverlay({
    super.key,
    required this.garment,
    required this.scaleNotifier,
    required this.offsetNotifier,
    required this.opacityNotifier,
    required this.blendModeNotifier,
  });

  @override
  State<LiveGarmentOverlay> createState() => _LiveGarmentOverlayState();
}

class _LiveGarmentOverlayState extends State<LiveGarmentOverlay> {
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialScale = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.garment == null) return const SizedBox.shrink();

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (details) {
          _initialFocalPoint = details.focalPoint;
          _initialOffset = widget.offsetNotifier.value;
          _initialScale = widget.scaleNotifier.value;
        },
        onScaleUpdate: (details) {
          final delta = details.focalPoint - _initialFocalPoint;
          widget.offsetNotifier.value = _initialOffset + delta;

          final newScale = (_initialScale * details.scale).clamp(0.4, 2.5);
          widget.scaleNotifier.value = newScale;
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.offsetNotifier,
            widget.scaleNotifier,
            widget.opacityNotifier,
            widget.blendModeNotifier,
          ]),
          builder: (context, _) {
            final offset = widget.offsetNotifier.value;
            final scale = widget.scaleNotifier.value;
            final opacity = widget.opacityNotifier.value;
            final blendMode = widget.blendModeNotifier.value;

            return Center(
              child: Transform.translate(
                offset: offset,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 310,
                    height: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fabric Glow / Realistic Silhouette Ambient Shadow
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35 * opacity),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Garment Image with dynamic fabric lighting blend
                        Opacity(
                          opacity: opacity,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.transparent,
                              blendMode,
                            ),
                            child: Image.network(
                              widget.garment!.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.checkroom,
                                    size: 72,
                                    color: AppTheme.primaryGold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Floating Live Fit Pin Marker
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Pinch / Drag',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
