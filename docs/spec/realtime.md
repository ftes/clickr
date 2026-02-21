# Real-Time Behavior

## Requirements

The following interactions must update the UI in real-time (without page reload):

### During Roll Call
- When a student presses their button, their seat immediately turns green on the teacher's screen.

### During a Question
- When a student presses their button to answer, the teacher's screen immediately reflects the new answer.
- When a student is manually added to the lesson, the grid updates.

### Room Button Assignment
- When the teacher is assigning buttons to room seats (in "awaiting click" mode), the next button press should immediately assign to the selected seat.
- Any button press in the room should briefly flash the corresponding cell (visual feedback).

### Gateway Status
- Gateway online/offline status changes should update the indicator in the top bar across all pages.

## Event Flow

### Button press -> student action
1. A physical button press (or keyboard key) produces a button click event with a `button_id`.
2. The system maps `button_id` to a `student_id` using the button mapping (room seats + seating plan seats).
3. Depending on lesson state:
   - **Roll call**: creates an attendance record (LessonStudent)
   - **Question**: creates an answer record (QuestionAnswer)
4. The teacher's UI updates in real-time.

### Gateway lifecycle
1. When a Zigbee2MQTT gateway comes online, it's marked as online in the database and the UI updates.
2. The system periodically health-checks gateways. If a gateway stops responding (configurable timeout, default 10s), it's marked offline.
3. When the MQTT connection drops, all gateways are marked offline.

> **Reference (current implementation):** Uses Phoenix PubSub for in-process event broadcasting, OTP GenServers (one per active roll call, one per active question, one per online gateway) managed via Registry + DynamicSupervisor. The MQTT client is Tortoise311. These are reasonable choices for Elixir but not the only way to implement the behavior.
