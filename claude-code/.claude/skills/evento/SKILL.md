---
name: evento
description: "Trigger: /evento, 'créame un evento', 'apúntame…', 'ponme en el calendario…', 'bloquéame…'. Create a calendar event from natural language in the right calendar: work (Google Calendar, a.saavedra@lookiero.com) or personal (Personal de Google via macOS Calendar)."
metadata:
  author: mralexsaavedra
  version: "1.0"
---

## When to Use

The user describes an event in plain words ("mañana a las 10 dentista 1h", "daily extra con Mikel el jueves 16:00", "el viernes todo el día mudanza"). For time off approved in Factorial use `vacaciones` instead.

## Calendars

| Kind | Calendar | How |
| --- | --- | --- |
| Work (default for meetings, teammates, tickets, reviews, demos, `LK-*`) | `a.saavedra@lookiero.com` (primary) | Google Calendar connector `create_event` |
| Personal (default for health, sport, errands, plans, family) | `Personal` with description `mralexsaavedra@gmail.com` | macOS Calendar via JXA (below) |
| Family (only when the user says "familia") | `Familia` (Google family group, two calendars share the name) | macOS Calendar via JXA; ask which one if both match |

Never write to `Styling Team Holidays`, `Festivos en España`, `Cumpleaños`, other people's calendars or iCloud calendars unless the user names them.

## Flow

1. **Parse** title, date, start, end or duration (default 30 min for work, 1 h for personal), all-day, people, place, Meet. Relative dates ("mañana", "el jueves") are from today in Europe/Madrid; a weekday means the next one. Missing time → ask once; never invent it.
2. **Classify** work vs personal with the table. Ambiguous ("comida con Beñat") → ask.
3. **Conflicts**: work → `list_events` on the primary for that window; personal → `icalBuddy -ea -nc -iep "datetime,title" -tf "%H:%M" -b "" eventsFrom:<YYYY-MM-DD> to:<YYYY-MM-DD>`. Report overlaps; do not block.
4. **Draft and wait for an explicit yes**:

   ```text
   📅 Personal · mar 03/11 10:00–11:00 · Dentista
   ```

   Work events also list attendees and Meet. Attendees only when the user named them; resolve emails as `<initial>.<surname>@lookiero.com` only after checking them with Slack `slack_search_users` (never guess an address).
5. **Create**:
   - Work: `create_event` with `summary`, `startTime`/`endTime` (local ISO, no offset), `allDay` when all-day (end date exclusive), `attendees`, `addGoogleMeetUrl` only if asked or there are attendees, `availability` busy. Read it back with `get_event` and give the link.
   - Personal/family: run JXA with `osascript -l JavaScript` (dates built with `new Date(y, m-1, d, h, min)`, locale-independent):

     ```javascript
     const C = Application("Calendar");
     const cal = C.calendars().filter(c => c.name() === "Personal" && c.description() === "mralexsaavedra@gmail.com")[0];
     const ev = C.Event({ summary: "Dentista", startDate: new Date(2026, 10, 3, 10, 0), endDate: new Date(2026, 10, 3, 11, 0) });
     // all-day: add alldayEvent: true, endDate = next day 00:00; optional: location, description
     cal.events.push(ev);
     ev.uid();
     ```

     Confirm it exists with the `icalBuddy` query from step 3.
6. **Report** calendar, final date and time, link (work) or uid (personal).

## Rules

- Never create, move or delete anything without the explicit yes in step 4.
- Changing or deleting an existing event: find it first (work: `list_events` with `fullText`; personal: `icalBuddy`), show it, and act only after a yes. Personal delete by uid (JXA): `cal.events.whose({ uid: "<uid>" })().forEach(e => C.delete(e))`, then check it is gone.
- Connector missing → say so and suggest `/mcp`; calendar not found by JXA → stop and report the calendars it sees.
