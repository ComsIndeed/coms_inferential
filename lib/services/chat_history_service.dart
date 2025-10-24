// lib/services/chat_history_service.dart
import 'package:coms_inferential/models/chat_history.dart';
import 'package:coms_inferential/models/chat_message.dart';
import 'package:coms_inferential/services/database_helper.dart';
import 'package:coms_inferential/utilities/chat_extensions.dart';
import 'package:sqflite/sqflite.dart';

class ChatHistoryService {
  final _dbHelper = DatabaseHelper.instance;

  Future<void> createNewChat(String chatId, String title) async {
    final db = await _dbHelper.database;
    await db.insert('chats', {
      'chatId': chatId,
      'title': title,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addMessage(String chatId, ChatMessage message) async {
    final db = await _dbHelper.database;

    final map = message.toMap();

    map['contentJson'] = map.remove('content');

    map['chatId'] = chatId;

    await db.insert(
      'messages',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ChatHistory> getChat(String chatId) async {
    final db = await _dbHelper.database;

    final chatMaps = await db.query(
      'chats',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
    if (chatMaps.isEmpty) {
      throw Exception('Chat not found');
    }
    final chatTitle = chatMaps.first['title'] as String;

    final messageMaps = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );

    final messages = messageMaps.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);
      final contentJson = mutableMap.remove('contentJson') as String;

      mutableMap['content'] = ContentSerialization.fromJson(contentJson);

      return ChatMessage.fromMap(mutableMap);
    }).toList();

    return ChatHistory(messages: messages, chatId: chatId, title: chatTitle);
  }

  Future<List<String>> getAllChatIds() async {
    final db = await _dbHelper.database;
    final maps = await db.query('chats', columns: ['chatId']);
    return maps.map((map) => map['chatId'] as String).toList();
  }

  Future<void> deleteChat(String chatId) async {
    final db = await _dbHelper.database;
    await db.delete('chats', where: 'chatId = ?', whereArgs: [chatId]);
  }

  void clearHistory() async {
    final db = await _dbHelper.database;
    await db.delete('messages');
    await db.delete('chats');
  }
}
