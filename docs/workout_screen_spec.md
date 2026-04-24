# Plan Screen Specification

## Overview
This document contains information about the Plan screen of **Workout Buddy**. In particular it contains information about the Plan screen's responsibilities, the agent that drives it, and the UI components it uses.

## Plan Screen Agent
The agent is an expert physical trainer, able to converse with the user and use tools to create an ideal workout plan to be executed immediately in the Workout screen.

### Goal
The goal for the agent is to produce a workout plan that is accepted by the user.

### Tools
The agent should have access to tools that allow it to:

* Get the user's current location
* Get the current weather
* Examine previous workout data stored on the device

### Process
The agent should start by asking the user some questions about how they are feeling, what their goals are, and what equipment they have available. It should then use its tools to gather information and create the first draft of a workout plan that is tailored to the user's needs and present it to the user.

After that, the agent and the user are in a human-in-the-loop negotiation. The user should be able to:

* Accept the current draft workout plan.
* Request changes (either through chat messages or by interacting with the UI elements presenting the workout plan), after which the agent will produce a new draft workout plan to replace the previous one.

## UI Components (the catalog of components the agent can use)
The agent should have access to the `genui` package's Basic Catalog and the following custom components:

* `WorkoutPlanCard` - Displays a draft workout plan and includes a button to start the workout.
* `ExerciseTile` - Displays a single exercise in the workout plan, including its name, number of sets, and number of repetitions or time. It should offer controls for the user to quickly swap the exercise for another one, or to delete it.

The agent should only ever display one `WorkoutPlanCard` at a time. When the agent modifies the draft workout plan, it should update the data model for the existing WorkoutPlanCard rather than create a second one.
