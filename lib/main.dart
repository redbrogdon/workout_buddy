// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

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
  model: 'gemini-3.1-pro-preview',
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
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onError(String text) {
    final snackBar = SnackBar(
      content: Text('ERROR: $text'),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _sendAndReceive(ChatMessage msg) async {
    if (msg.text.trim().isEmpty) return;
    debugPrint('--------- MESSAGE FROM ME ----------');
    debugPrint(msg.text);
    debugPrint('------------------------------------');
    final response = await _chatSession.sendMessage(Content.text(msg.text));
    debugPrint('--------- RESPONSE FROM AGENT ----------');
    debugPrint(response.text ?? '[NULL]');
    debugPrint('----------------------------------------');
    if (response.text?.isNotEmpty ?? false) {
      _transport.addChunk(response.text!);
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

    final catalog = BasicCatalogItems.asCatalog().copyWith([
      workoutCard,
      repsCard,
    ]);

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
                      decoration: const InputDecoration(
                        hintText: 'Enter a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        _conversation.sendRequest(
                          ChatMessage.user(_textController.text),
                        );
                        _textController.clear();
                      }
                    },
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

final workoutCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['WorkoutCard']),
    'title': S.string(description: 'The title of the workout'),
    'exercises': S.list(
      description: 'A list of 3-5 exercises to perform as part of the workout',
      items: S.string(
        description:
            'The type of exercise to perform, including name and details '
            'like the amount of reps. 50 characters max.',
        minLength: 3,
        maxLength: 5,
      ),
    ),
  },
  required: ['title', 'exercises'],
);

final workoutCard = CatalogItem(
  name: 'WorkoutCard',
  dataSchema: workoutCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final title = json['title'] as String;
    final exercises = (json['exercises'] as List<dynamic>)
        .map((s) => s.toString())
        .toList();

    return WorkoutCard(
      title: title,
      exercises: exercises,
    );
  },
);

class WorkoutCard extends StatelessWidget {
  final String title;
  final List<String> exercises;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: exercises
                  .map(
                    (exercise) => Chip(
                      avatar: const Icon(Icons.fitness_center),
                      label: Text(exercise),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

final repsCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['RepsCard']),
    'exercise': S.string(description: 'The name of the workout'),
    'instructions': S.string(
      description: 'A brief description of how one should perform the exercise',
    ),
    'numberOfReps': S.integer(
      description:
          'The number of reps to be done in order to complete this exercise',
    ),
    'repsCompleted': S.integer(
      description:
          'The number of reps that were actually performed by the user.',
    ),
    'completed': S.boolean(
      description:
          'Whether or not the exercise has been completed yet (initial value is false)',
    ),
    'completeAction': A2uiSchemas.action(
      description:
          'The action performed when the user has completed the exercise. I will '
          'provide the number of reps completed by the users as "numberOfRepsCompleted".',
    ),
  },
  required: [
    'exercise',
    'instructions',
    'numberOfReps',
    'completed',
    'completeAction',
  ],
);

final repsCard = CatalogItem(
  name: 'RepsCard',
  dataSchema: repsCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final exercise = json['exercise'] as String;
    final instructions = json['instructions'] as String;
    final numberOfReps = json['numberOfReps'] as int;
    final completed = json['completed'] as bool;
    final action = json['completeAction'] as JsonMap?;

    return RepsCard(
      exercise: exercise,
      instructions: instructions,
      numberOfReps: numberOfReps,
      completed: completed,
      onCompleted: (reps) {
        if (action == null) {
          return;
        }
        final actionEvent = action['event'] as JsonMap?;
        final eventName = (actionEvent?['name'] as String?) ?? '';
        final JsonMap contextDefinition =
            (action['context'] as JsonMap?) ?? <String, Object?>{};
        final JsonMap resolvedContext = resolveContext(
          itemContext.dataContext,
          contextDefinition,
        );
        resolvedContext['numberOfRepsCompleted'] = reps;
        itemContext.dispatchEvent(
          UserActionEvent(
            name: eventName,
            sourceComponentId: itemContext.id,
            context: resolvedContext,
          ),
        );
      },
    );
  },
);

class RepsCard extends StatefulWidget {
  final String exercise;
  final String instructions;
  final int numberOfReps;
  final bool completed;
  final void Function(int) onCompleted;

  const RepsCard({
    super.key,
    required this.exercise,
    required this.instructions,
    required this.numberOfReps,
    required this.completed,
    required this.onCompleted,
  });

  @override
  State<RepsCard> createState() => _RepsCardState();
}

class _RepsCardState extends State<RepsCard> {
  late int repsCompleted;

  @override
  void initState() {
    super.initState();
    repsCompleted = widget.numberOfReps;
  }

  @override
  void didUpdateWidget(RepsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.exercise != widget.exercise) {
      // We're reusing the widget with a new exercise, so reset the count.
      repsCompleted = widget.numberOfReps;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.exercise,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.numberOfReps}',
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 8,
              children: [
                const Text('Reps completed:'),
                Text('$repsCompleted'),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: widget.completed
                      ? null
                      : () => setState(() => repsCompleted++),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: widget.completed
                      ? null
                      : () => setState(() => repsCompleted--),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: widget.completed
                      ? null
                      : () => widget.onCompleted(repsCompleted),
                ),
              ],
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
          * Should only include exercises measured in reps, rather than time
            (push-ups are fine, but timed planks should not be included).
          * Each exercise must be a single set of reps.

          This is the process you should follow:

          1. Generate a WorkoutCard that displays a proposed workout plan, and
             then wait for a response from me. If I ask for changes, update
             that workout plan and then update the WorkoutPlan to reflect
             those changes.

          2. **Stop and wait for a confirmation from me. Do not proceed until I
             indicate the workout plan is acceptable.**

          3. Once I accept the workout plan, you will lead me through each of the
             exercises in the plan, one at a time, beginning with the first. Include
             **only the exercises in the plan I agreed to**. To
             do so, follow these steps for each exercise, one at a time:
             - Generate a RepsCard for the exercise and display it in a new surface.
               **Use a new RepsCard for each exercise.**
             - **Stop and wait for a confirmation from me. Do not proceed until you
               receive a completeAction event, which will indicate I've completed the
               exercise.**
             - Mark the exercise as completed, updating the relevant UI surface.
             - Congratulate me for completing the exercise, and include the number of
               repos completed in your message.
             - Restart Step 3 with the next uncompleted exercise, if one exists.
          
          4. When all the exercises have been completed, congratulate me on being
             finished.
''';
