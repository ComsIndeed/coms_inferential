import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_history_event.dart';
part 'chat_history_state.dart';

class ChatHistoryBloc extends Bloc<ChatHistoryEvent, ChatHistoryState> {
  ChatHistoryBloc() : super(const ChatHistoryInitial()) {
    on<LoadChatHistory>((event, emit) {
      // TODO: Implement loading chat history
    });

    on<AddChatMessage>((event, emit) {
      // TODO: Implement adding a chat message
    });

    on<ClearChatHistory>((event, emit) {
      // TODO: Implement clearing chat history
    });
  }
}
