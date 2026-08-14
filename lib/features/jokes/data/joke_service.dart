import 'dart:convert';

import 'package:http/http.dart' as http;

class JokeService {
  const JokeService();

  /// Fetches a random joke from the public Official Joke API.
  /// Returns a decoded JSON map with at least `setup` and `punchline`.
  Future<Map<String, dynamic>> fetchRandomJoke() async {
    final uri = Uri.parse('https://official-joke-api.appspot.com/random_joke');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch joke: ${res.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    return json;
  }
}
