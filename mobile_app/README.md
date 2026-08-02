# AI Teacher Mobile App

Android-first Flutter client for the AI Teacher project.

## Current implementation

- Page 01: Figma-derived premium Splash screen.
- GetX routing, bindings and presentation state.
- Central `http` package API client.
- Feature-based lightweight clean folder architecture.
- Temporary onboarding placeholder as the next route.
- Splash widget test.

## Folder structure

```text
lib/
├── app/
│   ├── bindings/
│   ├── routes/
│   └── theme/
├── core/
│   ├── config/
│   └── network/
└── features/
    ├── splash/
    │   └── presentation/
    │       ├── bindings/
    │       ├── controllers/
    │       ├── pages/
    │       └── widgets/
    └── onboarding/
        └── presentation/pages/
```

GetX is limited to routing, dependency injection and presentation state. API requests must go through `ApiClient`; widgets must not call `http` directly.

## First-time Android bootstrap

The repository currently stores the reviewed Flutter source. Generate the standard Android wrapper once from the `mobile_app` directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\bootstrap_android.ps1
```

The script runs `flutter create`, restores the reviewed source from Git and installs packages.

After generation, verify that the release/main Android manifest contains:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Run

For a physical Android phone, use the laptop's LAN IP instead of `localhost`:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_LAPTOP_LAN_IP:8000/api/v1
```

The Splash screen does not call the backend yet, so an empty API URL does not block Page 01.

## Checks

```powershell
flutter pub get
flutter analyze
flutter test
```

## Next screen

Replace `OnboardingPlaceholderPage` with Page 02 from the Figma design. Do not modify the Splash route while implementing Page 02.
