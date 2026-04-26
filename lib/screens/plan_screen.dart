import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'package:firebase_ai/firebase_ai.dart';
import '../catalog/catalog.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3-flash-preview',
  );

  late final ChatSession _chatSession;
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  final _surfaceIds = <String>[];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatSession = model.startChat();

    _controller = SurfaceController(catalogs: [workoutBuddyCatalog]);
    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    _conversation.events.listen((event) {
      if (mounted) {
        setState(() {
          switch (event) {
            case ConversationSurfaceAdded added:
              _surfaceIds.add(added.surfaceId);
            case ConversationSurfaceRemoved removed:
              _surfaceIds.remove(removed.surfaceId);
            default:
              break;
          }
        });
      }
    });

    _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    final promptBuilder = PromptBuilder.chat(
      catalog: workoutBuddyCatalog,
      systemPromptFragments: [_planScreenInstructions],
    );
    _conversation.sendRequest(
      ChatMessage.system(promptBuilder.systemPromptJoined()),
    );
  }

  Future<void> _sendAndReceive(ChatMessage msg) async {
    final buffer = StringBuffer();
    for (final part in msg.parts) {
      if (part.isUiInteractionPart) {
        buffer.write(part.asUiInteractionPart!.interaction);
      } else if (part is genui.TextPart) {
        buffer.write(part.text);
      }
    }

    if (buffer.isEmpty) return;

    final response = await _chatSession.sendMessage(
      Content.text(buffer.toString()),
    );
    if (response.text != null && mounted) {
      _transport.addChunk(response.text!);
    }
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      _conversation.sendRequest(ChatMessage.user(_textController.text));
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<ConversationState>(
          valueListenable: _conversation.state,
          builder: (context, state, child) {
            if (state.isWaiting) return const LinearProgressIndicator();
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _surfaceIds.length,
            itemBuilder: (context, index) {
              final id = _surfaceIds[index];
              return Surface(surfaceContext: _controller.contextFor(id));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Talk to your workout architect...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _planScreenInstructions = '''
You are the "Workout Architect" for Workout Buddy. 
Your personality is cheerful, efficient, and supportive (Planet Fitness vibe).
Everyone is welcome and accepted.

Your goal is to help the user create a perfect 3-5 exercise bodyweight workout plan.

Process:
1. Greet the user warmly.
2. Ask about their current energy level and available time.
3. Propose a workout plan using the `WorkoutCard`.
4. Refine the plan if the user asks for changes.
5. Once they are happy, encourage them to "Start Workout" (which triggers a navigate_to_workout event).

Guidelines:
- Only bodyweight exercises.
- 3 to 5 exercises per plan.
- Use `WorkoutCard` to show the full plan.
- Use `ExerciseTile` if the user wants to drill into or modify a specific exercise.
- Keep responses concise but encouraging.
''';

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _transport.dispose();
    _controller.dispose();
    super.dispose();
  }
}
