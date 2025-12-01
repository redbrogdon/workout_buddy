# Technical Architecture

## Overview
This project implements an **Agent-Driven State Machine**. Unlike standard Flutter apps where the User drives the navigation (e.g., tapping a tab), here the **AI Agent** drives the navigation and layout based on the conversation state.

## Tech Stack

### Core Framework
* **Flutter:** UI Toolkit.
* **Dart:** Programming Language.

### AI & Orchestration
* **[genui](https://pub.dev/packages/genui):** (Experimental) The bridge between the LLM and Flutter widgets. Handles the message history and tool dispatching.
* **[google_generative_ai](https://pub.dev/packages/google_generative_ai):** Access to the Gemini API.

### Data Layer
* **[drift](https://pub.dev/packages/drift):** (Formerly Moor) Reactive, type-safe SQLite database. Chosen for its ability to generate Dart code from SQL/Table definitions, making "Tool" creation safer.
* **[sqlite3](https://pub.dev/packages/sqlite3):** The underlying database engine.

### State Management
* **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod):** Used for Dependency Injection (Repositories) and managing the "Slot State" of the UI.
* **[freezed](https://pub.dev/packages/freezed):** For generating immutable data classes and unions, useful for parsing LLM JSON outputs.

---

## UI Architecture: The "Multi-Slot" Layout
The application uses a customized `Scaffold` controlled by the Agent. Instead of a linear chat feed, the Agent issues commands to populate specific "Slots" in the view.

### Slots
1.  **Main Stage (Center):** The primary interaction area (e.g., the Exercise Timer, the Plan List).
2.  **Overlay Dock (Bottom):** A persistent, long-lived container for session status (e.g., "Total Time: 12:00").
3.  **Toasts (Invisible):** Non-blocking messages ("Coach's Voice").

### Component Catalog
The Agent has access to a `Catalog` of Flutter widgets it can render.

| Mode | Widget Name | Description |
| :--- | :--- | :--- |
| **Plan** | `IntakeWizard` | Form/Chips for gathering initial context (time/energy). |
| **Plan** | `PlanProposal` | Interactive list of exercises. Emits events when user swipes/edits. |
| **Exec** | `ExerciseGuide` | Video loop and form cues for current movement. |
| **Exec** | `ActiveTimer` | Large countdown for static holds. Triggers event on completion. |
| **Exec** | `RepCounter` | Counter with +/- buttons. |
| **Exec** | `CheckInInterstitial` | "How was that?" card to capture RPE/Intensity. |
| **Exec** | `SessionDashboard` | Persistent bottom bar tracking overall progress. |
| **Report** | `SessionRecap` | Summary receipt of the completed workout. |
| **Report** | `DataVisualizer` | Flexible chart widget (Line/Bar) configurable by JSON data. |

---

## Database Schema (Drift)

The application uses a local relational database to support the Agent's long-term memory and reporting capabilities.

### 1. `ExerciseDefinitions`
The static library of available movements.
```dart
class ExerciseDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // e.g., "Pushup"
  // Enum: RepBased, TimeBased
  IntColumn get type => integer()(); 
  TextColumn get primaryMuscleGroup => text()(); // e.g., "Chest", "Core"
}
```

### 2. ExercisePreferences
Tracks the user's relationship with specific movements.

```dart
class ExercisePreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer().references(ExerciseDefinitions, #id)();
  
  // Enum: Favorite, Neutral, Disliked, Excluded
  IntColumn get sentiment => integer()(); 
  
  // Context for the Agent (e.g., "Hurts left wrist")
  TextColumn get reason => text().nullable()(); 
  DateTimeColumn get lastUpdated => dateTime()();
}
```

### 3. WorkoutSessions
The container for a completed workout.

```dart
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  
  IntColumn get totalVolume => integer()(); // Aggregated metric
  TextColumn get userFeeling => text().nullable()(); // "Strong", "Tired"
  TextColumn get notes => text().nullable()(); // Qualitative user feedback
}
```

### 4. WorkoutSets
The granular data for every movement performed.

```dart
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id)();
  IntColumn get exerciseId => integer().references(ExerciseDefinitions, #id)();
  
  IntColumn get reps => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get rpe => integer().nullable()(); // Rate of Perceived Exertion (1-10)
  IntColumn get orderIndex => integer()();
}
```

## Agent "Tools" (Logic Layer)
To interact with the database, the LLM is provided with the following function definitions (Tools):
* get_exercise_history(exercise_name, date_range): Returns JSON stats for Reporting Mode.
* save_workout_results(json_blob): Commits the session to the DB.
* update_preference(exercise, sentiment, reason): Updates the ExercisePreferences table based on chat.
* query_preferences(filter): Retrieving "Disliked" or "Excluded" exercises during Plan Mode.
