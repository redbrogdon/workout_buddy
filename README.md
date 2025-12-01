# Workout Buddy

## Overview
**Workout Buddy** is a next-generation fitness application that uses advanced AI to serve as a true training partner. Unlike traditional apps that rely on static, pre-written plans, Workout Buddy uses a generative "Agent" to architect, guide, and analyze your workouts in real-time.

The application adapts to you, negotiating the plan based on how you feel today, and managing the flow of the workout dynamically.

## The "Buddy" Philosophy
The core philosophy of the app is that of a knowledgeable, adaptive personal trainer.

* **It Negotiates:** It doesn't just dictate a plan; it asks about your energy levels and time constraints, then allows you to haggle over specific exercises.
* **It Guides:** It handles the pacing, counting, and instruction during the workout, changing the screen to match the exercise.
* **It Remembers:** It tracks not just your stats (reps/weight), but your *feelings* and *preferences* (e.g., "User hates burpees because of wrist pain").

---

## How It Works: The Three Modes
The application is designed around three distinct phases of a workout session. The Agent manages the transition between these modes.

### 1. Plan Mode (The Negotiation)
**Goal:** Create a tailored workout for the current moment.

* **Intake:** Upon launch, the Agent presents a quick "Intake Wizard" to gather your immediate context (e.g., "15 Minutes," "Low Energy," "Upper Body Focus").
* **Proposal:** The Agent generates a visual list of exercises proposed for the session.
* **Interaction:** This is an interactive process. You can manually swipe to delete or tap to swap exercises. Alternatively, you can chat with the Agent (e.g., "Swap the pushups for something easier"), and the plan will update instantly.
* **Start:** Once you are satisfied with the routine, you tap "Start Workout" to lock the plan.

### 2. Execution Mode (The Workout)
**Goal:** Complete the workout with real-time guidance.

* **Main Stage (Center Screen):** This area changes dynamically based on what you are doing:
    * *Instruction:* Shows video loops and form cues.
    * *Action:* Displays large timers for static holds (like Planks) or rep counters for dynamic moves.
    * *Feedback:* Occasionally asks "How was that set?" to adjust the intensity of the rest of the workout on the fly.
* **Session Dashboard (Bottom):** A persistent bar stays on screen to show your overall progress (e.g., "Exercise 3 of 8" and "Total Time Elapsed").
* **The Coach:** The Agent can provide encouragement and tips via unobtrusive messages without interrupting the flow.

### 3. Report Mode (The Analysis)
**Goal:** Review performance and track long-term trends.

* **Recap:** Immediately after finishing, you see a summary receipt of your volume and time.