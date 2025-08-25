# Ramadhan Companion App

Ramadhan Companion App is a Flutter application that helps users stay connected to their daily Islamic practices.  
It includes **prayer times**, **Hijri and Gregorian dates**, and a **daily Quran verse**.  
It also has **user authentication** with email/password login and signup.

---

## 📧 Test Account
Use this account to log in and test the app immediately:

**Email:** test@gmail.com  
**Password:** test1234

---

## Running the App

### 1. Prerequisites
Make sure you have:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (latest stable)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- An IDE like [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)

### 2. Clone the repository
- git clone https://github.com/your-username/ramadhan-companion-app.git
- cd ramadhan-companion-app
### 3. Install dependencies
- flutter pub get
### 4. Run the app
- flutter run

## Key Features
- Firebase Authentication for login/signup.
- Prayer Times API integration for real-time timings.
- Daily Quran and Hadith Verse with translation display from an external API.
- Hijri Date display alongside Gregorian date.
- Nearby Masjid to display the nearest Masjid under 10km based on location set.
- Quran using quran flutter package to ensure offline availability.
- Islamic calendar for Hijri date with special events during the month.
- State Management using Provider package.
- Custom UI Components for dialogs, buttons, and loading states.

## APIs Used
- Prayer Times API: Fetches daily prayer times.
- Quran API: Provides daily random Quran verse.
- Hijri Date API: Displays the Islamic date.
- Google Maps API: To display nearby masjid.

## Tech Stack
- Flutter (Dart)
- Firebase Authentication
- Provider (State Management)
- REST API Integration
