import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_chat_controller.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({
    super.key,
  });

  @override
  ConsumerState<AiChatPage> createState() =>
      _AiChatPageState();
}

class _AiChatPageState
    extends ConsumerState<AiChatPage> {
  final _controller =
      TextEditingController();

  final _scrollController =
      ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text =
        _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    _controller.clear();

    await ref
        .read(aiChatProvider.notifier)
        .send(text);

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController
              .position.maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Pincus KI'),
        actions: [
          IconButton(
            tooltip: 'Chat löschen',
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(
                          aiChatProvider
                              .notifier,
                        )
                        .clear();
                  },
            icon:
                const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller:
                  _scrollController,
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  state.messages.length,
              itemBuilder:
                  (context, index) {
                final message =
                    state.messages[index];

                if (message.roleName ==
                    'system') {
                  return const SizedBox();
                }

                final isUser =
                    message.roleName ==
                        'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 700,
                    ),
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration:
                        BoxDecoration(
                      color: isUser
                          ? Theme.of(
                              context,
                            )
                              .colorScheme
                              .primaryContainer
                          : Theme.of(
                              context,
                            )
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Text(
                      message.content
                              .isEmpty &&
                          !isUser &&
                          state.isStreaming
                          ? 'Pincus KI schreibt …'
                          : message.content,
                    ),
                  ),
                );
              },
            ),
          ),

          if (state.error != null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                state.error!,
                style: TextStyle(
                  color:
                      Theme.of(context)
                          .colorScheme
                          .error,
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _controller,
                      enabled:
                          !state.isLoading,
                      minLines: 1,
                      maxLines: 6,
                      textInputAction:
                          TextInputAction.newline,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Nachricht an Pincus KI …',
                        border:
                            OutlineInputBorder(),
                      ),
                      onSubmitted:
                          (_) => _send(),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton.filled(
                    onPressed:
                        state.isLoading
                            ? null
                            : _send,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
