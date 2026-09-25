# TryFit — AI Virtual Try-On & Personal Fashion Studio

TryFit is a Flutter-first AI virtual try-on application and personal fashion studio with high-performance 120 FPS architecture, zero frame drops, and snappy offline-first user experience. It features a real-time Live AR Camera Virtual Try-On Studio where users can preview clothes directly over their live camera feed, switch garments instantly, and synthesize realistic fits completely offline.

> **Disclaimer:** Generated try-on images are visual simulations, not verified sizing, physical fit, fabric drape, or guaranteed real-world appearance. TryFit does not claim exact sizing accuracy.

---

## 🌟 Key Features

- **Live AR Camera Try-On Studio**:
  - Real-time hardware camera feed with zero-latency viewfinder.
  - Interactive live clothing overlay with pinch-to-scale, drag-to-align, and fabric blend adjustments (Normal, Soft Light, Multiply).
  - Editorial AR pose & torso alignment HUD with real-time stability guidance.
  - Bottom live clothing dock with category filtering (All, Tops, Dresses, Outerwear) and 1-tap live switching.
  - 1-tap shutter capture triggering the background offline fitting synthesis engine.
  - Seamless fallback mode for desktop/emulator/permission-denied environments ensuring zero crashes.
- **Studio Photo Mode**:
  - Real device camera capture and photo gallery picker with background isolate validation (`ImageValidator.validateImageBytesAsync`).
  - Curated sample models and garments for zero-upload exploration.
- **120 FPS Performance Architecture**:
  - Strict `RepaintBoundary` isolation on camera viewfinders, overlay manipulators, and scrolling list items.
  - Fine-grained reactive state (`ValueNotifier` / `ListenableBuilder`) eliminating full-tree rebuilds during interaction.
  - Heavy image byte validation and synthesis offloaded to background Isolates via `compute()`.
  - Frame budget under 8.33ms for butter-smooth touch responsiveness.
- **Snappy Offline-First Persistence**:
  - Backed by `SharedPreferences` via `LocalStorageService`.
  - Permanent local persistence of wardrobe items, try-on history, and user preferences without requiring internet access or cloud servers.
- **Digital Wardrobe**:
  - Interactive collection view, category filters, and custom item registration.
- **AI Fashion Stylist**:
  - Curated looks, style recommendations, and outfit pairing.
- **Privacy & Consent First**:
  - Transparent consent screen, EXIF stripping, zero external data leakage, and one-tap data purge.

---

## 🏗️ Architecture

```text
tryfit/
├── lib/
│   ├── app/                 # App bootstrap, routing, theme, dependency injection
│   ├── core/
│   │   ├── constants/       # App constants & constraints
│   │   ├── errors/          # Failures & exceptions
│   │   ├── models/          # Core entities (Asset, GarmentCategory, JobStatus)
│   │   ├── services/        # CameraService, LocalStorageService (Offline-First)
│   │   ├── theme/           # Editorial design tokens & typography
│   │   ├── utils/           # ImageValidator (magic bytes check via compute)
│   │   └── widgets/         # Shared buttons, banners, badges
│   └── features/
│       ├── onboarding/      # Consent & privacy disclosure
│       ├── try_on/
│       │   ├── data/        # Mock fixtures & OfflineFittingEngine (compute isolate)
│       │   ├── domain/      # Repository contracts & entities
│       │   └── presentation/# LiveCameraStudio, StudioScreen, overlays, docks
│       ├── history/         # Try-on session history & offline cache
│       ├── wardrobe/        # Digital wardrobe & outfit builder
│       ├── stylist/         # Personal AI stylist
│       └── profile/         # Settings, privacy controls, data export & deletion
└── test/                    # Unit, domain, and widget test suite
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.47.x or later (Channel stable)
- **Dart SDK**: 3.13.x or later
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

---

## 🔒 Security & Privacy

1. **Offline First**: All photo processing, wardrobe items, and simulation history remain on device.
2. **Explicit Consent**: Transparent disclosure of image processing prior to photo intake.
3. **Data Minimization**: EXIF metadata stripped; raw user photos are never committed or logged.
4. **User Control**: Complete one-tap deletion of all assets, jobs, and history.

---

## 📄 License & Attribution

TryFit is open-source under the MIT License.
