[Back to Application Specification](application_spec.md)

# GenUI Catalog Schemas

This document describes the data required for each custom UI component available to the Agent in the `workoutBuddyCatalog`.

---

## Workout Buddy Components

### AiCoachProposalCard
Displays the conversational proposal or introductory text from the AI coach during the planning phase.
*   **Role:** Introductory chat bubble from the AI.
*   **Fields:**
    - `proposal` (string): The conversational proposal or introductory text.

### WorkoutCard
Displays the overall draft workout plan during the planning phase.
*   **Role:** High-level summary of the session.
*   **Fields:**
    - `title` (string): The title of the workout session.
    - `description` (optional string): A brief overview or motivation for the workout.
    - `exercises` (list of strings): A list of 3-5 exercise names planned for the session.
    - `onStart` (optional action): Dispatched when the user chooses to begin the workout.

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

### TimerCard
Used for active guidance during timed exercises (e.g., Planks).
*   **Role:** Active guidance for timed movements.
*   **Fields:**
    - `exercise` (string): The exercise name.
    - `instructions` (string): How to perform the movement.
    - `suggestedDuration` (integer): Target duration in seconds.
    - `actualDuration` (optional integer): Final duration performed by the user.
    - `isCompleted` (boolean): Whether the set is finished.
    - `onComplete` (action): Dispatched upon finishing the timer.

### RepsCard
Used for active guidance during repetition-based exercises (e.g., Pushups).
*   **Role:** Active guidance for repetition-based movements.
*   **Fields:**
    - `exercise` (string): The exercise name.
    - `instructions` (string): How to perform the movement.
    - `numberOfReps` (integer): Target number of repetitions.
    - `repsCompleted` (optional integer): Final number of reps performed by the user.
    - `isCompleted` (boolean): Whether the set is finished.
    - `onComplete` (action): Dispatched upon recording reps.

### AdaptiveFeedbackCard
Displays an interactive UI to ask the user about the difficulty of the last exercise.
*   **Role:** Solicits qualitative feedback during execution.
*   **Fields:**
    - `exercise` (string): The exercise that just completed.
    - `onFeedback` (action): Dispatched when the user clicks a feedback button ("Too Easy", "Just Right", "Too Hard").

### SessionSummary
A dashboard tracking overall session progress.
*   **Role:** Pinned at the top of the workout screen during the execution phase.
*   **Fields:**
    - `totalExercises` (integer): The total number of exercises in the session.
    - `completedExercises` (integer): The number of exercises completed so far.
    - `elapsedSeconds` (integer): Total elapsed time in seconds.

### EstimatedCalories
Displays the estimated calories burned after the workout session is complete.
*   **Role:** Motivational summary widget.
*   **Fields:**
    - `calories` (integer): Estimated calories burned during the workout.

---

## Reporting Components

### LatestSessionCard
Summarizes the most recent workout session.
*   **Role:** Performance Dashboard.
*   **Fields:**
    - `title` (string): Title of the card.
    - `duration` (integer): Duration in minutes.
    - `calories` (integer): Calories burned.
    - `exercises` (integer): Number of exercises completed.

### StreakWidget
Displays the user's current workout streak.
*   **Role:** Performance Dashboard.
*   **Fields:**
    - `streakCount` (integer): Current day streak.

### RankingWidget
Displays a motivational percentile ranking.
*   **Role:** Performance Dashboard.
*   **Fields:**
    - `percentile` (integer): User percentile ranking.

### WeeklyCalendarWidget
Shows which days the user worked out this week.
*   **Role:** Performance Dashboard.
*   **Fields:**
    - `completedDays` (list of integers): Days completed (0=Mon, 6=Sun).

### ProgressChartWidget
Displays a line chart of recent progress (calories or duration).
*   **Role:** Performance Dashboard.
*   **Fields:**
    - `title` (string): Chart title.
    - `labels` (list of strings): X-axis labels.
    - `values` (list of numbers): Y-axis values.

### InsightAlertCard
Provides a coaching tip or recovery advice based on history.
*   **Role:** Performance Dashboard.
*   **Fields:**
    - `title` (string): Insight title.
    - `insight` (string): The advice content.
