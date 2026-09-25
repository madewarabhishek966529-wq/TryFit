# Testing, QA, and Release Gates

Testing is continuous, not a final optional step. Antigravity must run relevant checks after each phase and record actual results in `reports/`.

## 1. Flutter static and unit checks
Run from `apps/tryfit_flutter` (adapt only if actual structure differs):
```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```
Fix analyzer errors and test failures. Do not suppress lints globally to get a green build. Review coverage for domain logic, validation, state transitions, and error mapping.

## 2. Flutter widget/UI tests
- Test every primary route and key widget.
- Test taps on every visible button, menu, tab, upload/remove, retry, save, share, delete, and navigation control.
- Assert navigation destination and resulting state.
- Test loading, empty, success, failure, offline, permission denied, and long-text states.
- Test form validation and unsupported image feedback.
- Test responsive constraints and text scaling.
- Verify no RenderFlex overflow, unbounded constraints, uncaught exception, or missing asset.
- Verify semantics labels and keyboard traversal where applicable.
- Run widget tests with deterministic mock repositories; no network or GPU in unit CI.

## 3. Device/emulator integration
Run `flutter devices`, then select available supported Android emulator/device. Execute:
```bash
flutter test integration_test
```
Where appropriate, also build:
```bash
flutter build apk --debug
```
For release candidate:
```bash
flutter build apk --release
```
Only claim device testing for devices actually used. Record OS, device/emulator, screen size, Flutter version, commands, and results.

## 4. Backend checks
From backend API and worker directories, use documented commands such as:
```bash
python -m pytest -q
```
Also run format/lint/type checks selected by repository (e.g. Ruff, mypy) and migration checks. Test auth, ownership, validation, job transitions, retry/idempotency, signed URL expiry, deletion, and rate limits.

## 5. End-to-end scenarios
- Fresh install -> consent -> demo try-on -> result -> save -> history -> delete.
- Permission denied -> explain -> continue with file picker or settings guidance.
- Invalid/corrupt/oversized image -> safe rejection and recovery.
- Network drops during upload -> clear error/retry; no duplicate job.
- App background/termination during processing -> reopen and recover job status.
- API 401/403/404/429/5xx -> correct UI response; no data leakage.
- User A cannot retrieve User B's asset/job/result.
- Account deletion removes/queues removal of all related assets per retention policy.
- Guest demo never accidentally sends fixture/personal data to an unconfigured real inference endpoint.

## 6. UI visual and interaction audit
For each release phase:
1. Launch app on available target(s).
2. Navigate every screen and capture screenshots.
3. Inspect alignment, clipping, safe areas, keyboard overlap, scroll behavior, image aspect ratios, theme contrast, loading/empty/error states.
4. Test all interactions manually or via integration tests.
5. Review animations at normal and reduced motion.
6. Record findings and fixes in `reports/phase-N-report.md`.
7. Do not claim visual QA passed based solely on compilation or widget tests.

## 7. AI output quality gate
A real model is not considered validated by a successful API response.
- Create a permissioned, documented evaluation set covering supported categories, poses, lighting, body representation, skin tones, garment colors/patterns, and image quality.
- Do not include private user images without explicit informed consent.
- Freeze and version the evaluation set; use the same set for comparisons.
- Evaluate: garment identity/pattern preservation, person/face consistency, anatomy/artifacts, category correctness, input failure handling, latency, peak VRAM, failure rate.
- Use human review rubric and, where suitable, image similarity/quality metrics; explain metric limitations.
- Record model name, exact version/commit, weights source/license, hardware, parameters, random seeds where supported, output artifacts, reviewer notes, and known failure modes.
- Test prompt/instruction injection and unsafe image cases.
- Never use the mock adapter's output to claim real-model quality.
- Release only for categories meeting documented acceptance thresholds; otherwise disable category or label as experimental.

## 8. Security and privacy QA
- Secret scan and dependency vulnerability scan.
- Confirm `.env`, signing keys, model weights, datasets, and personal images are ignored.
- Test authorization and signed URL expiration.
- Check logs for tokens, image URLs, filenames containing personal data, or image contents.
- Verify logout cache clearing and deletion behavior.
- Review package licenses and model/data licenses.

## 9. CI gates
CI should run on pull requests and pushes:
- Flutter format, analyze, unit/widget tests.
- Backend lint/type/unit/integration tests with mock inference.
- Secret/dependency scanning where available.
- Build verification for supported targets.
- No real GPU required in standard CI; schedule separate GPU/model evaluation when available.

## 10. Release report template
- Commit/branch:
- Environment and versions:
- Features in scope:
- Commands run and exact outcomes:
- Unit/widget/integration/e2e results:
- Device and UI screenshots reviewed:
- AI evaluation version and metrics (or “not run; mock only”):
- Security/privacy checks:
- Known issues and limitations:
- Release decision and approver:
