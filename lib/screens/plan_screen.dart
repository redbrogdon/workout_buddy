import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import '../catalog/catalog.dart';
import '../providers/navigation_providers.dart';
import '../services/agent_service.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  late final AgentService _agent;
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  final _surfaceIds = <String>[];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _agent = ref.read(agentServiceProvider('plan'));

    _controller = SurfaceController(catalogs: [workoutBuddyCatalog]);
    _transport = A2uiTransportAdapter(onSend: _handleSend);
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

  Future<void> _handleSend(ChatMessage msg) async {
    // Client-side intercept for navigation events
    for (final part in msg.parts) {
      if (part.isUiInteractionPart) {
        final interaction = part.asUiInteractionPart!.interaction;
        try {
          final json = jsonDecode(interaction) as Map<String, dynamic>;
          if (json['name'] == 'start_workout') {
            ref.read(navigationIndexProvider.notifier).setIndex(1);
          }
        } catch (_) {}
      }
    }

    // Hand off to abstract agent service
    final response = await _agent.sendMessage(msg);
    if (response != null && mounted) {
      _transport.addChunk(response);
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

Your goal is to help the user design the perfect workout session for today.

Tools:
- `readPreferences`: Use this to understand the user's general goals and workout style.
- `readHistory`: Use this to see what they've done recently and suggest progressive overload.

Process:
1. Start by reading preferences and history (quietly) to inform your greeting.
2. Draft a `WorkoutCard` with a suggested plan.
3. Negotiate any changes using `ExerciseTile` components.
4. When the user is ready, encourage them to click "Start Workout" on the `WorkoutCard`.
5. Ensure you have called `saveActiveSession` with the final plan BEFORE the user clicks start, or as a response to them saying they are ready.
6. The `onStart` action of the `WorkoutCard` should be set to dispatch an event named `start_workout`.

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
