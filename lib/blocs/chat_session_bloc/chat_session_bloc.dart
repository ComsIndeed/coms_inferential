import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_session_event.dart';
import 'chat_session_state.dart';

// Bloc for ChatSession
class ChatSessionBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  ChatSessionBloc() : super(const ChatSessionInitial()) {
    on<StartChatSession>((event, emit) {
      // TODO: Implement starting a chat session
    });

    on<EndChatSession>((event, emit) {
      // TODO: Implement ending a chat session
    });

    on<SendMessage>((event, emit) {
      // TODO: Implement sending a message
    });
  }
}
