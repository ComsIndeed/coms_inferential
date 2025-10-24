import 'dart:convert';

import 'package:coms_inferential/utilities/chat_extensions.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String id;
  final Content content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isEdited;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isEdited = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content.toJson(),
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'isEdited': isEdited ? 1 : 0,
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
      isEdited: (map['isEdited'] as int?) == 1,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);

  ChatMessage copyWith({
    String? id,
    Content? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isEdited,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

enum MessageRole { system, user, assistant }
