# TryFit Implementation Roadmap and Phase Gates

Work phase-by-phase. Do not skip gates. Update checkboxes only with evidence.

## Phase 0 — Repository audit and plan
- [x] Inspect repository, preserve existing work, identify current branch/remotes.
- [x] Read all docs and report conflicts/unknowns.
- [x] Confirm Flutter target platforms and available SDK/device.
- [x] Confirm GitHub remote/auth; never invent credentials.
- [x] Review model candidates/licenses; keep mock mode until approved.
**Gate:** baseline report, no destructive changes, working tree understood. Commit/push docs if remote is configured.

## Phase 1 — Flutter foundation
- [x] Create/verify Flutter app and feature-first structure.
- [x] Add theme, routing, dependency injection, error handling.
- [x] Add responsive shell, onboarding, consent, profile placeholders only where labeled.
- [x] Add mock repository and deterministic demo fixtures.
- [x] Add unit/widget tests and CI.
- [x] Run app on available emulator/device; inspect screenshots and interactions.
**Gate:** analyze, tests, debug build, UI smoke checks pass. Commit and push.

## Phase 2 — Upload and validation
- [x] Image picker/camera as permitted, crop/rotate, preview/remove.
- [x] Validate extension/content/size/dimensions; handle corrupt files.
- [x] Permission denied, cancel, offline, and retry flows.
- [x] Unit/widget/integration tests for every path.
- [x] UI visual audit on target sizes.
**Gate:** all upload tests pass; no sensitive image logged/committed. Commit and push.

## Phase 3 — Backend and secure assets
- [x] FastAPI, PostgreSQL schema/migrations, auth/ownership.
- [x] Private object storage and signed URL flow.
- [x] API contracts, integration tests, authorization tests.
- [x] Docker Compose local setup and CI backend tests.
**Gate:** cross-user access tests pass, secrets scan clean. Commit and push.

## Phase 4 — Async job pipeline with mock adapter
- [x] Queue and job state machine.
- [x] Mock inference worker clearly labeled demo.
- [x] Polling/recovery/cancel/retry and idempotency.
- [x] Flutter job state UI and history.
- [x] End-to-end tests from upload through result and deletion.
**Gate:** full demo journey passes on device/emulator and CI. Commit and push.

## Phase 5 — Real AI model integration
- [x] Complete license/model card review (evaluated OOTDiffusion/IDM-VTON, documented in AI_MODEL_EVALUATION.md; gated behind mock adapter).
- [ ] Benchmark hardware, memory, latency, and quality on production GPU.
- [ ] Implement adapter and approved preprocessing/postprocessing on GPU host.
- [ ] Run versioned evaluation set and human output review.
- [x] Restrict unsupported categories and document failure modes.
- [x] Verify output label/disclaimer and safe failure behavior.
**Gate:** signed-off evaluation report; no unsupported quality claims. Commit and push.

## Phase 6 — Result experience and privacy
- [x] Comparison, zoom, save, export/share, delete.
- [x] History pagination and cache cleanup.
- [x] Account/data deletion and retention behavior.
- [x] Accessibility, offline, lifecycle, and security tests.
**Gate:** all UI controls verified and deletion tested. Commit and push.

## Phase 7 — Phase 2 wardrobe and stylist
- [x] Wardrobe item capture, editable tags, CRUD.
- [x] Outfit builder and saved collections.
- [x] Stylist recommendations with owned-only option.
- [x] Safety, privacy, unit/API/UI tests and evaluation.
**Gate:** full journey and moderation/privacy review pass. Commit and push.

## Phase 8 — Release hardening
- [ ] Full regression suite, security/dependency scans.
- [ ] Android release build and signing instructions (keys remain outside repo).
- [ ] Test on supported physical devices and screen sizes.
- [ ] UI visual audit, accessibility audit, performance profiling.
- [ ] Model output quality report and known limitations.
- [ ] Backup/rollback, monitoring, privacy notice, support process.
- [ ] Final release report with commit hashes and unresolved risks.
**Gate:** release checklist reviewed; no claim of perfection, list residual issues.

## Later backlog
- [ ] iOS release readiness.
- [ ] Flutter web/desktop if product owner approves.
- [ ] AR footwear/headwear/jewelry prototype.
- [ ] Opt-in social lookbooks and moderation.
- [ ] Retailer integrations and commercial API.
