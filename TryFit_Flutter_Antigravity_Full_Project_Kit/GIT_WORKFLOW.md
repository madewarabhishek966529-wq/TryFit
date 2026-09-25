# GitHub Workflow — Commit and Push Each Phase

## Initial verification
```bash
git status --short
git branch --show-current
git remote -v
git log -5 --oneline
```
If the repository is not initialized, inspect files first, then initialize only when appropriate. Never overwrite existing Git history.

## Branch policy
- Use a feature branch per phase, e.g. `feat/flutter-foundation`, `feat/tryon-upload`, `feat/tryon-results`.
- If the repo owner has a branch/PR policy, follow it.
- Do not force push or bypass branch protections.
- Do not push directly to main unless explicitly permitted by repository policy.

## Per-phase commit sequence
1. Run tests and UI/AI checks required by the phase.
2. `git diff --check`
3. Inspect `git status --short` and staged diff.
4. Scan for secrets and large/binary files.
5. Stage only intended files.
6. Commit with conventional message.
7. Verify commit exists and working tree is clean.
8. Push the phase branch to the configured remote.
9. Verify push result and record commit hash/remote/branch in phase report.
10. Continue to next phase.

Example:
```bash
git add apps/tryfit_flutter/lib/features/try_on docs
git diff --cached --check
git diff --cached
git commit -m "feat(tryon): implement validated image intake"
git status --short
git push -u origin feat/tryon-upload
```
Commands are examples; adapt paths and branch after inspecting repository.

## No remote/authentication
If `git remote -v` is empty or authentication fails:
- Do not invent a remote URL or request/store credentials in source.
- Continue local work and local commits when safe.
- Tell the user the exact step needed (configure remote/auth in their environment).
- Do not report the phase as pushed.

## Large files
Do not commit model weights, datasets, generated previews, app build folders, or user images. Use approved artifact/model storage and document download instructions. Use Git LFS only after explicit approval and verify repository quota/licensing.
