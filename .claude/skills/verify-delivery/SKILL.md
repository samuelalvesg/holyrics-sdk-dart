---
name: verify-delivery
description: Runs the delivery gate of the holyrics_core Dart package, the same steps as its CI (pub get, dart format check, dart analyze, generated code up to date, dart test), and reports PASS, FAIL or NÃO EXECUTADO per command. Use before handing off to @qa-engineer or @reviewer, before marking a PR ready, and whenever someone asks whether it is green.
---

# Verify delivery (holyrics-sdk-dart)

## Rules
- Detect capability first: `command -v dart`. Missing tool →
  `NÃO EXECUTADO: dart ausente`; never report green.
- Never skip, weaken or delete a test to get green.
- While fixing, re-run only the failing test file (`dart test <file>`); the
  full gate at the end.
- Keep only failures, totals and skip lines.

## Commands (same as `.github/workflows/ci.yml`; run in `packages/holyrics_core/`)
1. `dart pub get`
2. `dart format --output=none --set-exit-if-changed .`
3. `dart analyze` (no issues on 2026-11-22)
4. Generated code is up to date:
   `dart run tool/generate_actions.dart && dart format lib && git diff --exit-code lib`.
   A diff means the generator and `lib/src/actions/` disagree: fix the
   generator or commit the regenerated files, never hand-edit them.
5. `dart test` (20 passed on 2026-11-22)

## Before a release (never publish for real without the user's confirmation)
`dart pub publish --dry-run`; report the output.

## Report (same block in the PR body)
```
VERIFY: holyrics-sdk-dart @ <short sha>
format → PASS | FAIL | NÃO EXECUTADO: <motivo>
analyze → PASS | FAIL (<n> issues)
generated code → PASS | FAIL
test → PASS | FAIL (<passed>/<failed>/<skipped>)
```
