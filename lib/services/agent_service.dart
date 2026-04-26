import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:genai_primitives/genai_primitives.dart' as genai;
import '../tools/storage_tools.dart';

/// Abstract interface for the workout agent service.
/// Decoupled from genui-specific concepts like Transport.
abstract class AgentService {
  /// Sends a [genai.ChatMessage] and returns the raw string response.
  Future<String?> sendMessage(genai.ChatMessage msg);

  void dispose();
}

/// Firebase implementation of the [AgentService].
class FirebaseAgentService implements AgentService {
  final firebase_ai.ChatSession _chatSession;

  FirebaseAgentService({
    required firebase_ai.GenerativeModel model,
  }) : _chatSession = model.startChat();

  @override
  Future<String?> sendMessage(genai.ChatMessage msg) async {
    final buffer = StringBuffer();
    for (final part in msg.parts) {
      if (part is genai.TextPart) {
        buffer.write(part.text);
      } else if (part is genai.DataPart) {
        // GenUI Interactions are sent as DataPart with this mime type
        if (part.mimeType == 'application/vnd.genui.interaction+json') {
          try {
            final json =
                jsonDecode(utf8.decode(part.bytes)) as Map<String, dynamic>;
            final interaction = json['interaction'] as String?;
            if (interaction != null) {
              buffer.write(interaction);
            }
          } catch (_) {
            // Not a valid GenUI interaction after all?
          }
        }
      }
    }

    if (buffer.isEmpty) return null;

    final response = await _chatSession.sendMessage(
      firebase_ai.Content.text(buffer.toString()),
    );

    return response.text;
  }

  @override
  void dispose() {}
}

/// Provider for the [AgentService].
final agentServiceProvider = Provider.family<AgentService, String>((
  ref,
  purpose,
) {
  final tools = ref.watch(storageToolsProvider);
  final model = firebase_ai.FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3-flash-preview',
    tools: tools,
  );
  return FirebaseAgentService(model: model);
});
