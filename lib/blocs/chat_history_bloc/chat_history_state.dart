part of 'chat_history_bloc.dart';

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();

  @override
  List<Object?> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {
  const ChatHistoryInitial();
}

class ChatHistoryLoading extends ChatHistoryState {
  const ChatHistoryLoading();
}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<ChatHistory> chats;
  final bool isSelectionMode;
  final Set<String> selectedChatIds;

  const ChatHistoryLoaded(
    this.chats, {
    this.isSelectionMode = false,
    this.selectedChatIds = const {},
  });

  ChatHistoryLoaded copyWith({
    List<ChatHistory>? chats,
    bool? isSelectionMode,
    Set<String>? selectedChatIds,
  }) {
    return ChatHistoryLoaded(
      chats ?? this.chats,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedChatIds: selectedChatIds ?? this.selectedChatIds,
    );
  }

  @override
  List<Object?> get props => [chats, isSelectionMode, selectedChatIds];
}

class ChatHistoryError extends ChatHistoryState {
  final String error;

  const ChatHistoryError(this.error);

  @override
  List<Object?> get props => [error];
}
