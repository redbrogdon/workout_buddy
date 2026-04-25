[Back to Application Specification](application_spec.md)

# GenUI Catalog Schemas

This document describes the data required for each custom UI component available to the Agent.

---

## 1. Workout Planning (Plan Screen)

### WorkoutCard
Displays the overall draft workout plan.
*   **Role:** High-level summary of the session.
*   **Fields:**
    - A title for the workout.
    - A list of exercises to be performed (currently strings, moving toward `ExerciseTile` children).

### ExerciseTile
An interactive tile for individual exercises during negotiation.
*   **Role:** Allows the user to modify the plan at a granular level.
*   **Fields:**
    - The name of the exercise.
    - A number of sets.
    - A number of repetitions.
    - A duration in seconds.
    - An action for deleting the exercise.
    - An action for replacing the exercise.

---

## 2. Active Workout (Workout Screen)

### TimerCard
Used for timed exercises (e.g., Planks).
*   **Role:** Active guidance for timed movements.
*   **Fields:**
    - The exercise name.
    - Instructions on how to perform the movement.
    - A suggested duration in seconds.
    - The actual duration performed by the user.
    - Status indicating if the exercise is completed.
    - An action to trigger when the exercise is finished.

### RepsCard
Used for exercises involving repetitions (e.g., Pushups).
*   **Role:** Active guidance for repetition-based movements.
*   **Fields:**
    - The exercise name.
    - Instructions on how to perform the movement.
    - The target number of repetitions.
    - The actual number of repetitions performed by the user.
    - Status indicating if the exercise is completed.
    - An action to trigger when the exercise is finished.

### SessionSummary
A pinned dashboard tracking overall session progress.
*   **Role:** Ever-present at the top of the workout screen.
*   **Fields:**
    - The total number of exercises in the session.
    - The number of exercises remaining to be completed.
    - The total time elapsed during the exercise session.

---

## 3. Reporting (Report Screen)

### Bar Chart
*   **Fields:**
    - A title and optional description.
    - Label for the X axis
    - Label for the Y axis
    - A series of labeled amounts to be displayed as bars.

### Line Graph
*   **Fields:**
    - A title and optional description.
    - Label for the X axis
    - Label for the Y axis
    - A series of data points to be connected by a line.

### Summary Card
*   **Fields:**
    - A title.
    - Markdown-formatted text summary.
