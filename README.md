# CaptureYourLife 📸

> A premium Android camera app built with **Flutter + Firebase**. Capture, store, and share your life's moments — with AI features coming soon.

---

## 🎯 Project Overview

CaptureYourLife is a full-stack mobile app that lets users:
- **Register / Sign in** securely with Firebase Auth
- **Capture photos** using the device camera or import from gallery
- **Store photos** locally on the device (saving cloud costs)
- **Store metadata** in Firestore for real-time gallery sync
- **Browse their gallery** in a real-time grid view
- **View photos full-screen** with pinch-to-zoom, share, and save-to-device
- **AI Studio** (sticker & avatar generation — Phase 2, coming soon)

**Stack:** Flutter · Firebase Auth · Firestore · Local Device Storage · FastAPI · Python

---

## 🏗️ Project Structure

```
CaptureYourLife/
├── backend/                         # FastAPI Python backend (for AI phase)
│   ├── app/
│   │   ├── main.py                  # FastAPI entry point
│   │   ├── config.py                # App configuration
│   │   ├── models.py                # Pydantic models
│   │   ├── dependencies.py          # Firebase Admin & JWT auth
│   │   ├── routes/
│   │   │   ├── auth.py              # Register / Login endpoints
│   │   │   ├── images.py            # Image upload endpoint
│   │   │   └── generation.py        # AI generation endpoints (Phase 2)
│   │   └── services/
│   │       ├── ai_service.py        # Replicate AI integration
│   │       └── firebase_service.py  # Firestore helpers
│   ├── requirements.txt
│   └── .env.example
│
└── frontend/                        # Flutter Android app
    ├── android/
    │   └── app/
    │       ├── google-services.json # ← Your Firebase Android config
    │       └── build.gradle.kts
    └── lib/
        ├── main.dart                # App entry + Firebase init + routing
        ├── config/
        │   ├── app_colors.dart      # Dark premium color palette
        │   ├── app_theme.dart       # Material 3 dark theme (Google Fonts)
        │   ├── api_config.dart      # Backend API URLs
        │   └── firebase_options.dart # Firebase platform configs
        ├── pages/
        │   ├── login_page.dart      # Sign in screen
        │   ├── register_page.dart   # Create account screen
        │   ├── home_page.dart       # Dashboard + recent photos
        │   ├── camera_page.dart     # Capture / import photo
        │   ├── gallery_page.dart    # Full photo grid (Firestore stream)
        │   ├── photo_detail_page.dart # Full-screen viewer + actions
        │   ├── editor_page.dart     # AI Studio (Phase 2 stub)
        │   └── preview_page.dart    # AI result preview (Phase 2)
        ├── components/
        │   ├── primary_button.dart
        │   ├── loading_spinner.dart
        │   ├── image_picker_widget.dart
        │   ├── image_preview.dart
        │   └── style_selector.dart
        ├── services/
        │   ├── storage_service.dart # Local file storage + Firestore metadata
        │   ├── api_service.dart     # Backend API client (Phase 2)
        │   ├── auth_service.dart    # Token-based auth helper
        │   └── image_service.dart   # image_picker wrapper
        └── providers/
            ├── firebase_auth_provider.dart # Firebase Auth state + notifier
            ├── photo_provider.dart         # Local photo management + Firestore sync
            ├── image_provider.dart         # Image picker state
            ├── auth_provider.dart          # Backend auth (Phase 2)
            └── generation_provider.dart    # AI generation state (Phase 2)
```

---

## 📋 Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Python | ≥ 3.10 (backend only) |
| Android SDK | API 21+ |
| Firebase project | ✅ Already configured |

---

## 🚀 Quick Start — Flutter App (Android)

### 1. Install dependencies

```bash
cd CaptureYourLife/frontend
flutter pub get
```

### 2. Verify Firebase setup

Ensure these files exist:
- `android/app/google-services.json` ✅ (your Android config)
- `lib/config/firebase_options.dart` ✅ (all platforms configured)

### 3. Run on Android

```bash
# On a connected device or emulator
flutter run

# Specific device
flutter run -d emulator-5554

# Build release APK
flutter build apk --release
```

---

## 🔥 Firebase Configuration

### Frontend (already configured ✅)

| File | Purpose |
|------|---------|
| `android/app/google-services.json` | Android Firebase credentials |
| `lib/config/firebase_options.dart` | Dart platform config (Android/iOS/Web) |

**Firebase Project:** `captureyourlife-4f28d`  
**Android Package:** `com.wanyee.captureyourlife`

### Firebase Console Setup Checklist

1. **Authentication** → Enable **Email/Password** sign-in method
2. **Firestore Database** → Create database (start in test mode or set rules below)

#### Recommended Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/photos/{photoId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

> 💡 **Note on Storage**: This app has been optimized to save photos directly to the device's local storage to prevent cloud storage costs. Firebase Storage is **not required**.

---

## 📱 App Flow

