import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Editorial AR alignment HUD overlay.
/// Isolates custom painting inside a RepaintBoundary to eliminate frame drops.
class PoseGuideOverlay extends StatelessWidget {
  final bool showGuides;
  final String statusText;
  final bool isAligned;

  const PoseGuideOverlay({
    super.key,
    this.showGuides = true,
    this.statusText = 'Align torso in frame • Hold steady',
    this.isAligned = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGuides) return const SizedBox.shrink();

    return RepaintBoundary(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PoseGuidePainter(isAligned: isAligned),
              ),
            ),
            // Floating Status Pill
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(
                      color: isAligned
                          ? AppTheme.accentEmerald.withOpacity(0.8)
                          : AppTheme.accentAmber.withOpacity(0.8),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAligned
                              ? AppTheme.accentEmerald
                              : AppTheme.accentAmber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoseGuidePainter extends CustomPainter {
  final bool isAligned;

  const _PoseGuidePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final guideColor = isAligned
        ? AppTheme.accentEmerald.withOpacity(0.4)
        : AppTheme.accentAmber.withOpacity(0.35);

    final linePaint = Paint()
      ..color = guideColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashedPaint = Paint()
      ..color = guideColor.withOpacity(0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height * 0.45;

    // Torso Target Box (Chest & Shoulders bounding area)
    final boxWidth = size.width * 0.68;
    final boxHeight = size.height * 0.52;
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: boxWidth,
      height: boxHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    canvas.drawRRect(rrect, linePaint);

    // Corner brackets accent
    final bracketLen = 22.0;
    final cornerPaint = Paint()
      ..color = isAligned ? AppTheme.accentEmerald : AppTheme.accentAmber
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(bracketLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(0, bracketLen),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(-bracketLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(0, bracketLen),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(bracketLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(0, -bracketLen),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(-bracketLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(0, -bracketLen),
      cornerPaint,
    );

    // Subtle horizontal shoulder guideline
    final shoulderY = rect.top + rect.height * 0.28;
    canvas.drawLine(
      Offset(rect.left + 20, shoulderY),
      Offset(rect.right - 20, shoulderY),
      dashedPaint,
    );

    // Center vertical spine guideline
    canvas.drawLine(
      Offset(centerX, rect.top + 10),
      Offset(centerX, rect.bottom - 10),
      dashedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PoseGuidePainter oldDelegate) =>
      oldDelegate.isAligned != isAligned;
}
