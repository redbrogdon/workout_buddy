import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'package:firebase_ai/firebase_ai.dart';
import '../catalog/catalog.dart';
import '../tools/storage_tools.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  late final GenerativeModel model;
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
    final tools = ref.read(storageToolsProvider);
    model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
      tools: tools,
    );
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
      systemPromptFragments: [_workoutScreenInstructions],
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

    final response = await _chatSession.sendMessage(Content.text(buffer.toString()));
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
    final hasSummary = _surfaceIds.contains('summary');
    final otherIds = _surfaceIds.where((id) => id != 'summary').toList();

    return Column(
      children: [
        if (hasSummary)
          Surface(surfaceContext: _controller.contextFor('summary')),
        
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
            itemCount: otherIds.length,
            itemBuilder: (context, index) {
              final id = otherIds[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Surface(surfaceContext: _controller.contextFor(id)),
              );
            },
          ),
        ),
        
        // Chat input bar (no message history displayed)
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

  static const _workoutScreenInstructions = '''
You are the "Workout Coach" for Workout Buddy.
Your personality is cheerful, energetic, and supportive (Planet Fitness vibe).

Your goal is to lead the user through their workout plan exercise by exercise.

Process:
1. Start by calling `readActiveSession` to understand the workout plan for today.
2. Display a `SessionSummary` with the initial stats (use a persistent `surfaceId` like 'summary').
3. Present the first exercise using either a `RepsCard` or a `TimerCard` (use a persistent `surfaceId` like 'exercise_1').
4. Wait for the user to complete the exercise (you will receive an event).
5. Update the `SessionSummary` and relevant `ExerciseTile` IN-PLACE.
5. If the user asks for form tips or suggests a change, respond by updating the UI elements in-place where possible.

Guidelines:
- UPDATING IN-PLACE: Use the same `surfaceId` to update components rather than creating new ones for existing exercises.
- CHAT: Since there is no chat history visible to the user, your "verbal" responses should be concise or reflected in UI updates. If you must speak, users will only see your text if you include it in a UI component or if you update a text area. 
- (Note: In this implementation, text particles from the agent are NOT visible on the Workout Screen, so you MUST rely on updating the UI cards).

Tool Usage:
- Every time an exercise is completed, use the `saveActiveSession` tool to persist progress to history.
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
