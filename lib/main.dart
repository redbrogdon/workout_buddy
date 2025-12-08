// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'firebase_options.dart';

void main() async {
  configureGenUiLogging(
    logCallback: (level, msg) => debugPrint('GenUI $level: $msg'),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Workout Companion'),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  // Stitch Colors
  const primary = Color(0xFF6D28D9);

  final background = isDark ? const Color(0xFF111111) : const Color(0xFFF3F4F6);
  final card = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFFFFFF);
  final text = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
  final textSecondary = isDark
      ? const Color(0xFF9CA3AF)
      : const Color(0xFF6B7280);
  final subtle = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

  final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

  return baseTheme.copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      surface: card,
      onSurface: text,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: subtle, // For subtle/background elements
      background: background,
    ),
    textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
      bodyColor: text,
      displayColor: text,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: card,
      foregroundColor: text,
      elevation: 0,
    ),
    useMaterial3: true,
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final GenUiConversation conversation;
  final _surfaceIds = <String>[];

  void _onSurfaceAdded(SurfaceAdded update) {
    setState(() => _surfaceIds.add(update.surfaceId));
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

  void _onSurfaceDeleted(SurfaceRemoved update) {
    setState(
      () => _surfaceIds.remove(update.surfaceId),
    );
  }

  void _onTextAdded(String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _sendMessage(String text) async {
    final msg = text.trim();
    if (msg.isNotEmpty) {
      return conversation.sendRequest(UserMessage.text(text));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final catalog = CoreCatalogItems.asCatalog().copyWith([
      workoutCard,
      repsCard,
    ]);
    final generator = FirebaseAiContentGenerator(
      modelCreator:
          ({
            required FirebaseAiContentGenerator configuration,
            Content? systemInstruction,
            List<Tool>? tools,
            ToolConfig? toolConfig,
          }) {
            return GeminiGenerativeModel(
              FirebaseAI.googleAI().generativeModel(
                model: 'gemini-2.5-pro',
                systemInstruction: systemInstruction,
                tools: tools,
                toolConfig: toolConfig,
              ),
            );
          },
      catalog: catalog,
      systemInstruction: '''
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
''',
    );
    conversation = GenUiConversation(
      genUiManager: GenUiManager(catalog: catalog),
      contentGenerator: generator,
      onSurfaceAdded: _onSurfaceAdded,
      onSurfaceDeleted: _onSurfaceDeleted,
      onTextResponse: _onTextAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              controller: _scrollController,
              itemCount: _surfaceIds.length,
              itemBuilder: (context, index) {
                final id = _surfaceIds[index];
                return GenUiSurface(
                  host: conversation.host,
                  surfaceId: id,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Add note...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _sendMessage(_textController.text);
                      _textController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
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
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: exercises
                  .map(
                    (exercise) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        exercise,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

final repsCardSchema = S.object(
  properties: {
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
        final actionName = action['name'] as String;
        final List<Object?> contextDefinition =
            (action['context'] as List<Object?>?) ?? <Object>[];
        final JsonMap resolvedContext = resolveContext(
          itemContext.dataContext,
          contextDefinition,
        );
        resolvedContext['numberOfRepsCompleted'] = reps;
        itemContext.dispatchEvent(
          UserActionEvent(
            name: actionName,
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
    final isCompleted = widget.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.exercise,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.autorenew,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      Text(
                        'Target: ${widget.numberOfReps}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Counter Controls
                Row(
                  children: [
                    _buildControlButton(
                      theme,
                      Icons.remove,
                      isCompleted
                          ? null
                          : () => setState(() => repsCompleted--),
                    ),
                    Container(
                      width: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$repsCompleted',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Reps',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildControlButton(
                      theme,
                      Icons.add,
                      isCompleted
                          ? null
                          : () => setState(() => repsCompleted++),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted
                    ? null
                    : () => widget.onCompleted(repsCompleted),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: theme.colorScheme.onSurface
                      .withOpacity(0.12),
                  disabledForegroundColor: theme.colorScheme.onSurface
                      .withOpacity(0.38),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Complete',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    ThemeData theme,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
