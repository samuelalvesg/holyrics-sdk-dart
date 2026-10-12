# Decisions log

Durable record of non-obvious decisions. Language: English.

## Repo layout

- **Monorepo with `packages/`**, mirroring `youversion-platform-sdk-dart`.
  `holyrics_core` is the first package; UI widgets (e.g. a stage view), if
  ever built, would be siblings (`holyrics_ui`) depending on core via `path:`.
- **Package name `holyrics_core`**: `holyrics`, `holyrics_sdk` and
  `holyrics_api` were free on pub.dev on 2026-10-12; `_core` follows the
  sibling repo's naming. Re-verify before the first publish.
- No Dart/Flutter Holyrics SDK was found on pub.dev or the web on
  2026-10-12 (GitHub repository search was unavailable in that session).

## Architecture

- **Two layers on the same client.** Raw layer: one generated method per
  documented action (231 names incl. aliases), returning the `data` field.
  Typed layer: hand-written feature APIs with domain models (started with
  `presentation`). Raw guarantees full API coverage on day one; typed models
  are added feature by feature, driven by real use (Symmetris stage view
  first).
- **Generated raw layer, grouped by feature** (`tool/generate_actions.dart`,
  groups by action name): the docs are the single source of truth and the
  API has 200+ actions, so hand-writing them would drift.
- **Contracts in `core/contracts`**: `HolyricsActionCaller` and
  `HolyricsTransport` are interfaces; feature APIs depend only on them.
- **Storage/HTTP agnostic**: callers may inject `http.Client`; no storage.
- **Default port is a required parameter**: the API docs do not state one.
- **Cloud relay vs local**: local uses the hash method by default so the
  token never crosses the network.

## Known gaps

- Parameters with pattern names (`position_?`) or nested (`a.b`) are not
  generated; use `call()`.
- The docs' `Auth` example hash does not match its inputs (illustrative);
  tests use an independently computed value, and the two other documented
  vectors match.
- Real-time events: the API has no websocket/webhook; polling
  `presentation.current()` or a JS script inside Holyrics are the options.
