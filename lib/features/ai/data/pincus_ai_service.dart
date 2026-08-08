import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/ai_message.dart';
import 'ai_config.dart';

class PincusAiService {
  PincusAiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AiConfig.apiKey}',
      'Accept': 'application/json',
    };
  }

  Future<bool> health() async {
    final uri = Uri.parse(
      AiConfig.baseUrl.replaceFirst(
        '/v1',
        '/health',
      ),
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(AiConfig.requestTimeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> models() async {
    final response = await _client
        .get(
          Uri.parse(
            '${AiConfig.baseUrl}/models',
          ),
          headers: _headers,
        )
        .timeout(AiConfig.requestTimeout);

    _checkResponse(response);

    final json =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final data =
        json['data'] as List<dynamic>? ?? [];

    return data
        .map(
          (item) =>
              (item as Map<String, dynamic>)['id']
                  as String,
        )
        .toList();
  }

  Future<AiMessage> sendMessage({
    required List<AiMessage> messages,
    String model = AiConfig.defaultModel,
    double? temperature,
    int? maxTokens,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'stream': false,
      'messages':
          messages.map((e) => e.toJson()).toList(),
    };

    if (temperature != null) {
      body['temperature'] = temperature;
    }

    if (maxTokens != null) {
      body['max_tokens'] = maxTokens;
    }

    final response = await _client
        .post(
          Uri.parse(
            '${AiConfig.baseUrl}/chat/completions',
          ),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(AiConfig.requestTimeout);

    _checkResponse(response);

    final json =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final choices =
        json['choices'] as List<dynamic>? ?? [];

    if (choices.isEmpty) {
      throw Exception(
        'Pincus AI returned no choices.',
      );
    }

    final first =
        choices.first as Map<String, dynamic>;

    final message =
        first['message']
            as Map<String, dynamic>;

    return AiMessage.assistant(
      message['content'] as String? ?? '',
      model: json['model'] as String?,
    );
  }

  Stream<String> streamMessage({
    required List<AiMessage> messages,
    String model = AiConfig.defaultModel,
    double? temperature,
    int? maxTokens,
  }) async* {
    final body = <String, dynamic>{
      'model': model,
      'stream': true,
      'messages':
          messages.map((e) => e.toJson()).toList(),
    };

    if (temperature != null) {
      body['temperature'] = temperature;
    }

    if (maxTokens != null) {
      body['max_tokens'] = maxTokens;
    }

    final request = http.Request(
      'POST',
      Uri.parse(
        '${AiConfig.baseUrl}/chat/completions',
      ),
    );

    request.headers.addAll(_headers);
    request.headers['Accept'] =
        'text/event-stream';

    request.body = jsonEncode(body);

    final streamedResponse =
        await _client.send(request);

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      final errorBody =
          await streamedResponse.stream.bytesToString();

      throw Exception(
        'Pincus AI error '
        '${streamedResponse.statusCode}: '
        '$errorBody',
      );
    }

    String buffer = '';

    await for (final chunk
        in streamedResponse.stream.transform(
      utf8.decoder,
    )) {
      buffer += chunk;

      final lines =
          buffer.split('\n');

      buffer = lines.removeLast();

      for (final line in lines) {
        final trimmed =
            line.trim();

        if (trimmed.isEmpty) {
          continue;
        }

        if (!trimmed.startsWith('data:')) {
          continue;
        }

        final data =
            trimmed.substring(5).trim();

        if (data == '[DONE]') {
          return;
        }

        try {
          final json =
              jsonDecode(data)
                  as Map<String, dynamic>;

          final choices =
              json['choices']
                  as List<dynamic>?;

          if (choices == null ||
              choices.isEmpty) {
            continue;
          }

          final choice =
              choices.first
                  as Map<String, dynamic>;

          final delta =
              choice['delta']
                  as Map<String, dynamic>?;

          final content =
              delta?['content']
                  as String?;

          if (content != null &&
              content.isNotEmpty) {
            yield content;
          }
        } catch (_) {
          // Unvollständiger SSE-Block.
        }
      }
    }
  }

  Future<List<double>> embedding(
    String text, {
    String model =
        AiConfig.embeddingModel,
  }) async {
    final response = await _client
        .post(
          Uri.parse(
            '${AiConfig.baseUrl}/embeddings',
          ),
          headers: _headers,
          body: jsonEncode({
            'model': model,
            'input': text,
          }),
        )
        .timeout(AiConfig.requestTimeout);

    _checkResponse(response);

    final json =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final data =
        json['data'] as List<dynamic>? ?? [];

    if (data.isEmpty) {
      throw Exception(
        'No embedding returned.',
      );
    }

    final embedding =
        data.first
            as Map<String, dynamic>;

    return (embedding['embedding']
            as List<dynamic>)
        .map(
          (value) =>
              (value as num).toDouble(),
        )
        .toList();
  }

  void _checkResponse(
    http.Response response,
  ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message =
        'HTTP ${response.statusCode}';

    try {
      final json =
          jsonDecode(response.body);

      final error =
          json['error'];

      if (error is Map) {
        message =
            error['message']
                ?.toString() ??
            message;
      }
    } catch (_) {}

    throw Exception(
      'Pincus AI: $message',
    );
  }

  void dispose() {
    _client.close();
  }
}
