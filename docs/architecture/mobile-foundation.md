# MeMy mobile foundation

## Why Flutter is being introduced

The HTML/CSS/JavaScript application under `/app` is the approved **visual prototype**. It validated navigation, tone, and information architecture quickly in the browser.

Production MeMy needs a native-quality mobile client with:

- Reliable offline-friendly UI foundations
- Shared code across Android and iOS
- A maintainable feature-first codebase
- Room for future auth, API, and device integrations without rewriting the UI layer

Flutter is introduced **beside** the prototype so design iteration can continue in HTML while the mobile foundation hardens in Dart.

## How the prototype and mobile app coexist

| Path | Role |
|------|------|
| `/app` | Design prototype and interaction reference — do not convert wholesale |
| `/index.html` | Design-system / marketing reference page |
| `/apps/mobile` | Production Flutter mobile foundation |
| `/reference images` | Visual references and screenshots |

Rules:

- Do not delete or rewrite the prototype to “make room” for Flutter.
- Port **design language and IA**, not DOM structure or JavaScript modules.
- When Flutter screens diverge, update ADRs / product docs rather than silently mutating the prototype.

## Chosen mobile architecture

Feature-first layout under `apps/mobile/lib`:

```
lib/
  app/          # bootstrap, router, theme
  core/         # shared constants and reusable widgets
  features/     # feature modules (presentation first in this milestone)
```

Principles for this foundation:

- **Presentation-first features** — screens and shell only; no real repositories yet
- **Thin `app/` layer** — theme, routing, and bootstrap stay centralized
- **Reusable MeMy primitives** — cards, buttons, empty states, page headers
- **Material 3 base** — heavily themed to match MeMy tokens (canvas, ember, Fraunces/Inter)

Future layers (not in this milestone):

- `domain/` entities and use cases
- `data/` repository implementations and DTOs
- platform adapters (health, notifications, secure storage)

## Navigation strategy

- **go_router** for declarative, deep-linkable routes
- Initial route: `/signin` (demo-only)
- Primary tabs use **`StatefulShellRoute.indexedStack`** so Today / Plan / Coach / More preserve scroll and nested stack state
- Central **Quick Add** is a shell-owned modal, not a fifth tab destination
- Secondary feature routes (`/goals`, `/finance`, …) are top-level routes reachable from Plan, More, or Quick Add

## State-management strategy

- **flutter_riverpod** as the default app-wide state approach
- This foundation keeps providers minimal (router / shell concerns only as needed)
- Prefer immutable UI state and small providers as features grow
- Avoid introducing code-generation (Freezed, Riverpod codegen) until complexity warrants it

## Repository abstraction strategy

Not implemented in this milestone. Intended direction:

1. Define repository interfaces in `domain/` (or feature `domain/`)
2. Provide demo / in-memory implementations for UI development
3. Swap to remote implementations behind the same interfaces when a backend exists
4. Keep presentation unaware of HTTP, databases, or vendor SDKs

Until then, screens use clearly labeled **demo content** only.

## Future backend integration approach

When backend work begins:

1. Introduce a thin API client layer (not in this milestone)
2. Map network models → domain models in `data/`
3. Auth tokens and session live behind an auth repository — never inside widgets
4. AI Coach becomes a streaming/message repository; UI must still show offline / unavailable states honestly
5. Health / sensors remain optional platform adapters with graceful fallbacks

This foundation intentionally **does not** include Firebase, Auth0, OpenAI, Dio, databases, or real authentication.
