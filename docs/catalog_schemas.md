[Back to Application Specification](application_spec.md)

# GenUI Catalog Schemas

This document describes the data required for each custom UI component available to the Agent.

---

## 1. Workout Planning (Plan Screen)

### WorkoutCard
Displays the overall draft workout plan.
*   **Role:** High-level summary of the session.
*   **Fields:**
    - `title` (string): The title of the workout session.
    - `exercises` (list of strings): A list of 3-5 exercise names/descriptions to perform.

### ExerciseTile
An interactive tile for individual exercises during negotiation.
*   **Role:** Allows the user to modify the plan at a granular level.
*   **Fields:**
    - `name` (string): The name of the exercise.
    - `sets` (optional integer): Number of sets.
    - `repetitions` (optional integer): Number of reps per set.
    - `duration` (optional integer): Duration in seconds (for timed exercises).
    - `deleteAction` (optional action): Dispatched when the user wants to remove the exercise.
    - `replaceAction` (optional action): Dispatched when the user wants to swap the exercise.
    - `instructions` (optional string): Form tips or cues.

---

## 2. Active Workout (Workout Screen)

### TimerCard
Used for timed exercises (e.g., Planks).
*   **Role:** Active guidance for timed movements.
*   **Fields:**
    - `name` (string): The exercise name.
    - `instructions` (string): How to perform the movement.
    - `suggestedDuration` (integer): Target duration in seconds.
    - `actualDuration` (optional integer): Final duration performed by the user.
    - `isCompleted` (boolean): Whether the set is finished.
    - `onComplete` (action): Dispatched upon finishing the timer.

### RepsCard
Used for exercises involving repetitions (e.g., Pushups).
*   **Role:** Active guidance for repetition-based movements.
*   **Fields:**
    - `name` (string): The exercise name.
    - `instructions` (string): How to perform the movement.
    - `targetReps` (integer): Target number of repetitions.
    - `actualReps` (optional integer): Final number of reps performed by the user.
    - `isCompleted` (boolean): Whether the set is finished.
    - `onComplete` (action): Dispatched upon recording reps.

### SessionSummary
A pinned dashboard tracking overall session progress.
*   **Role:** Ever-present at the top of the workout screen.
*   **Fields:**
    - `totalExercises` (integer): The total number of exercises in the session.
    - `completedExercises` (integer): The number of exercises completed so far.
    - `elapsedSeconds` (integer): Total elapsed time in seconds.

---

## 3. Reporting (Report Screen)

### BarChart
A vertical bar chart for performance visualization.
*   **Fields:**
    - `title` (string): Title of the chart.
    - `description` (optional string): Context for the data.
    - `labels` (list of strings): Labels for each bar (e.g., days of the week).
    - `values` (list of numbers): Numeric values for each bar.

### LineGraph
A horizontal line chart for progress trends.
*   **Fields:**
    - `title` (string): Title of the graph.
    - `description` (optional string): Context for the data.
    - `xAxisLabel` (string): Label for time/session axis.
    - `yAxisLabel` (string): Label for value/volume axis.
    - `dataPoints` (list of numbers): Values to be connected by the line.

### SummaryCard
A text-based narrative card for reports.
*   **Fields:**
    - `title` (string): Title of the summary.
    - `content` (string): Markdown-formatted coaching insights or narrative.
