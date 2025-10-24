import 'package:coms_inferential/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onEdit;
  final VoidCallback? onRegenerate;

  const MessageBubble({
    super.key,
    required this.message,
    this.onEdit,
    this.onRegenerate,
  });

  String _getTextFromContent(Content content) {
    return content.parts
        .whereType<TextPart>()
        .map((part) => part.text)
        .join('\n');
  }

  bool _hasMedia(Content content) {
    return content.parts.any(
      (part) => part is FileData || part is InlineDataPart,
    );
  }

  List<Widget> _buildMediaPreviews(Content content) {
    final mediaParts = content.parts.where(
      (part) => part is FileData || part is InlineDataPart,
    );

    return mediaParts.map((part) {
      if (part is InlineDataPart) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getMediaIcon(part.mimeType),
                size: 20,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                part.mimeType,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  IconData _getMediaIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    return Icons.attach_file;
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final text = _getTextFromContent(message.content);
    final hasMedia = _hasMedia(message.content);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).cardColor.withAlpha(180),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasMedia) ..._buildMediaPreviews(message.content),
                  if (text.isNotEmpty)
                    SelectableText(
                      text,
                      style: TextStyle(
                        color: isUser
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.white,
                      ),
                    ),
                  if (message.isEdited)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '(edited)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withAlpha(128),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isUser && onEdit != null || !isUser && onRegenerate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUser && onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: onEdit,
                        color: Colors.white54,
                        tooltip: 'Edit',
                      ),
                    if (!isUser && onRegenerate != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: onRegenerate,
                        color: Colors.white54,
                        tooltip: 'Regenerate',
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
