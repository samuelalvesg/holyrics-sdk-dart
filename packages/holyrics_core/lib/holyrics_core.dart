/// Unofficial Dart client for the Holyrics API Server (core/protocol, no UI).
///
/// Local network (token or hash) and cloud relay transports, one raw method
/// per documented action and typed models for the main features.
library;

export 'src/actions/action_names.dart';
export 'src/actions/actions.dart';
export 'src/client/holyrics_client.dart';
export 'src/core/auth/dtoken.dart';
export 'src/core/contracts/holyrics_action_caller.dart';
export 'src/core/exceptions/holyrics_exception.dart';
export 'src/core/transport/holyrics_cloud_transport.dart';
export 'src/core/transport/holyrics_hash_transport.dart';
export 'src/core/transport/holyrics_token_transport.dart';
export 'src/core/transport/holyrics_transport.dart';
export 'src/presentation/api/holyrics_presentation_api.dart';
export 'src/presentation/models/current_presentation.dart';
export 'src/presentation/models/presentation_slide.dart';
