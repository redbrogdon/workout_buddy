[Back to Application Specification](application_spec.md) | [Back to Architecture Documentation](architecture.md)

# Workout Screen Specification

## Overview
This document contains information about the Workout screen of **Workout Buddy**. In particular it contains information about the Workout screen's responsibilities, the agent that drives it, and the UI components it uses.

## Workout Screen Agent
The agent is a dynamic orchestrator and guide, responsible for leading the user through their workout plan, handling mid-session adjustments, and capturing performance data.

### Goal
The goal for the agent is to guide the user through the accepted workout plan, allowing for real-time modifications and recording the actual effort (reps/time) performed for each exercise to local storage.

### Tools
The agent should have access to tools that allow it to:

* Record workout performance data to local storage.

### Process
The agent should present the first exercise in the plan and then wait for the user to indicate they have completed it before moving to the next. While this is happening, the agent should display the SessionSummary component to show the user's progress through the workout plan. Once the entire workout plan is complete, the agent should congratulate the user and then suggest they navigate to the Report screen.

The agent should manage the "Instruction vs. Action" flow by allowing the user to toggle detailed exercise descriptions. This can be done via chat (e.g., "How do I do this?") or by the user interacting with UI triggers like a chevron.

If the user requests changes to the plan mid-workout (e.g., "Skip the next one" or "Replace pushups with something easier"), the agent should negotiate and update the remaining workout plan accordingly. This is done by **updating the existing UI components in-place** using their unique identifiers, rather than adding new ones to the conversation history.

Once the final exercise is completed, the agent should summarize the session and ensure all data is correctly recorded for later analysis.

## UI Components (the catalog of components the agent can use)
See [Catalog Schemas](catalog_schemas.md) for technical definitions of these components.

The agent should have access to the `genui` package's Basic Catalog and the following custom components:

* `TimerCard` - Used for timed exercises (e.g., Planks). Includes a client-side timer, an expandable description section for form cues, and controls to adjust the final recorded time.
* `RepsCard` - Used for exercises involving repetitions. Includes an expandable description section and input fields for the user to report the actual number of repetitions/sets performed.
* `SessionSummary` - A persistent dashboard component that tracks overall progress (e.g., "Exercise 2 of 10") and total elapsed session time.

In general, the composition of the UI should be:

* A pinned, everpresent `SessionSummary` at the top of the screen.
* One or more exercise cards (`TimerCard`, `RepsCard`, etc.) that the user can scroll through. New cards should appear only when the user progresses to that exercise in the workout plan.
* A persistent "Chat Input Bar" consisting of a text field and a "send" button. The agent responds to user messages by updating the onscreen components in real-time; **there is no chronological message history** on this screen. 
* A navigation bar at the bottom of the screen for switching between the Plan, Workout, and Report screens. This should be the same navigation bar as the Plan annd Report screens.
