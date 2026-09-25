# TryFit — Product Requirements Document

**Version:** 3.0 Flutter-first implementation brief  
**Product:** TryFit — AI Virtual Try-On & Personal Fashion Studio  
**Primary client:** Flutter (Android first; iOS supported where dependencies permit; web/desktop considered after mobile baseline)  
**Status:** Implementation specification

## 1. Vision
Help users preview supported garments on their own photos, discover outfits, and organize clothing through a transparent, privacy-conscious fashion studio.

## 2. Product truth and non-goals
TryFit generates visual simulations. It does not determine exact garment size, true fit, comfort, fabric feel, or guaranteed real-world appearance. Do not market generated output as a sizing guarantee.

Not MVP: full CapCut-style editor, unrestricted social network, marketplace payments, guaranteed size prediction, live AR for every garment, model training from user photos, or commercial deployment before license review.

## 3. Users
- Fashion shoppers comparing looks.
- Students and budget-conscious users planning outfits.
- Style enthusiasts experimenting with combinations.
- Later: boutiques and catalog partners.

## 4. MVP scope
### Flutter app
- Welcome/onboarding, consent and privacy explanation.
- Guest/demo mode using bundled synthetic/sample assets only.
- Authentication behind an interface; implement secure auth only when backend configuration is available.
- Try-On Studio: select/upload person photo and garment image; crop, rotate, preview, remove, validate.
- Supported garment category selector driven by backend/model capability.
- Create generation job, show honest queue/processing status, retry/cancel where supported.
- Result view: original/result comparison, zoom, AI-generated label, disclaimer, save, share through OS share sheet, download/export, delete.
- History screen with pagination and deletion.
- Profile/settings: privacy controls, data export/deletion request, accessibility and motion preferences.
- Helpful empty, loading, offline, error, permission denied, and unsupported input states.
- Mock inference mode that is clearly labeled as demo and cannot be confused with real model output.

### Backend/inference
- FastAPI API, PostgreSQL, private object storage, queue, worker.
- Upload validation and signed URLs.
- Async job lifecycle and authenticated result access.
- Mock worker for CI and local use.
- Real model adapter behind interface and feature flag.

## 5. Phase 2
- Digital wardrobe: photo catalog, editable AI tags, category/color/season.
- Outfit builder and saved collections.
- AI stylist: occasion, style preference, budget, weather (only if user supplies/permits), owned-items-only mode.
- Private share links with expiration/revocation.
- User feedback on garment preservation and artifacts.

## 6. Later experiments
- Flutter iOS polish, tablet/desktop responsive layouts.
- AR shoes/headwear/jewelry with supported 3D assets and platform tracking.
- Opt-in social lookbooks and collaborative boards with moderation.
- Retailer/catalog integration and B2B API.
Each later feature requires its own feasibility, privacy, safety, and quality gate.

## 7. Functional requirements
### User and consent
- FR-001: explain image processing, retention, and deletion before personal image upload.
- FR-002: users can use guest demo without uploading personal photos to a real inference service.
- FR-003: authenticated users can view and delete their assets, jobs, results, and account.
- FR-004: separate opt-in required for any model training use; default is no training.

### Image input
- FR-010: support JPEG, PNG, and WebP; configurable byte and pixel limits.
- FR-011: validate actual decoded content, not filename or MIME header alone.
- FR-012: strip EXIF metadata; reject corrupt, unsupported, multi-person, low-quality, or unsuitable images where detectable.
- FR-013: provide crop/rotate and guidance without silently altering body/face.
- FR-014: person and garment assets remain private and ownership-protected.

### Jobs and output
- FR-020: jobs have queued, validating, processing, succeeded, failed, cancelled states.
- FR-021: job status updates are real server status or clearly labeled local demo status.
- FR-022: store model identifier/version and processing metadata.
- FR-023: present AI-generated label and simulation disclaimer wherever results appear.
- FR-024: do not claim exact fit, size, fabric drape, or product fidelity.
- FR-025: retries are idempotent and do not create duplicate charges/jobs where applicable.
- FR-026: support deletion and retention policy enforcement.

### UX and quality
- FR-030: all visible controls perform the stated action or are clearly disabled with explanation.
- FR-031: all screens support loading, success, empty, error, offline, and retry states as applicable.
- FR-032: no fake 0–100% progress unless actual measurable progress is provided.
- FR-033: app handles process death, navigation away, and network interruption during jobs.
- FR-034: analytics are privacy-minimized and do not include raw images or sensitive data.

## 8. Non-functional requirements
- Security: TLS, encrypted storage, scoped signed URLs, least privilege, secure token storage.
- Performance: image work off UI thread; avoid jank; use pagination and image caching with explicit cache clearing.
- Reliability: resumable/retryable upload where practical; idempotent job requests.
- Accessibility: semantic labels, screen-reader support, contrast, scalable text, reduced motion.
- Maintainability: feature-first structure, typed models, repository interfaces, CI, migrations.
- Observability: correlation IDs, structured logs, job latency/failure/queue metrics, no image content in logs.

## 9. Metrics
Activation, successful job completion, p50/p95 latency, crash-free sessions, upload failure rate, UI test pass rate, user-rated output quality, user understanding of preview limitations, deletion completion time, privacy incidents. Establish baselines before targets. Do not claim business impact without controlled evidence.

## 10. MVP acceptance
- Flutter app builds and launches on documented target devices.
- User can complete demo and real configured try-on flows end-to-end.
- All app routes and interactive controls are tested.
- Cross-user data access is denied by backend tests.
- Unsupported inputs fail safely with actionable guidance.
- AI results are labeled, evaluation documented, and not represented as ground-truth fit.
- No secrets or user data in Git.
- CI, UI, API, security, and model quality gates are documented with evidence.
