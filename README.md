# RoadResQ - On-Demand Roadside Assistance User App 🚗🔧

**RoadResQ** is a Flutter application designed for drivers facing vehicle breakdowns, flat tyres, fuel shortages, battery drain, lockout situations, or other road emergencies.

---

## 🎨 Theme & Branding
- **Design Language**: Professional Blue & White palette with modern curves and elevated cards
- **Primary Color**: `#1565C0` (Royal Blue)
- **Secondary Color**: `#1E88E5` (Light Blue)
- **SOS / Emergency**: `#D32F2F` (Urgent Amber & Crimson Red)
- **Typography**: Poppins font family (Regular, Medium, SemiBold, Bold) bundled locally in `assets/fonts/`

---

## 📱 Features & Implemented Screens

1. **Splash Screen** (`lib/screens/splash/splash_screen.dart`):
   - Animated RoadResQ emblem with elastic bounce and fade effects.
   - Intelligent navigation routing based on user session authentication state.

2. **Authentication Flow** (`lib/screens/auth/`):
   - **Login Screen** (`login_screen.dart`): Clean phone number input with India (+91) prefix and validation.
   - **OTP Verification Screen** (`otp_screen.dart`): 6-digit PIN input with pin code fields and a 60s resend timer.
   - **Register Screen** (`register_screen.dart`): Name, email, and vehicle details input with profile photo setup.

3. **Home Dashboard** (`lib/screens/home/home_screen.dart`):
   - Dynamic SliverAppBar with current location display and quick notification access.
   - Prominent **SOS Emergency Button** for instant help.
   - Active Request status card with direct tracking shortcut.
   - 2x3 Grid of core roadside assistance services:
     - 🛞 Flat Tyre Assistance
     - ⛽ Fuel Delivery
     - 🔋 Battery Jumpstart
     - 🪝 Towing Service
     - 🔑 Vehicle Lockout
     - 🔧 Engine & General Breakdown
   - Bottom navigation switching between Home, History, and Profile.

4. **Service Request Flow** (`lib/screens/request/request_screen.dart`):
   - Service summary with estimated pricing breakdown (Base Fare + Distance Charges).
   - GPS Auto-detected pickup location with custom manual edit option.
   - Registered vehicle selector with registration numbers.
   - Issue description field and live fare estimate.

5. **Live Tracking & Mechanic Status** (`lib/screens/request/tracking_screen.dart`):
   - Interactive map simulation with user and mechanic markers.
   - Assigned mechanic profile card with photo, name, rating (4.7 ⭐), vehicle details, and live ETA countdown.
   - Step progress indicator: *Requested ➔ Confirmed ➔ En Route ➔ Arrived ➔ Completed*.
   - Direct call mechanic and in-app chat integration.

6. **In-App Messaging** (`lib/screens/chat/chat_screen.dart`):
   - Real-time chat bubbles between user and mechanic.
   - Pre-filled quick response chips (*"Where are you?", "I'm near the petrol pump", "Traffic is heavy"*).

7. **Service History & Details** (`lib/screens/history/` & `request_detail_screen.dart`):
   - Chronological list of past requests with colored status tags (Completed, In Progress, Cancelled).
   - Detailed receipt view with payment breakdown, mechanic contact, and re-order button.

8. **In-App Payment** (`lib/screens/payment/payment_screen.dart`):
   - Itemized bill (Base fare, distance charges, taxes & platform fee).
   - Multiple payment options: UPI (Google Pay / PhonePe / Paytm), Credit/Debit Card, Net Banking, and Cash on Service.

9. **Ratings & Reviews** (`lib/screens/ratings/rating_screen.dart`):
   - Interactive 5-star rating bar.
   - Quick feedback tags (*"Punctual", "Skilled", "Polite", "Reasonable"*) and written review field.

10. **Emergency SOS** (`lib/screens/sos/sos_screen.dart`):
    - Pulsing 1-tap SOS trigger.
    - Quick dial for Emergency Helpline `112`.
    - Live location coordinates and "Share Location" utility.
    - Emergency contacts management list.

11. **User Profile & Garage** (`lib/screens/profile/profile_screen.dart`):
    - User avatar, name, phone, and email management.
    - Garage section for managing multiple vehicles.
    - App settings: Notifications, Help & Support, Privacy Policy, and Logout.

---

## 🏗️ Architecture & State Management

- **Providers** (`lib/providers/`):
  - `AuthProvider`: User authentication, profile state, and session persistence.
  - `RequestProvider`: Active roadside requests, request creation, history, and status progression.
  - `ChatProvider`: Real-time conversation messages between driver and technician.
  - `LocationProvider`: Coordinates, address reverse-geocoding, and permission handling.
- **Models** (`lib/models/`):
  - `UserModel`, `ServiceRequestModel`, `MechanicModel`, `MessageModel`, `ReviewModel`.
- **Services** (`lib/services/`):
  - `AuthService`, `FirestoreService`, `LocationService`, `NotificationService`.

---

## 🚀 Running the App

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit & widget tests
flutter test

# 3. Launch the app (on connected device or emulator)
flutter run
```
