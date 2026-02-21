# Overview

## Purpose

Clickr is a classroom response system ("Klassenknopf") that lets teachers run interactive lessons with physical clicker hardware. Students sit at assigned seats in a classroom. Each seat has a physical Zigbee button. When a student presses their button, the system records their attendance or answer in real-time.

## User Roles

- **Teacher** (regular user): Manages their own classes, students, rooms, subjects, lessons, and grades. All data is scoped to the owning teacher.
- **Admin**: Can view all data across all teachers. Can impersonate other teachers (for support/debugging). Can see the Users list.
- **System user**: Virtual user used internally by MQTT gateway processes to perform device operations without a real user session.

## High-Level Workflow

### One-Time Setup
1. Create **classes** and add **students** to them
2. Create **subjects** (e.g., "Math", "English")
3. Create **rooms** with a grid layout (width x height) representing physical desk positions
4. Register **gateways** (Zigbee2MQTT bridges or keyboard)
5. In a room, **assign physical buttons to grid positions** by clicking each seat and pressing the button at that desk
6. Create **seating plans** linking a class to a room grid, assigning each student to an (x,y) position

### Per-Lesson Flow
1. **Create lesson**: Select subject, seating plan, and room. Name auto-generated.
2. **Roll call** (optional): System listens for button presses. Students press their buttons to register attendance. Or teacher clicks "All present".
3. **Active phase**: Teacher asks questions. Students press buttons to answer. Teacher sees real-time who answered on the seating grid. Teacher can use "wheel of fortune" to randomly select an answering student.
4. **End lesson**: Teacher sets grading parameters (min/max point thresholds on a slider). System calculates per-student grades using a linear scale.
5. **Grades**: Lesson grades and optional bonus grades are averaged into an overall per-subject grade for each student.

### Key Concept: Button Mapping

The system maps physical button presses to students through two layers:
- **Room**: maps button_id -> (x, y) grid position
- **Seating plan**: maps (x, y) grid position -> student_id

Combined: button press -> grid position -> student. This means different seating plans can reuse the same room (same physical buttons) with different student assignments.
