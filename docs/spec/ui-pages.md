# UI Pages

All UI is in German. German labels are shown in [brackets] below.

## Layout

The overall layout (navigation, page chrome, tables) is **not prescribed** — use whatever is simplest to implement. The only requirements are:

- Navigation links to: Stunden [Lessons], Noten [Grades], Klassen [Classes], Sitzpläne [Seating Plans], Räume [Rooms], Fächer [Subjects], Gateways, Users [admin only]
- Gateway status indicator somewhere visible (online count, e.g., "N Gateways verbunden")
- Impersonation banner when active
- Flash messages for success/error feedback
- German locale throughout

## German State Labels

| State | German |
|-------|--------|
| started | Gestartet |
| roll_call | Anwesenheit |
| active | Läuft |
| question | Frage |
| ended | Beendet |
| graded | Benotet |

## Authentication Pages

Standard auth pages: login, register, password reset, email confirmation, settings. No special requirements beyond what `phx.gen.auth` (or equivalent) provides.

## Lessons

### List + Creation

| Route | Description |
|-------|-------------|
| `/lessons` | Filterable/sortable table. Filter by: name (text), class (select), subject (select), state (select). Sort by: name, state, inserted_at (default desc). Actions per row: "Durchführen" [Conduct], "Löschen" [Delete]. |
| `/lessons/new` | Form: subject, seating plan, room, name. "Recent combinations" quick-create buttons (last 15 unique combos). |

### Lesson Conduct Pages (keep close to existing layout)

The lesson conduct UI is the core of the app. The seating grid layout, student cell content, and action buttons should stay close to the current design.

![Lesson Active](screenshots/lesson-active.png)
*Active lesson: seating grid with student names and point totals. Action bar at top right: "Punkt für alle", "Stunde beenden", "Frage stellen", gear icon for question options. Absent students shown in lighter text. Grid matches the room's physical layout (8 columns x 4 rows).*

| Route | State | Description |
|-------|-------|-------------|
| `/lessons/:id/started` | started | Seating grid. Actions: "Anwesenheit abfragen" [Roll Call], "Alle anwesend" [All present] |
| `/lessons/:id/roll_call` | roll_call | Seating grid with real-time attendance highlighting (green). Actions: "Anwesenheit eintragen" [Note Attendance] |
| `/lessons/:id/active` | active | Seating grid with points per student. Per-student hover: register answer, +/- points, remove, add bonus grade. Top actions: "Schüler auswählen" [Select answer] (wheel of fortune), "Punkt für alle" [Add point for all], "Stunde beenden" [End Lesson], "Frage stellen" [Ask Question], "Frage Optionen" [Question Options] |
| `/lessons/:id/question` | question | Same as active but question is live. Per-student answers shown. Actions: "Frage beenden" [End Question] |
| `/lessons/:id/ended` | ended | Seating grid with points + German grade preview. Grading sliders (Minimum/Maximum). Action: "Benoten" [Grade] |
| `/lessons/:id/graded` | graded | Same as ended with finalized grades + overall grade %. Each student shows: points, German grade, subject %. Action: "Benoten" [Re-grade, with confirmation] |

![Lesson Ended/Graded](screenshots/lesson-ended.png)
*Ended/graded lesson: two range sliders (Minimum/Maximum) at top, seating grid below. Each cell shows student name, point total, and German grade preview (e.g., "17 2+"). Grade updates live as sliders move. After grading, each cell additionally shows the cumulative subject grade percentage (e.g., "17 1- 94%").*

## CRUD Pages (use whatever is simplest)

These are standard CRUD pages. Use the simplest approach (tables, forms, modals — whatever the framework provides). The important thing is the data and actions, not the layout.

### Classes
- List with name filter. CRUD.
- Detail: students table + bulk add (names, one per line). Edit/delete individual students.

### Seating Plans
- List. CRUD (name, class, width, height).
- Detail: interactive grid. Drag-and-drop students from "unseated" list to grid cells. Move or unseat (X button per cell).

![Seating Plan](screenshots/seating-plan.png)
*Seating plan editor: metadata at top (name, width/height, class), then the same CSS grid layout as the lesson pages. Occupied cells show student name + X to unseat. Empty cells are drag targets. Unseated students listed below the grid.*

### Rooms
- List. CRUD (name, width, height).
- Detail: interactive grid for button assignment. Click cell → press physical button → assigns to position. Visual feedback on button press.

![Room](screenshots/room.png)
*Room button assignment: same grid layout. Each cell shows the assigned device/button name (truncated). X to remove assignment. Empty cells can be clicked to enter "awaiting click" mode.*

### Gateways
- List with online/offline status indicator. CRUD (name, URL, type).
- Detail: name, URL, type, connected status.

### Subjects
- List. CRUD (name only).

### Grades
- Filterable/sortable table. Filter: student name, class, subject. Shows German grade.
- Detail: student, subject, overall grade (German + %). Tables of lesson grades and bonus grades. Delete bonus grades. Add bonus grade (name, percent slider).
- Also accessible by student+subject IDs.

### Users (Admin)
- Table of all users. "Impersonate" action per user.

## Shared UI Components

- **Seating grid**: CSS grid. Used in lesson conduct pages, seating plan management, and room button assignment. Cells show student names, points, grades, hover actions depending on context. **This is the most important shared component — keep the layout close to the current design.**
- **Drag-and-drop**: Used in seating plan (assign students to seats) and room (assign buttons). Implementation approach is open.
- **Keyboard capture**: Hidden element with key listener. On lesson and room pages. Generates deterministic button IDs from key presses.
