# Alfred 1.0 Agent Instructions

## Overview
Alfred 1.0 is a simple habit tracker app built with Flutter. The app allows users to:
- Add new habits by name
- View a list of all habits
- Check or uncheck (undo) a habit for the present day
- See a streak count for each habit (increments when checked, decrements when unchecked, never below zero)
- View a streak dashboard at the top of the app, showing each habit's name and current streak

## Technical Details
- Flutter/Dart frontend
- No persistent storage or backend in 1.0
- All state is in-memory and resets on app restart

## Features
- Colorful, comfy UI
- Centered app bar title
- Streak dashboard below the title
- Each habit can be checked/unchecked for today only
- Streaks are displayed and updated live

## Out of Scope
- No authentication
- No database or Supabase integration
- No todo app functionality

---
For future versions, consider adding persistent storage, authentication, and analytics.
