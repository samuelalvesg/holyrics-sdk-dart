import 'package:holyrics_core/holyrics_core.dart';
import 'package:test/test.dart';

void main() {
  group('computeDtoken', () {
    test('hashes the auth handshake as nonce:0:token:auth', () {
      // Value computed independently with sha256sum: the Auth example in the
      // API docs is illustrative and does not match its own inputs.
      expect(
        computeDtoken(
          nonce: 'b58ba4f605bed27c40a20be53ee3cf3d',
          rid: 0,
          token: '1234',
          data: 'auth',
        ),
        '7a34b2de74f096ea79ca1e2fca28a99995805c6b002cc20949b7ea236dd5922f',
      );
    });

    test('matches the documented GetCPInfo vector', () {
      expect(
        computeDtoken(nonce: '1a2b3c', rid: 4, token: 'abcdef', data: '{}'),
        'f3391f69cbe03940bd0d4a63ee191092aab2f3573f56b410a9cf94da05d4cdb5',
      );
    });

    test('matches the documented SetTextCP vector', () {
      expect(
        computeDtoken(
          nonce: '1a2b3c',
          rid: 5,
          token: 'abcdef',
          data: '{"text": "Example", "show": true, "display_ahead": true}',
        ),
        '02a7789759694c535cd032489bf101110837c972d76cec51c7ad7e797696749d',
      );
    });
  });
}
