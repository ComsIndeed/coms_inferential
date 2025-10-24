import 'package:coms_inferential/models/chat_history.dart';
import 'package:coms_inferential/services/chat_history_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_history_event.dart';
part 'chat_history_state.dart';

class ChatHistoryBloc extends Bloc<ChatHistoryEvent, ChatHistoryState> {
  final ChatHistoryService _chatHistoryService;

  ChatHistoryBloc({required ChatHistoryService chatHistoryService})
    : _chatHistoryService = chatHistoryService,
      super(const ChatHistoryInitial()) {
    on<LoadAllChats>(_onLoadAllChats);
    on<SelectChat>(_onSelectChat);
    on<DeleteChatEvent>(_onDeleteChat);
    on<ClearAllChats>(_onClearAllChats);
  }

  Future<void> _onLoadAllChats(
    LoadAllChats event,
    Emitter<ChatHistoryState> emit,
  ) async {
    emit(const ChatHistoryLoading());

    try {
      final chats = await _chatHistoryService.getAllChats();
      emit(ChatHistoryLoaded(chats));
    } catch (e) {
      emit(ChatHistoryError(e.toString()));
    }
  }

  Future<void> _onSelectChat(
    SelectChat event,
    Emitter<ChatHistoryState> emit,
  ) async {
    if (state is! ChatHistoryLoaded) return;
  }

  Future<void> _onDeleteChat(
    DeleteChatEvent event,
    Emitter<ChatHistoryState> emit,
  ) async {
    try {
      await _chatHistoryService.deleteChat(event.chatId);
      add(const LoadAllChats());
    } catch (e) {
      emit(ChatHistoryError(e.toString()));
    }
  }

  Future<void> _onClearAllChats(
    ClearAllChats event,
    Emitter<ChatHistoryState> emit,
  ) async {
    try {
      _chatHistoryService.clearHistory();
      emit(const ChatHistoryLoaded([]));
    } catch (e) {
      emit(ChatHistoryError(e.toString()));
    }
  }
}
