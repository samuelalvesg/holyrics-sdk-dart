import 'presentation_slide.dart';

/// The item being presented right now (`GetCurrentPresentation`).
class CurrentPresentation {
  const CurrentPresentation({
    required this.id,
    required this.type,
    required this.name,
    this.slideNumber,
    this.totalSlides,
    this.slideType,
    this.slides,
  });

  factory CurrentPresentation.fromJson(Map<String, Object?> json) {
    final slides = json['slides'] as List<Object?>?;
    return CurrentPresentation(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slideNumber: (json['slide_number'] as num?)?.toInt(),
      totalSlides: (json['total_slides'] as num?)?.toInt(),
      slideType: json['slide_type'] as String?,
      slides: slides
          ?.cast<Map<String, Object?>>()
          .map(PresentationSlide.fromJson)
          .toList(),
    );
  }

  final String id;

  /// `song`, `verse`, `text`, `audio`, `image`, `announcement`,
  /// `automatic_presentation` or `quick_presentation`.
  final String type;
  final String name;

  /// Starts at 1.
  final int? slideNumber;
  final int? totalSlides;

  /// `default`, `wallpaper`, `blank`, `black` or `final_slide`.
  final String? slideType;

  /// Only filled when requested with `includeSlides`.
  final List<PresentationSlide>? slides;
}
