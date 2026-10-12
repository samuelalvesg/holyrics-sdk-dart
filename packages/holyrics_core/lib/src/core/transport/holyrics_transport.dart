/// Contract for the wire layer: sends one action and returns its `data`.
abstract interface class HolyricsTransport {
  /// Sends [action] with a JSON [body] and returns the decoded `data` field.
  ///
  /// Throws a `HolyricsException` subclass on protocol or server errors.
  Future<Object?> send(String action, Map<String, Object?> body);

  /// Releases the underlying HTTP client, if this transport owns it.
  void close();
}
