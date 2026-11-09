# CHI app: demo

Clickable demo of the Cockney Hudayetool Islam Society member app (Expo SDK 58, Expo Router, TypeScript).
All data is local mock data; the Juice by MCB checkout is a simulated sandbox flow.

## Run

```bash
npm install
npx expo start          # scan the QR code with Expo Go (SDK 58)
npx expo start --web    # or open in a browser
```

Demo login is prefilled (member CHI-01427).

## Checks

```bash
npx tsc --noEmit
npx eslint src
```

## Layout

- `src/app`: routes (tabs: Home, Committee, FAQ, Contacts, Member; stacked screens for payments, prayer, events, admin preview…)
- `src/components`: UI kit, brand art, cards
- `src/lib`: store (useReducer + context), i18n (EN/FR), prayer times and Hijri calendar, receipts
- `src/data/content.ts`: placeholder content (names, numbers, address and logo are placeholders)
