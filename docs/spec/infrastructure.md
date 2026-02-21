# Infrastructure

## Tech Stack

- **Language**: Elixir
- **Framework**: Phoenix with LiveView (server-rendered real-time UI)
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS
- **JS**: Alpine.js (for drag-and-drop and mobile menu)
- **Locale**: German (all UI labels, grade formatting)
- **Icons**: Heroicons

## ID Strategy

All database tables use UUID primary keys. Device/button IDs are deterministic (derived from hardware identifiers), ensuring stable mappings across system restarts.

## Environment Variables (Production)

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string |
| `SECRET_KEY_BASE` | Application secret (min 64 bytes) |
| `PHX_HOST` | Public hostname |
| `MQTT_HOST` | MQTT broker hostname |
| `MQTT_PORT` | MQTT broker port |
| `MQTT_USER` | MQTT username |
| `MQTT_PASSWORD` | MQTT password (presence enables MQTT) |
| `MQTT_CLIENT_ID` | MQTT client identifier |

> **Reference (current implementation):** Deployed on Fly.io. Uses Tortoise311 for MQTT, Bodyguard for authorization, Boundary for compile-time context boundaries, bcrypt_elixir for password hashing, Swoosh for email, AppSignal for monitoring. The supervision tree includes a Zigbee2Mqtt.Supervisor (with per-gateway GenServers via Registry + DynamicSupervisor) and a Lessons.Supervisor (with ActiveRollCall and ActiveQuestion GenServers, also via Registry + DynamicSupervisor).
