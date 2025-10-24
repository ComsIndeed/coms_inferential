import 'package:equatable/equatable.dart';

abstract class ChatSessionState extends Equatable {
  const ChatSessionState();

  @override
  List<Object?> get props => [];
}

class ChatSessionInitial extends ChatSessionState {
  const ChatSessionInitial();
}

class ChatSessionActive extends ChatSessionState {
  final String sessionId;

  const ChatSessionActive(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ChatSessionEnded extends ChatSessionState {
  const ChatSessionEnded();
}

class ChatSessionError extends ChatSessionState {
  final String error;

  const ChatSessionError(this.error);

  @override
  List<Object?> get props => [error];
}
