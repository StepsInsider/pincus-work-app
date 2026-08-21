import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pincus_work/features/jokes/data/joke_service.dart';

class _FakeClient extends http.BaseClient {
  final http.Response response;
  _FakeClient(this.response);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final stream = Stream.fromIterable([response.bodyBytes]);
    return Future.value(
      http.StreamedResponse(
        stream,
        response.statusCode,
        headers: response.headers,
      ),
    );
  }
}

void main() {
  test('fetchRandomJoke returns joke map', () async {
    final payload = jsonEncode({
      'id': 1,
      'type': 'general',
      'setup': 'Setup',
      'punchline': 'Punch',
    });
    final client = _FakeClient(http.Response(payload, 200));
    final svc = JokeService(client: client);

    final joke = await svc.fetchRandomJoke();

    expect(joke['setup'], 'Setup');
    expect(joke['punchline'], 'Punch');
  });
}
