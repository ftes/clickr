# Device Integration

## Button Press Pipeline

A physical button press (or keyboard key) must be translated into a student action:

1. A button press produces a `button_id` (a stable, deterministic identifier for that physical button).
2. The system maps `button_id` to a grid position `(x, y)` using the room's button assignments.
3. The system maps `(x, y)` to a `student_id` using the lesson's seating plan.
4. Depending on lesson state, the system creates the appropriate record (attendance or answer).

## Gateway Types

### Zigbee2MQTT
- Physical Zigbee buttons connect to a Zigbee2MQTT bridge.
- The bridge communicates with the app via an MQTT broker.
- Each gateway has online/offline status, tracked via periodic health checks (default timeout: 10s).
- When the MQTT connection drops, all gateways are marked offline.

### Keyboard
- Virtual gateway for development/testing or classrooms without physical hardware.
- A hidden element on lesson and room pages captures keyboard key presses.
- Each key generates a deterministic, stable button ID (same key always produces same ID, scoped per user).
- Keyboard button presses flow through the same pipeline as physical button presses.

## Stable Button IDs

Button identifiers must be **deterministic and stable** across system restarts. Pressing the same physical button (or keyboard key) must always produce the same `button_id`. This is what allows stable button-to-seat mappings in rooms.

## Button Mapping (Two-Layer Indirection)

The mapping from button press to student uses two grids:
1. **Room seats**: `button_id` -> `(x, y)` position
2. **Seating plan seats**: `(x, y)` position -> `student_id`

This indirection means different seating plans can reuse the same room (same physical buttons) with different student assignments.

## Room Button Assignment

The room detail page has a special interaction for mapping physical buttons to grid positions:
1. Teacher clicks an empty cell in the room grid -> cell turns green ("awaiting click").
2. Someone presses the physical button at that desk.
3. The system assigns that `button_id` to the `(x, y)` position.
4. Any button press in the room should briefly flash the corresponding cell (visual feedback).

## Device Sync

When a Zigbee2MQTT gateway reports its device list, the system:
1. Soft-deletes all existing devices for that gateway (`deleted = true`).
2. Upserts all reported devices (un-deletes if already known, creates if new).

This handles devices being added to or removed from the Zigbee network.

> **Reference (current implementation):** The MQTT client is Tortoise311 (SSL). MQTT topics follow the convention `clickr/gateways/<gateway_uuid>/...`. Per-gateway OTP GenServers manage lifecycle (start on first message, periodic health checks, timeout on silence). Device/button IDs use UUID v5 — e.g., `UUID.uuid5(device_type_uuid, ieee_address)` for Zigbee devices, `UUID.uuid5(keyboard_type_uuid, user_id)` for keyboard devices. Button click events are broadcast via Phoenix PubSub.
