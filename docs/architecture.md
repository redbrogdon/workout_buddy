[Back to Application Specification](application_spec.md)

# Workout Buddy Architecture

## Overview
This document contains information about the technical architecture of **Workout Buddy**. In particular it contains information about dependencies to be included (or not included), patterns to be followed (or not followed), and other architectural decisions that should be made.

## Overall architecture
**Workout Buddy** is a Flutter application that uses an agent hosted on Firebase AI Logic as its backend. Its most important other dependency is Google's `genui` package for Flutter and Dart, which gives the agent a catalog of UI components it can use to build the user interface.

The three screens of the application are:

1. [Plan](plan_screen_spec.md)
2. [Workout](workout_screen_spec.md)
3. [Report](report_screen_spec.md)

All of these should be driven by the agent, with the agent responsible for maintaining the application's data state (using `genui`'s Data Model), and for choosing which UI components are rendered at any given time to display that data.

## The Agent
Each of the app's three screens uses a separate instance of the agent (Gemini 3 Flash Preview) with its own state and instructions.

### Agent Service Abstraction
The application uses an **Agent Service Abstraction Layer** to decouple the UI from the underlying AI platform (Firebase AI / Gemini SDK).

*   **Preferred Model:** `gemini-3-flash-preview`
*   **Interface:** `AgentService` (defined in `lib/services/agent_service.dart`) provides a generic `sendMessage(ChatMessage message)` API.
*   **Decoupling:** The `AgentService` public API is built on the `genai_primitives` package and contains **no dependencies on GenUI**. It handles raw message processing and model coordination.
*   **Implementation:** `FirebaseAgentService` implements the interface using the `firebase_ai` package.
*   **Scoped Providers:** The `agentServiceProvider` is a family provider that generates scoped instances for the 'plan', 'workout', and 'report' purposes, injecting specific tools into each.

### Interaction Workflow
1.  **Screen-Managed Transport:** Screens own the `A2uiTransportAdapter` and `Conversation` objects.
2.  **Message Flow:** When a user sends a message, the screen calls `_agent.sendMessage(msg)`.
3.  **UI Updates:** The screen receives a string response from the agent and manually pipes it into the transport via `_transport.addChunk(response)`.
4.  **Handoffs:**
    *   **Plan to Workout:** When a workout plan is accepted, the `WorkoutCard` dispatches a `start_workout` event. The `PlanScreen` intercepts this event, saves the plan to `active_session.json`, and updates the global `navigationIndexProvider` to transition the app shell to the Workout screen.
    *   **Workout to Report:** Upon selecting "Finish Workout", the Workout Agent saves the completed session to `workout_history.json` and prompts the user to navigate to the Report screen via the bottom bar.

### Global State Providers
- `navigationIndexProvider`: A `StateProvider<int>` that governs the active tab in the `MainShell`.
- `storageServiceProvider`: Provides the persistence layer to all custom agent tools.

## Storage Implementation

The application uses a "Document-as-DB" approach for local persistence to ensure simplicity, testability, and compatibility with LLM context windows.

### Persistence Mechanism
*   **Engine:** Flat JSON files managed via `dart:io`.
*   **Path Management:** Files are stored in the `getApplicationDocumentsDirectory()` provided by the `path_provider` package.
*   **Serialization:** Standard `dart:convert` with explicit `fromJson` and `toJson` methods in model classes.

### Managed Files
| File Name | Data Schema | Purpose |
| :--- | :--- | :--- |
| `active_session.json` | `WorkoutSessionRecord` | Tracks the "Live" workout state. Deleted after finalization. |
| `workout_history.json` | `List<WorkoutSessionRecord>` | Historical log of all completed sessions. |
| `user_preferences.json` | `UserPreferences` | Natural language preferences and app settings. |

### Rationale
1.  **Agent Visibility:** LLMs can easily parse and reason over a single JSON document.
2.  **State Handoff:** Screens communicate by reading/writing to `active_session.json`, allowing a "fresh" Agent on a new screen to resume exactly where the previous one left off.
3.  **Atomic Updates:** Simple file overwrites avoid the complexity of SQL migrations during the rapid prototyping phase.

## Tools
The app should try to minimize the number of packages it depends on by using vanilla Flutter widgets and Dart APIs wherever possible. For example, the app should use Flutter's built-in HTTP client to make network requests.

For state management, Riverpod is the preferred solution. No code generation like `freezed` is needed, however, and should be avoided.

### Data Model
A workout plan is composed of:

* A name
* A list of one or more exercises

An exercise is composed of:

* A name
* A description of how to perform the exercise
* A number of sets
* A number of repetitions or an amount of time for which to perform the exercise (e.g. reps for push-ups or seconds for planks)

## Testing
The app is designed for high testability by decoupling UI, Service, and Storage layers.

### Isolation Strategy
*   **Storage Layer:** Each custom tool interacts with an abstract `StorageService`, which is mocked in widget tests using a `MockStorageService`.
*   **Agent Layer:** Screens are tested by overriding the `agentServiceProvider` with a `MockAgentService`. This allows verifying UI rendering and navigation without firing real LLM requests or requiring Firebase initialization.
*   **Component Testing:** Individual GenUI catalog items can be verified in isolation by pumping them into a `Surface` widget.

## The UI
The app is composed of three screens, and the user can switch between them using a navigation bar at the bottom of the screen. The navigation bar should always be visible, with UI components from the agent appearing above. 

The Plan screen should be the default screen when the app is launched.

Unless otherwise specified, the main content region of the screen (above the navigation bar) should scroll vertically to allow for more content that can be viewed at one time.

### The "In-Place" UI Pattern
To avoid the cognitive load of a growing chat history, the application leverages persistent `surfaceId`s for core UI components:
*   **Workout Screen:** The `SessionSummary` and active `ExerciseTile`s use stable IDs. The agent updates these existing surfaces in-place rather than sending new messages.
*   **Chat Minimization:** In tracking-heavy screens (like Workout), chronological chat bubbles are suppressed to keep the focus on the active tracking cards.

### Visual Design
The application follows a premium, branded design philosophy:
*   **Theme:** A custom `ThemeData` inspired by the **Planet Fitness** aesthetic.
    - **Colors:** Deep Purple (`#6D2077`) for primary actions and Yellow (`#FEB822`) for highlights.
    - **Mode:** Primarily utilizes a high-contrast dark theme for a focused "gym" feel.
*   **Typography:** Custom typography system using bold headlines for clarity and refined body text for readability.
*   **Transitions:** Fluid sliding transitions between screens implemented via `PageView` and `PageController`.
