import 'dart:io';
import 'dart:typed_data';

import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_event.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_state.dart';
import 'package:coms_inferential/widgets/model_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final List<PlatformFile> _attachedFiles = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _attachedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFiles.isEmpty) return;

    final state = context.read<ChatSessionBloc>().state;
    if (state is! ChatSessionActive) return;

    final parts = <Part>[];

    if (text.isNotEmpty) {
      parts.add(TextPart(text));
    }

    for (final file in _attachedFiles) {
      if (file.path != null) {
        final bytes = await File(file.path!).readAsBytes();
        final mimeType = _getMimeType(file.extension ?? '');
        parts.add(InlineDataPart(mimeType, Uint8List.fromList(bytes)));
      } else if (file.bytes != null) {
        final mimeType = _getMimeType(file.extension ?? '');
        parts.add(InlineDataPart(mimeType, file.bytes!));
      }
    }

    if (parts.isEmpty) return;

    context.read<ChatSessionBloc>().add(SendMessage(Content.multi(parts)));

    _controller.clear();
    setState(() {
      _attachedFiles.clear();
    });
  }

  String _getMimeType(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/avi';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mp3';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }

  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.attach_file;
    final ext = extension.toLowerCase().replaceAll('.', '');
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return Icons.image;
    }
    if (['mp4', 'avi', 'mov'].contains(ext)) return Icons.video_file;
    if (['mp3', 'wav'].contains(ext)) return Icons.audio_file;
    if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) return Icons.description;
    return Icons.attach_file;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatSessionBloc, ChatSessionState>(
      builder: (context, state) {
        final isActive = state is ChatSessionActive;
        final isGenerating = isActive && state.isGenerating;

        return Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.lightBlueAccent, width: 1),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_attachedFiles.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _attachedFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Chip(
                            avatar: Icon(
                              _getFileIcon(file.extension),
                              size: 16,
                            ),
                            label: Text(
                              file.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeFile(index),
                          );
                        }).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: isGenerating ? null : _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          tooltip: 'Attach files',
                        ),
                        const ModelSelector(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !isGenerating && isActive,
                            decoration: InputDecoration(
                              hintText: isActive
                                  ? 'Ask Coms anything...'
                                  : 'Start a new chat to begin',
                              hintStyle: const TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          onPressed: (!isGenerating && isActive)
                              ? _sendMessage
                              : null,
                          icon: const Icon(Icons.send),
                          tooltip: 'Send',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
