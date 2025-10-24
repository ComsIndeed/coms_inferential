// lib/services/chat_history_service.dart
import 'dart:convert';

import 'package:coms_inferential/models/chat_history.dart';
import 'package:coms_inferential/models/chat_message.dart';
import 'package:coms_inferential/services/database_helper.dart';
import 'package:coms_inferential/utilities/chat_extensions.dart';
import 'package:sqflite/sqflite.dart';

class ChatHistoryService {
  final _dbHelper = DatabaseHelper.instance;

  Future<void> createNewChat(
    String chatId,
    String title, {
    String selectedModel = 'gemini-2.0-flash-exp',
  }) async {
    final db = await _dbHelper.database;
    await db.insert('chats', {
      'chatId': chatId,
      'title': title,
      'selectedModel': selectedModel,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateChatTitle(String chatId, String newTitle) async {
    final db = await _dbHelper.database;
    await db.update(
      'chats',
      {'title': newTitle, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> updateChatModel(String chatId, String selectedModel) async {
    final db = await _dbHelper.database;
    await db.update(
      'chats',
      {
        'selectedModel': selectedModel,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> addMessage(String chatId, ChatMessage message) async {
    final db = await _dbHelper.database;

    final map = message.toMap();
    final contentMap = map.remove('content') as Map<String, dynamic>;
    map['contentJson'] = jsonEncode(contentMap);
    map['chatId'] = chatId;

    await db.insert(
      'messages',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.update(
      'chats',
      {'updatedAt': DateTime.now().toIso8601String()},
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> updateMessage(ChatMessage message) async {
    final db = await _dbHelper.database;
    final map = message.toMap();
    map['contentJson'] = map.remove('content');

    await db.update('messages', map, where: 'id = ?', whereArgs: [message.id]);
  }

  Future<void> deleteMessage(String messageId) async {
    final db = await _dbHelper.database;
    await db.delete('messages', where: 'id = ?', whereArgs: [messageId]);
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
    final chatData = chatMaps.first;
    final chatTitle = chatData['title'] as String;
    final selectedModel =
        (chatData['selectedModel'] as String?) ?? 'gemini-2.0-flash-exp';
    final createdAt = chatData['createdAt'] != null
        ? DateTime.parse(chatData['createdAt'] as String)
        : null;
    final updatedAt = chatData['updatedAt'] != null
        ? DateTime.parse(chatData['updatedAt'] as String)
        : null;

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

    return ChatHistory(
      messages: messages,
      chatId: chatId,
      title: chatTitle,
      selectedModel: selectedModel,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Future<List<ChatHistory>> getAllChats() async {
    final db = await _dbHelper.database;
    final chatMaps = await db.query('chats', orderBy: 'updatedAt DESC');

    final chats = <ChatHistory>[];
    for (final chatMap in chatMaps) {
      final chatId = chatMap['chatId'] as String;
      try {
        final chat = await getChat(chatId);
        chats.add(chat);
      } catch (e) {
        continue;
      }
    }
    return chats;
  }

  Future<List<String>> getAllChatIds() async {
    final db = await _dbHelper.database;
    final maps = await db.query('chats', columns: ['chatId']);
    return maps.map((map) => map['chatId'] as String).toList();
  }

  Future<void> deleteChat(String chatId) async {
    final db = await _dbHelper.database;
    await db.delete('chats', where: 'chatId = ?', whereArgs: [chatId]);
    await db.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
  }

  void clearHistory() async {
    final db = await _dbHelper.database;
    await db.delete('messages');
    await db.delete('chats');
  }
}
