---
name: bandeja
description: "Trigger: /bandeja, 'qué tengo pendiente', 'ponme al día', 'revisa mis mensajes', 'qué me ha llegado'. Triage Slack, work Gmail and personal mail: show only what needs action, draft replies in the user's tone, and send nothing without an explicit yes."
metadata:
  author: mralexsaavedra
  version: "1.0"
---

## Sources

| Source | How | Account |
| --- | --- | --- |
| Slack | Slack connector | user `U035NGP2TDH` (lookierotech) |
| Work mail | Gmail connector **only** | `a.saavedra@lookiero.com` |
| Personal mail | macOS Mail via JXA | accounts `iCloud` and `Google` (`mralexsaavedra@gmail.com`) |

Never read the `a.saavedra@lookiero.com` account through macOS Mail: LOG policy is that customer/employee data only leaves through the approved connectors. WhatsApp and Telegram are out of scope (user decision); for them just point to the status line badge.

Default window: since the last working day 08:00 (Monday → Friday). The user can say "de hoy", "de esta semana", etc.

## What needs action

- **Slack**
  - Mentions: `slack_search_public_and_private` with `keywords: ["<@U035NGP2TDH>"]` (in keywords, not filters) and `after`.
  - Direct and group messages to him: `channel_types: "im,mpim"`, `after`, not `from:<@U035NGP2TDH>`.
  - Threads he wrote in that got new replies: search `from:<@U035NGP2TDH> is:thread` in the window, then `slack_read_thread` and keep the ones whose last message is not his.
  - Skip bots, his own last-word threads, and channels he muted (see the channel audit: deploy/alert/notification channels, other squads).
- **Work mail**: `search_threads` with `in:inbox is:unread category:primary newer_than:<n>d -from:me`, `view: THREAD_VIEW_SUMMARY`. Skip newsletters, notifications (Jira, GitHub, Google Calendar invites already answered) and anything he is only CC'd on unless it asks him something.
- **Personal mail** (JXA, read-only listing; open a body only for items that need action):

  ```javascript
  const M = Application("Mail"), since = new Date(Date.now() - DAYS * 864e5);
  ["iCloud", "Google"].flatMap(name => {
    const inbox = M.accounts.byName(name).mailboxes().find(b => /^(INBOX|Inbox|Bandeja de entrada)$/i.test(b.name()));
    return inbox.messages.whose({ readStatus: false })().filter(m => m.dateReceived() > since)
      .map(m => ({ account: name, id: m.id(), from: m.sender(), subject: m.subject(), date: m.dateReceived() }));
  });
  ```

  Skip promotions, newsletters and automated receipts.

## Output

```text
📥 Bandeja · 3 cosas · desde ayer 08:00

Slack
 1. @Mikel · #sty-sp-vip · hace 20 min — pregunta si LK-46147 está listo para QA
    → «Sí, está en CR con los checks en verde; en cuanto lo apruebes lo subo a DEV»
Correo trabajo
 2. Factorial — vacaciones aprobadas 22/12–02/01 → ¿lanzo /vacaciones?
Correo personal
 3. Clínica — confirmar cita del mar 03/11 10:00 → ¿lo apunto con /evento?

Sin acción: 9 mensajes en canales silenciados · 4 newsletters
```

- One line of context per item, a link (Slack permalink, Gmail `viewUrl`), and a suggested reply when one is expected.
- Suggested replies in the user's tone: Spanish, short, direct, informal with teammates (look at his recent messages in that channel/thread if unsure). No AI signatures.
- Hand off when it fits: approved time off → `vacaciones`; appointment or meeting → `evento`; ticket question → read the Jira issue first.

## Acting

The user answers per item: "envía la 1", "cambia la 2: …", "salta la 3", "borrador de la 2".

- Slack: `slack_send_message` in the same thread (`thread_ts`) or DM.
- Work mail: `reply` to the latest message of the thread (`get_thread` first), or `create_draft` with `replyToMessageId` when he says "borrador".
- Personal mail: open a reply window in Mail with the text filled in and let him press send:

  ```javascript
  const msg = M.accounts.byName(ACCOUNT).mailboxes.byName("INBOX").messages.byId(ID);
  const r = msg.reply({ openingWindow: true });
  r.content = TEXT + "\n\n" + r.content();
  ```

## Rules

- Never send, reply, mark as read, archive, label or delete anything without an explicit yes for that item.
- Do not copy message contents anywhere else (no notes, files, other chats).
- A connector is missing → say which and suggest `/mcp`; macOS Mail not running or permission denied → say so.
