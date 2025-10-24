import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_event.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_state.dart';
import 'package:coms_inferential/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatSessionBloc, ChatSessionState>(
      builder: (context, state) {
        if (state is! ChatSessionActive) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          tooltip: 'Select Model',
          icon: const Icon(Icons.psychology, size: 20),
          onSelected: (modelName) {
            context.read<ChatSessionBloc>().add(ChangeModel(modelName));
          },
          itemBuilder: (context) {
            return GeminiService.availableModels.map((model) {
              final isSelected = state.selectedModel == model;
              return PopupMenuItem<String>(
                value: model,
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        model,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}
