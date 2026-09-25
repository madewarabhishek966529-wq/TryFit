# AGENTS.md — TryFit Autonomous Development Contract

## 0. First actions
1. Read every root Markdown file, especially PRD, ARCHITECTURE, TASKS, TESTING_AND_QA, GIT_WORKFLOW, SECURITY_PRIVACY, and AI_MODEL_EVALUATION.
2. Inspect the existing repository, current branch, git status, remotes, app structure, dependency versions, and available SDKs before editing.
3. Preserve working code and user changes. Never overwrite or delete project files without inspecting and explaining the impact.
4. Produce a short implementation plan and identify blockers, but then proceed autonomously through safe, well-defined work. Ask only when a decision requires credentials, paid services, legal approval, destructive changes, or a user-specific product choice.
5. Do not invent API keys, remote URLs, model weights, test results, or successful deployment status.

## 1. Product and stack requirements
- Flutter is the primary client framework. Use Dart and Flutter stable already installed in the environment; do not upgrade Flutter/Dart or major packages without approval and compatibility checks.
- Use feature-first, layered architecture with clear presentation, domain, and data boundaries.
- Keep inference out of Flutter UI isolates and out of synchronous API request handlers.
- Build an end-to-end mock AI adapter first so all app flows can be developed and tested without paid APIs or a GPU.
- Real AI model integration is gated on license, model card, hardware, quality, and data-provenance review.
- Backend default: Python FastAPI, PostgreSQL, private S3-compatible storage, Redis-backed queue, isolated inference worker. Local development may use Docker Compose and MinIO.
- Do not introduce Firebase, Supabase, Ollama, or a cloud AI API unless explicitly approved by the project owner. Keep providers behind interfaces.

## 2. Autonomous implementation loop
For each phase or coherent folder:
1. Read related requirements and acceptance criteria.
2. Inspect existing implementation and dependencies.
3. Implement the smallest complete vertical slice.
4. Run formatter, analyzer/linter, unit tests, and relevant integration/e2e tests.
5. Launch the app and inspect relevant screens at phone and tablet/desktop sizes when supported.
6. Test interaction states: initial, loading, success, empty, error, offline, permission denied, and retry.
7. For AI features, run the documented evaluation set and inspect outputs; mock output is not evidence of real-model quality.
8. Fix failures and rerun affected tests; record exact commands, environment, result, and known limitations.
9. Update TASKS.md, CHANGELOG.md, and MEMORY/DECISIONS where needed.
10. Commit the completed phase with a conventional commit message.
11. Push to the configured GitHub remote only after verifying branch, remote, diff, tests, and absence of secrets/large artifacts.
12. Continue to the next phase only after the gate passes or a clearly documented blocker is escalated.

## 3. Git safety
- Start with `git status --short`, `git branch --show-current`, and `git remote -v`.
- Never force-push, rewrite shared history, change default branch, or delete branches without explicit authorization.
- Never push directly to a protected/main branch if project policy or remote protection disallows it. Use a feature branch and PR instead.
- Never commit `.env`, credentials, private images, model weights, datasets, build outputs, signing keys, or local databases.
- If no GitHub remote or authentication is configured, finish local commit if safe, report the exact blocker, and continue local work; do not fabricate a push.
- Before each commit, inspect `git diff --check`, `git status`, staged diff, and secret scan.
- Commit after each completed phase/folder, not after every trivial file. Push after each phase as requested.
- Suggested commit format: `feat(tryon): add validated upload flow`, `test(ui): cover try-on states`, `docs: record phase 2 results`.

## 4. Quality bar
- No placeholder buttons that appear functional but do nothing.
- No fake progress percentages or fabricated model results presented as real.
- No TODO-only implementations for core MVP flows.
- No swallowed exceptions; show actionable safe errors and log diagnostic IDs.
- No hardcoded secrets, user IDs, local machine paths, or production URLs.
- Use typed models, repository/service interfaces, dependency injection, and centralized error handling.
- Add tests with every feature and bug fix.
- Ensure responsive layouts, accessibility semantics, keyboard navigation where applicable, reduced-motion support, and usable touch targets.
- Avoid body-shaming, discriminatory styling advice, or sensitive-trait inference.

## 5. Required reporting after each phase
Append to `TASKS.md` or create `reports/phase-N-report.md` containing:
- Scope completed and files/folders changed.
- Commands run and exact pass/fail results.
- UI routes/devices tested and screenshots or artifacts location (no private user photos).
- AI model/version, test-set identifier, evaluation metrics, representative approved test outputs, failures, and limitations.
- Git commit hash, branch, remote, push result, and PR link if applicable.
- Remaining issues and next phase.

## 6. Definition of done
A phase is done only when its acceptance criteria, automated checks, relevant manual/UI checks, documentation updates, and Git commit are complete. The entire project is done only when all release gates in TASKS.md and TESTING_AND_QA.md pass. Never claim “perfect” or guaranteed correctness; report evidence and residual risk.
