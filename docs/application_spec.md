# Workout Buddy

## Overview
**Workout Buddy** is a agentic fitness application that uses Generative AI and Generative UI. Unlike traditional apps that rely on static, pre-written plans, Workout Buddy uses a generative "Agent" to architect, guide, and analyze your workouts in real-time, and builds user interface components on the fly to guide you through planning, executing, and tracking your workouts.

The application adapts to you, negotiating the plan based on how you feel today, and managing the flow of the workout dynamically.

## Architecture
For information on technical architecture (dependencies, patterns, testing) see [Architecture Documentation](architecture.md).

## The "Buddy" Philosophy
The core philosophy of the app is that of a knowledgeable, adaptive personal trainer.

* **It Negotiates:** It doesn't just dictate a plan; it asks about your energy levels and time constraints, then allows you to haggle over specific exercises.
* **It Guides:** It handles the pacing, counting, and instruction during the workout, changing the screen to match the exercise.
* **It Remembers:** It tracks not just your stats (reps/weight), but your *feelings* and *preferences* (e.g., "User hates burpees because of wrist pain").

---

## How It Works: The Two Modes
The application is designed around two distinct phases of a workout session. The user manages the transition between these modes, which are represented by an ever-present navigation bar at the bottom of the screen. Agent state is maintained regardless of which mode the user is in.

### 1. [Workout Mode](workout_screen_spec.md)
**Goal:** Design and execute a tailored workout for the current moment.

* **Phase A: Planning & Negotiation:**
    * **Intake:** Upon launch, the Agent starts a conversation to determine your goals and constraints. It might ask about your overall energy level, how much time and space is available, and whether you're experiencing any soreness or injuries.
    * **Proposal:** The Agent generates a visual list of exercises proposed for the session.
    * **Iteration:** You can suggest changes to the workout, either by manually deleting or swapping exercises, or by chatting with the Agent (e.g., "Swap the pushups for something easier"). The plan will update in response.
    * **Start:** Once you are satisfied with the routine, you tap "Start Workout" to begin the tracking phase within the same screen.

* **Phase B: Execution & Tracking:**
    * **Main Stage:** The screen transitions to focus on the active exercise:
        * *Instruction:** Shows instructions for how to complete exercises.
        * *Action:** Displays large timers for static holds (like Planks) or rep counters for dynamic moves. You can use controls to indicate the number of reps or time actually performed.
        * *Feedback:** Occasionally asks "How was that set?" to adjust the intensity of the rest of the workout on the fly.
    * **Session Dashboard:** A persistent summary stays on screen to show your overall progress (e.g., "Exercise 3 of 8" and "Total Time Elapsed").
    * **Finalization:** As the user progresses through the workout, the Agent updates the session record with information about the user's performance on each exercise (e.g. reps completed, etc.). When the user finishes the workout, the Agent will suggest navigating to the Report screen via the bottom navigation bar.

### 2. [Report Mode](report_screen_spec.md)
**Goal:** Review performance and track long-term trends.

* **Recap:** View summary receipts of volume and time from the latest session.
* **History:** The agent can display charts and graphs to show how your performance has changed over time.
