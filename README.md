# CHI app: demo

Clickable demo of the Cockney Hudayetool Islam Society member app, built in **Flutter** for Android and iOS (web build for sharing the demo).
All data is local mock data; the Juice by MCB checkout is a simulated sandbox flow. Requirements: `assets/CHI Mobile App - Requirements Document.pdf`.

The earlier Expo/React Native version is kept on the `expo` branch.

## Run

```bash
export PATH="$HOME/development/flutter/bin:$PATH"   # or wherever Flutter is installed
flutter pub get
flutter run              # pick an emulator or device
flutter run -d chrome    # or in a browser
```

Demo login is prefilled (member CHI-01427).

## Checks

```bash
dart format .
flutter analyze
flutter test
```

## Layout

- `lib/app/router.dart`: go_router, five tabs (Home, Committee, FAQ, Contacts, Member) plus stacked and modal routes
- `lib/features/*`: one folder per area (home, payments, prayer, member, news, events, centenary…)
- `lib/core/theme`: design tokens and theme · `lib/core/widgets`: UI kit, `Photo`/`PhotoScreen`, brand marks
- `lib/core/l10n`: EN/FR ARB strings · `lib/core/utils`: prayer times, Hijri, formatting, PDF receipts, biometrics
- `lib/data`: models, mock content, Riverpod state, photo registry
- `assets/images/photos`: placeholder photography from Wikimedia Commons (credited in-app under Photo credits)
