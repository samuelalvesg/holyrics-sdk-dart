/// One slide of the presentation currently on screen.
class PresentationSlide {
  const PresentationSlide({
    required this.number,
    required this.text,
    this.themeId,
    this.slideDescription,
    this.preview,
  });

  factory PresentationSlide.fromJson(Map<String, Object?> json) {
    return PresentationSlide(
      number: (json['number'] as num).toInt(),
      text: json['text'] as String? ?? '',
      themeId: json['theme_id'] as String?,
      slideDescription: json['slide_description'] as String?,
      preview: json['preview'] as String?,
    );
  }

  /// Slide number, starting at 1.
  final int number;
  final String text;
  final String? themeId;

  /// Slide description name (e.g. "Chorus"); music presentations only.
  final String? slideDescription;

  /// Preview image in base64, when requested.
  final String? preview;
}
