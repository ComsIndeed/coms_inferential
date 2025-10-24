import 'dart:convert';

import 'package:coms_inferential/models/chat_message.dart';

class ChatHistory {
  final List<ChatMessage> messages;
  final String chatId;
  final String title;

  ChatHistory({
    required this.messages,
    required this.chatId,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'messages': messages.map((x) => x.toMap()).toList(),
      'chatId': chatId,
      'title': title,
    };
  }

  factory ChatHistory.fromMap(Map<String, dynamic> map) {
    return ChatHistory(
      messages: List<ChatMessage>.from(
        (map['messages'] as List<dynamic>).map<ChatMessage>(
          (x) => ChatMessage.fromMap(x as Map<String, dynamic>),
        ),
      ),
      chatId: map['chatId'] as String,
      title: map['title'] as String,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatHistory.fromJson(String source) =>
      ChatHistory.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
