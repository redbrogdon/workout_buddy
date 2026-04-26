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

*   **Default Model:** `gemini-3-flash-preview`
*   **Prompting Strategy:** System instructions are built using `PromptBuilder`'s `systemPromptFragments` for modularity and sent via `ChatMessage.system(promptBuilder.systemPromptJoined())`.

## State Management & Navigation
The application uses a **Shared State via Local Storage** pattern to manage transitions between screens:

*   **Plan to Workout:** When a workout plan is accepted and "Start Workout" is triggered, the Plan Screen Agent (or client code) saves the finalized plan to a "Current Session" slot in local storage. The application then navigates to the Workout screen.
*   **Workout to Report:** As the user completes exercises, the Workout Screen Agent updates the "Current Session" record with actual performance data. Upon completion, the session is moved from "Current" to "History," and the user is prompted to view the Report screen.

By using local storage as the bridge, each screen's agent can remain focused on its specific task while remaining aware of the broader session context.

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
The app should be constructed in such a way that it is easy to test. Each screen should be testable in isolation, and the agents should be testable in isolation.

## The UI
The app is composed of three screens, and the user can switch between them using a navigation bar at the bottom of the screen. The navigation bar should always be visible, with UI components from the agent appearing above. 

The Plan screen should be the default screen when the app is launched.

Unless otherwise specified, the main content region of the screen (above the navigation bar) should scroll vertically to allow for more content that can be viewed at one time.

*   **Workout Screen Exception:** On the Workout screen, the `SessionSummary` component is pinned to the top, while the exercise cards are scrollable beneath it. Additionally, chronological chat bubbles are suppressed to keep the focus on the active exercise cards.

### Visual Design
The application follows a "lean and native" design philosophy:
*   **Framework:** Use standard **Material 3** widgets and patterns.
*   **Theming:** Support both **Light and Dark modes**, honoring the user's system-level preference.
*   **Typography:** Use the device's **default system fonts** to maintain a clean, efficient feel.
*   **Color Palette:** Use the default Material 3 color schemes for a familiar, welcoming experience (the "Planet Fitness" vibe).
