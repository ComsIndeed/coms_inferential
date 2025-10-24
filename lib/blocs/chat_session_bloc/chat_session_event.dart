import 'package:equatable/equatable.dart';

abstract class ChatSessionEvent extends Equatable {
  const ChatSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartChatSession extends ChatSessionEvent {
  const StartChatSession();
}

class EndChatSession extends ChatSessionEvent {
  const EndChatSession();
}

class SendMessage extends ChatSessionEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}
