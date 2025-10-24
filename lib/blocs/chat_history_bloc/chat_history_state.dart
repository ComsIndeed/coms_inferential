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
  final List<String> messages;

  const ChatHistoryLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatHistoryError extends ChatHistoryState {
  final String error;

  const ChatHistoryError(this.error);

  @override
  List<Object?> get props => [error];
}
