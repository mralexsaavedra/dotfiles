---
name: vacaciones
description: "Trigger: /vacaciones, 'me han aprobado las vacaciones', 'apunta mis vacaciones', PTO approved in Factorial. After Factorial approves time off: add the PTO to the Styling Team Holidays Google Calendar and announce it in #sty-sp-vip."
metadata:
  author: mralexsaavedra
  version: "1.0"
---

## When to Use

The user's time off is already **approved in Factorial** (they request it there themselves and get an approval email) and they want it registered for the team. Factorial has no connector: never try to request or approve time off.

## Fixed data

| Item | Value |
| --- | --- |
| Calendar | Styling Team Holidays — `lookiero.com_mtvmg5rdhthag8cap3huusopjk@group.calendar.google.com` (Google Calendar connector, the user is `writer`) |
| Event title | `Alexander PTO`, plus a short reason in parentheses only if the user gives one (`Alexander PTO (Semana Santa)`) |
| Event shape | One all-day event per continuous range, `availability: AVAILABILITY_FREE` (never blocks anyone), `eventType: DEFAULT` |
| Slack channel | `#sty-sp-vip` (`G01H25PFM5Y`) |

All-day end dates are exclusive: 10–11 Nov → `startTime 2026-11-10T00:00:00`, `endTime 2026-11-12T00:00:00`, `allDay: true`.

## Flow

1. **Dates.** Take them from the request or from the pasted Factorial approval email. Accept "del 22/12 al 2/1", single days, or several ranges. Ambiguous year or range → ask once.
2. **Check overlaps.** `list_events` on the calendar for those dates with `fullText: "Alexander"`. Same range already there → report it and skip creation. Partial overlap → show it and ask.
3. **Show the plan and wait for an explicit yes:**
   - each event: title, first and last day (inclusive, weekday + date);
   - the Slack message, by default:

     ```text
     :palm_tree: Vacaciones aprobadas: del lun 22/12 al vie 02/01, ambos incluidos. Ya está en Styling Team Holidays.
     ```

     One day: `:palm_tree: El mar 10/11 estaré de vacaciones. Ya está en Styling Team Holidays.` Adapt the wording if the user asks.
4. **Create** each event with `create_event` (fields above). Read it back and report its link.
5. **Post** the message in `#sty-sp-vip` with `slack_send_message` only after the yes in step 3.
6. **Report:** events created (links), Slack message link, anything skipped.

## Rules

- Never create, edit or delete events in other calendars, and never touch other people's PTO events.
- Cancelling or changing approved days: find the event with `list_events`, show the change, and update or delete only after a yes; offer a follow-up message in `#sty-sp-vip`.
- Connector missing (Google Calendar or Slack) → say so and tell the user to connect it with `/mcp`; do not improvise.
