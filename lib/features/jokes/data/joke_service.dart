import 'dart:convert';

import 'package:http/http.dart' as http;

class JokeService {
  final http.Client _client;
  JokeService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a random joke from the public Official Joke API.
  /// Throws on non-200 or on timeout.
  Future<Map<String, dynamic>> fetchRandomJoke({Duration timeout = const Duration(seconds: 5)}) async {
    final uri = Uri.parse('https://official-joke-api.appspot.com/random_joke');
    final res = await _client.get(uri).timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch joke: ${res.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    return json;
  }
}
