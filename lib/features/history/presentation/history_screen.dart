import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/asset.dart';
import '../../../core/models/job_status.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/simulation_badge.dart';
import '../../try_on/domain/try_on_models.dart';
import '../../try_on/domain/try_on_repository.dart';
import '../../try_on/presentation/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  final TryOnRepository repository;

  const HistoryScreen({super.key, required this.repository});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TryOnJob> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final items = await widget.repository.getHistory();
      if (!mounted) return;
      setState(() {
        _history = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    await widget.repository.deleteResult(id);
    _loadHistory();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Try-On History?'),
        content: const Text(
          'This will permanently delete all simulation history and cached preview assets from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppTheme.accentRose),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository.clearAllData();
      _loadHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All history cleared.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Try-On History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppTheme.accentRose,
              ),
              tooltip: 'Clear All History',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? EmptyStateView(
              icon: Icons.history_toggle_off_outlined,
              title: 'No Try-On History Yet',
              description: 'Generate your first virtual try-on in the Studio to review looks here.',
              actionLabel: 'Go to Studio',
              onAction: () => Navigator.pop(context),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = _history[index];
                final dateStr = DateFormat('MMM d, y • h:mm a')
                    .format(job.createdAt);

                return Dismissible(
                  key: Key(job.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => _deleteItem(job.id),
                  child: InkWell(
                    onTap: () {
                      if (job.status == JobStatus.succeeded) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ResultScreen(
                              job: job,
                              repository: widget.repository,
                            ),
                          ),
                        ).then((_) => _loadHistory());
                      }
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                            child: Container(
                              width: 60,
                              height: 75,
                              color: AppTheme.darkSurfaceElevated,
                              child: _buildThumbnail(
                                job.resultAsset ?? job.garmentAsset,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      job.category.label,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SimulationBadge(
                                      isDemo: job.isDemo,
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  job.status.displayLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: job.status == JobStatus.succeeded
                                        ? AppTheme.accentEmerald
                                        : AppTheme.accentAmber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () => _deleteItem(job.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildThumbnail(Asset asset) {
    if (asset.bytes != null) {
      return Image.memory(asset.bytes!, fit: BoxFit.cover);
    }
    if (asset.uri.startsWith('http')) {
      return Image.network(
        asset.uri,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 20, color: Colors.grey),
        ),
      );
    }
    return const Center(child: Icon(Icons.image, size: 20));
  }
}
