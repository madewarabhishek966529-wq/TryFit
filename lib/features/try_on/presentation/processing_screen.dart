import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/job_status.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/simulation_badge.dart';
import '../domain/try_on_models.dart';
import '../domain/try_on_repository.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final TryOnJob initialJob;
  final TryOnRepository repository;

  const ProcessingScreen({
    super.key,
    required this.initialJob,
    required this.repository,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late TryOnJob _currentJob;
  Timer? _pollingTimer;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentJob = widget.initialJob;
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1400), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        final updated = await widget.repository.getJob(_currentJob.id);
        if (!mounted) return;

        setState(() {
          _currentJob = updated;
        });

        if (updated.status == JobStatus.succeeded) {
          timer.cancel();
          // Short pause for user to see completion before navigation
          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) =>
                  ResultScreen(job: updated, repository: widget.repository),
            ),
          );
        } else if (updated.status.isTerminal) {
          timer.cancel();
        }
      } catch (e) {
        // Safe error handling
      }
    });
  }

  Future<void> _handleCancel() async {
    setState(() => _isCancelling = true);
    _pollingTimer?.cancel();
    try {
      final cancelled = await widget.repository.cancelJob(_currentJob.id);
      if (!mounted) return;
      setState(() {
        _currentJob = cancelled;
        _isCancelling = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentJob.status == JobStatus.failed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Processing Failed')),
        body: ErrorView(
          title: 'Simulation Could Not Complete',
          message: _currentJob.errorMessage ?? 'The model could not process this combination. Check garment alignment or select another category.',
          onRetry: () => Navigator.pop(context),
          retryLabel: 'Return to Studio',
        ),
      );
    }

    if (_currentJob.status == JobStatus.cancelled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Cancelled')),
        body: ErrorView(
          title: 'Simulation Cancelled',
          message: 'This try-on job was cancelled by request. No assets were altered.',
          onRetry: () => Navigator.pop(context),
          retryLabel: 'Back to Studio',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synthesizing Try-On'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SimulationBadge(isDemo: false),
              const SizedBox(height: 36),
              // Indeterminate animated progress circle (honest, no fake % counter)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryAccent,
                      ),
                      backgroundColor: AppTheme.darkBorder,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.darkSurfaceElevated,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                _currentJob.status.displayLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _currentJob.progressMessage.isNotEmpty
                    ? _currentJob.progressMessage
                    : 'Synthesizing cloth deformation and lighting match...',
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildPipelineStep(
                title: 'Queue Intake',
                status: _getStepStatus(0),
              ),
              const SizedBox(height: 12),
              _buildPipelineStep(
                title: 'Pose & Silhouette Validation',
                status: _getStepStatus(1),
              ),
              const SizedBox(height: 12),
              _buildPipelineStep(
                title: 'Garment Warp & Color Transfer',
                status: _getStepStatus(2),
              ),
              const SizedBox(height: 12),
              _buildPipelineStep(
                title: 'Rendering Output Simulation',
                status: _getStepStatus(3),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isCancelling ? null : _handleCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentRose,
                    side: const BorderSide(color: AppTheme.accentRose),
                  ),
                  child: _isCancelling
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentRose,
                            ),
                          ),
                        )
                      : const Text('Cancel Simulation'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  int _getStepStatus(int stepIndex) {
    // 0: completed, 1: in progress, 2: pending
    switch (_currentJob.status) {
      case JobStatus.queued:
        return stepIndex == 0 ? 1 : 2;
      case JobStatus.validating:
        if (stepIndex == 0) return 0;
        if (stepIndex == 1) return 1;
        return 2;
      case JobStatus.processing:
        if (stepIndex <= 1) return 0;
        if (stepIndex == 2) return 1;
        return 2;
      case JobStatus.succeeded:
        return 0;
      default:
        return 2;
    }
  }

  Widget _buildPipelineStep({required String title, required int status}) {
    Color iconColor;
    IconData icon;

    if (status == 0) {
      iconColor = AppTheme.accentEmerald;
      icon = Icons.check_circle;
    } else if (status == 1) {
      iconColor = AppTheme.primaryAccent;
      icon = Icons.radio_button_checked;
    } else {
      iconColor = const Color(0xFF64748B);
      icon = Icons.radio_button_off;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: status == 1 ? FontWeight.w600 : FontWeight.normal,
            color: status == 2 ? const Color(0xFF64748B) : Colors.white,
          ),
        ),
      ],
    );
  }
}
