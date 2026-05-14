# 🚀 Quick Start Guide

Get CaptureYourLife running in minutes!

## Prerequisites
- Python 3.10+
- Flutter SDK (latest)
- Replicate API key: https://replicate.com/account
- Firebase project: https://firebase.google.com

## 1️⃣ Backend Setup (5 minutes)

```bash
# Navigate to backend
cd CaptureYourLife/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Replicate token and Firebase credentials

# Run server
python -m uvicorn app.main:app --reload
```

✅ Backend running at `http://localhost:8000`

## 2️⃣ Frontend Setup (5 minutes)

```bash
# Navigate to frontend
cd CaptureYourLife/frontend

# Install Flutter packages
flutter pub get

# Configure Firebase
# Edit lib/config/firebase_options.dart with your Firebase project details

# Run app
flutter run
```

✅ App running on your emulator/device

## 3️⃣ Test the Flow

1. Open the app on your emulator
2. **Home Page** - See the main menu
3. **Camera Page** - Pick an image from gallery
4. **Editor Page** - Select sticker or avatar style
5. **Preview Page** - See your generated result

## 🔧 Quick Configuration

### Replicate API Token
```bash
# Get from: https://replicate.com/account/api-tokens
# Add to backend/.env:
REPLICATE_API_TOKEN=YOUR_TOKEN_HERE
```

### Firebase Setup
```bash
# 1. Create Firebase project at https://firebase.google.com
# 2. Download service account key (JSON file)
# 3. Extract values and add to backend/.env:
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-email@firebase.gserviceaccount.com
```

## 📝 File Structure Highlights

**Backend** - REST API with AI integration
- `app/main.py` - FastAPI server
- `app/routes/` - API endpoints
- `app/services/ai_service.py` - Replicate integration

**Frontend** - Mobile app UI
- `lib/main.dart` - App entry
- `lib/pages/` - Screens
- `lib/components/` - Reusable widgets
- `lib/providers/` - State management (Riverpod)

## 🎯 Key Features Included

✅ User authentication (register/login)
✅ Image upload & storage
✅ AI sticker generation
✅ AI avatar generation (5 styles)
✅ Generation history
✅ Modern UI with Riverpod state management
✅ Complete error handling

## 🆘 Common Issues

**Backend won't start?**
```bash
# Port 8000 might be in use
lsof -i :8000
kill -9 <PID>
```

**Flutter build error?**
```bash
flutter clean
flutter pub get
flutter run
```

**Image picker not working?**
- Check device permissions
- Ensure camera/gallery permissions in manifest

## 📚 What's Next?

1. Customize colors in `lib/config/app_colors.dart`
2. Add more avatar styles in `app/services/ai_service.py`
3. Implement social media sharing
4. Add voice-controlled prompts
5. Deploy backend to cloud (Railway, Render, Heroku)

## 📖 Full Documentation

See `README.md` for complete setup, API docs, and deployment guide.

---

**Ready to create? Start the backend and frontend, then pick an image!** 🎨
