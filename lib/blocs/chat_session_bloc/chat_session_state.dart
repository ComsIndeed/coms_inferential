import 'package:coms_inferential/models/chat_message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatSessionState extends Equatable {
  const ChatSessionState();

  @override
  List<Object?> get props => [];
}

class ChatSessionInitial extends ChatSessionState {
  const ChatSessionInitial();
}

class ChatSessionLoading extends ChatSessionState {
  const ChatSessionLoading();
}

class ChatSessionActive extends ChatSessionState {
  final String chatId;
  final String title;
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String selectedModel;

  const ChatSessionActive({
    required this.chatId,
    required this.title,
    required this.messages,
    this.isGenerating = false,
    this.selectedModel = 'gemini-2.0-flash-exp',
  });

  @override
  List<Object?> get props => [
    chatId,
    title,
    messages,
    isGenerating,
    selectedModel,
  ];

  ChatSessionActive copyWith({
    String? chatId,
    String? title,
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? selectedModel,
  }) {
    return ChatSessionActive(
      chatId: chatId ?? this.chatId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}

class ChatSessionError extends ChatSessionState {
  final String errorMessage;
  final List<ChatMessage> messages;

  const ChatSessionError(this.errorMessage, this.messages);

  @override
  List<Object?> get props => [errorMessage, messages];
}
