import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/content.dart';

extension ChatSerialization on ChatSession {
  List<Map<String, dynamic>> toMap() {
    final mappedHistory = history.map((content) => content.toJson());
    return mappedHistory.toList();
  }

  static List<Map<String, dynamic>> historyToMap(List<Content> history) {
    final mappedHistory = history.map((content) => content.toJson());
    return mappedHistory.toList();
  }

  static List<Content> historyFromMap(
    List<Map<String, dynamic>> mappedHistory,
  ) {
    return mappedHistory
        .map((mappedContent) => parseContent(mappedContent))
        .toList();
  }

  static List<Content> historyFromJson(String json) {
    final decoded = jsonDecode(json) as List<Map<String, dynamic>>;
    final deserialized = ChatSerialization.historyFromMap(decoded);
    return deserialized;
  }

  String toJson() {
    final mappedHistory = toMap();
    return jsonEncode(mappedHistory);
  }
}

extension ChatHistorySerialization on List<Content> {
  List<Map<String, dynamic>> toMap() {
    final mappedHistory = map((content) => content.toJson());
    return mappedHistory.toList();
  }

  static List<Map<String, dynamic>> historyToMap(List<Content> history) {
    final mappedHistory = history.map((content) => content.toJson());
    return mappedHistory.toList();
  }

  static List<Content> historyFromMap(
    List<Map<String, dynamic>> mappedHistory,
  ) {
    return mappedHistory
        .map((mappedContent) => parseContent(mappedContent))
        .toList();
  }

  static List<Content> historyFromJson(String json) {
    final uncasted = jsonDecode(json);
    if (uncasted is List) {
      final casted = uncasted.whereType<Map<String, dynamic>>().toList();
      final deserialized = ChatHistorySerialization.historyFromMap(casted);
      return deserialized;
    } else {
      throw Exception("Unexpected format for persisted history: not a List");
    }
  }

  String toJson() {
    final mappedHistory = toMap();
    return jsonEncode(mappedHistory);
  }
}

extension ContentSerialization on Content {
  Map<String, dynamic> toMap() {
    return this.toJson();
  }

  static Content fromMap(Map<String, dynamic> mappedContent) {
    return parseContent(mappedContent);
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static Content fromJson(String json) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return fromMap(decoded);
  }
}
