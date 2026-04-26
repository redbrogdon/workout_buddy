import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' hide TextPart;
import '../services/agent_service.dart';
import '../catalog/catalog.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
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
    // Using 'workout' as the purpose for the consolidated agent
    _agent = ref.read(agentServiceProvider('workout'));

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
              if (!_surfaceIds.contains(added.surfaceId)) {
                _surfaceIds.add(added.surfaceId);
              }
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
      systemPromptFragments: [_unifiedWorkoutInstructions],
    );
    _conversation.sendRequest(
      ChatMessage.system(promptBuilder.systemPromptJoined()),
    );
  }

  Future<void> _handleSend(ChatMessage msg) async {
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
    // Check if we have a summary or a main workout card
    final hasSummary = _surfaceIds.contains('summary');
    final hasWorkoutCard = _surfaceIds.contains('workout_card');

    // Sort surfaces to keep summary or main card at the top
    final otherIds = _surfaceIds
        .where((id) => id != 'summary' && id != 'workout_card')
        .toList();

    return Column(
      children: [
        ValueListenableBuilder<ConversationState>(
          valueListenable: _conversation.state,
          builder: (context, state, child) {
            if (state.isWaiting) return const LinearProgressIndicator();
            return const SizedBox.shrink();
          },
        ),

        if (hasSummary)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Surface(surfaceContext: _controller.contextFor('summary')),
          ),

        if (hasWorkoutCard)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Surface(
              surfaceContext: _controller.contextFor('workout_card'),
            ),
          ),

        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: otherIds.length,
            itemBuilder: (context, index) {
              final id = otherIds[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Surface(surfaceContext: _controller.contextFor(id)),
              );
            },
          ),
        ),

        // Chat input bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Ask your coach anything...',
                    border: OutlineInputBorder(),
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

  static const _unifiedWorkoutInstructions = '''
You are the "Workout Buddy" — a knowledgeable, adaptive personal trainer.
Your personality is cheerful, energetic, and supportive (Planet Fitness vibe).

You manage the entire workout session in two phases:

### Phase 1: Planning & Negotiation
Goal: Help the user design a tailored bodyweight workout for today.

1. Start by reading the user's `readPreferences` and `readHistory` (quietly) to inform your greeting.
2. Ask the user how they feel today (energy, soreness, time).
3. Draft a `WorkoutCard` (use `surfaceId: 'workout_card'`) with a suggested plan (3-5 exercises).
4. Negotiate changes using `ExerciseTile` components or by updating the `WorkoutCard`.
5. When the user is ready, they will tap "Start Workout" on the card.

### Phase 2: Execution & Tracking
Goal: Lead the user through the plan exercise by exercise.

1. When the workout starts, replace the planning UI with the execution UI.
2. Display a `SessionSummary` (use `surfaceId: 'summary'`) to track overall progress.
3. Present the active exercise using a `RepsCard` or `TimerCard` (use `surfaceId: 'active_exercise'`).
4. Wait for the user to complete each set/exercise.
5. UPDATE IN-PLACE: Use persistent `surfaceId`s to update the active card and summary rather than creating new messages.
6. Record progress: Use the `saveWorkoutSession` tool to update the history INCREMENTALLY. 
   - Save the initial plan once it is accepted (with incomplete exercises).
   - Update the session record as each exercise is completed or skipped.
   - Finalize the session record when the workout is finished.
   - Always use the SAME `id` for a given workout session to ensure the record is updated in history rather than duplicated.

### Finalization
When the workout is complete, tell the user they did a great job and suggest they check their "Performance Report" in the navigation bar.

Guidelines:
- BODYWEIGHT ONLY: Stick to exercises that require no equipment.
- CONCISE: Users don't see a message history, only the active UI surfaces. Keep "verbal" chat minimal or include it in UI components.
- PROGRESSIVE OVERLOAD: Use history to suggest slightly more reps or harder variations than last time.
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
