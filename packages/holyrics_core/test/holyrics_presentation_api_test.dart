import 'package:holyrics_core/holyrics_core.dart';
import 'package:test/test.dart';

class _FakeCaller implements HolyricsActionCaller {
  _FakeCaller(this.response);

  final Object? response;
  final calls = <(String, Map<String, Object?>?)>[];

  @override
  Future<Object?> call(String action, [Map<String, Object?>? params]) async {
    calls.add((action, params));
    return response;
  }
}

void main() {
  group('HolyricsPresentationApi', () {
    test('current() parses the item and its slides', () async {
      final caller = _FakeCaller({
        'id': 'abc',
        'type': 'song',
        'name': 'Amazing Grace',
        'slide_number': 2,
        'total_slides': 5,
        'slide_type': 'default',
        'slides': [
          {'number': 1, 'text': 'Verse', 'theme_id': 't1'},
          {
            'number': 2,
            'text': 'Chorus',
            'theme_id': 't1',
            'slide_description': 'Chorus',
          },
        ],
      });

      final current =
          await HolyricsPresentationApi(caller).current(includeSlides: true);

      expect(current!.name, 'Amazing Grace');
      expect(current.slideNumber, 2);
      expect(current.slides!.length, 2);
      expect(current.slides![1].slideDescription, 'Chorus');
      expect(caller.calls.single.$1, 'GetCurrentPresentation');
      expect(caller.calls.single.$2, {
        'include_slides': true,
        'include_slide_comment': null,
      });
    });

    test('current() returns null when nothing is presented', () async {
      final current =
          await HolyricsPresentationApi(_FakeCaller(null)).current();

      expect(current, isNull);
    });

    test('navigation calls the matching actions', () async {
      final caller = _FakeCaller(null);
      final api = HolyricsPresentationApi(caller);

      await api.next();
      await api.previous();
      await api.goToIndex(4);
      await api.close();

      expect(caller.calls.map((c) => c.$1), [
        'ActionNext',
        'ActionPrevious',
        'ActionGoToIndex',
        'CloseCurrentPresentation',
      ]);
      expect(caller.calls[2].$2, {'index': 4});
    });
  });
}
