# Offline Lesson

## Motivation

The server may be unreachable during a lesson (network issues, server downtime). Since an on-prem Raspberry Pi (RPi) is already present in the classroom for Zigbee2MQTT, the lesson UI can connect directly to the RPi for button events and run fully client-side. This makes lessons reliable regardless of server availability.

## Architecture Overview

```
RPi (Zigbee2MQTT)  <--WebSocket-->  Browser (Svelte app)
                                        |
                                        | best-effort sync via Phoenix channel
                                        v
                                    Server (PostgreSQL)
```

During the lesson (started → roll_call → active ↔ question → ended), the entire UI runs as a **standalone Svelte app** in the browser. No server connection is required. State lives in localStorage.

When the lesson ends, the collected data is submitted to the server. Grading (ended → graded) happens server-side via the normal LiveView UI.

## Lesson Lifecycle

### 1. Setup (server-driven)

The lesson creation form is a normal LiveView page. Teacher picks subject, seating plan, room (same as today). On submit, instead of creating a lesson record, the server renders a page that boots the Svelte app with embedded JSON config:

```json
{
  "subject": { "id": "...", "name": "Mathe" },
  "seatingPlan": { "id": "...", "name": "...", "width": 5, "height": 4 },
  "room": { "id": "..." },
  "name": "7a Mathe 21.02.",
  "students": [
    { "id": "...", "name": "Max Müller", "x": 1, "y": 2 }
  ],
  "buttonMapping": {
    "button-uuid-1": "student-uuid-1",
    "button-uuid-2": "student-uuid-2"
  },
  "rpiWebSocketUrl": "ws://rpi.local:8080/ws"
}
```

The server pre-computes the button mapping (joining room seats + seating plan seats) and embeds it, so the Svelte app needs no DB access.

### 2. Lesson Execution (client-side Svelte app)

The Svelte app manages the full lesson state machine: started → roll_call → active ↔ question → ended. Same states and transitions as described in [lesson-flow.md](lesson-flow.md), but all running in the browser.

#### Client-Side State

```js
{
  config: { subject, seatingPlan, room, name },
  state: "roll_call",
  students: {
    [studentId]: { name, x, y, present: false, extraPoints: 0 }
  },
  buttonMapping: { [buttonId]: studentId },
  questions: [
    { id: "q1", name: "Frage 1", points: 1, answers: ["student-uuid-1", ...] }
  ],
  currentQuestion: null,  // id of active question, or null
  bonusGrades: [
    { studentId: "...", name: "Tolle Mitarbeit", percent: 0.85 }
  ]
}
```

State is persisted to **localStorage** on every change. If the browser crashes or is accidentally closed, the lesson can be resumed from localStorage.

#### Button Events

The Svelte app connects to the RPi via **WebSocket**. When a button press arrives:
1. Look up `buttonId` in `buttonMapping` → `studentId`
2. If in roll_call: mark student as present
3. If in question: add student to current question's answers (if not already answered)
4. Update the seating grid reactively

Unknown button IDs are ignored (student not in this lesson's seating plan).

#### Keyboard Fallback

Same as today: a hidden element captures keyboard key presses. Each key generates a deterministic button ID (scoped per user). This allows development/testing without hardware.

### 3. Best-Effort Server Sync

While the lesson runs, the app **optionally** maintains a Phoenix channel connection. On every state change, it pushes the full lesson state as a JSON blob to the server. The server stores it in a `pending_lessons` table:

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | FK -> User | Owning teacher |
| `config` | JSONB | Subject, seating plan, room, name |
| `data` | JSONB | Full lesson state (students, questions, answers, points) |
| `status` | enum | `active`, `submitted` |
| `inserted_at` | datetime | |
| `updated_at` | datetime | |

This is a safety net — if the browser crashes and localStorage is lost, the last synced state can be recovered.

The sync is fire-and-forget. If the server is unreachable, the app continues without issue.

### 4. Submission (client → server)

When the teacher clicks "End Lesson" (state → ended), the Svelte app submits the full lesson data to the server via HTTP POST. The server:

1. Creates the `Lesson` record (state: `ended`)
2. Creates `LessonStudent` records for all present students (with `extra_points`)
3. Creates `Question` records (state: `ended`)
4. Creates `QuestionAnswer` records
5. Creates any `BonusGrade` records
6. Marks the `pending_lessons` row as `submitted` (if one exists)
7. All in a single database transaction

On success, the browser redirects to the normal LiveView grading page (`/lessons/:id/ended`).

On failure (server unreachable), the data stays in localStorage. The teacher can retry later, or the data can be recovered from the `pending_lessons` table.

### 5. Grading (server-driven)

From this point, everything is the normal LiveView flow: grading sliders, grade preview, save grades, overall grade recalculation. No changes needed.

## RPi WebSocket API

The RPi exposes a WebSocket endpoint that streams button press events:

```json
{ "type": "button_press", "buttonId": "uuid", "timestamp": "..." }
```

The RPi also provides gateway status:

```json
{ "type": "gateway_status", "gatewayId": "uuid", "online": true }
```

The exact RPi-side implementation (how it bridges Zigbee2MQTT to WebSocket) is out of scope for this spec.

## Svelte App Structure

One Svelte entry point, compiled to a single JS bundle via Vite (or esbuild + svelte plugin).

```
assets/
  svelte/
    OfflineLesson.svelte       -- root component, state machine, localStorage persistence
    components/
      SeatingGrid.svelte       -- reactive grid, same layout as LiveView version
      LessonControls.svelte    -- state transition buttons, question options
      QuestionPanel.svelte     -- active question display, answer tracking
      WheelOfFortune.svelte    -- random student selection animation
    lib/
      rpiSocket.js             -- WebSocket connection to RPi
      serverSync.js            -- Phoenix channel best-effort sync
      buttonMapping.js         -- buttonId → studentId lookup
      storage.js               -- localStorage read/write
```

The Svelte app is mounted into a server-rendered page that provides the config JSON:

```html
<!-- Rendered by Phoenix (dead view or minimal LiveView) -->
<div id="offline-lesson" data-config="<%= Jason.encode!(@config) %>"></div>
<script src="/assets/offline-lesson.js"></script>
```

## Recovery Scenarios

| Scenario | Recovery |
|----------|----------|
| Browser tab closed mid-lesson | Reopen the offline lesson URL → app restores from localStorage |
| Browser crash | Same as above |
| localStorage cleared | If server sync was active, recover from `pending_lessons` table |
| Server unreachable at submission | Data stays in localStorage, teacher retries later |
| RPi WebSocket drops | App shows connection warning, auto-reconnects. Lesson state is unaffected (just no new button events until reconnected) |

## What Changes vs. Current Architecture

| Aspect | Current | Offline Lesson |
|--------|---------|----------------|
| Lesson state machine | Server-side (Ecto + GenServers) | Client-side (Svelte) |
| Button events | MQTT → server → PubSub → LiveView | RPi WebSocket → Svelte directly |
| State persistence | PostgreSQL | localStorage + best-effort server sync |
| Roll call / question UI | LiveView (server-rendered) | Svelte (client-rendered) |
| Grading | LiveView | LiveView (unchanged) |
| Lesson creation | LiveView | LiveView (unchanged) |
| Everything else | LiveView | LiveView (unchanged) |
