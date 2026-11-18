# CHI app: demo (Flutter)

Clickable demo of the Cockney Hudayetool Islam Society member app. Mobile-first: Android and iOS are the targets; web is a nice-to-have for sharing the demo, never a design driver.
All data is local mock data; the Juice by MCB checkout is a simulated sandbox flow. The product spec is `assets/CHI Mobile App - Requirements Document.pdf`.

> Migration in progress: the app is being ported from Expo/React Native (`src/`, `package.json`, `app.json`) to Flutter. The TypeScript code is the behavioural reference until each screen is ported; delete the Expo files once the Flutter build reaches parity.

## Product rules from the spec (cite the ID in commits/PRs)

The PDF is the source of truth; these are the rules that shape app code. Priorities: M = must, S = should, N = nice.

- **Navigation (§10):** five bottom tabs, always in this order: Home, Committee, FAQ, Contacts, Member. Visitors see all five; only Member needs login. Prayer times, Ramadan, Qibla, events, documents open from Home (or a "More" menu), not as extra tabs.
- **Roles (§2, FR-010, FR-018):** Visitor = public tabs + Member login/Request access. Member status gates access: *Active* can pay; *Inactive* sees balance + "contact the society" and no pay button; *Deceased* has no access. Model the status as an enum and branch on it explicitly.
- **Access request (FR-011, US-02):** full name, NIC, mobile, email, member number (optional), and a required consent checkbox. Validate Mauritian NIC (14 chars: letter + 12 digits + letter, uppercase) and mobile (+230, 8 digits starting with 5) before submit; show a confirmation screen.
- **Login (FR-015–017):** email *or* member number + password; biometric unlock offered only after a first successful login; session times out after inactivity (configurable constant); "Forgot password?" on the login screen.
- **Subscriptions & payment (FR-020–024, PAY-01–07):** dashboard shows status, paid-up-to month, next due amount. 12-month calendar with Paid / Due / Overdue / Upcoming. Member selects months (arrears must be included before future months), sees the MUR total, then Juice checkout. Result screen always ends in one of **success / failed / pending**, never ambiguous. The app never marks months paid on its own in production: payment confirmation is server-side (PAY-03); in the demo the mock store stands in for the server. Paying the same months twice must be impossible (PAY-05). PDF receipt with CHI logo, member no., months, amount, date, Juice ref.
- **Payments need connectivity (NFR-04):** disable the pay button offline with a message; never queue a payment for later. If Juice is unavailable, show the manual-payment fallback (PAY-15).
- **Offline (FR-009, NFR-04):** public content and the last-synced member dashboard stay readable offline. Cache via a repository layer; screens don't know if data is cached.
- **Donations (FR-036, PAY-12):** separate from subscriptions, tagged to a fund, own receipts.
- **Prayer & Islamic features (FR-003, FR-030–035):** times for Mauritius (Asia/Port_Louis, UTC+4) and Hijri date on Home; per-prayer adhan toggle, **off by default**; Ramadan suhoor/iftar + countdown; Qibla compass with a stated accuracy tolerance and a calibration hint.
- **Content norms (§10):** respectful imagery, no music; adhan audio optional and off by default. Tone suits older members: large tap targets, readable type.
- **Localisation (FR-041, NFR-07):** EN + FR required; layouts must tolerate longer French/Kreol strings and Arabic labels (test with FR). Format dates, MUR currency (`Rs` / `MUR`, no decimals unless needed) and time in Mauritius locale/timezone, never device timezone for prayer/due dates.
- **Accessibility (NFR-06):** WCAG 2.1 AA target: contrast, scalable text, screen-reader labels.
- **Privacy & security (SEC-*, FR-028):** never store card or Juice credentials; store only transaction refs and statuses. Tokens go in `flutter_secure_storage`, never `SharedPreferences`. Don't log NIC, phone, email or tokens. Member can request account deletion from the profile screen.
- **Data usage (NFR-11):** compressed images, cached network images, keep APK/IPA lean for budget Android devices. Support min Android API 23 / iOS 13 unless the toolchain forces higher (NFR-05: 95% of devices in Mauritius).
- **Out of scope for the app:** voting, accounting, non-Juice in-app payments (cash/bank are recorded by the treasurer in admin), live streaming. The web admin panel is a separate product; the in-app `admin` screen is only a demo preview.
- **Placeholders:** names, numbers, address and logo in mock data are placeholders until CHI supplies real content.

