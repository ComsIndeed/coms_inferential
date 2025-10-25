part of 'chat_history_bloc.dart';

abstract class ChatHistoryEvent extends Equatable {
  const ChatHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllChats extends ChatHistoryEvent {
  const LoadAllChats();
}

class SelectChat extends ChatHistoryEvent {
  final String chatId;

  const SelectChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class DeleteChatEvent extends ChatHistoryEvent {
  final String chatId;

  const DeleteChatEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ClearAllChats extends ChatHistoryEvent {
  const ClearAllChats();
}

class ToggleSelectionMode extends ChatHistoryEvent {
  const ToggleSelectionMode();
}

class ToggleChatSelection extends ChatHistoryEvent {
  final String chatId;

  const ToggleChatSelection(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class DeleteSelectedChats extends ChatHistoryEvent {
  const DeleteSelectedChats();
}

class ClearSelection extends ChatHistoryEvent {
  const ClearSelection();
}
