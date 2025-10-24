import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_event.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_state.dart';
import 'package:coms_inferential/models/chat_message.dart';
import 'package:coms_inferential/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessagesList extends StatefulWidget {
  const ChatMessagesList({super.key});

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showEditDialog(ChatMessage message) {
    _editController.text = message.content.parts
        .whereType<TextPart>()
        .map((part) => part.text)
        .join('\n');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: _editController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_editController.text.trim().isNotEmpty) {
                context.read<ChatSessionBloc>().add(
                  EditMessage(
                    message.id,
                    Content.text(_editController.text.trim()),
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatSessionBloc, ChatSessionState>(
      listener: (context, state) {
        if (state is ChatSessionActive && state.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatSessionInitial) {
          return const Center(
            child: Text(
              'Start a new chat or select an existing one',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        if (state is ChatSessionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatSessionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is ChatSessionActive) {
          if (state.messages.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet. Start the conversation!',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: state.messages.length + (state.isGenerating ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.messages.length && state.isGenerating) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Thinking...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              final message = state.messages[index];
              final isLastUserMessage =
                  message.role == MessageRole.user &&
                  (index == state.messages.length - 1 ||
                      (index == state.messages.length - 2 &&
                          state.messages.last.role == MessageRole.assistant));

              final isLastAssistantMessage =
                  message.role == MessageRole.assistant &&
                  index == state.messages.length - 1;

              return MessageBubble(
                key: ValueKey(message.id),
                message: message,
                onEdit: isLastUserMessage
                    ? () => _showEditDialog(message)
                    : null,
                onRegenerate: isLastAssistantMessage
                    ? () => context.read<ChatSessionBloc>().add(
                        const RegenerateLastMessage(),
                      )
                    : null,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
