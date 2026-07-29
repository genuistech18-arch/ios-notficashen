# Code-Based Notification System

Two-part system implementing `flutter-notification-app-prompt.md`:

- **`backend/`** — NestJS + TypeORM + PostgreSQL service that stores `code ⇄ FCM token` pairs and dispatches push notifications via Firebase Cloud Messaging.
- **`mobile_app/`** — Flutter app (Riverpod) that registers a device against an existing code (no password) and shows notification history.

## Prerequisites

- Node.js 20+, npm
- Docker Desktop (for local Postgres)
- Flutter SDK, with `flutter doctor` passing for your target platform(s)
- A Firebase project (you create this yourself — see below)

## 1. Start Postgres

```
docker compose up -d
```

Runs Postgres 16 on `localhost:5433` (not 5432, to avoid clashing with any other local Postgres instance). Credentials are in `docker-compose.yml` / `backend/.env`.

## 2. Backend setup

```
cd backend
npm install
cp .env.example .env   # already present with working local defaults
npm run migration:run  # creates clients + notifications tables
npm run seed            # inserts sample codes: 1001, 1002, 1003 (no fcm_token)
npm run start:dev       # http://localhost:3000, Swagger docs at /docs
```

The server boots fine even without Firebase credentials in place — FCM sends will just fail gracefully (`{"status":"failed"}`) instead of crashing.

### Firebase Admin credentials

1. Firebase Console → your project → Project Settings → Service Accounts → **Generate new private key**.
2. Save the downloaded JSON as `backend/firebase-service-account.json` (gitignored).
3. Restart the backend — it will pick it up automatically via `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`.

### Code seeding — open item

The backend **never generates codes**, only persists them (see prompt Section 7, item 1). `npm run seed` inserts a few hardcoded sample codes for local development/demo only — it is **not** an HTTP endpoint, to keep the attack surface minimal. Real code provisioning from the external system that owns code generation is still an open integration to define.

### API summary

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/v1/clients/register` | none (rate-limited: 5/min) | Link a code to a device's FCM token |
| POST | `/api/v1/notifications/send` | `x-api-key` header | External service triggers a push by code |
| GET | `/api/v1/clients/:code/notifications` | none | Notification history for a code |
| PATCH | `/api/v1/notifications/:id/read` | none | Mark a notification read |

Full request/response contract: `http://localhost:3000/docs` (Swagger) once the server is running.

## 3. Flutter app setup

```
cd mobile_app
flutter pub get
```

### Firebase platform config

1. Run `flutterfire configure` (FlutterFire CLI) against the same Firebase project used for the backend's service account — this generates `lib/firebase_options.dart` and drops `android/app/google-services.json` / `ios/Runner/GoogleService-Info.plist` automatically.
2. The app boots and the registration/notifications UI works even without this step (Firebase calls degrade gracefully to no-ops) — but you won't get a real FCM token or receive real pushes until it's done.

### Android Gradle/Java note

`flutter create` warned that the detected Java version may not match the scaffolded Gradle version. If Android builds fail, either run `flutter config --jdk-dir=<compatible JDK>` or bump the Gradle version in `android/gradle/wrapper/gradle-wrapper.properties` per Flutter's on-screen instructions.

### Pointing the app at your backend

```
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000
```

Defaults if omitted: `http://10.0.2.2:3000` on the Android emulator (host-loopback alias), `http://localhost:3000` elsewhere.

### Deep link testing

Custom scheme: `myapp://open?code=1234`.

```
# Android
adb shell am start -a android.intent.action.VIEW -d "myapp://open?code=1001"

# iOS simulator
xcrun simctl openurl booted "myapp://open?code=1001"
```

## 4. End-to-end manual test

1. `docker compose up -d && cd backend && npm run migration:run && npm run seed && npm run start:dev`
2. `cd mobile_app && flutter run`
3. Enter code `1001` on the registration screen → should land on Home.
4. Trigger a push:
   ```
   curl -X POST http://localhost:3000/api/v1/notifications/send \
     -H "Content-Type: application/json" -H "x-api-key: <API_SEND_KEY from backend/.env>" \
     -d '{"code":"1001","message":"Test notification"}'
   ```
5. Open Notifications screen → message should appear; tap it → marks read.

## 5. Automated tests

```
cd backend && npm run test:e2e   # spins up against notification_app_test DB, mocks FCM
cd mobile_app && flutter test
```

The backend e2e suite needs a `notification_app_test` database migrated once:
```
docker exec <postgres-container-name> psql -U notification_app -d notification_app -c "CREATE DATABASE notification_app_test"
cd backend && DB_NAME=notification_app_test npm run migration:run
```
