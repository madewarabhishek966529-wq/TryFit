# TryFit — AI Virtual Try-On & Personal Fashion Studio

TryFit is a Flutter-first AI virtual try-on application and personal fashion studio. It enables users to preview supported garments on their own photos, explore curated styles, manage their digital wardrobe, and experiment with combinations in a privacy-conscious, transparent environment.

> **Disclaimer:** Generated try-on images are visual simulations, not verified sizing, physical fit, fabric drape, or guaranteed real-world appearance. TryFit does not claim exact sizing accuracy.

---

## 🌟 Key Features

- **Try-On Studio**: Select/upload person photo and garment image, validate inputs, crop & rotate, preview, and process.
- **Deterministic Demo / Mock Mode**: Full client & backend testing without requiring a GPU or paid API.
- **Async Job Pipeline**: Honest status tracking (`queued`, `validating`, `processing`, `succeeded`, `failed`, `cancelled`).
- **Interactive Result Viewer**: Side-by-side / split comparison, interactive zoom, AI-generated disclosure label, export, download, and delete.
- **Try-On History**: Paginated history of sessions with local cache management and single-tap deletion.
- **Digital Wardrobe (Phase 2)**: Item catalog, category tagging, color/season filters, and outfit builder.
- **AI Fashion Stylist (Phase 2)**: Occasion, style preference, budget, and owned-item recommendation studio.
- **Privacy & Consent First**: Transparent consent screen, EXIF stripping, scoped signed URLs, no automated model training on personal images, and one-tap data deletion.

---

## 🏗️ Architecture

```text
tryfit/
├── lib/
│   ├── app/                 # App bootstrap, routing, theme, dependency injection
│   ├── core/                # Errors, networking, config, utils, design system
│   └── features/
│       ├── onboarding/      # Welcome, consent & privacy disclosure
│       ├── auth/            # Auth interface & session management
│       ├── try_on/          # Studio, image intake, validation, job progress, result viewer
│       ├── history/         # Try-on session history & caching
│       ├── wardrobe/        # Phase 2 digital wardrobe & outfit builder
│       ├── stylist/         # Phase 2 personal AI stylist
│       └── profile/         # Settings, privacy controls, data export & deletion
├── backend/
│   ├── api/                 # FastAPI REST API (v1 endpoints)
│   ├── worker/              # Asynchronous job queue consumer & mock/real model adapters
│   └── tests/               # Backend API and isolation tests
├── test/                    # Unit, domain, and widget test suite
├── integration_test/        # Flutter end-to-end integration tests
└── docs/                    # Architectural decisions, PRD, and QA reports
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.47.x or later (Channel stable)
- **Dart SDK**: 3.13.x or later
- **Python**: 3.10+ (for backend services)
- **Git**

### Running the Flutter Client

```bash
# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run the app (on connected device, web, or emulator)
flutter run
```

### Running Backend Services

```bash
# Navigate to backend
cd backend

# Create virtual environment and install dependencies
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows
pip install -r requirements.txt

# Run FastAPI server
uvicorn api.main:app --reload --port 8000
```

---

## 🔒 Security & Privacy

1. **Explicit Consent**: Transparent disclosure of image processing and retention prior to personal photo upload.
2. **Data Minimization**: EXIF metadata stripped; raw user photos are never committed, logged, or used for model training without opt-in.
3. **User Control**: Complete one-tap deletion of assets, jobs, and history.

---

## 📄 License & Attribution

TryFit is open-source under the MIT License. Model weights and third-party adapters operate under their respective non-commercial / permissive licenses.
