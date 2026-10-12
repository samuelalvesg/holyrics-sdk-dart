import 'package:http/http.dart' as http;

import '../actions/actions.dart';
import '../core/contracts/holyrics_action_caller.dart';
import '../core/transport/holyrics_cloud_transport.dart';
import '../core/transport/holyrics_hash_transport.dart';
import '../core/transport/holyrics_token_transport.dart';
import '../core/transport/holyrics_transport.dart';
import '../presentation/api/holyrics_presentation_api.dart';

/// Client for the Holyrics API Server.
///
/// Typed feature APIs (e.g. [presentation]) return domain models; the raw
/// action mixins return the decoded `data` field as is.
///
/// ```dart
/// final holyrics = HolyricsClient.local(
///   host: '192.168.0.10',
///   port: 8091,
///   token: 'abc',
/// );
/// final current = await holyrics.presentation.current(includeSlides: true);
/// await holyrics.presentation.next();
/// holyrics.close();
/// ```
class HolyricsClient
    with
        HolyricsBibleActions,
        HolyricsCommunicationPanelActions,
        HolyricsLyricsActions,
        HolyricsMediaActions,
        HolyricsPlanningActions,
        HolyricsPlaylistsActions,
        HolyricsPresentationActions,
        HolyricsSettingsActions,
        HolyricsSystemActions,
        HolyricsTextsActions
    implements HolyricsActionCaller {
  HolyricsClient(this.transport);

  /// Local network client. Uses the hash method (the token never leaves the
  /// machine) unless [useHash] is false.
  factory HolyricsClient.local({
    required String host,
    required int port,
    required String token,
    bool secure = false,
    bool useHash = true,
    http.Client? httpClient,
  }) =>
      HolyricsClient(
        useHash
            ? HolyricsHashTransport(
                host: host,
                port: port,
                token: token,
                secure: secure,
                client: httpClient,
              )
            : HolyricsTokenTransport(
                host: host,
                port: port,
                token: token,
                secure: secure,
                client: httpClient,
              ),
      );

  /// Internet client through the Holyrics cloud relay.
  factory HolyricsClient.cloud({
    required String apiKey,
    required String token,
    bool waitForResponse = true,
    http.Client? httpClient,
  }) =>
      HolyricsClient(
        HolyricsCloudTransport(
          apiKey: apiKey,
          token: token,
          waitForResponse: waitForResponse,
          client: httpClient,
        ),
      );

  final HolyricsTransport transport;

  /// Typed access to the presentation currently on screen.
  late final HolyricsPresentationApi presentation =
      HolyricsPresentationApi(this);

  /// Sends any action by name, including ones newer than this SDK.
  @override
  Future<Object?> call(String action, [Map<String, Object?>? params]) {
    final body = <String, Object?>{};
    params?.forEach((key, value) {
      if (value != null) body[key] = value;
    });
    return transport.send(action, body);
  }

  void close() => transport.close();
}
