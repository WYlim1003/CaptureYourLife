# CaptureYourLife - Complete Setup & Development Guide

## 🎯 Project Overview

CaptureYourLife is an AI-powered mobile app that transforms photos into stickers and avatars using real AI models. Built with Flutter (frontend) + FastAPI (backend) + Firebase + Replicate AI.

---

## 📋 Prerequisites

### Global Requirements
- Python 3.10+
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Git
- A Replicate API account (https://replicate.com)
- A Firebase project

### API Keys Needed
1. **Replicate API Token** - Get from https://replicate.com/account
2. **Firebase Project Credentials** - Create at https://firebase.google.com

---

## 🚀 Backend Setup (FastAPI)

### Step 1: Navigate to Backend
```bash
cd CaptureYourLife/backend
```

### Step 2: Create Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Configure Environment
```bash
# Copy example to actual .env
cp .env.example .env

# Edit .env with your values
# - REPLICATE_API_TOKEN: Your Replicate API token
# - FIREBASE_PROJECT_ID: Your Firebase project ID
# - FIREBASE_PRIVATE_KEY: Your Firebase private key (JSON escaped)
# - FIREBASE_CLIENT_EMAIL: Your Firebase client email
# - SECRET_KEY: Generate a random secret key
```

### Step 5: Run Backend Server
```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The backend will be available at `http://localhost:8000`

### API Documentation
Once running, visit `http://localhost:8000/docs` for interactive API docs.

---

## 📱 Frontend Setup (Flutter)

### Step 1: Navigate to Frontend
```bash
cd CaptureYourLife/frontend
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure Environment
```bash
# Copy example to actual .env
cp .env.example .env

# Edit .env with your Firebase credentials
```

### Step 4: Update Firebase Options
Edit `lib/config/firebase_options.dart` with your Firebase project details:
```dart
static FirebaseOptions get currentPlatform {
  return FirebaseOptions(
    apiKey: 'YOUR_FIREBASE_API_KEY',
    appId: 'YOUR_FIREBASE_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
```

### Step 5: Run Flutter App
```bash
# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d ios

# Run on connected device
flutter run
```

---

## 🏗️ Project Structure

```
CaptureYourLife/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPI entry point
│   │   ├── config.py               # Configuration
│   │   ├── models.py               # Pydantic models
│   │   ├── dependencies.py         # Firebase & Auth
│   │   ├── routes/
│   │   │   ├── auth.py             # Auth endpoints
│   │   │   ├── images.py           # Image upload
│   │   │   └── generation.py       # AI generation
│   │   └── services/
│   │       ├── ai_service.py       # Replicate API
│   │       └── firebase_service.py # Firebase ops
│   ├── requirements.txt
│   ├── .env.example
│   └── .gitignore
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── config/                 # Configs
│   │   │   ├── app_colors.dart
│   │   │   ├── api_config.dart
│   │   │   └── firebase_options.dart
│   │   ├── pages/                  # App screens
│   │   │   ├── home_page.dart
│   │   │   ├── camera_page.dart
│   │   │   ├── editor_page.dart
│   │   │   ├── preview_page.dart
│   │   │   └── gallery_page.dart
│   │   ├── components/             # Reusable widgets
│   │   │   ├── primary_button.dart
│   │   │   ├── loading_spinner.dart
│   │   │   ├── image_picker_widget.dart
│   │   │   ├── style_selector.dart
│   │   │   └── image_preview.dart
│   │   ├── services/               # Business logic
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── image_service.dart
│   │   ├── providers/              # Riverpod state
│   │   │   ├── auth_provider.dart
│   │   │   ├── image_provider.dart
│   │   │   └── generation_provider.dart
│   │   └── assets/
│   │       ├── images/
│   │       └── icons/
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── .env.example
│   └── .gitignore
│
└── README.md
```

---

## 🔑 API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user

### Images
- `POST /images/upload` - Upload image
- `GET /images/{image_id}` - Get image metadata

### Generation
- `POST /generate/sticker` - Generate sticker
- `POST /generate/avatar` - Generate avatar
- `GET /generate/history` - Get user's generation history

---

## 🧪 Testing

### Backend Testing with curl
```bash
# Register
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","username":"testuser"}'

# Login
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Upload Image
curl -X POST "http://localhost:8000/images/upload" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@path/to/image.jpg"

# Generate Sticker
curl -X POST "http://localhost:8000/generate/sticker" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"image_id":"YOUR_IMAGE_ID","style":"sticker"}'
```

### Flutter Testing
```bash
# Run with debug output
flutter run -v

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

---

## 🎨 App Flow

1. **Home Page** - User sees menu with options
2. **Camera Page** - User picks image from camera or gallery
3. **Editor Page** - User selects generation type (sticker/avatar) and style
4. **Preview Page** - User sees generated result
5. **Gallery Page** - User views all past generations

---

## 🔧 Environment Variables

### Backend (.env)
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-email
REPLICATE_API_TOKEN=your-token
APP_NAME=CaptureYourLife
DEBUG=True
SECRET_KEY=your-secret-key
```

### Frontend (.env)
```env
API_BASE_URL=http://localhost:8000
FIREBASE_API_KEY=your-key
FIREBASE_PROJECT_ID=your-project-id
```

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows, macOS, Linux

---

## 🐛 Troubleshooting

### Backend Issues
- **Port already in use**: Change port in main.py or kill process on port 8000
- **Firebase auth error**: Check credentials in .env file
- **Replicate API errors**: Verify API token is correct and valid

### Frontend Issues
- **Image picker not working**: Check permissions in AndroidManifest.xml or Info.plist
- **API connection failed**: Ensure backend is running and API_BASE_URL is correct
- **Build errors**: Run `flutter clean && flutter pub get`

---

## 📚 Key Dependencies

### Backend
- FastAPI - Web framework
- Firebase Admin SDK - Database & auth
- Replicate - AI model API
- Pillow - Image processing
- Pydantic - Data validation

### Frontend
- Flutter - UI framework
- Riverpod - State management
- Dio - HTTP client
- Image Picker - Camera/Gallery access
- Firebase - Database & auth

---

## 🚢 Deployment

### Backend (Production)
1. Set `DEBUG=False` in .env
2. Generate strong `SECRET_KEY`
3. Deploy to: Heroku, Railway, Render, or AWS
4. Update Firebase security rules for production

### Frontend
1. Build release APK: `flutter build apk --release`
2. Build release IPA: `flutter build ios --release`
3. Submit to Google Play / App Store

---

## 📝 Next Steps

1. ✅ Run backend: `python -m uvicorn app.main:app --reload`
2. ✅ Run frontend: `flutter run`
3. ✅ Test auth flow (register/login)
4. ✅ Test image upload & generation
5. ✅ Test UI navigation
6. 🔄 Customize colors in `lib/config/app_colors.dart`
7. 🔄 Add more generation styles in `ai_service.py`
8. 🔄 Implement social media sharing

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review API docs at `http://localhost:8000/docs`
3. Check Flutter logs: `flutter logs`
4. Review backend logs in terminal

---

**Happy Creating! 🎉**
