import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// A prominent visual tag informing users that the media is an AI visual simulation.
class SimulationBadge extends StatelessWidget {
  final bool isDemo;
  final bool compact;

  const SimulationBadge({super.key, this.isDemo = false, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDisclaimerDialog(context),
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: isDemo
              ? AppTheme.accentAmber.withOpacity(0.18)
              : AppTheme.simulationColor.withOpacity(0.18),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isDemo
                ? AppTheme.accentAmber.withOpacity(0.6)
                : AppTheme.simulationColor.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDemo ? Icons.auto_awesome_outlined : Icons.auto_awesome,
              size: compact ? 12 : 14,
              color: isDemo ? AppTheme.accentEmerald : AppTheme.simulationColor,
            ),
            const SizedBox(width: 5),
            Text(
              isDemo
                  ? AppConstants.demoBadgeText
                  : AppConstants.simulationBadgeText,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDemo ? AppTheme.accentAmber : AppTheme.simulationColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: AppTheme.primaryAccent),
            SizedBox(width: 8),
            Text('Simulation Notice'),
          ],
        ),
        content: const Text(
          AppConstants.simulationDisclaimer,
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
