# Workout Buddy Architecture

## Overview
This document contains information about the technical architecture of **Workout Buddy**. In particular it contains information about dependencies to be included (or not included), patterns to be followed (or not followed), and other architectural decisions that should be made.

## Overall architecture
**Workout Buddy** is a Flutter application that uses an agent hosted on Firebase AI Logic as its backend. Its most important other dependency is Google's `genui` package for Flutter and Dart, which gives the agent a catalog of UI components it can use to build the user interface.

The three screens of the application are:

1. Plan
2. Workout
3. Report

All of these should be driven by the agent, with the agent responsible for maintaining the application's data state (using `genui`'s Data Model), and for choosing which UI components are rendered at any given time to display that data.

## The Agent
Each of the app's three screens should use a separate "instance" of the agent with its own state, system instruction, history, and so on. This is to narrow the scope of the agent to make it more likely to succeed and to make it easier to test.

Tools should be given to the agent so that it can take advantage of device capabilities, though only insofar as needed to accomplish the agent's goal. For example, all of the agents should have access to local storage to read and record data about workouts the user performs, but only the planning agent should have access to the device's location (which could be used to get a weather report and determine how current temperatures might affect the user's desired workout plan).

## Dependencies
The app should try to minimize the number of packages it depends on by using vanilla Flutter widgets and Dart APIs wherever possible. For example, the app should use Flutter's built-in HTTP client to make network requests.

For state management, Riverpod is the preferred solution. No code generation like `freezed` is needed, however, and should be avoided.

### Data Model
A workout plan is composed of:

* A name
* A list of one or more exercises

An exercise is composed of:

* A name
* A description of how to perform the exercise
* A number of sets
* A number of repetitions or an amount of time for which to perform the exercise (e.g. reps for push-ups or seconds for planks)

## Testing
The app should be constructed in such a way that it is easy to test. Each screen should be testable in isolation, and the agents should be testable in isolation.

## The UI
The app is composed of three screens, and the user can switch between them using a navigation bar at the bottom of the screen. The navigation bar should always be visible, with UI components from the agent appearing above. 

The Plan screen should be the default screen when the app is launched.

Unless otherwise specified, the main content region of the screen (above the navigation bar) should scroll vertically to allow for more content that can be viewed at one time.
