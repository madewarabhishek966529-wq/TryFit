import '../../../core/constants/app_constants.dart';
import '../../../core/models/asset.dart';
import '../../../core/models/garment_category.dart';
import '../../../core/models/job_status.dart';

/// Complete try-on job entity representing an end-to-end simulation lifecycle.
class TryOnJob {
  final String id;
  final String? idempotencyKey;
  final Asset personAsset;
  final Asset garmentAsset;
  final GarmentCategory category;
  final JobStatus status;
  final String progressMessage;
  final String simulationDisclaimer;
  final Asset? resultAsset;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? modelVersion;
  final bool isDemo;

  const TryOnJob({
    required this.id,
    this.idempotencyKey,
    required this.personAsset,
    required this.garmentAsset,
    required this.category,
    required this.status,
    required this.progressMessage,
    this.simulationDisclaimer = AppConstants.simulationDisclaimer,
    this.resultAsset,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
    this.modelVersion,
    this.isDemo = true,
  });

  TryOnJob copyWith({
    JobStatus? status,
    String? progressMessage,
    Asset? resultAsset,
    String? errorMessage,
    DateTime? completedAt,
    String? modelVersion,
    bool? isDemo,
  }) {
    return TryOnJob(
      id: id,
      idempotencyKey: idempotencyKey,
      personAsset: personAsset,
      garmentAsset: garmentAsset,
      category: category,
      status: status ?? this.status,
      progressMessage: progressMessage ?? this.progressMessage,
      simulationDisclaimer: simulationDisclaimer,
      resultAsset: resultAsset ?? this.resultAsset,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      modelVersion: modelVersion ?? this.modelVersion,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idempotency_key': idempotencyKey,
      'person_asset': personAsset.toJson(),
      'garment_asset': garmentAsset.toJson(),
      'category': category.id,
      'status': status.id,
      'progress_message': progressMessage,
      'simulation_disclaimer': simulationDisclaimer,
      'result_asset': resultAsset?.toJson(),
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'model_version': modelVersion,
      'is_demo': isDemo,
    };
  }

  factory TryOnJob.fromJson(Map<String, dynamic> json) {
    return TryOnJob(
      id: json['id'] as String,
      idempotencyKey: json['idempotency_key'] as String?,
      personAsset: Asset.fromJson(json['person_asset'] as Map<String, dynamic>),
      garmentAsset: Asset.fromJson(
        json['garment_asset'] as Map<String, dynamic>,
      ),
      category: GarmentCategory.fromId(json['category'] as String),
      status: JobStatus.fromId(json['status'] as String),
      progressMessage: json['progress_message'] as String? ?? '',
      simulationDisclaimer:
          json['simulation_disclaimer'] as String? ??
          AppConstants.simulationDisclaimer,
      resultAsset: json['result_asset'] != null
          ? Asset.fromJson(json['result_asset'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      modelVersion: json['model_version'] as String?,
      isDemo: json['is_demo'] as bool? ?? true,
    );
  }
}
