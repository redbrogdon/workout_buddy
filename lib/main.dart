// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'catalog/reps_card.dart';
import 'catalog/timer_card.dart';
import 'catalog/workout_card.dart';
import 'firebase_options.dart';

void main() async {
  configureLogging(
    logCallback: (level, msg) => debugPrint('GenUI $level: $msg'),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final model = FirebaseAI.googleAI().generativeModel(
  model: 'gemini-3-flash-preview',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Workout Companion'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _chatSession = model.startChat();

  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  final _surfaceIds = <String>[];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isRecording = false;

  void _onSurfaceAdded(String id) {
    setState(() => _surfaceIds.add(id));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSurfaceDeleted(String id) {
    setState(
      () => _surfaceIds.remove(id),
    );
  }

  void _onTextAdded(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      final snackBar = SnackBar(content: Text(trimmed));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _onError(String text) {
    final snackBar = SnackBar(
      content: Text('ERROR: $text'),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      _conversation.sendRequest(
        ChatMessage.user(_textController.text),
      );
      _textController.clear();
    }
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

    if (buffer.isEmpty) {
      return;
    }

    final text = buffer.toString();

    debugPrint('--------- MESSAGE FROM ME ----------');
    debugPrint(text);
    debugPrint('------------------------------------');

    final response = await _chatSession.sendMessage(Content.text(text));

    debugPrint('--------- RESPONSE FROM AGENT ----------');
    debugPrint(response.text ?? '[NULL]');
    debugPrint('----------------------------------------');

    if (response.text?.isNotEmpty ?? false) {
      _transport.addChunk(response.text!);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() => _isRecording = false);
    } else {
      setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _transport.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final catalog = BasicCatalogItems.asCatalog().copyWith(
      newItems: [
        workoutCard,
        repsCard,
        timerCard,
      ],
    );

    _controller = SurfaceController(catalogs: [catalog]);

    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);

    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    _conversation.events.listen((event) {
      switch (event) {
        case ConversationSurfaceAdded added:
          _onSurfaceAdded(added.surfaceId);
        case ConversationSurfaceRemoved removed:
          _onSurfaceDeleted(removed.surfaceId);
        case ConversationContentReceived content:
          _onTextAdded(content.text);
        case ConversationError error:
          _onError(error.error.toString());
        default:
      }
    });

    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      instructions: systemInstruction,
    );

    _conversation.sendRequest(ChatMessage.system(promptBuilder.systemPrompt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<ConversationState>(
            valueListenable: _conversation.state,
            builder: (context, state, child) {
              if (state.isWaiting) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _surfaceIds.length,
              itemBuilder: (context, index) {
                final id = _surfaceIds[index];
                return Surface(
                  surfaceContext: _controller.contextFor(id),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Enter a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    color: _isRecording ? Colors.red : null,
                    onPressed: _toggleRecording,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const systemInstruction = '''
          You are an expert in creating workout plans and leading the user
          through performing the exercises. No cardio, free weights, or other
          sports. Each workout plan should be 3 to 5 different exercises, each
          with a number of sets and repetitions.

          The workout plans you create should meet these criteria:
          * Composed of three to five individual exercises.
          * Only includes bodyweight exercises, things that can be done without
            equipment while alone in a small room.
          * Should only include exercises measured in reps or time, rather than
            other metrics.
          * Each exercise must be a single set of reps or time.

          This is the process you should follow:

          1. Generate a WorkoutCard that displays a proposed workout
             plan, and then wait for a response from me. If I ask for
             changes, update that workout plan and then update the
             WorkoutPlan to reflect those changes.

          2. **Stop and wait for a confirmation from me. Do not proceed
             until I indicate the workout plan is acceptable.**

          3. Once I accept the workout plan, you will lead me through each
             of the exercises in the plan, one at a time, beginning with
             the first. Include **only the exercises in the plan I agreed
             to**. To do so, follow these steps for each exercise, one at
             a time:
             - Generate a new RepsCard (if the exercise is measured in reps) or
               a new TimerCard (if the exercise is measured in seconds) for the
               exercise and display it in a new surface. **Use a new RepsCard
               or TimerCard for each exercise.**
             - **Stop and wait for a confirmation from me that I have completed
               the exercise. Do not proceed until you receive a completeAction
               event, which will indicate I've completed the exercise.**
             - Mark the exercise as completed and update the relevant UI
               surface.
             - Congratulate me for completing the exercise, and include
               the number of reps or amount of time completed in your message.
             - Restart Step 3 with the next uncompleted exercise, if one
               exists.
          
          4. When all the exercises have been completed, congratulate me
             on being finished.

          Some other, important instructions:
          * If I ask for a change to the workout plan, update the existing
            WorkoutCard surface rather than creating a new one. There should
            never be more than one WorkoutCard at a time.
''';
