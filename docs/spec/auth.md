# Authentication & Authorization

## Authentication

- Email + password login with "keep me logged in" option.
- Registration with live validation.
- Email confirmation (7-day token expiry).
- Password reset via email (1-day token expiry).
- Sessions valid for 60 days.
- LiveView pages check authentication on mount and redirect unauthenticated users to login.

## Authorization

### Data Scoping
Every query is automatically scoped by user:
- **Regular users (teachers)**: Only see their own data (filtered by `user_id`, directly or through parent chain).
- **Admin users**: See all data across all teachers.
- **System user**: Virtual user used by background processes (e.g., MQTT gateway) to perform device operations without a real user session. Same access as admin.

### Action Authorization
- Admins: all actions permitted.
- Regular users: permitted if they own the resource (matching `user_id`).
- Create actions: generally open (the `user_id` is set to the current user on creation).
- Special case: creating lesson students and question answers requires ownership of the parent lesson (verified via DB lookup).

## Impersonation

Admin-only feature for support/debugging:
- Admin can impersonate any teacher from the Users page.
- All subsequent requests run as the impersonated user (seeing only their data).
- A red "Stop impersonating" banner is shown in the top bar.
- Clearing impersonation returns to the admin's own session.

> **Reference (current implementation):** Uses `phx.gen.auth` pattern with bcrypt password hashing. Authorization via Bodyguard library (policy modules per context, `Bodyguard.Schema.scope/3` for data scoping). Impersonation stores `impersonated_user_id` in the session, checked in both Plug pipeline and LiveView `on_mount` hooks.
