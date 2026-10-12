/// Base class for every error thrown by this SDK.
class HolyricsException implements Exception {
  HolyricsException(this.message, {this.code, this.key});

  /// Human readable message.
  final String message;

  /// Numeric error code, when the server provides one (cloud relay errors).
  final int? code;

  /// Machine readable error key such as `invalid_api_key`, when provided.
  final String? key;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server answered with `status: error` (bad token, missing permission,
/// invalid parameters...) or with a malformed body.
class HolyricsApiException extends HolyricsException {
  HolyricsApiException(super.message, {super.code, super.key});
}

/// The cloud relay could not deliver the request or the response timed out.
class HolyricsCloudException extends HolyricsException {
  HolyricsCloudException(super.message, {super.code, super.key});
}
