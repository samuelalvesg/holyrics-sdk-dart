import 'package:holyrics_core/holyrics_core.dart';

Future<void> main() async {
  final holyrics = HolyricsClient.local(
    host: '192.168.0.10',
    port: 8091,
    token: 'your-token',
  );
  try {
    final current = await holyrics.presentation.current(includeSlides: true);
    print(current?.name ?? 'nothing on screen');
    await holyrics.presentation.next();
  } on HolyricsException catch (e) {
    print('Holyrics error: $e');
  } finally {
    holyrics.close();
  }
}
