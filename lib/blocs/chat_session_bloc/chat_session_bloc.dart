import 'package:coms_inferential/models/chat_message.dart';
import 'package:coms_inferential/services/chat_history_service.dart';
import 'package:coms_inferential/services/gemini_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import 'chat_session_event.dart';
import 'chat_session_state.dart';

class ChatSessionBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  final ChatHistoryService _chatHistoryService;
  final GeminiService _geminiService;

  ChatSessionBloc({
    required ChatHistoryService chatHistoryService,
    required GeminiService geminiService,
  }) : _chatHistoryService = chatHistoryService,
       _geminiService = geminiService,
       super(const ChatSessionInitial()) {
    on<StartNewChat>(_onStartNewChat);
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<EditMessage>(_onEditMessage);
    on<RegenerateLastMessage>(_onRegenerateLastMessage);
    on<ChangeModel>(_onChangeModel);
    on<MessageReceived>(_onMessageReceived);
    on<MessageError>(_onMessageError);
  }

  Future<void> _onStartNewChat(
    StartNewChat event,
    Emitter<ChatSessionState> emit,
  ) async {
    final chatId = const Uuid().v4();
    final title = 'New Chat';

    try {
      await _chatHistoryService.createNewChat(chatId, title);
      emit(ChatSessionActive(chatId: chatId, title: title, messages: const []));
    } catch (e) {
      emit(ChatSessionError(e.toString(), const []));
    }
  }

  Future<void> _onLoadChat(
    LoadChat event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(const ChatSessionLoading());

    try {
      final chatHistory = await _chatHistoryService.getChat(event.chatId);
      _geminiService.setModel(chatHistory.selectedModel);

      emit(
        ChatSessionActive(
          chatId: chatHistory.chatId,
          title: chatHistory.title,
          messages: chatHistory.messages,
          selectedModel: chatHistory.selectedModel,
        ),
      );
    } catch (e) {
      emit(ChatSessionError(e.toString(), const []));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;

    final currentState = state as ChatSessionActive;
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: event.content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    emit(
      currentState.copyWith(
        messages: [...currentState.messages, userMessage],
        isGenerating: true,
      ),
    );

    try {
      await _chatHistoryService.addMessage(currentState.chatId, userMessage);

      if (currentState.messages.isEmpty) {
        final firstWords = event.content.parts
            .whereType<TextPart>()
            .map((p) => p.text)
            .join(' ')
            .split(' ')
            .take(5)
            .join(' ');
        await _chatHistoryService.updateChatTitle(
          currentState.chatId,
          firstWords.isEmpty ? 'New Chat' : firstWords,
        );
      }

      final history = currentState.messages.map((msg) => msg.content).toList();

      final response = await _geminiService.sendMessage(history, event.content);

      if (response.text != null) {
        add(MessageReceived(response.candidates.first.content));
      } else {
        add(const MessageError('No response from AI'));
      }
    } catch (e) {
      add(MessageError(e.toString()));
    }
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;

    final currentState = state as ChatSessionActive;
    final messageIndex = currentState.messages.indexWhere(
      (msg) => msg.id == event.messageId,
    );

    if (messageIndex == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentState.messages);
    final editedMessage = updatedMessages[messageIndex].copyWith(
      content: event.newContent,
      isEdited: true,
    );
    updatedMessages[messageIndex] = editedMessage;

    updatedMessages.removeRange(messageIndex + 1, updatedMessages.length);

    emit(currentState.copyWith(messages: updatedMessages, isGenerating: true));

    try {
      await _chatHistoryService.updateMessage(editedMessage);

      for (int i = messageIndex + 1; i < currentState.messages.length; i++) {
        await _chatHistoryService.deleteMessage(currentState.messages[i].id);
      }

      final history = updatedMessages
          .take(messageIndex)
          .map((msg) => msg.content)
          .toList();

      final response = await _geminiService.sendMessage(
        history,
        event.newContent,
      );

      if (response.text != null) {
        add(MessageReceived(response.candidates.first.content));
      } else {
        add(const MessageError('No response from AI'));
      }
    } catch (e) {
      add(MessageError(e.toString()));
    }
  }

  Future<void> _onRegenerateLastMessage(
    RegenerateLastMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;

    final currentState = state as ChatSessionActive;
    if (currentState.messages.isEmpty) return;

    final lastMessage = currentState.messages.last;
    if (lastMessage.role != MessageRole.assistant) return;

    final messagesWithoutLast = currentState.messages.sublist(
      0,
      currentState.messages.length - 1,
    );

    emit(
      currentState.copyWith(messages: messagesWithoutLast, isGenerating: true),
    );

    try {
      await _chatHistoryService.deleteMessage(lastMessage.id);

      final userMessage = messagesWithoutLast.last;
      final history = messagesWithoutLast
          .take(messagesWithoutLast.length - 1)
          .map((msg) => msg.content)
          .toList();

      final response = await _geminiService.sendMessage(
        history,
        userMessage.content,
      );

      if (response.text != null) {
        add(MessageReceived(response.candidates.first.content));
      } else {
        add(const MessageError('No response from AI'));
      }
    } catch (e) {
      add(MessageError(e.toString()));
    }
  }

  Future<void> _onChangeModel(
    ChangeModel event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;

    final currentState = state as ChatSessionActive;
    _geminiService.setModel(event.modelName);

    await _chatHistoryService.updateChatModel(
      currentState.chatId,
      event.modelName,
    );

    emit(currentState.copyWith(selectedModel: event.modelName));
  }

  Future<void> _onMessageReceived(
    MessageReceived event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;

    final currentState = state as ChatSessionActive;
    final assistantMessage = ChatMessage(
      id: const Uuid().v4(),
      content: event.response,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );

    await _chatHistoryService.addMessage(currentState.chatId, assistantMessage);

    emit(
      currentState.copyWith(
        messages: [...currentState.messages, assistantMessage],
        isGenerating: false,
      ),
    );
  }

  Future<void> _onMessageError(
    MessageError event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;

    final currentState = state as ChatSessionActive;
    emit(ChatSessionError(event.error, currentState.messages));
  }
}
