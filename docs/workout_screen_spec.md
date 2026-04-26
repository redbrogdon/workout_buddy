[Back to Application Specification](application_spec.md) | [Back to Architecture Documentation](architecture.md)

# Workout Screen Specification

## Overview
This document contains information about the Workout screen of **Workout Buddy**. The Workout screen is the primary interface where the user designs and executes their workout session. It is driven by an Agent that manages two distinct phases: **Planning & Negotiation** and **Execution & Tracking**.

## Workout Screen Agent
The agent is a dynamic orchestrator and guide, responsible for leading the user through the entire lifecycle of a workout session.

### Goal
The goal for the agent is to help the user design a tailored bodyweight workout plan and then guide them through its execution, recording performance data incrementally to local storage.

### Tools
The agent has access to tools that allow it to:

*   **Read Preferences**: Understand the user's general goals and workout style.
*   **Read History**: Review past performance to suggest progressive overload.
*   **Save Workout Session**: Record or update the session record in history (incrementally or finally).

---

## The Workflow

### Phase 1: Planning & Negotiation
Upon launch, the Agent starts a conversation to determine the user's goals for today.

1.  **Intake**: The Agent asks about energy levels, time constraints, and any soreness.
2.  **Proposal**: The Agent generates a `WorkoutCard` with a suggested plan (3-5 bodyweight exercises).
3.  **Iteration**: The user can suggest changes via chat or by interacting with `ExerciseTile` components. The Agent updates these components **in-place**.
4.  **Acceptance**: When the user is satisfied, they tap "Start Workout". The Agent saves the initial plan to history with a unique session ID.

### Phase 2: Execution & Tracking
Once the workout begins, the screen transitions to focus on guiding the user through each exercise.

1.  **Guidance**: The Agent presents the active exercise using a `TimerCard` or `RepsCard`.
2.  **Tracking**: The Agent waits for the user to complete each set.
3.  **In-Place Updates**: As the user progresses, the Agent updates the persistent `SessionSummary` and active cards using their unique identifiers.
4.  **Incremental Persistence**: The Agent updates the session record in history after each exercise is completed or skipped.
5.  **Finalization**: Once the last exercise is done, the Agent summarizes the performance and suggests navigating to the Report screen via the bottom bar.

---

## UI Components
The agent uses the following custom components from the `workoutBuddyCatalog`:

### Planning Components
*   **WorkoutCard**: High-level summary of the session plan. Includes an "onStart" action to begin the workout.
*   **ExerciseTile**: Interactive tile for individual exercises during negotiation (supports delete/replace).

### Execution Components
*   **SessionSummary**: A persistent dashboard pinned at the top tracking overall progress (e.g., "Exercise 3 of 8").
*   **TimerCard**: Active guidance for timed exercises (e.g., Planks) with a client-side timer.
*   **RepsCard**: Active guidance for repetition-based moves (e.g., Pushups) with input for actual reps completed.

## Composition & Layout
*   **Pinned Header**: The `SessionSummary` (in Phase 2) or `WorkoutCard` (in Phase 1) should stay at the top.
*   **Dynamic List**: Exercise cards appear below as the user progresses.
*   **Chat Input**: A persistent bar at the bottom for communicating with the coach.
*   **No History**: Chronological chat bubbles are suppressed; the Agent's responses are reflected in the UI cards.
*   **Navigation**: A bottom bar allows manual switching between **Workout** and **Report** screens.
