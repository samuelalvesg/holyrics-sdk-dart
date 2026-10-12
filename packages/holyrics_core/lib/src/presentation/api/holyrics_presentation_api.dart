import '../../core/contracts/holyrics_action_caller.dart';
import '../models/current_presentation.dart';

/// Typed access to the presentation currently on screen.
class HolyricsPresentationApi {
  HolyricsPresentationApi(this._caller);

  final HolyricsActionCaller _caller;

  /// The item being presented, or null when nothing is on screen.
  Future<CurrentPresentation?> current({
    bool includeSlides = false,
    bool includeSlideComment = false,
  }) async {
    final data = await _caller.call('GetCurrentPresentation', {
      'include_slides': includeSlides ? true : null,
      'include_slide_comment': includeSlideComment ? true : null,
    });
    if (data is! Map<String, Object?>) return null;
    return CurrentPresentation.fromJson(data);
  }

  /// Advances to the next slide.
  Future<void> next() => _caller.call('ActionNext');

  /// Goes back one slide.
  Future<void> previous() => _caller.call('ActionPrevious');

  /// Jumps to the slide at [index].
  Future<void> goToIndex(int index) =>
      _caller.call('ActionGoToIndex', {'index': index});

  /// Closes the current presentation.
  Future<void> close() => _caller.call('CloseCurrentPresentation');
}
