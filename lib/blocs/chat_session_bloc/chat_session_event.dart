import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class ChatSessionEvent extends Equatable {
  const ChatSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartNewChat extends ChatSessionEvent {
  const StartNewChat();
}

class LoadChat extends ChatSessionEvent {
  final String chatId;

  const LoadChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends ChatSessionEvent {
  final Content content;

  const SendMessage(this.content);

  @override
  List<Object?> get props => [content];
}

class EditMessage extends ChatSessionEvent {
  final String messageId;
  final Content newContent;

  const EditMessage(this.messageId, this.newContent);

  @override
  List<Object?> get props => [messageId, newContent];
}

class RegenerateLastMessage extends ChatSessionEvent {
  const RegenerateLastMessage();
}

class ChangeModel extends ChatSessionEvent {
  final String modelName;

  const ChangeModel(this.modelName);

  @override
  List<Object?> get props => [modelName];
}

class MessageReceived extends ChatSessionEvent {
  final Content response;

  const MessageReceived(this.response);

  @override
  List<Object?> get props => [response];
}

class MessageError extends ChatSessionEvent {
  final String error;

  const MessageError(this.error);

  @override
  List<Object?> get props => [error];
}
