# Implementation Plan: GenUI Workout Buddy

This plan is divided into four sequential phases, progressing from the data foundation to the final polish.

## Phase 1: The Foundation (Data & Services)

**Goal:** Establish the persistent data model and the services that abstract the database logic. This phase is entirely independent of the AI.

| # | Task | Description | Output |
| :--- | :--- | :--- | :--- |
| **1.1** | Project Initialization | Setup Flutter project, install core packages (`drift`, `riverpod`, `google_generative_ai`, `genui`). | `pubspec.yaml`, basic Flutter structure. |
| **1.2** | Database Schema Definition | Implement all four table classes (`ExerciseDefinitions`, `ExercisePreferences`, `WorkoutSessions`, `WorkoutSets`) using the `drift` package. | `database.dart`, generated drift files. |
| **1.3** | Repository Implementation | Create the CRUD (Create, Read, Update, Delete) classes that interact directly with the database. These are the underlying services for the Agent's tools. | `exercise_repository.dart`, `session_repository.dart`. |
| **1.4** | Database Seeding | Populate the `ExerciseDefinitions` table with a starting set of bodyweight exercises (e.g., Pushups, Planks, Squats, Lunges). | Initial database state. |

## Phase 2: The Agent Bridge (Tools & State Management)

**Goal:** Establish the connection between the LLM and the application state/data services.

| # | Task | Description | Output |
| :--- | :--- | :--- | :--- |
| **2.1** | Riverpod Providers Setup | Define providers for the Database Repositories, the `GenUiConversation`, and the current UI Slot State (Main, Overlay). | `providers.dart`. |
| **2.2** | GenUI Tool Implementation (Data) | Create the Dart functions that mirror the `PROMPTS.md` tool definitions (`get_user_preferences`, `save_workout_session`, `run_analytics_query`, etc.). These wrap the Phase 1 repositories. | `agent_data_tools.dart`. |
| **2.3** | Agent Service Initialization | Initialize the `GenUiConversation` with the `FirebaseAiContentGenerator` and inject the `System Instruction` and Data Tools. | `agent_service.dart`. |
| **2.4** | Core Layout Setup (The Stack) | Build the main `Scaffold` using a `Stack` widget. This widget will listen to the Riverpod state providers for the `Main Stage` and `Overlay Dock` slots. | `main_scaffold.dart`. |

## Phase 3: Mode Implementation (UI Iteration)

**Goal:** Build the specific widgets and connect them to the Agent's commands, enabling the core functionality.

| # | Task | Description | Output |
| :--- | :--- | :--- | :--- |
| **3.1** | **Plan Mode** Widgets | Build the `IntakeWizard` and the interactive `PlanProposal` widgets (including swipe/tap event emission back to the Agent). | `plan_mode_widgets.dart`. |
| **3.2** | **Plan Mode** GenUI Catalog | Define the `CatalogItem` entries for the Plan Mode widgets and wire them into the main `Catalog`. | `widget_catalog.dart`. |
| **3.3** | **Execution Mode** Widgets (Passive) | Build the display components: `ExerciseGuide` (visuals/cues) and `SessionDashboard` (progress bar). | `execution_mode_widgets.dart`. |
| **3.4** | **Execution Mode** Widgets (Active) | Build the interactive components: `ActiveTimer` (countdown logic) and `RepCounter` (button logic). These must emit structured events to the Agent. | `interactive_widgets.dart`. |
| **3.5** | **Report Mode** Widgets | Build the `SessionRecap` and the dynamic `DataVisualizer` (charting library integration). | `report_mode_widgets.dart`. |
| **3.6** | Mode Transition Logic | Implement the Agent's logic to handle the state transitions (e.g., on receiving the "Start Workout" tool output, transition from Plan to Execution Mode). | Updates to `agent_service.dart` logic. |

## Phase 4: Feedback Loops & Polish

**Goal:** Ensure the personalization and conversational features are robust and the app is visually appealing.

| # | Task | Description | Output |
| :--- | :--- | :--- | :--- |
| **4.1** | Preference Logic Integration | Update the Agent's system prompt and logic to actively query `ExercisePreferences` when creating a plan proposal. | Refined Agent prompting. |
| **4.2** | Conversational Analyst Refinement | Ensure the Agent can successfully parse complex reporting queries ("Show me volume vs. time for pushups last month") and correctly invoke `run_analytics_query` to update the `DataVisualizer`. | Robust query parsing logic. |
| **4.3** | Visual Polish & Transitions | Add subtle animations and transitions when the Agent swaps the Main Stage widget to create a smooth, modern feel. | CSS/Animation code. |
| **4.4** | Error and Loading States | Implement graceful handling for AI timeouts, database errors, and invalid Agent responses. | UI elements for error messages. |