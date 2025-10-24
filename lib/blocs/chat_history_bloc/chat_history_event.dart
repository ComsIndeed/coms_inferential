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
