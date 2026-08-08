import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pincus_ai_service.dart';
import '../domain/ai_message.dart';

final pincusAiServiceProvider =
    Provider<PincusAiService>((ref) {
  final service = PincusAiService();

  ref.onDispose(service.dispose);

  return service;
});

final aiChatProvider =
    NotifierProvider<AiChatController,
        AiChatState>(
  AiChatController.new,
);

class AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages:
          messages ?? this.messages,
      isLoading:
          isLoading ?? this.isLoading,
      isStreaming:
          isStreaming ?? this.isStreaming,
      error:
          clearError
              ? null
              : error ?? this.error,
    );
  }
}

class AiChatController
    extends Notifier<AiChatState> {
  late final PincusAiService _service;

  @override
  AiChatState build() {
    _service =
        ref.read(pincusAiServiceProvider);

    return const AiChatState();
  }

  Future<void> send(
    String text,
  ) async {
    final clean =
        text.trim();

    if (clean.isEmpty ||
        state.isLoading) {
      return;
    }

    final userMessage =
        AiMessage.user(clean);

    final updatedMessages = [
      ...state.messages,
      userMessage,
    ];

    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      isStreaming: true,
      clearError: true,
    );

    final assistantMessage =
        AiMessage.assistant('');

    state = state.copyWith(
      messages: [
        ...updatedMessages,
        assistantMessage,
      ],
    );

    final buffer =
        StringBuffer();

    try {
      await for (final chunk
          in _service.streamMessage(
        messages: updatedMessages,
        model: 'auto',
      )) {
        buffer.write(chunk);

        final messages =
            List<AiMessage>.from(
          state.messages,
        );

        messages[messages.length - 1] =
            AiMessage.assistant(
          buffer.toString(),
        );

        state = state.copyWith(
          messages: messages,
          isLoading: true,
          isStreaming: true,
        );
      }

      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        error: error.toString(),
      );
    }
  }

  void clear() {
    state = const AiChatState();
  }
}
