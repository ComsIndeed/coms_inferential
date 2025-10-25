import 'package:coms_inferential/blocs/chat_history_bloc/chat_history_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHistorySidebar extends StatelessWidget {
  const ChatHistorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(100),
        border: Border(
          right: BorderSide(color: Colors.white.withAlpha(30), width: 1),
        ),
      ),
      child: Column(
        children: [
          BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
            builder: (context, state) {
              final isSelectionMode =
                  state is ChatHistoryLoaded && state.isSelectionMode;
              final selectedCount = state is ChatHistoryLoaded
                  ? state.selectedChatIds.length
                  : 0;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (isSelectionMode) ...[
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          context.read<ChatHistoryBloc>().add(
                            const ClearSelection(),
                          );
                        },
                        tooltip: 'Cancel',
                      ),
                      Text(
                        '$selectedCount selected',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      if (selectedCount > 0)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete Chats'),
                                content: Text(
                                  'Are you sure you want to delete $selectedCount chat(s)?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<ChatHistoryBloc>().add(
                                        const DeleteSelectedChats(),
                                      );
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Delete Selected',
                        ),
                    ] else ...[
                      const Text(
                        'Chat History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          context.read<ChatSessionBloc>().add(
                            const StartNewChat(),
                          );
                        },
                        tooltip: 'New Chat',
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
              builder: (context, state) {
                if (state is ChatHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatHistoryError) {
                  return Center(
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is ChatHistoryLoaded) {
                  if (state.chats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      final chat = state.chats[index];
                      final isSelected = state.selectedChatIds.contains(
                        chat.chatId,
                      );

                      return ListTile(
                        leading: state.isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  context.read<ChatHistoryBloc>().add(
                                    ToggleChatSelection(chat.chatId),
                                  );
                                },
                              )
                            : null,
                        title: Text(
                          chat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${chat.messages.length} messages',
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: isSelected,
                        onTap: () {
                          if (state.isSelectionMode) {
                            context.read<ChatHistoryBloc>().add(
                              ToggleChatSelection(chat.chatId),
                            );
                          } else {
                            context.read<ChatSessionBloc>().add(
                              LoadChat(chat.chatId),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!state.isSelectionMode) {
                            context.read<ChatHistoryBloc>().add(
                              const ToggleSelectionMode(),
                            );
                            context.read<ChatHistoryBloc>().add(
                              ToggleChatSelection(chat.chatId),
                            );
                          }
                        },
                        trailing: !state.isSelectionMode
                            ? IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Chat'),
                                      content: Text(
                                        'Are you sure you want to delete "${chat.title}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.read<ChatHistoryBloc>().add(
                                              DeleteChatEvent(chat.chatId),
                                            );
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : null,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
