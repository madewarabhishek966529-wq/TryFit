# Environment and Setup

## Prerequisites
- Flutter SDK stable compatible with repository; verify with `flutter --version`.
- Dart version bundled with selected Flutter SDK.
- Android Studio/Android SDK and emulator or physical Android device.
- Git and GitHub authentication configured in the developer environment.
- Python supported by FastAPI dependencies.
- Docker Desktop/Engine for local backend services.
- Optional GPU and drivers for real inference; mock mode must work without GPU.

## Initial inspection commands
```bash
flutter --version
flutter doctor -v
git status --short
git remote -v
docker version
python --version
```
Record actual versions in the phase report. Do not upgrade tooling blindly.

## Environment variables
Create `.env` from `.env.example` locally. Never commit `.env`.
Typical server-side placeholders (names finalized during implementation):
- `DATABASE_URL`
- `REDIS_URL`
- `OBJECT_STORAGE_ENDPOINT`
- `OBJECT_STORAGE_BUCKET`
- `OBJECT_STORAGE_ACCESS_KEY`
- `OBJECT_STORAGE_SECRET_KEY`
- `AUTH_ISSUER` / auth provider settings
- `TRYFIT_INFERENCE_MODE=mock`
- `MODEL_ID` / `MODEL_REVISION` only after approval

Do not embed server secrets in Flutter assets or `--dart-define` values shipped to users. Client configuration may include only non-secret API base URL and public identifiers.

## Local development
Start with mock inference and local object storage. Confirm health checks, migrations, and test suite before connecting a real model. Add exact copy/paste commands after repo structure and versions are inspected.

## Troubleshooting
- Android device not listed: check `flutter doctor -v`, SDK licenses, USB debugging or emulator boot.
- Gradle failure: capture full log; verify JDK/Gradle/AGP compatibility before changing versions.
- Docker daemon unavailable: start Docker Desktop and verify `docker version`.
- Model OOM: reduce supported resolution/batch, profile VRAM, or use an approved GPU worker; never silently degrade output.
- API unavailable: show offline state and retry; never present mock output as real.
