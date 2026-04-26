class ExerciseRecord {
  final String name;
  final int? suggestedDuration;
  final int? numberOfReps;
  final int? actualDuration;
  final int? repsCompleted;
  final String? exerciseFeedback;
  final DateTime? completedTimestamp;
  final bool wasSkipped;

  ExerciseRecord({
    required this.name,
    this.suggestedDuration,
    this.numberOfReps,
    this.actualDuration,
    this.repsCompleted,
    this.exerciseFeedback,
    this.completedTimestamp,
    this.wasSkipped = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'suggestedDuration': suggestedDuration,
      'numberOfReps': numberOfReps,
      'actualDuration': actualDuration,
      'repsCompleted': repsCompleted,
      'exerciseFeedback': exerciseFeedback,
      'completedTimestamp': completedTimestamp?.toIso8601String(),
      'wasSkipped': wasSkipped,
    };
  }

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      name: json['name'] as String,
      suggestedDuration: json['suggestedDuration'] as int?,
      numberOfReps: json['numberOfReps'] as int?,
      actualDuration: json['actualDuration'] as int?,
      repsCompleted: json['repsCompleted'] as int?,
      exerciseFeedback: json['exerciseFeedback'] as String?,
      completedTimestamp: json['completedTimestamp'] != null
          ? DateTime.parse(json['completedTimestamp'] as String)
          : null,
      wasSkipped: json['wasSkipped'] as bool? ?? false,
    );
  }
}

class WorkoutSessionRecord {
  final String id;
  final DateTime createdTimestamp;
  final DateTime? startedTimestamp;
  final DateTime? completedTimestamp;
  final String? overallFeedback;
  final List<ExerciseRecord> exercises;

  WorkoutSessionRecord({
    required this.id,
    required this.createdTimestamp,
    this.startedTimestamp,
    this.completedTimestamp,
    this.overallFeedback,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'startedTimestamp': startedTimestamp?.toIso8601String(),
      'completedTimestamp': completedTimestamp?.toIso8601String(),
      'overallFeedback': overallFeedback,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory WorkoutSessionRecord.fromJson(Map<String, dynamic> json) {
    final createdStr = json['createdTimestamp'] as String;
    return WorkoutSessionRecord(
      id: json['id'] as String? ?? createdStr,
      createdTimestamp: DateTime.parse(createdStr),
      startedTimestamp: json['startedTimestamp'] != null
          ? DateTime.parse(json['startedTimestamp'] as String)
          : null,
      completedTimestamp: json['completedTimestamp'] != null
          ? DateTime.parse(json['completedTimestamp'] as String)
          : null,
      overallFeedback: json['overallFeedback'] as String?,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
