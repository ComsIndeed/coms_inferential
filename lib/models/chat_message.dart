import 'dart:convert';

import 'package:coms_inferential/utilities/chat_extensions.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String id;
  final Content content;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content.toJson(),
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      content: ContentSerialization.fromMap(
        map['content'] as Map<String, dynamic>,
      ),
      role: MessageRole.values.byName(map['role'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

enum MessageRole { system, user, assistant }
