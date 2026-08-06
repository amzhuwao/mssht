# MSSHT Android App

Native Android client for **Manica Skyview School of Hospitality and Tourism**.

## Capabilities

- **Authentication** — student ID / email + password against `/api/mobile/v1/login.php`
- **Biometric unlock** — fingerprint / face / device credential after first login (AndroidX Biometric)
- **Offline sync** — Room cache of notifications, invoices, classes; WorkManager periodic refresh
- **Push notifications** — Firebase Cloud Messaging (`MsshtFirebaseMessagingService`)
- **Design parity** — teal `#0D4F4C`, gold accent `#C9A227`, background `#F4F6F9`, 10dp radius, DM Sans / Playfair Display intent (serif/sans mapping; bundle font files for pixel-perfect match)

## Modular structure

```
android/
├── app/                      # Shell, navigation, DI container
├── core/
│   ├── common/               # Result, config
│   ├── model/                # Kotlinx serialization DTOs
│   ├── designsystem/         # Colors, typography, theme, shared UI
│   ├── network/              # Retrofit Mobile API
│   ├── database/             # Room offline store
│   └── datastore/            # Encrypted token + preferences
└── feature/
    ├── auth/                 # Login + biometric lock
    ├── home/                 # Dashboard
    ├── notifications/        # Inbox + FCM service
    └── sync/                 # SyncRepository + Worker
```

## Backend API

PHP endpoints under the web root:

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/api/mobile/v1/login.php` | Issue bearer token |
| GET | `/api/mobile/v1/me.php` | Current user |
| POST | `/api/mobile/v1/logout.php` | Revoke token |
| POST | `/api/mobile/v1/device.php` | Register FCM token |
| GET | `/api/mobile/v1/sync.php` | Offline snapshot |
| GET | `/api/mobile/v1/notifications.php` | Notifications list |

Migration: `database/migrations/011_mobile_tokens.sql` (also auto-created on first API call).

## Setup (Android Studio)

1. Open the `android/` folder in Android Studio (Ladybug / AGP 8.7+).
2. Set `sdk.dir` in `local.properties`.
3. Point `API_BASE_URL` in `app/build.gradle.kts` at your XAMPP host:
   - Emulator → `http://10.0.2.2/mssht/`
   - Physical device → `http://YOUR_LAN_IP/mssht/`
4. Copy `app/google-services.json.example` → `app/google-services.json` from Firebase Console.
5. Uncomment `alias(libs.plugins.google.services)` in `app/build.gradle.kts`.
6. Run the `app` configuration.

## Admin website download

Super administrators can download the debug APK from **System Settings → Mobile App**.

1. Build: `cd android && ./gradlew assembleDebug`
2. Copy the APK to the web app:
   ```bash
   mkdir -p storage/mobile
   cp android/app/build/outputs/apk/debug/app-debug.apk storage/mobile/mssht-android-debug.apk
   ```
3. Open **System Settings** (super_admin only) and use **Download Android APK**.

The download is gated by `modules/settings/download-apk.php` (`requireModule('settings')` + `requireRole(['super_admin'])`). Direct access to `/storage/` is blocked in `.htaccess`.

## Security notes

- Access tokens are stored in **EncryptedSharedPreferences**.
- Biometric gate locks the UI when the process is backgrounded (set `unlocked=false` on stop if desired).
- Prefer HTTPS in production and disable cleartext in `network_security_config.xml`.

## Typography / brand

Web CSS tokens (`assets/css/main.css`) are mirrored in `core/designsystem` (`MsshtColors`, `MsshtTypography`). For exact DM Sans + Playfair Display on device, add `.ttf` files under `core/designsystem/src/main/res/font/` and wire `FontFamily`.
