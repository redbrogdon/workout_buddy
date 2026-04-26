[Back to Application Specification](application_spec.md)

# Agent Tool Definitions

This document defines the technical signatures for the tools available to the Workout Buddy agents. These tools allow the agents to interact with local storage to manage preferences and history.

---

## 1. User Profile & Preferences

### `readPreferences()`
*   **Description:** Retrieves the natural language preference description for the current user.
*   **Returns:** A JSON object containing the user's fitness profile (goals, injuries, favorite exercises, etc.).

---

## 2. Workout History

### `readHistory()`
*   **Description:** Retrieves the entire workout history log stored on the device.
*   **Returns:** A list of all previous `WorkoutSessionRecord` objects.

### `saveWorkoutSession(session)`
*   **Description:** Saves or updates a workout session in the history log. 
*   **Details:** To perform incremental updates (e.g., after every exercise), the Agent must provide a unique session `id`. If a record with that ID already exists, it will be overwritten with the new data; otherwise, a new record is created.
*   **Arguments:**
    - `session` (object): The full `WorkoutSessionRecord` data as defined in [data_schemas.md](data_schemas.md).

---

## 3. Note on Implementation
While the agents may express interest in external data (like weather or location), current version focus is on **Local Persistence** only. Future tools for environment sensing will be documented here once implemented.
