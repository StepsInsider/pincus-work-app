class AiConfig {
  const AiConfig._();

  /// Flutter Web / Chromebook:
  /// Gateway läuft lokal auf demselben Rechner.
  static const String baseUrl =
      'http://127.0.0.1:3001/v1';

  static const String apiKey =
      'local-dev-key';

  static const String defaultModel =
      'auto';

  static const String embeddingModel =
      'nomic-embed-text';

  static const Duration requestTimeout =
      Duration(minutes: 5);
}
