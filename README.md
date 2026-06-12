# CaptureYourLife 📸

> A cross-platform camera app built with **Flutter + Firebase**. Capture, store, and share your life's moments — with AI-powered sticker and avatar generation.

---

## 🎯 Project Overview

CaptureYourLife is a full-stack app that lets users:

- **Register / Sign in** with Firebase Auth (Email/Password or Google)
- **Capture photos** — native camera on Android/iOS; WebRTC camera on web
- **Import from gallery** on any platform
- **Store photos** locally on device (no cloud storage costs)
- **Sync metadata** to Firestore for real-time gallery across sessions
- **Browse their gallery** in a real-time grid view
- **View photos full-screen** with pinch-to-zoom, share, and save-to-device
- **AI Studio** — Gemini-powered sticker & avatar generation

**Stack:** Flutter 3 · Firebase Auth · Firestore · Local Storage · FastAPI · Python · Gemini API

---

## 🏗️ Project Structure

```
CaptureYourLife/
├── backend/                          # FastAPI Python backend (AI generation)
│   ├── app/
│   │   ├── main.py                   # FastAPI entry point
│   │   ├── config.py                 # App configuration
│   │   ├── models.py                 # Pydantic models
│   │   ├── dependencies.py           # Firebase Admin & JWT auth
│   │   ├── routes/
│   │   │   ├── auth.py               # Register / Login endpoints
│   │   │   ├── images.py             # Image upload endpoint
│   │   │   └── generation.py         # AI generation endpoints
│   │   └── services/
│   │       ├── ai_service.py         # AI integration
│   │       └── firebase_service.py   # Firestore helpers
│   ├── requirements.txt
│   └── .env.example
│
└── frontend/                         # Flutter app (Android, iOS, Web)
    ├── android/
    │   └── app/
    │       ├── google-services.json  # Firebase Android config
    │       └── src/main/AndroidManifest.xml
    ├── web/
    │   └── index.html                # Firebase web SDK init
    └── lib/
        ├── main.dart                 # App entry + Firebase init + routing
        ├── config/
        │   ├── app_colors.dart       # Dark premium color palette
        │   ├── app_theme.dart        # Material 3 dark theme
        │   ├── api_config.dart       # Backend API URLs
        │   └── firebase_options.dart # Firebase platform configs
        ├── ai/
        │   ├── ai_config.dart        # Gemini model + API key config
        │   └── ai_agent.dart         # Gemini image generation logic
        ├── pages/
        │   ├── splash_page.dart      # Animated logo splash (4s)
        │   ├── login_page.dart       # Sign in (email or Google)
        │   ├── register_page.dart    # Create account
        │   ├── home_page.dart        # Dashboard + recent photos
        │   ├── camera_page.dart      # Capture / import photo
        │   ├── gallery_page.dart     # Full photo grid (Firestore stream)
        │   ├── photo_detail_page.dart # Full-screen viewer + actions
        │   └── editor_page.dart      # AI Studio (sticker & avatar)
        ├── components/
        │   ├── animated_logo.dart    # Anime-style neon draw animation
        │   ├── primary_button.dart
        │   ├── loading_spinner.dart
        │   ├── image_picker_widget.dart
        │   └── style_selector.dart
        ├── services/
        │   ├── image_service.dart    # Camera/gallery picker (web + mobile)
        │   ├── storage_service.dart  # Local file storage + Firestore metadata
        │   ├── gemini_service.dart   # AI generation wrapper
        │   └── api_service.dart      # Backend API client
        ├── providers/
        │   ├── firebase_auth_provider.dart  # Firebase Auth state + Google Sign-In
        │   ├── photo_provider.dart          # Local photo management + Firestore sync
        │   ├── image_provider.dart          # Image picker state
        │   └── generation_provider.dart     # AI generation state
        └── utils/
            ├── web_camera_capture.dart      # Conditional import shim
            ├── web_camera_capture_web.dart  # WebRTC camera (web only)
            └── web_camera_capture_stub.dart # No-op stub (mobile/desktop)
```

---

## 📋 Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Python | ≥ 3.10 (backend only) |
| Android SDK | API 21+ |
| Firebase project | ✅ Configured (`captureyourlife-4f28d`) |

---

## 🚀 Quick Start

### Frontend

```bash
cd CaptureYourLife/frontend
flutter pub get

# Android / iOS
flutter run

# Web (Chrome) — port must match OAuth authorized origins
flutter run -d chrome --web-port=8080

# Release APK
flutter build apk --release
```

---

## 🔥 Firebase Configuration

**Project:** `captureyourlife-4f28d`  
**Android Package:** `com.wanyee.captureyourlife`

| File | Purpose |
|------|---------|
| `android/app/google-services.json` | Android Firebase credentials |
| `lib/config/firebase_options.dart` | Dart multi-platform config |

### Firebase Console Checklist

1. **Authentication → Sign-in method** — Enable:
   - ✅ Email/Password
   - ✅ Google (required for Google Sign-In button)

2. **Authentication → Settings → Authorized domains** — Confirm `localhost` is listed (for web dev)

3. **Firestore Database** — Create database with these rules:

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

4. **Project Settings → Android app → SHA-1** — Add your debug fingerprint:
   ```bash
   cd android && ./gradlew signingReport
   ```

