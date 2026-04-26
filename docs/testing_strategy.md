[Back to Application Specification](application_spec.md)

# Testing Strategy

This document outlines the approach for verifying the deterministic components of the **Workout Buddy** application, specifically the data layer and the UI catalog.

---

## 1. Unit Testing (Data & Logic)
Unit tests focus on the integrity of the data models and the storage persistence logic.

### Data Models
*   **Serialization:** Verify that `WorkoutSessionRecord` and `ExerciseRecord` can be correctly serialized to and from JSON, including the unique session ID.
*   **Validation:** Test that models handle edge cases (missing timestamps, optional feedback) gracefully.

### Storage Service
*   **Upsert Logic:** Verify that `saveToHistory` correctly identifies existing sessions by ID and updates them instead of creating duplicates.
*   **Preference Management:** Test that the "User Preferences" string is correctly read and updated.

### Pure Logic
*   **Calculations:** Test logic used for reporting (e.g., aggregating volume or frequency for charts).

---

## 2. Widget Testing (GenUI Catalog)
Every component defined in the [Catalog Schemas](catalog_schemas.md) must have a dedicated widget test.

### `TimerCard` Tests
*   **Timer State:** Verify that start/pause/reset controls work as expected.
*   **Completion:** Ensure the completion callback passes the `actualDuration` correctly.

### `RepsCard` Tests
*   **Counters:** Verify that rep increment/decrement controls work correctly.
*   **Completion:** Ensure the checkmark button dispatches the callback with the final count.

### `WorkoutCard` / `ExerciseTile` Tests
*   **Layout:** Verify the card displays the proposed plan correctly.
*   **Actions:** Test that "Delete" or "Swap" on an `ExerciseTile` triggers the appropriate callbacks.

---

## 3. Integration Testing
Focus on the technical flow within and between screens.

### Unified Workout Flow
*   **Phase Transition:** Test that triggering "Start Workout" in Phase 1 causes the Agent to transition the UI to Phase 2 (Execution) while maintaining session state.
*   **Incremental History:** Verify that completing an exercise in Phase 2 results in an immediate, partial update to `workout_history.json`.

### Navigation
*   **Manual Tab Switching:** Verify that the user can move between Workout and Report screens via the bottom bar and that the Agent state for each screen is preserved.
