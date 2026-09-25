import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Permanent editorial banner displayed near try-on generation and results
/// ensuring users understand output is a visual simulation, not an accurate sizing guarantee.
class SimulationDisclaimerBanner extends StatelessWidget {
  final bool compact;

  const SimulationDisclaimerBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.darkBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryGold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.simulationDisclaimer,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: const Color(0xFF94A3B8),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
