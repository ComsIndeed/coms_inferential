import 'dart:convert';

import 'package:coms_inferential/models/chat_message.dart';

class ChatHistory {
  final List<ChatMessage> messages;
  final String chatId;
  final String title;
  final String selectedModel;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatHistory({
    required this.messages,
    required this.chatId,
    required this.title,
    this.selectedModel = 'gemini-2.0-flash-exp',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'messages': messages.map((x) => x.toMap()).toList(),
      'chatId': chatId,
      'title': title,
      'selectedModel': selectedModel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      selectedModel:
          (map['selectedModel'] as String?) ?? 'gemini-2.0-flash-exp',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatHistory.fromJson(String source) =>
      ChatHistory.fromMap(jsonDecode(source) as Map<String, dynamic>);

  ChatHistory copyWith({
    List<ChatMessage>? messages,
    String? chatId,
    String? title,
    String? selectedModel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatHistory(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      title: title ?? this.title,
      selectedModel: selectedModel ?? this.selectedModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
