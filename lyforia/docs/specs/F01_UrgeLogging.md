# F01: Urge Logging + Coping Prompts — UX Specification

**Feature ID:** F01
**RICE Score:** 108.0
**Target Release:** Week 2
**Dependencies:** Firebase Cloud Messaging (for notifications)
**Owner:** TBD
**Status:** 📝 Spec Review

---

## Problem Statement

The app currently tracks *completed* binges (post-hoc logging), missing the critical intervention window when users feel an urge but haven't acted yet. Research shows urge→binge escalation takes 15-45 minutes—a window where coping strategies are most effective. Without urge logging, users have no in-app tool for real-time intervention.

**User Pain:**
> "I feel the urge coming but I don't know what to do. By the time I remember to open the app, it's too late—I already binged."

---

## Success Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Urge log rate (logs/user/week) | N/A | >2 | Firestore query |
| Outcome completion rate | N/A | >50% | % urges with outcome marked |
| Resistance rate | N/A | >60% | % urges marked "resisted" |
| Notification response rate | N/A | >30% | % of 30min reminders acted on |
| Binge reduction (users who log 3+ urges/week) | Baseline TBD | -15% | Compare binge_entries count |

---

## User Flow

### Entry Points

**Primary:** CheckInPage (Check-in tab)
**Secondary:** Notification (30min after urge logged)

