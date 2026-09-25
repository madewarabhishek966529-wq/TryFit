# TryFit Architecture — Flutter First

## 1. Monorepo layout
```text
tryfit/
  apps/
    tryfit_flutter/
      lib/
        app/                 # app bootstrap, router, theme, DI
        core/                # errors, network, config, utils, widgets
        features/
          onboarding/
          auth/
          try_on/
          history/
          wardrobe/           # phase 2
          stylist/            # phase 2
          profile/
      test/
      integration_test/
  backend/
    api/                     # FastAPI
    worker/                  # queue consumer and model adapters
    tests/
  infra/                     # compose, deployment, monitoring examples
  docs/                      # project docs and QA reports
  scripts/
  .github/workflows/
```

## 2. Flutter architecture
Use feature-first clean architecture:
- Presentation: screens, widgets, view models/state notifiers.
- Domain: entities, use cases, repository contracts.
- Data: DTOs, API clients, local cache, repository implementations.

Choose a state management and routing pair after inspecting the existing repo. If greenfield, prefer Riverpod and go_router, subject to current Flutter compatibility. Use Dio or package:http behind a typed ApiClient. Use secure storage for tokens; never store tokens in shared preferences.

Recommended packages are candidates, not a mandate: image_picker or file_picker, image_cropper, flutter_image_compress, cached_network_image, flutter_secure_storage, connectivity_plus, share_plus, path_provider, permission_handler, freezed/json_serializable, riverpod, go_router. Verify current package maintenance, license, platform support, and versions before adding.

## 3. Backend components
- FastAPI: auth integration, asset metadata, job API, history, privacy requests.
- PostgreSQL: users, consent, assets, jobs, results, wardrobe, audit events.
- S3-compatible private object store; MinIO locally.
- Redis queue and one selected worker framework (Celery, RQ, or Dramatiq—choose one).
- Worker: validates inputs, preprocesses, calls model adapter, stores output, updates job.
- Mock adapter: deterministic, watermarked test fixture output for CI; never imply it is a real AI result.

## 4. Try-on flow
Flutter requests signed upload URL -> uploads directly to private storage -> creates job -> API validates ownership and writes job -> queue -> worker loads assets -> preprocessing -> model adapter -> postprocessing and output validation -> private output storage -> job succeeded -> Flutter polls or receives supported notification -> API authorizes and issues short-lived result URL.

## 5. Interfaces
`TryOnRepository`: uploadPersonImage, uploadGarmentImage, createJob, getJob, cancelJob, getHistory, deleteAsset, deleteResult.
`TryOnModelAdapter`: healthCheck, validateInputs, preprocess, infer, postprocess, evaluate.
`InferenceResult`: output asset, model ID/version, warnings, elapsed time, quality flags.

## 6. Offline and demo behavior
- Demo mode uses local bundled fixtures and simulated states, explicitly marked DEMO.
- Offline mode permits viewing cached non-sensitive metadata where appropriate; do not claim generation works offline unless a real on-device model is installed and tested.
- Queue requests only when product behavior is explicitly designed; otherwise show retry.
- Clear sensitive caches on logout and account deletion.

## 7. Environments
Local: Docker Compose for PostgreSQL, Redis, MinIO, API, mock worker; Flutter runs on emulator/device.
CI: mock inference, seeded synthetic fixtures, no real user data or GPU dependency.
Staging: private bucket, isolated test accounts, feature flags.
Production: TLS, managed DB/storage/queue, GPU workers, secret manager, backups, monitoring, documented rollback.

## 8. Architectural constraints
- No inference in Flutter widget build methods or API request handlers.
- Never load arbitrary user-supplied remote URLs from worker.
- All DB access scoped by authenticated user/tenant.
- Model adapter and storage provider are replaceable.
- All async UI work handles cancellation, disposal, and stale responses.
