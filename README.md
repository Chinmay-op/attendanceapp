# Offline Biometric Attendance System (AttendEase)

A production-ready Flutter mobile application for an offline-first biometric attendance system using Raspberry Pi, Firebase, and local networking.

## Features

- **Biometric Authentication** — Fingerprint/Face ID via `local_auth` before marking attendance
- **Offline-First** — Hive local storage with auto-sync to Firebase Firestore
- **Raspberry Pi Integration** — HTTP API communication with Pi running in AP mode
- **Role-Based Access** — Separate Student and Teacher dashboards
- **Real-time Attendance** — Live polling from Raspberry Pi server
- **Analytics & Calendar** — Monthly calendar view, bar/pie charts, attendance percentage
- **Chat System** — Student-Teacher messaging via Firestore

## Architecture

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config (placeholder)
├── models/                      # Data models
├── services/                    # Business logic services
├── providers/                   # State management (Provider)
├── screens/                     # UI screens
├── widgets/                     # Reusable widgets
└── utils/                       # Theme, constants, helpers
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter + Provider |
| Auth | Firebase Authentication |
| Cloud DB | Cloud Firestore |
| Local DB | Hive |
| Biometric | local_auth |
| Networking | http (Raspberry Pi) |
| Charts | fl_chart |
| Connectivity | connectivity_plus |

## Setup

### Prerequisites
- Flutter SDK ≥ 3.1.0
- Firebase project configured
- Raspberry Pi running Flask server at `192.168.4.1:5000`

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/kunalshelke08-boop/attendance-system-.git
cd attendance-system-
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Replace `lib/firebase_options.dart` with the generated file.

4. **Add google-services.json** (Android)
Place `google-services.json` in `android/app/`

5. **Run the app**
```bash
flutter run
```

## Raspberry Pi API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/mark` | Mark attendance `{uid, name, timestamp}` |
| GET | `/attendance_list` | Get current attendance list |
| POST | `/start_session` | Start attendance session |
| POST | `/stop_session` | Stop current session |
| GET | `/ping` | Health check |

## Firestore Structure

```
users/{uid}           → name, email, role, classId
attendance/{classId}  → records/{date}/students/{uid}
sessions/{sessionId}  → classId, teacherUid, startTime, endTime
messages/{classId}    → chat/{messageId}
```

## Screenshots

The app features a premium dark theme with:
- Gradient cards and glassmorphism
- Animated transitions
- Color-coded attendance calendar
- Interactive charts

## License

MIT License © 2026