> 💡 Firebase Storage is **not used** — photos are stored on the device to avoid cloud storage costs.

---

## 🔑 Google Sign-In Setup

Google Sign-In works differently per platform:

| Platform | Method | Requirement |
|----------|--------|-------------|
| Android | `google_sign_in` native popup | SHA-1 in Firebase Console |
| Web | `FirebaseAuth.signInWithPopup()` | Authorized JS origins in Google Cloud Console |

### Web: Authorize your dev origin

Go to **[Google Cloud Console → APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials)** → your Web OAuth 2.0 client → add:

- **Authorized JavaScript origins:** `http://localhost:8080`
- **Authorized redirect URIs:** `http://localhost:8080`

> Always run web with a fixed port: `flutter run -d chrome --web-port=8080`

---

## 🤖 AI Features (Gemini)

AI sticker and avatar generation is powered by the **Gemini API**.

### Setup

Create `frontend/.env`:
```env
GEMINI_API_KEY=your_google_ai_studio_key_here
```

Get your key at [Google AI Studio](https://aistudio.google.com/app/apikey).  
Keys starting with `AQ.` are the current format.

### Models Used

| Purpose | Model |
|---------|-------|
| Image generation (stickers, avatars) | `gemini-2.0-flash-exp` |
| Text / descriptions | `gemini-2.0-flash` |

---

## 📱 App Flow

```
Launch → Splash (4s animated logo)
  └── Auth Check (Firebase)
        ├── Not logged in → Login Page
        │     ├── Email/Password sign in
        │     ├── Google Sign-In
        │     └── Sign Up → Register Page → Home
        └── Logged in → Home Page
              ├── 📸 Camera Button → Camera Page
              │     ├── Take Photo
              │     │     ├── Web: WebRTC camera overlay (getUserMedia)
              │     │     └── Android/iOS: native camera
              │     ├── Pick from Gallery (file picker)
              │     └── Save → Photo Detail Page
              │           ├── Pinch to zoom
              │           ├── Save to device gallery
              │           ├── Share
              │           └── Delete
              ├── 🖼️  Gallery → Gallery Page
              │     ├── Real-time grid (Firestore stream + local files)
              │     ├── Tap → Photo Detail
              │     └── Long-press → Delete (device + Firestore)
              └── ✨ AI Studio → Editor Page
                    ├── Generate Sticker (Gemini image generation)
                    └── Generate Avatar (style selection)
```

---

## 📦 Key Dependencies

### Frontend

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.x | State management |
| `firebase_core` / `firebase_auth` | latest | Authentication |
| `google_sign_in` | ^6.x | Native Google Sign-In (Android/iOS) |
| `cloud_firestore` | latest | Photo metadata sync |
| `image_picker` | ^1.0.4 | Gallery picker + mobile camera |
| `path_provider` | latest | Local device storage paths |
| `gal` | latest | Save to device photo gallery |
| `share_plus` | latest | System share sheet |
| `google_fonts` | latest | Outfit font family |
| `google_generative_ai` | latest | Gemini API client |
| `cross_file` | ^0.3.4 | Platform-agnostic file type |

### Backend

| Package | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `firebase-admin` | Firestore & Auth server SDK |
| `pydantic` | Data validation |
| `PyJWT` / `bcrypt` | Auth tokens |

---

## 🎨 Design System

- **Theme:** Dark mode, premium feel
- **Primary:** `#7C3AED` (violet)
- **Background:** `#0F0F1A` deep dark
- **Font:** [Outfit](https://fonts.google.com/specimen/Outfit) via Google Fonts
- **Logo:** Anime-style neon left-to-right draw animation on splash

---

## 🔧 Backend Setup (AI Generation)

```bash
cd CaptureYourLife/backend

python -m venv venv
venv\Scripts\activate      # Windows
pip install -r requirements.txt
```

Create `.env`:
```env
FIREBASE_PROJECT_ID=captureyourlife-4f28d
FIREBASE_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@captureyourlife-4f28d.iam.gserviceaccount.com
SECRET_KEY=your-secret-key
DEBUG=True
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
```

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

API docs: `http://localhost:8000/docs`

> For Android emulator connecting to local backend, use `10.0.2.2:8000` instead of `localhost:8000`.

---

## 🐛 Troubleshooting

| Issue | Fix |
|-------|-----|
| `origin_mismatch` on Google Sign-In (web) | Add `http://localhost:8080` to Authorized JS Origins in Google Cloud Console |
| `popup_closed` on Google Sign-In (web) | Ensure `clientId` is set and origin is authorized; allow popups in Chrome |
| `serverClientId is not supported on Web` | Already fixed — `serverClientId` is only passed on Android/iOS |
| Camera opens file picker on web | Already fixed — uses WebRTC `getUserMedia` overlay on web |
| Camera permission denied (Android) | `image_picker` handles permissions internally; grant in device Settings if denied |
| Gemini API 404 | Verify model name is `gemini-2.0-flash-exp`; check API key in `.env` |
| Google Sign-In fails on Android | Add SHA-1 fingerprint in Firebase Console → Project Settings → Android app |
| Photos not loading | Check Firestore rules allow authenticated reads |
| `flutter pub get` fails | Run `flutter clean && flutter pub get` |
| Web build errors | Run `flutter clean` then rebuild |

---

**Happy Capturing! 📸✨**