```
Launch
  └── Auth Check (Firebase)
        ├── Not logged in → Login Page
        │     └── Sign Up → Register Page → Home
        └── Logged in → Home Page
              ├── 📸 Camera Button → Camera Page
              │     ├── Take Photo (camera)
              │     ├── Pick from Gallery
              │     └── Save locally to device → Photo Detail Page
              │           ├── Pinch to zoom
              │           ├── Save to device gallery
              │           ├── Share
              │           └── Delete
              ├── 🖼️ Gallery → Gallery Page
              │     ├── Real-time grid (Firestore stream + local images)
              │     ├── Tap → Photo Detail
              │     └── Long-press → Delete (removes from device + Firestore)
              └── ✨ AI Studio → Editor Page (Phase 2 — Coming Soon)
```

---

## 🧪 Testing the App

```bash
# Analyze for errors
flutter analyze

# Run tests
flutter test

# Run with verbose logs
flutter run -v
```

### Manual Test Checklist
- [ ] App launches and shows login screen
- [ ] Register with email + password creates an account
- [ ] Login redirects to Home
- [ ] Camera opens and captures a photo
- [ ] Gallery picker imports a photo
- [ ] "Save Photo" saves file to device application folder
- [ ] Photo metadata appears in Gallery grid via Firestore
- [ ] Tapping photo opens full-screen viewer using local file
- [ ] "Save to gallery" saves a copy to device photo library
- [ ] "Share" opens system share sheet
- [ ] Long-press in gallery shows delete confirmation
- [ ] Delete removes file from device and Firestore metadata
- [ ] Logout returns to login screen

---

## 🔧 Backend Setup (For AI Phase — Phase 2)

The backend is **not required** for the current camera app version. It will be used when AI generation features are activated.

### Setup

```bash
cd CaptureYourLife/backend

# Windows
python -m venv venv
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Configure `.env`

```bash
cp .env.example .env
```

Edit `.env`:
```env
FIREBASE_PROJECT_ID=captureyourlife-4f28d
FIREBASE_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@captureyourlife-4f28d.iam.gserviceaccount.com
SECRET_KEY=your-random-secret-key-here
DEBUG=True
APP_NAME=CaptureYourLife
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
REPLICATE_API_TOKEN=your-replicate-token  # For AI features
```

### Run

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

API docs: `http://localhost:8000/docs`

> **Note:** For the Android emulator to reach a local backend, use `10.0.2.2:8000` instead of `localhost:8000` in `lib/config/api_config.dart`.

### API Endpoints (Phase 2)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register user |
| POST | `/auth/login` | Login user |
| POST | `/images/upload` | Upload image |
| GET | `/images/{id}` | Get image metadata |
| POST | `/generate/sticker` | Generate sticker (AI) |
| POST | `/generate/avatar` | Generate avatar (AI) |
| GET | `/generate/history` | User's generation history |

---

## 📦 Key Dependencies

### Frontend
| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `firebase_core` / `firebase_auth` | Authentication |
| `cloud_firestore` | Photo metadata storage |
| `path_provider` | Local device photo storage |
| `image_picker` | Camera & gallery access |
| `gal` | Save to device gallery |
| `share_plus` | System share sheet |
| `google_fonts` | Outfit font family |
| `dio` / `http` | HTTP client (backend calls) |

### Backend
| Package | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `firebase-admin` | Firestore & Auth server SDK |
| `replicate` | AI model API (Phase 2) |
| `pydantic` | Data validation |
| `PyJWT` / `bcrypt` | Auth tokens |

---

## 🎨 Design System

- **Theme:** Dark mode premium
- **Primary Color:** `#6C63FF` (purple-indigo)
- **Accent:** `#FF6584` (pink), `#43E97B` (green)
- **Background:** `#0F0F1A` deep dark
- **Font:** [Outfit](https://fonts.google.com/specimen/Outfit) (Google Fonts)
- **Border Radius:** 12–20px rounded cards

---

## 🛣️ Roadmap

| Phase | Status | Features |
|-------|--------|---------|
| Phase 1 — Camera App | ✅ **Complete** | Auth, capture, gallery, share, save |
| Phase 2 — AI Studio | 🔄 Planned | Sticker generator, Avatar styles |
| Phase 3 — Social | 🔄 Planned | Share to feed, likes, comments |

---

## 🐛 Troubleshooting

| Issue | Fix |
|-------|-----|
| `google-services.json not found` | Ensure file is in `android/app/` |
| Firebase Auth not working | Enable Email/Password in Firebase Console → Authentication |
| Photos not loading | Check Firestore + Storage rules allow authenticated reads |
| Camera permission denied | Grant Camera permission in device Settings |
| Backend connection refused | Use `10.0.2.2:8000` for emulator, not `localhost` |
| `flutter pub get` fails | Run `flutter clean && flutter pub get` |
| Build errors | Run `flutter clean` then rebuild |

---

## 📞 Support

1. Check the troubleshooting table above
2. Run `flutter analyze` for code issues  
3. Check Flutter logs: `flutter logs`
4. Review Firebase console for auth/storage errors

---

**Happy Capturing! 📸✨**
