enum AiMessageRole {
  system,
  user,
  assistant,
}

class AiMessage {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime createdAt;
  final String? model;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.model,
  });

  factory AiMessage.user(String content) {
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiMessageRole.user,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  factory AiMessage.assistant(
    String content, {
    String? model,
  }) {
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiMessageRole.assistant,
      content: content,
      createdAt: DateTime.now(),
      model: model,
    );
  }

  factory AiMessage.system(String content) {
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: AiMessageRole.system,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  String get roleName {
    switch (role) {
      case AiMessageRole.system:
        return 'system';
      case AiMessageRole.user:
        return 'user';
      case AiMessageRole.assistant:
        return 'assistant';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'role': roleName,
      'content': content,
    };
  }
}
