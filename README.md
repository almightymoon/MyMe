# MeMy

MeMy is a personal life-operating system by **MoonTech** — goals, habits, calendar, finance, health, and an AI coach in one calm daily surface.

This repository currently holds:

1. An approved **HTML/CSS/JavaScript visual prototype** (design reference)
2. A new **Flutter mobile application foundation** under `apps/mobile`

The HTML application is the design prototype. It is not the production mobile client. Do not treat it as something to convert line-for-line into Flutter.

## Repository structure

```
/
├── index.html                 # Design-system / marketing-style reference page
├── app/                       # Interactive MeMy web prototype (approved visual reference)
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── assets/
├── apps/
│   └── mobile/                # Flutter production mobile foundation (Android + iOS)
├── docs/
│   ├── architecture/          # Architecture notes
│   ├── decisions/             # Architecture decision records (ADRs)
│   └── product/               # Product notes
└── reference images/          # Design / screenshot references
```

## Development status

| Area | Status |
|------|--------|
| Web prototype (`/app`) | Approved visual reference — keep intact |
| Flutter mobile (`/apps/mobile`) | Foundation: design system, shell, routing, placeholders |
| Backend / auth / AI / sensors | Not in scope for this foundation milestone |

## Run the web prototype

From the repository root:

```bash
# Any static file server works. Examples:
cd app && python3 -m http.server 8080
# then open http://localhost:8080
```

Or open `app/index.html` directly in a browser (some features may prefer a local server).

The root `index.html` is a design-system reference page, not the interactive phone prototype.

## Run the Flutter mobile app

Requirements: Flutter stable (Dart null safety), Android Studio / Xcode tooling as needed.

```bash
cd apps/mobile
flutter pub get
flutter run
```

Useful checks:

```bash
cd apps/mobile
dart format .
flutter analyze
flutter test
```

Organization / application id (provisional): `com.moontech.memy`

## Contribution conventions

- Do **not** delete, rename, move, or rewrite `/app`, root `/index.html`, or `/reference images`.
- Build new mobile work under `/apps/mobile`.
- Keep the HTML prototype as the visual source of truth until Flutter screens are intentionally redesigned.
- Prefer small, focused PRs; document architecture decisions under `docs/decisions/`.
- Do not commit secrets, `.env` files, or local IDE junk (see `.gitignore`).
- Do not add backend, Firebase, Auth0, OpenAI, or real sensor integrations unless a milestone explicitly calls for them.
- Run `dart format`, `flutter analyze`, and `flutter test` before submitting mobile changes.
