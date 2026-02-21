# Clickr (Klassenknopf) - Application Specification

A classroom response system for teachers. Teachers run interactive lessons where students respond via physical Zigbee clicker buttons (or keyboard keys). The system tracks attendance, question responses, and calculates grades automatically.

**Locale:** German (UI labels, grade formatting)
**Branding:** "Klassenknopf" (classroom clicker)
**Stack:** Elixir, Phoenix LiveView, PostgreSQL, Zigbee2MQTT via MQTT

## Documentation Structure

| File | Contents |
|------|----------|
| [overview.md](overview.md) | Purpose, user roles, high-level workflow |
| [data-model.md](data-model.md) | All entities, fields, relationships, constraints |
| [lesson-flow.md](lesson-flow.md) | Lesson state machine, roll call, questions, grading |
| [devices.md](devices.md) | Hardware integration, button mapping, keyboard fallback |
| [grades.md](grades.md) | Grade calculation, German scale, bonus grades |
| [ui-pages.md](ui-pages.md) | Every page/route, what it shows, user actions |
| [realtime.md](realtime.md) | Real-time update requirements, event flows |
| [auth.md](auth.md) | Authentication, authorization, impersonation |
| [ui-patterns.md](ui-patterns.md) | Component design patterns (composition, data-slot, grid, touch targets) |
| [offline-lesson.md](offline-lesson.md) | Offline-capable lesson UI (Svelte), RPi direct connection, sync |
| [infrastructure.md](infrastructure.md) | Tech stack, ID strategy, configuration |