```
[Check-in Tab]
    ↓
["Feeling an urge?" card - Prominent]
    ↓
[Log Urge] → Urge Log Sheet → Coping Prompt → [Start/Not now]
    ↓
[I'm OK] → Dismisses card for session
```

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ START: User opens Check-in tab                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ See "💭 Feeling an urge?" card at top of page              │
│ [Log Urge]  [I'm OK]                                        │
└─────────────────────────────────────────────────────────────┘
                    ┌─────────┴─────────┐
                    │                   │
          User taps "I'm OK"    User taps "Log Urge"
                    │                   │
                    ↓                   ↓
         Dismiss card for       ┌───────────────────┐
         current session        │ Urge Log Sheet    │
         (reappears next        └───────────────────┘
          app open)                     ↓
                          ┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
                          ┃ What triggered this?     ┃
                          ┃ ☐ Emotion (sad, anxious) ┃
                          ┃ ☐ Location (home, work)  ┃
                          ┃ ☐ Social (alone, conflict)┃
                          ┃ ☐ Physical (tired, hungry)┃
                          ┃                          ┃
                          ┃ Intensity: [1---●---5]   ┃
                          ┃                          ┃
                          ┃ [Cancel]  [Save Urge]    ┃
                          ┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                    ↓
                          User taps "Save Urge"
                                    ↓
                          Save to Firestore (urge_logs)
                                    ↓
                          ┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
                          ┃ ✅ Urge logged.          ┃
                          ┃ Try this:                ┃
                          ┃                          ┃
                          ┃ • 5-min breathing        ┃
                          ┃ • Call a friend          ┃
                          ┃ • Go for a walk          ┃
                          ┃                          ┃
                          ┃ [Start] [Not now]        ┃
                          ┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
                          ┌─────────┴─────────┐
                          │                   │
              User taps "Not now"    User taps "Start"
                          │                   │
                          ↓                   ↓
                  Dismiss screen      Navigate to coping
                  Return to Check-in  (placeholder: "Coming soon"
                                       or Check-in page)
                          ↓
                  ⏰ 30min later
                          ↓
                  ┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
                  ┃ 🔔 NOTIFICATION          ┃
                  ┃ How did it go?           ┃
                  ┃ [Update] [Dismiss]       ┃
                  ┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
                          ↓
              User taps "Update"
                          ↓
                  ┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
                  ┃ Outcome?                 ┃
                  ┃ ● I resisted 🎉          ┃
                  ┃ ○ I gave in              ┃
                  ┃                          ┃
                  ┃ [Save]                   ┃
                  ┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
                          ↓
                  Update urge_logs.outcome
                          ↓
                  Show SnackBar:
                  "Thanks for updating. You're doing great!"
                          ↓
                          END
```

---

## Screen Mockups

### 1. Check-in Page (Modified)

```
╔═══════════════════════════════════════════════════╗
║  ← Daily Check-in                                 ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ║ ← NEW
║  ┃ 💭 Feeling an urge?                        ┃  ║
║  ┃ Log it now and get support                 ┃  ║
║  ┃                                            ┃  ║
║  ┃ [Log Urge]           [I'm OK]              ┃  ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ║
║                                                   ║
║  How are you feeling today?                       ║ ← Existing
║  ┌───────────────────────────────────────────┐   ║   check-in
║  │ [Mood slider 1-5]                         │   ║   form
║  └───────────────────────────────────────────┘   ║
║  ...                                              ║
╚═══════════════════════════════════════════════════╝
```

**Placement:** Top of page, above mood slider (most urgent use case)
**Color:** Warm orange/yellow background (urgency, not alarm)

---

### 2. Urge Log Sheet (Bottom Modal)

```
              ┌─────────────────────────────┐
              │ ━━━                         │ ← Drag handle
              │                             │
              │ What triggered this urge?   │
              │                             │
              │ ☑ Emotion                   │ ← Multi-select
              │   (sad, anxious, angry)     │   checkboxes
              │                             │
              │ ☐ Location                  │
              │   (home, work, public)      │
              │                             │
              │ ☐ Social                    │
              │   (alone, after conflict)   │
              │                             │
              │ ☐ Physical                  │
              │   (tired, hungry, pain)     │
              │                             │
              │ ─────────────────────────   │
              │                             │
              │ Intensity (how strong?)     │
              │ 1 ----●----------------  5  │ ← Slider
              │ Mild                 Intense│
              │                             │
              │ [Cancel]      [Save Urge →]│
              └─────────────────────────────┘
```

**Modal Type:** Bottom sheet (dismissible by drag down or tap outside)
**Height:** ~60% of screen
**Keyboard:** No text input, so no keyboard obstruction

---

### 3. Coping Prompt Screen (Full Screen Overlay)

```
╔═══════════════════════════════════════════════════╗
║                    [× Close]                      ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║              ✅ Urge logged.                      ║
║                                                   ║
║           You took the first step.                ║
║         Here's what might help:                   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 🫁 5-minute breathing exercise            │   ║
║  │ Calm your nervous system                  │   ║
║  │                              [Start →]    │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 📞 Call a supportive friend               │   ║
║  │ Connection can interrupt urges            │   ║
║  │                              [Start →]    │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║  ┌───────────────────────────────────────────┐   ║
║  │ 🚶 Go for a 10-minute walk                │   ║
║  │ Movement shifts your focus                │   ║
║  │                              [Start →]    │   ║
║  └───────────────────────────────────────────┘   ║
║                                                   ║
║                [Not now]                          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

**Layout:** Full-screen overlay (can't accidentally dismiss)
**Action:** "Start" buttons placeholder (MVP: just dismiss + show "Coming soon")
**Future:** Link to breathing timer (F07), phone dialer, timer for walk

---

### 4. Notification (30min Later)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🔔 Lyforia                                      ┃
┃ How did it go?                                  ┃
┃ Did you resist the urge or give in?            ┃
┃                                                 ┃
┃ [Update]  [Dismiss]                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Timing:** Exactly 30 minutes after urge logged
**Sound:** Default notification sound (not silent, but not alarming)
**Behavior:**
- Tap notification body → Open outcome dialog
- Tap "Update" → Open outcome dialog
- Tap "Dismiss" → Mark as `outcome: null`, don't re-notify

---

### 5. Outcome Dialog (From Notification)

```
              ┌─────────────────────────────┐
              │ How did it go?              │
              ├─────────────────────────────┤
              │                             │
              │ ● I resisted 🎉             │ ← Radio button
              │                             │   (default selected)
              │ ○ I gave in                 │
              │                             │
              │ ─────────────────────────   │
              │                             │
              │ [Save]                      │
              └─────────────────────────────┘
```

**Tone:** Positive default ("I resisted" pre-selected) to reduce shame
**Success Message:** "Thanks for updating. You're doing great!" (no judgment)

---

## Data Model

### New Collection: `urge_logs`

```dart
// Collection: urge_logs
{
  uid: string,                  // User ID
  dateTime: serverTimestamp,    // When urge was logged
  triggers: List<string>,       // ["emotion", "location"] (multi-select)
  intensity: int,               // 1-5
  copingAttempted: bool,        // Did user tap "Start" on coping prompt?
  copingAction: string?,        // "breathing" | "call_friend" | "walk" | null
  outcome: string?,             // "resisted" | "gave_in" | null (if not updated)
  outcomeUpdatedAt: timestamp?, // When user updated outcome (null if not updated)
  notificationSent: bool,       // Track if 30min notification was sent
  notificationSentAt: timestamp?, // When notification was sent
}
```

**Indexes:**
- `uid` + `dateTime` (descending) — for user's recent urges
- `uid` + `outcome` — for analytics (resistance rate)

---

## Interaction Details

### Component: Urge Prompt Card

**States:**
| State | Visual | Behavior |
|-------|--------|----------|
| Default | Orange background, 💭 icon, both buttons enabled | Tappable |
| "I'm OK" tapped | Card fades out, disappears | Hidden until next app session |
| "Log Urge" tapped | Modal sheet slides up from bottom | User fills triggers + intensity |
| User not signed in | Card shows "Sign in required" banner | Buttons disabled |

**Dismissal Logic:**
```dart
// Store in local session state (not persistent)
class _CheckInPageState extends State<CheckInPage> {
  bool _urgeCardDismissed = false;

  void _dismissUrgeCard() {
    setState(() => _urgeCardDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_urgeCardDismissed) {
      // Show urge card
    }
    // ...
  }
}
```

---

### Component: Trigger Checklist

**Options & Labels:**
```dart
enum UrgeTriggger {
  emotion,   // "Emotion (sad, anxious, angry)"
  location,  // "Location (home, work, public)"
  social,    // "Social (alone, after conflict)"
  physical,  // "Physical (tired, hungry, pain)"
}
```

**UI:**
- Checkboxes (can select multiple or none)
- Subtle examples in parentheses (guidance, not exhaustive)
- **Validation:** At least 1 trigger required? **No** — allow user to skip if uncertain

---

### Component: Intensity Slider

**Range:** 1 (Mild) to 5 (Intense)
**Default:** 3 (midpoint)
**Visual:**
```dart
Slider(
  value: _intensity,
  min: 1,
  max: 5,
  divisions: 4,
  label: _intensity.round().toString(),
  onChanged: (value) => setState(() => _intensity = value),
)
```

**Labels:**
- Left: "Mild"
- Right: "Intense"

---

### Component: Coping Prompt Cards

**Hardcoded MVP Actions:**
1. **Breathing Exercise**
   - Icon: 🫁
   - Title: "5-minute breathing exercise"
   - Subtitle: "Calm your nervous system"
   - Action: Show "Coming soon" dialog (or navigate to placeholder)

2. **Call Friend**
   - Icon: 📞
   - Title: "Call a supportive friend"
   - Subtitle: "Connection can interrupt urges"
   - Action: **Future:** Open phone dialer with preset contact

3. **Go for Walk**
   - Icon: 🚶
   - Title: "Go for a 10-minute walk"
   - Subtitle: "Movement shifts your focus"
   - Action: **Future:** Start 10min timer with notification

**Personalization (Future):**
- If user has "Evening walk" habit → suggest "Go for your evening walk"
- If user logged "call friend" as outcome before → prioritize that suggestion

---

## Notification Logic

### Scheduling (Local Notification)

**Trigger:** Immediately after urge saved to Firestore
**Code:**
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _scheduleOutcomeReminder(String urgeLogId) async {
  final notificationId = urgeLogId.hashCode; // Unique per urge
  final scheduledDate = DateTime.now().add(Duration(minutes: 30));

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId,
    'How did it go?',
    'Did you resist the urge or give in?',
    tz.TZDateTime.from(scheduledDate, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'urge_outcome_channel',
        'Urge Outcome Reminders',
        channelDescription: 'Reminds you to update urge outcomes',
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction('update', 'Update'),
          AndroidNotificationAction('dismiss', 'Dismiss'),
        ],
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: urgeLogId, // Pass urge ID for updating
  );
}
```

**Permissions:**
- Request notification permissions on first urge log (not on app open)
- If denied, show in-app banner: "Enable notifications to track outcomes"

---

### Handling Notification Tap

```dart
Future<void> _onNotificationTap(NotificationResponse response) async {
  final urgeLogId = response.payload;
  if (urgeLogId == null) return;

  if (response.actionId == 'update') {
    // Show outcome dialog
    _showOutcomeDialog(urgeLogId);
  } else if (response.actionId == 'dismiss') {
    // Mark as outcome: null, don't re-notify
    await _dismissOutcome(urgeLogId);
  } else {
    // Tapped notification body → show outcome dialog
    _showOutcomeDialog(urgeLogId);
  }
}
```

---

## Edge Cases & Error Handling

### 1. User Closes App Before Saving Urge

**Scenario:** User opens urge sheet, selects triggers, but closes app
**Expected Behavior:**
- No entry created (no autosave)
- Modal dismissed on app reopen
- No data loss (nothing was saved)

---

### 2. Notification Sent While App Open

**Scenario:** 30min notification fires while user is actively using app
**Expected Behavior:**
- Show in-app dialog (not notification banner)
- Same outcome options
- Less intrusive than interrupting

**Implementation:**
```dart
// Check if app is in foreground
if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
  _showOutcomeDialog(urgeLogId); // In-app
} else {
  _showNotification(urgeLogId); // Banner
}
```

---

### 3. User Logs Multiple Urges Before 30min

**Scenario:** User logs urge at 2:00pm, then another at 2:15pm
**Expected Behavior:**
- Two separate notifications: 2:30pm and 2:45pm
- Each tracks its own outcome independently
- No notification deduplication

---

### 4. User Disables Notifications Mid-Session

**Scenario:** User logs urge, then disables notifications in system settings
**Expected Behavior:**
- Notification silently fails (no crash)
- Urge still saved in Firestore
- Analytics tracks `notification_sent: false`

---

### 5. User Updates Outcome Twice

**Scenario:** User marks "I resisted", then reopens and changes to "I gave in"
**Expected Behavior:**
- Allow update (no lock after first save)
- Overwrite `outcome` field
- Update `outcomeUpdatedAt` timestamp
- **Future:** Track edit history for integrity

---

### 6. Notification Permission Denied

**Scenario:** User taps "Don't Allow" on notification permission prompt
**Expected Behavior:**
- Show one-time banner: "Enable notifications in Settings to track outcomes"
- Don't repeatedly ask (iOS/Android reject this)
- Urge logging still works, just no reminders

---

## Accessibility

### Screen Reader Support

**Urge Card:**
```dart
Semantics(
  label: 'Feeling an urge? Log it now to get support and track your progress',
  child: UrgePromptCard(...),
)
```

**Trigger Checkboxes:**
```dart
CheckboxListTile(
  title: Text('Emotion (sad, anxious, angry)'),
  semanticsLabel: 'Emotion as trigger. Examples: sad, anxious, angry',
  value: _triggerEmotion,
  onChanged: (value) => setState(() => _triggerEmotion = value ?? false),
)
```

**Coping Cards:**
```dart
Semantics(
  label: '5-minute breathing exercise. Calm your nervous system. Tap to start',
  button: true,
  child: CopingCard(...),
)
```

---

### Haptic Feedback

- Urge saved: Light success haptic (`HapticFeedback.lightImpact()`)
- Outcome updated: Medium success haptic (`HapticFeedback.mediumImpact()`)
- Notification tap: System default

---

## Analytics Events

### Event: `urge_prompt_shown`
**When:** Check-in page loads with urge card visible
**Parameters:**
```json
{
  "user_signed_in": true,
  "timestamp": "2025-10-01T14:00:00Z"
}
```

---

### Event: `urge_logged`
**When:** User saves urge in modal sheet
**Parameters:**
```json
{
  "triggers": ["emotion", "social"],
  "intensity": 4,
  "time_to_log_seconds": 8,
  "timestamp": "2025-10-01T14:00:08Z"
}
```

---

### Event: `coping_prompt_shown`
**When:** Coping screen appears after urge logged
**Parameters:**
```json
{
  "urge_intensity": 4,
  "timestamp": "2025-10-01T14:00:09Z"
}
```

---

### Event: `coping_action_selected`
**When:** User taps "Start" on a coping card
**Parameters:**
```json
{
  "action": "breathing" | "call_friend" | "walk",
  "timestamp": "2025-10-01T14:00:15Z"
}
```

---

### Event: `outcome_notification_sent`
**When:** 30min notification successfully scheduled
**Parameters:**
```json
{
  "scheduled_time": "2025-10-01T14:30:00Z",
  "urge_id": "abc123",
  "timestamp": "2025-10-01T14:00:10Z"
}
```

---

### Event: `outcome_updated`
**When:** User marks urge outcome (resisted/gave_in)
**Parameters:**
```json
{
  "outcome": "resisted" | "gave_in",
  "time_since_urge_minutes": 32,
  "from_notification": true,
  "timestamp": "2025-10-01T14:32:00Z"
}
```

---

## Testing Checklist

### Unit Tests

- [ ] Urge trigger enum and validation
- [ ] Intensity slider value constraints (1-5)
- [ ] Firestore save logic (correct schema)
- [ ] Notification scheduling (30min delay)
- [ ] Outcome update logic (overwrite allowed)

### Widget Tests

- [ ] Urge card renders on Check-in page
- [ ] "Log Urge" opens modal sheet
- [ ] "I'm OK" dismisses card for session
- [ ] Trigger checkboxes toggle correctly
- [ ] Intensity slider updates state
- [ ] Coping prompt shows after save
- [ ] Outcome dialog renders correctly

### Integration Tests

- [ ] End-to-end: Log urge → Save → Verify in Firestore
- [ ] Notification: Log urge → Wait 30min → Verify notification sent (mock time)
- [ ] Outcome: Tap notification → Update outcome → Verify in Firestore
- [ ] Offline: Log urge while offline → Online → Verify sync
- [ ] Permissions: Deny notifications → Verify graceful handling

### Accessibility Tests

- [ ] Screen reader announces all interactive elements
- [ ] Keyboard navigation (if applicable)
- [ ] Color contrast meets WCAG AA
- [ ] Haptic feedback works on save/update

---

## Open Questions for Review

1. **Notification Timing:** Is 30min the right delay?
   **Recommendation:** Start with 30min, analyze response rate, adjust (15min? 45min?)

2. **Coping Actions:** Should MVP implement breathing timer or just placeholders?
   **Recommendation:** Placeholders only (F07 is separate feature), show "Coming soon"

3. **Outcome Required?** Should we force outcome update or allow null?
   **Recommendation:** Allow null (optional), but encourage with notification

4. **Multiple Urges Per Day:** Should we limit (e.g., max 10/day)?
   **Recommendation:** No limit initially, flag outliers for review (may indicate crisis)

5. **Dismiss Behavior:** Should "I'm OK" persist across sessions or reset daily?
   **Recommendation:** Reset on app reopen (don't persist dismissal)

---

## Implementation Checklist

- [ ] Create `urge_logs` collection schema in Firestore
- [ ] Add `flutter_local_notifications` dependency to pubspec.yaml
- [ ] Create `UrgePromptCard` widget (lib/widgets/urge_prompt_card.dart)
- [ ] Create `UrgeLogSheet` modal widget
- [ ] Create `CopingPromptScreen` widget
- [ ] Implement trigger checkboxes and intensity slider
- [ ] Implement Firestore save logic
- [ ] Set up notification channel (Android/iOS)
- [ ] Implement notification scheduling (30min delay)
- [ ] Create `OutcomeDialog` widget
- [ ] Implement notification tap handler (show outcome dialog)
- [ ] Modify CheckInPage to include urge card at top
- [ ] Add analytics events
- [ ] Write unit tests for data models and logic
- [ ] Write widget tests for UI components
- [ ] Write integration test for end-to-end flow
- [ ] Test notification permissions (grant/deny scenarios)
- [ ] Accessibility audit with screen reader
- [ ] Test notification delivery on physical devices (iOS + Android)

---

**Approval Required From:**
- [ ] Product (feature scope, coping suggestions)
- [ ] Design (visual mockups, tone)
- [ ] Engineering (notification architecture, technical feasibility)
- [ ] QA (test coverage, edge cases)
- [ ] Clinical (optional: verify coping suggestions are evidence-based)

---

**Ready for Implementation:** ✅ / ❌ (circle one)
