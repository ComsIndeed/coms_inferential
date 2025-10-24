import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const List<String> availableModels = [
    'gemini-2.0-flash-exp',
    'gemini-2.0-flash-lite',
    'gemini-2.5-flash-exp',
    'gemini-2.5-flash-lite',
  ];

  GenerativeModel? _model;
  String _currentModel = 'gemini-2.0-flash-exp';

  void setModel(String modelName) {
    if (!availableModels.contains(modelName)) {
      throw ArgumentError('Model $modelName is not available');
    }
    _currentModel = modelName;
    _model = GenerativeModel(model: modelName, apiKey: apiKey);
  }

  GenerativeModel getModel() {
    if (_model == null) {
      setModel(_currentModel);
    }
    return _model!;
  }

  Stream<GenerateContentResponse> sendMessageStream(
    List<Content> history,
    String message,
  ) async* {
    final model = getModel();
    final chat = model.startChat(history: history);
    final response = chat.sendMessageStream(Content.text(message));
    yield* response;
  }

  Future<GenerateContentResponse> sendMessage(
    List<Content> history,
    Content message,
  ) async {
    final model = getModel();
    final chat = model.startChat(history: history);
    final response = await chat.sendMessage(message);
    return response;
  }

  Future<GenerateContentResponse> sendMessageWithModel(
    List<Content> history,
    Content message,
    String modelName,
  ) async {
    if (!availableModels.contains(modelName)) {
      throw ArgumentError('Model $modelName is not available');
    }
    final model = GenerativeModel(model: modelName, apiKey: apiKey);
    final chat = model.startChat(history: history);
    final response = await chat.sendMessage(message);
    return response;
  }
}
