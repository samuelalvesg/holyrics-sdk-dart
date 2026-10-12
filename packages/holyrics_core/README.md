# holyrics_core

Unofficial Dart & Flutter client for the [Holyrics](https://holyrics.com.br/)
API Server. Pure Dart: works in Flutter, CLI tools and servers.

Two layers: typed feature APIs with domain models (`holyrics.presentation`)
and one raw method per documented action (231 names, including aliases),
plus `call()` for anything newer than this SDK.

## Usage

```dart
import 'package:holyrics_core/holyrics_core.dart';

Future<void> main() async {
  // Local network. Uses the hash method, so the token is never sent.
  final holyrics = HolyricsClient.local(
    host: '192.168.0.10',
    port: 8091, // see File > Settings > API Server in Holyrics
    token: 'your-token',
  );

  final current = await holyrics.presentation.current(includeSlides: true);
  print(current?.name);
  await holyrics.presentation.next();

  // Raw access to any action (returns the decoded `data` field):
  print(await holyrics.getCPInfo());
  holyrics.close();
}
```

Over the internet, through the Holyrics cloud relay:

```dart
final holyrics = HolyricsClient.cloud(apiKey: 'API_KEY', token: 'your-token');
```

Errors surface as `HolyricsApiException` (server said `status: error`) or
`HolyricsCloudException` (relay failure or timeout).

Responses are the raw decoded JSON `data` field. Typed models are on the
roadmap; every shape is documented in [`doc/api`](doc/api).

## API documentation

The full API Server documentation is vendored in [`doc/api`](doc/api)
(English and Portuguese) - see [`NOTICE`](NOTICE) for its origin.

## Regenerating the action methods

`lib/src/actions/*.dart` are generated from the vendored docs:

```sh
cd packages/holyrics_core
dart run tool/generate_actions.dart && dart format lib
```

Parameters whose names are patterns (e.g. `position_?`) or nested
(`a.b`) are not generated; pass them through `call()`.

## License

Apache 2.0, see `LICENSE`. Not affiliated with Holyrics.
