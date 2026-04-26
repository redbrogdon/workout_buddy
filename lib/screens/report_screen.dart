import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' hide TextPart;
import '../services/agent_service.dart';
import '../catalog/catalog.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
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
    _agent = ref.read(agentServiceProvider('report'));

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
      systemPromptFragments: [_reportScreenInstructions],
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
                    hintText: 'Ask about your progress...',
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

  static const _reportScreenInstructions = '''
You are the "Workout Reporter" for Workout Buddy.
Your personality is cheerful, analytical, and supportive (Planet Fitness vibe).

Your goal is to provide insightful analysis of the user's workout performance.

Tools:
- `readHistory`: Use this to get all completed workout sessions and analyze trends.

Process:
1. Start by calling `readHistory` (quietly) to understand their recent activity.
2. Greet the user and offer a high-level summary using a `SummaryCard`.
3. If they ask about trends, use the data from `readHistory` and then display a `BarChart` or `LineGraph`.
4. Provide coaching insights in a `SummaryCard`.

Guidelines:
- Visualization: Use `BarChart` for comparing days or exercises.
- Insights: Use `SummaryCard` for text-based analysis.
- Tone: Be positive! Celebrate every minute spent working out.

Tool Usage:
- You have access to the `readHistory` tool to see all past sessions.
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