## Don't trust your training data

Flutter and its packages ship breaking changes often. Before writing code against a Flutter, Dart or pub.dev API:

1. Check the SDK constraint in `pubspec.yaml` and the installed version (`flutter --version`).
2. Read the current docs (https://docs.flutter.dev, https://api.flutter.dev) or the package's pub.dev page and changelog for the pinned version. Don't answer from memory.

## Commands

```bash
flutter pub add <package>      # add a dependency (never hand-edit versions without checking pub.dev)
flutter pub get
flutter run                    # pick a device/emulator; `-d chrome` for web
dart format .
flutter analyze                # lints (flutter_lints / analysis_options.yaml)
flutter test
dart run build_runner build -d # only if codegen packages are added
```

Run `dart format .`, `flutter analyze` and `flutter test` before calling any task done. Zero analyzer warnings.

## Project layout

```
lib/
  main.dart            # runApp, theme, router, providers
  app/router.dart      # go_router config (tabs shell + stacked/modal routes)
  features/<feature>/  # one folder per area: home, committee, faq, contacts, member,
                       # payments (pay, checkout, receipt, history), prayer, qibla,
                       # ramadan, events, news, donate, documents, admin, request_access…
    <x>_screen.dart
    widgets/
  core/
    theme/             # tokens: colors, spacing, radii, text styles (port of src/theme.ts)
    widgets/           # shared UI kit (port of src/components/ui.tsx)
    l10n/              # ARB files (app_en.arb, app_fr.arb)
    utils/             # time/Hijri/prayer helpers, receipt builder
  data/                # models + mock content (port of src/data, src/lib/store.tsx)
test/
assets/fonts/, assets/images/
```

Screens stay thin: layout + wiring. Logic lives in providers/services so it can be unit-tested without widgets.

## Architecture rules

- **Navigation:** `go_router`. Bottom tabs (Home, Committee, FAQ, Contacts, Member) via `StatefulShellRoute.indexedStack` so each tab keeps its own stack. Checkout and request-access open as full-screen modals (`fullscreenDialog: true`). Deep link scheme: `chi://`.
- **State:** Riverpod (`flutter_riverpod`). App state mirrors the old reducer in `src/lib/store.tsx`: immutable models, a `Notifier` with explicit methods instead of a dispatch switch. No global mutable singletons.
- **Models:** immutable classes with `const` constructors, `copyWith`, and Dart 3 `enum`/sealed classes for statuses (`MonthStatus`, `PayMethod`, …). Money as `int` (rupees), never `double`.
- **i18n:** `flutter_localizations` + `intl` with ARB files, EN and FR. No hard-coded user-facing strings in widgets. Localised content in mock data uses a small `Localized {en, fr}` type.
- **Theme:** one `ThemeData` (Material 3) built from tokens in `core/theme`. Widgets read colours and text styles from the theme/tokens, never inline hex values. Light mode only for now (matches the current app).
- **Fonts:** bundle Fraunces, Inter and Amiri as assets in `pubspec.yaml` (offline-safe); don't fetch fonts at runtime.

## Mobile rules

- Wrap screens in `SafeArea` (or use `Scaffold` correctly) and respect notches, home indicator and the keyboard (`resizeToAvoidBottomInset`, scrollable forms).
- Touch targets at least 48×48 dp. Text must survive 200% system text scaling without clipping; don't clamp `textScaler`.
- Use `ListView.builder` / slivers for anything that can grow (news, payments, notifications). No `Column` inside `SingleChildScrollView` for long lists.
- `const` constructors wherever possible; avoid rebuilding whole screens — scope `ref.watch` / `select` narrowly.
- Platform feel: Material widgets by default, adaptive variants (`Switch.adaptive`, `showAdaptiveDialog`, Cupertino back-swipe via `go_router`) where iOS users would notice. Haptics through `HapticFeedback` from `flutter/services.dart`.
- Accessibility: `Semantics` labels on icon-only buttons and custom painters (Qibla compass, brand art); contrast tokens already meet WCAG AA, don't introduce colours that don't.
- Portrait only (`SystemChrome.setPreferredOrientations`); tablets get the same layout with a max content width.
- Permissions (location for Qibla, biometrics) are requested in context, with a fallback path when denied. Declare usage strings in `ios/Runner/Info.plist` and `android/app/src/main/AndroidManifest.xml`.

## Visual design rules

The app must look designed for CHI, not generated. Audience includes older members: clarity beats decoration.

- **One design system.** All colours, spacing, radii and text styles come from `core/theme` tokens (palette from the CHI logo: amber sun, charcoal wave, warm paper). No ad-hoc `Color(0x…)`, `EdgeInsets` magic numbers or one-off `TextStyle`s in screens.
- **One accent.** Amber is the accent for the primary action and the current state (next prayer, selected month, active tab). Everything else stays neutral. Amber is a fill, never body text; use `amberDeep` when amber text is needed.
- **Emphasise the CTA.** Each screen has at most one filled primary button (e.g. "Pay with Juice", "Log in", "Get directions"). Secondary actions are outlined or text buttons.
- **Enlarge the main thing.** Each screen has one obvious hero: next prayer on Home, status + amount due on Member, total on Pay, the tick + receipt no. on payment success. Give it the largest type and the most space.
- **Show the real thing.** Use real-looking content (prayer times, MUR amounts, months) in mocks and empty states, not lorem ipsum or decorative illustrations.
- **Cut filler.** No decorative badges, "New!" chips, gradients, glows, sparkles or ornamental dividers. A badge only appears if it carries state (Active, Paid, Overdue, Manual). Don't label what is already obvious (no "Name:" above a name).
- **Headlines are specific.** "Asr in 42 min", "2 months overdue · Rs 300", not "Welcome back!" or "Your dashboard". Balance multi-line headlines so a single word isn't orphaned (`TextWrap`-style: shorten copy or set `maxLines` + sensible width).
- **Typography.** Fraunces for display, Inter for UI, Amiri for Arabic only. No random italics; italic only for a quote or Arabic transliteration. No monospace except reference codes (receipt no., Juice ref). All numbers that line up or change (times, amounts, countdowns, calendars) use tabular figures: `fontFeatures: [FontFeature.tabularFigures()]`.
- **Group with spacing, not boxes.** Related items sit closer than unrelated ones (spacing scale 4/8/12/16/24/32). Prefer whitespace over extra cards, borders and dividers.
- **Nested radii.** Inner radius = outer radius − padding (min 0). A 12-radius card with 8 padding holds 4-radius children.
- **Icons.** One icon family (Material Symbols, rounded, one weight) at consistent sizes (20 inline, 24 nav). Never mix filled and outlined in the same row except to show selected state.
- **Contrast.** Body text ≥ 4.5:1, large text and icons ≥ 3:1 against their real background. Muted text uses the `muted` token, not opacity.
- **Optical alignment.** Align by eye: icons beside text are vertically centred on the cap height, circular avatars/play icons may need a 1–2 px nudge. Check on device, not just in code.
- **Loading, empty and error states** for every async screen: skeletons shaped like the content (not a lone spinner) for lists; disabled + progress state on buttons while submitting; empty and offline states that say what to do next.

## Motion rules

Motion explains what changed; it never decorates. Respect reduced motion: when `MediaQuery.disableAnimationsOf(context)` is true, replace movement with instant changes or a short fade.

- **Curves.** Entrances: `Curves.easeOutCubic`. Moves of something already on screen: `Curves.easeInOutCubic`. Exits: `Curves.easeInCubic`. No `elasticOut`/`bounceOut` on everyday UI.
- **Durations.** Taps/press feedback 100 ms; menus, popovers, bottom sheets, dropdowns 150–250 ms; page transitions 250–300 ms. Exits are ~20% shorter than their entrance. Keep everything under 400 ms (Doherty threshold); anything that takes longer needs visible progress.
- **Press feedback.** Tappable cards and buttons scale to 0.97 on press (no animation while the finger is held; snap back with ease-out on release). Pair important actions with `HapticFeedback.selectionClick()` / `lightImpact()`.
- **Origin.** Popovers, menus and sheets start at 0.95 scale + fade and grow from their trigger; they shrink back toward it on exit (`transformAlignment` / anchor). Bottom sheets come from the bottom edge.
- **Lists.** Stagger row entrances by ~30 ms (cap at ~8 rows, then show the rest at once). Only on first load, never on every rebuild or scroll.
- **Continuity.** Elements that persist between screens (news image → article, month chip → checkout summary, avatar → profile) use `Hero` with a stable tag. Old and new states overlap (cross-fade / `AnimatedSwitcher`) instead of blanking in between. Icons that change (bell on/off, play/pause) cross-fade with a slight scale/blur.
- **Moving things.** Objects travelling across the screen follow a gentle arc (`MaterialRectArcTween` for Heroes), not a straight diagonal. Toggle knobs may stretch ~12% along the direction of travel. Things that settle can have a small follow-through, not a bounce.
- **Reveals.** Use clips/masks (`ClipRect`, `ShaderMask`, `SizeTransition`) to reveal content and colour changes rather than sliding big blocks around.
- **Success.** Confirm success with one short pulse (tick draws in + scale 1.0→1.06→1.0) and a haptic, e.g. payment success, access request sent. Errors shake once, lightly, plus a message.
- **Scroll edges.** Keep platform overscroll: iOS rubber-band (`BouncingScrollPhysics`), Android stretch. Don't force one platform's physics on the other.
- **Anticipation and staging.** Dim/blur the background behind sheets and dialogs so focus is on the new layer. A slight wind-up is allowed on big gestures (pull-to-refresh), not on taps.
- **Depth.** One consistent light source: elevation and shadows come from the theme, same direction everywhere; don't mix flat and heavy-shadow cards.

## UX laws to apply

- **Fitts's law / bigger hit areas:** primary actions are large and within thumb reach (bottom half). Hit areas ≥ 48 dp even when the visual is smaller (pad with `InkWell`/`SizedBox`, not bigger icons).
- **Hick's law:** few choices per screen; secondary features go behind Home cards or a "More" sheet, not crammed into the tab bar.
- **Miller's law:** chunk information: group FAQ by category, break long forms into short sections, show months in rows of 4–6.
- **Doherty threshold:** respond within 400 ms. Show optimistic UI or a skeleton immediately; never leave a tap without feedback.
- **Postel's law:** accept input liberally (spaces/dashes in phone and NIC, lower-case NIC, `+230` or not) and normalise it; output strictly formatted.
- **Jakob's law:** use the patterns members already know from banking and WhatsApp-style apps: bottom tabs, pull-to-refresh, swipe-back on iOS, system share sheet, standard date pickers.
- **Frequency of use:** the most-used things (next prayer, pay due months) are reachable in one tap from launch; rare things (deletion request, documents) can be deeper.

## Native folders

`android/` and `ios/` are committed and edited directly (unlike Expo CNG). Keep changes minimal: app id, name, icons, permissions, min SDK. Generate icons and splash with `flutter_launcher_icons` and `flutter_native_splash` (brand bg `#FBF6EE`) rather than hand-editing image assets.

## Package map (Expo → Flutter)

| Expo / RN | Flutter |
|---|---|
| expo-router | go_router |
| useReducer + context | flutter_riverpod |
| adhan | adhan (Dart port) |
| expo-local-authentication | local_auth |
| expo-location | geolocator (+ flutter_compass for Qibla heading) |
| expo-print + expo-sharing | pdf + printing, share_plus |
| expo-haptics | `HapticFeedback` (built-in) |
| react-native-svg | flutter_svg / `CustomPainter` |
| expo-splash-screen | flutter_native_splash |
| @expo-google-fonts/* | bundled font assets |
| (new) secure token storage | flutter_secure_storage |
| (new) offline/connectivity | connectivity_plus, cached_network_image |
| (new) adhan / reminder alerts | flutter_local_notifications (push later: firebase_messaging) |
| Linking (call, email, WhatsApp, maps) | url_launcher |

Prefer the Flutter SDK and first-party (flutter.dev / dart.dev verified publisher) packages before adding third-party ones. Every new dependency needs a reason.
