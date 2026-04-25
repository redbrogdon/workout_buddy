[Back to Application Specification](application_spec.md)

# Testing Strategy

This document outlines the approach for verifying the deterministic components of the **Workout Buddy** application, specifically the data layer and the UI catalog.

---

## 1. Unit Testing (Data & Logic)
Unit tests should focus on the integrity of the data models and the storage handoff logic.

### Data Models
*   **Serialization:** Verify that `WorkoutRecord` and `ExerciseRecord` can be correctly serialized to and from JSON.
*   **Validation:** Test that the models handle edge cases, such as missing timestamps or optional feedback strings, without crashing.

### Storage Service
*   **Handoff Logic:** Verify the service responsible for moving data from `current_session.json` to the long-term history files.
*   **Preference Management:** Test that the "User Preferences" string is correctly read and updated.

### Pure Logic
*   **Calculations:** Test any logic used to calculate "Success Rates" or "Total Volume" for the Report screen.

---

## 2. Widget Testing (GenUI Catalog)
Every component defined in the [Catalog Schemas](catalog_schemas.md) must have a dedicated widget test to ensure it behaves correctly for the Agent.

### `TimerCard` Tests
*   **Timer State:** Verify that tapping "Play" starts the incrementing timer and "Pause" stops it.
*   **Interactive Constraints:** Ensure the "Check" button correctly passes the `actualDuration` to the `completeAction` callback.
*   **Reset:** Verify the refresh button resets the local timer state to zero.

### `RepsCard` Tests
*   **Counters:** Verify the up/down arrows correctly modify the "Reps Completed" count.
*   **Completion:** Ensure the checkmark button dispatches the correct `UserActionEvent` with the final rep count.

### `WorkoutCard` / `ExerciseTile` Tests
*   **Layout:** Verify that the card displays the correct number of chips/tiles.
*   **Actions:** Test that tapping "Delete" or "Swap" on an `ExerciseTile` triggers the appropriate action callback.

---

## 3. Integration Testing
Focus on the technical "Bridge" between screens.

*   **Navigation & State:** Test that triggering a "Start Workout" action on the Plan screen results in the correct `current_session.json` being created and the app navigating to the Workout screen.
*   **Session Persistence:** Verify that if the app is closed and reopened during a workout, the Workout Agent can resume from the saved state in local storage.
