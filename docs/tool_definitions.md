[Back to Application Specification](application_spec.md)

# Agent Tool Definitions

This document defines the technical signatures for the tools available to the Workout Buddy agents. These tools allow the agents to interact with the device's sensors and local storage.

---

## 1. User Profile & Preferences

### `getPreferences()`
*   **Description:** Retrieves the natural language preference string for the current user.
*   **Returns:** A string containing fav/hated exercises, injuries, and personal vibe preferences.

### `updatePreferences(newPreferenceDescription)`
*   **Description:** Overwrites the current user preference string with a new description.
*   **Arguments:**
    - `newPreferenceDescription` (string): The updated profile.

---

## 2. Workout History (Storage)

### `queryWorkoutHistory(startDate?, endDate?, limit?)`
*   **Description:** Retrieves a high-level list of previous workout sessions.
*   **Arguments:**
    - `startDate` (string, ISO 8601): Filter sessions after this date.
    - `endDate` (string, ISO 8601): Filter sessions before this date.
    - `limit` (integer): Maximum number of results to return.
*   **Returns:** A list of session summaries containing:
    - `sessionId` (string)
    - `date` (string)
    - `title` (string)
    - `totalDurationSeconds` (integer)
    - `successRate` (number, 0-1)

### `getWorkoutDetails(sessionId)`
*   **Description:** Retrieves the full, exercise-level data for a specific previous session.
*   **Arguments:**
    - `sessionId` (string): The unique ID of the session.
*   **Returns:** The full Workout Session Record as defined in [data_schemas.md](data_schemas.md).

### `getExerciseTrends(exerciseName)`
*   **Description:** Helper tool to retrieve historical performance specifically for one exercise.
*   **Arguments:**
    - `exerciseName` (string): The name of the exercise (e.g., "Pushups").
*   **Returns:** A list of data points containing `date`, `reps`, `weight`, and `duration`.

---

## 3. Environment & Location

### `getLocation()`
*   **Description:** Retrieves the user's current GPS coordinates and city name.
*   **Returns:**
    - `latitude`, `longitude`, `city`, `state/country`.

### `getWeather(location?)`
*   **Description:** Retrieves the current weather forecast.
*   **Arguments:**
    - `location` (optional): If not provided, uses the user's current location.
*   **Returns:**
    - `temperature` (celsius)
    - `condition` (e.g., "Rainy", "Sunny", "Hot")
    - `recommendation` (e.g., "Good for outdoor run" or "Better for indoor weights")

---

## 4. Active Session Recording

### `recordWorkout(sessionData)`
*   **Description:** Saves a finalized workout session to the device's history.
*   **Arguments:**
    - `sessionData`: The complete record defined in [data_schemas.md](data_schemas.md).
