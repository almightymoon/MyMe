# ADR 0001: Flutter mobile foundation

- **Status:** Accepted
- **Date:** 2026-08-07
- **Product:** MeMy (MoonTech)
- **Deciders:** Mobile foundation milestone

## Context

MeMy has an approved HTML/CSS/JavaScript prototype under `/app`. That prototype is the visual source of truth for tone, navigation patterns, and information architecture. Production requires a native-quality Android and iOS application that can grow into auth, APIs, and device features without converting the prototype’s JavaScript into Flutter.

## Decision

1. Introduce Flutter as the production mobile client at `/apps/mobile`.
2. Keep the existing `/app` prototype, root `/index.html`, and `/reference images` intact.
3. Use a feature-first structure with centralized theme tokens and reusable MeMy widgets.
4. Use **go_router** with a StatefulShellRoute for primary tabs and a demo `/signin` initial route.
5. Use **flutter_riverpod** for state management going forward.
6. Use **google_fonts** (Fraunces, Inter, IBM Plex Mono) to approximate the prototype typography until bundled fonts are finalized.
7. Ship placeholder feature screens and a Quick Add sheet; no backend, auth provider, AI, or sensors in this milestone.

## Consequences

### Positive

- Mobile work can proceed without blocking prototype iteration.
- Clear separation between design reference and production code.
- Minimal dependency set keeps the foundation reviewable and easy to extend.

### Negative / trade-offs

- Some visual parity work remains after the foundation (assets, motion, glass effects).
- google_fonts requires network or cached font downloads at first run in some environments.
- Repository and domain layers are deferred, so screens temporarily own demo data.

### Follow-ups

- Bundle fonts locally if offline-first branding becomes a hard requirement.
- Introduce repository interfaces when the first real data source lands.
- Expand widget and golden tests as screens move beyond placeholders.
