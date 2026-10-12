/// Contract for anything able to send a named action to Holyrics.
///
/// Feature APIs (e.g. the presentation API) depend on this instead of the
/// concrete client, so they can be tested with a trivial fake.
abstract interface class HolyricsActionCaller {
  /// Sends [action] with [params] and returns the response `data` field.
  ///
  /// Entries of [params] with a null value are omitted from the request.
  Future<Object?> call(String action, [Map<String, Object?>? params]);
}
