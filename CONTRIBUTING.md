# Contributing

## Language

Code, comments, doc comments, exception messages, commit messages and docs
are written in **English** (pub.dev package, international audience).

## Repo layout

Monorepo, same layout as the sibling `youversion-platform-sdk-dart`: each
published package lives under `packages/<name>/` with its own
`pubspec.yaml`. See [`docs/DECISIONS.md`](docs/DECISIONS.md).

Inside a package, `lib/src/` is organised by feature, then by layer:

```
lib/src/
  core/          shared infrastructure
    contracts/   interfaces features depend on (HolyricsActionCaller)
    exceptions/  error types
    transport/   HolyricsTransport contract + token/hash/cloud implementations
    auth/        request signing
  actions/       GENERATED raw action mixins (one file per group)
  <feature>/     e.g. presentation/
    api/         typed API of the feature
    models/      domain models (fromJson, immutable)
  client/        HolyricsClient: wires transport, mixins and feature APIs
```

Features depend on `core/contracts`, never on a concrete transport, so they
are testable with a trivial fake. Public API is exported only from
`lib/holyrics_core.dart`.

## Style

- `dart format .` (80 columns), `dart analyze` clean.
- Files target <= 300 lines (generated files exempt), methods <= 40 lines,
  one responsibility per class.
- Every change comes with a regression test. Tests mock HTTP
  (`package:http/testing.dart`) - no real network.

## Generated code

`lib/src/actions/` is produced from `docs/api/API-Server.en.md`:

```sh
cd packages/holyrics_core
dart run tool/generate_actions.dart && dart format lib
```

Never edit those files by hand; change the generator. When the vendored docs
are refreshed, regenerate and commit both together.

## Publishing

`dart pub publish` is irreversible. Always run `dart pub publish --dry-run`
first and get explicit confirmation before the real publish.
