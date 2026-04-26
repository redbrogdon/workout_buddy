[Back to Application Specification](application_spec.md)

# Data & Storage Schemas

This document defines the structure of the data stored locally on the device, which is read and written by the Workout Buddy and Report Agents.

---

## 1. Workout Session Record
A record is created for every workout session and updated **incrementally** during the session. This data is used by the **Report Screen Agent** to generate trends and summaries.

### Session Metadata
*   **ID:** A unique identifier for the session (used to update the record in-place).
*   **Created Timestamp:** When the workout plan was first architected.
*   **Started Timestamp:** When the user tapped "Start Workout".
*   **Completed Timestamp:** When the user finished the final exercise or ended the session.
*   **Overall Feedback:** A string containing the user's summary thoughts on the entire workout.

### Exercise Records
A session contains a list of records for every exercise included in the plan:
*   **Name:** The name of the exercise.
*   **Suggested Duration:** The number of seconds planned (matches `suggestedDuration` in UI).
*   **Number of Reps:** The number of reps planned (matches `numberOfReps` in UI).
*   **Actual Duration:** The number of seconds actually performed (matches `actualDuration` in UI).
*   **Reps Completed:** The number of reps actually performed (matches `repsCompleted` in UI).
*   **Exercise Feedback:** A string containing the user's specific thoughts on this exercise/set.
*   **Completed Timestamp:** When the specific exercise was marked as finished.
*   **Was Skipped:** A boolean indicating if the user intentionally skipped this exercise.

---

## 2. User Profile & Preferences
This data is used primarily by the agent during the planning phase to ensure new workouts align with the user's history and constraints.

### Natural Language Preferences
*   **Description:** A single, persistent string that serves as a natural language biography of the user's fitness profile. It can include:
    - Favorite/Hated exercises.
    - Ongoing injuries or physical constraints.
    - Typical energy levels or time preferences.
    - Available equipment.

> [!TIP]
> This string is provided directly to the workout agent's system instruction to help it "get to know" the user over time.
