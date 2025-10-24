part of 'chat_history_bloc.dart';

abstract class ChatHistoryEvent extends Equatable {
  const ChatHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatHistoryEvent {
  const LoadChatHistory();
}

class AddChatMessage extends ChatHistoryEvent {
  final String message;

  const AddChatMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearChatHistory extends ChatHistoryEvent {
  const ClearChatHistory();
}
