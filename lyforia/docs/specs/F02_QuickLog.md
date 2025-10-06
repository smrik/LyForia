# F02: Quick-Log Binge — UX Specification

**Feature ID:** F02
**RICE Score:** 171.0
**Target Release:** Week 1
**Owner:** TBD
**Status:** 📝 Spec Review

---

## Problem Statement

Current binge logging requires 7 fields (time, place, food, comments, V/L/starred, weight) and multiple taps through a calendar interface. This takes 2-3 minutes and creates friction during emotionally difficult moments. Users report abandoning logs mid-entry, resulting in incomplete data and reduced insight quality.

**User Pain:**
> "By the time I fill out all the fields, I just want to forget it happened. I end up not logging at all."

---

## Success Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Quick-log adoption rate | N/A (new) | >60% of total logs | Firebase Analytics |
| Time to log | ~120s | <30s | Client-side timer |
| Entry volume/user/week | TBD | +20-30% | Firestore query |
| Completion rate (expand to full) | N/A | 20-30% | Event tracking |

---

## User Flow

### Entry Points

**Primary:** BingeEatingLogPage (Eating tab)
```
[Bottom Nav: Eating]
    ↓
[Binge Eating Log Page - Existing]
    ↓ NEW
[Quick Log Card - Top of page]
    ↓
[Quick Log Form Modal/Inline]
```

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ START: User opens Eating tab                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ See "⚡ Quick Log" card at top (above calendar)            │
│ [Log Now →]                                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
                  User taps "Log Now"
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ MODAL/SHEET: Quick Log Form                                 │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ ⚡ Quick Log                                            ││
│ │                                                          ││
│ │ Time: [Now ▼] ← Dropdown: Now | Pick time              ││
│ │                                                          ││
│ │ Place: [_____________] ← Text field (required)          ││
│ │        e.g., "Home", "Work", "Car"                      ││
│ │                                                          ││
│ │ [Cancel]  [Log It]                                      ││
│ └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                          ↓
               User taps "Log It"
                          ↓
             ┌─────────────┴─────────────┐
             │                           │
        Place empty?               Place filled
             │                           │
             ↓                           ↓
     Show validation            Save to Firestore
      error on field                    ↓
             ↓                  ┌────────────────┐
      User corrects             │ SUCCESS        │
             │                  └────────────────┘
             └──────────────────→       ↓
                          Show SnackBar:
                   "✅ Entry saved. Want to add details?"
                          [Yes] [No]
                          ↓         ↓
                    User taps     Dismiss
                      "Yes"          ↓
                          ↓       END (stay on page)
              Navigate to full form
               (time + place pre-filled)
                          ↓
                    User adds details
                          ↓
                      END
```

---

## Screen Mockups

### 1. Binge Eating Log Page (Modified)

```
╔═══════════════════════════════════════════════════╗
║  ← Binge Eating Log                               ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ║ ← NEW
║  ┃ ⚡ Quick Log                               ┃  ║
║  ┃ Log in seconds, add details later         ┃  ║
║  ┃                                            ┃  ║
║  ┃ Time: [Now ▼]    Place: [_________]       ┃  ║
║  ┃                                            ┃  ║
║  ┃              [Log It →]                    ┃  ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ║
║                                                   ║
║  Track your eating habits.                        ║
║                                                   ║
║  ┌─────────────────────────────────────────────┐ ║ ← Existing
║  │ Time *                                      │ ║   full form
║  │ [Select time]                               │ ║   (collapsed
║  └─────────────────────────────────────────────┘ ║   or below)
║  ┌─────────────────────────────────────────────┐ ║
║  │ Place *                                     │ ║
║  │ [___________________________________]       │ ║
║  └─────────────────────────────────────────────┘ ║
║  ...                                              ║
╚═══════════════════════════════════════════════════╝
```

**Layout Decision:**
- Quick-log card **above** existing form (most prominent)
- Full form remains visible below (users can still choose detailed entry)
- Card uses accent color border (blue/purple) to stand out

---

### 2. Quick Log Modal (Alternative: Modal Sheet)

```
         ┌─────────────────────────────┐
         │ ⚡ Quick Log                │
         ├─────────────────────────────┤
         │                             │
         │ Time                        │
         │ ┌─────────────────────────┐ │
         │ │ Now              ▼      │ │ ← Dropdown
         │ └─────────────────────────┘ │
         │                             │
         │ Place *                     │
         │ ┌─────────────────────────┐ │
         │ │                         │ │ ← Text input
         │ │ e.g., Home, Work        │ │
         │ └─────────────────────────┘ │
         │                             │
         │ [Cancel]        [Log It →] │
         └─────────────────────────────┘
```

**Modal vs Inline:**
- **Inline (recommended):** Faster (no modal animation), less context switch
- **Modal:** Cleaner separation, but adds tap to dismiss

**Decision:** Start with **inline card**, A/B test modal if adoption < 50%

---

### 3. Time Picker Dropdown (Expanded State)

```
┌─────────────────────────────┐
│ Time                        │
│ ┌─────────────────────────┐ │
│ │ ● Now                   │ │ ← Default selected
│ │ ○ 5 minutes ago         │ │
│ │ ○ 15 minutes ago        │ │
│ │ ○ 30 minutes ago        │ │
│ │ ○ 1 hour ago            │ │
│ │ ○ Pick exact time... ▸  │ │ ← Opens TimePicker
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**Rationale:** Users often log immediately or within 30min. Quick presets reduce taps.

---

### 4. Success SnackBar

```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║  ... (page content) ...                           ║
║                                                   ║
╠═══════════════════════════════════════════════════╣
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  ║ ← SnackBar
║  ┃ ✅ Entry saved. Want to add details?       ┃  ║   (bottom)
║  ┃                           [Yes]  [No]      ┃  ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  ║
╚═══════════════════════════════════════════════════╝
```

**Duration:** 5 seconds (longer than default 2s to allow read + tap)

---

## Interaction Details

### Component: Quick Log Card

**Visual Design:**
```dart
Container(
  margin: EdgeInsets.all(AppSpacing.lg),
  padding: EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: Theme.colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    border: Border.all(
      color: Theme.colorScheme.primary.withValues(alpha: 0.3),
      width: 2,
    ),
  ),
  // ... children
)
```

**States:**
| State | Visual | Behavior |
|-------|--------|----------|
| Default | Blue background, ⚡ icon, "Log It" button enabled if place filled | Tappable |
| Place empty | "Log It" button grayed out | Not tappable |
| Validation error | Red border on Place field, error text below | Shakes animation |
| Saving | "Log It" shows spinner, disabled | Wait for Firestore |
| Success | SnackBar appears, card resets | User can log again |

---

### Component: Time Dropdown

**Options:**
```dart
enum QuickTimeOption {
  now,           // DateTime.now()
  min5Ago,       // DateTime.now().subtract(Duration(minutes: 5))
  min15Ago,      // DateTime.now().subtract(Duration(minutes: 15))
  min30Ago,      // DateTime.now().subtract(Duration(minutes: 30))
  hour1Ago,      // DateTime.now().subtract(Duration(hours: 1))
  pickCustom,    // Opens TimePicker dialog
}
```

**Display Labels:**
- "Now" (default)
- "5 minutes ago"
- "15 minutes ago"
- "30 minutes ago"
- "1 hour ago"
- "Pick exact time..." → Opens Flutter's `showTimePicker()`

---

### Component: Place Text Field

**Validation:**
```dart
String? validatePlace(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Place is required';
  }
  if (value.trim().length < 2) {
    return 'Please enter at least 2 characters';
  }
  return null; // Valid
}
```

**Autocomplete (Future Enhancement):**
- Track user's past places in local storage
- Show suggestions dropdown: "Home" (12 times), "Work" (8 times), "Mom's house" (3 times)

**Max Length:** 100 characters (prevent abuse)

---

## Data Model

### Firestore Schema (No Changes)

Quick-log uses existing `binge_entries` collection:

```dart
// Collection: binge_entries
{
  uid: string,                  // User ID
  date: timestamp,              // Date only (for calendar)
  dateTime: timestamp,          // Full timestamp (for analytics)
  createdAt: serverTimestamp,   // Server-generated
  time: string,                 // "HH:mm" format (for display)
  place: string,                // Required in quick-log
  food: string,                 // Empty in quick-log
  comments: string,             // Empty in quick-log
  v: bool,                      // false (vomited)
  l: bool,                      // false (laxatives)
  starred: bool,                // false (starred)

  // NEW (optional): Track origin
  source: string?,              // "quick_log" | "full_form" (for analytics)
}
```

**Why no schema change?**
- Quick-log is just a simplified input to the same data structure
- Analytics can differentiate via `source` field (optional enhancement)

---

## Edge Cases & Error Handling

### 1. Network Offline

**Scenario:** User saves quick-log while offline
**Expected Behavior:**
- Firestore SDK queues write locally
- SnackBar shows: "✅ Entry saved (will sync when online)"
- No error thrown
- Data syncs automatically when connection restored

**Implementation:** Firestore handles this natively with `enablePersistence()`

---

### 2. User Not Signed In

**Scenario:** User attempts quick-log without authentication
**Expected Behavior:**
- Show error SnackBar: "Please sign in to add entries."
- Disable "Log It" button (gray out)
- **Future:** Offer "Sign in" button in SnackBar

**Code:**
```dart
if (Fb.auth.currentUser?.uid == null) {
  showError(AppStrings.signInRequired);
  return;
}
```

---

### 3. Place Field Empty on Submit

**Scenario:** User taps "Log It" with empty Place field
**Expected Behavior:**
- Show validation error: "Place is required"
- Red border on Place text field
- Shake animation (subtle, 2x left-right)
- Focus Place field for immediate correction

**Animation:**
```dart
AnimatedContainer(
  decoration: BoxDecoration(
    border: Border.all(
      color: hasError ? Colors.red : Colors.grey,
      width: hasError ? 2 : 1,
    ),
  ),
  duration: Duration(milliseconds: 200),
)
```

---

### 4. Time Picker Returns Null

**Scenario:** User picks "Pick exact time..." but cancels picker
**Expected Behavior:**
- Revert to previous selection (default: "Now")
- No error shown
- Dropdown closes

---

### 5. Rapid Tapping "Log It"

**Scenario:** User double-taps "Log It" (impatient)
**Expected Behavior:**
- First tap disables button, shows spinner
- Second tap ignored (button already disabled)
- Only one entry created

**Implementation:**
```dart
bool _saving = false;

Future<void> _saveQuickLog() async {
  if (_saving) return; // Guard
  setState(() => _saving = true);

  try {
    await _firestoreSave();
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}
```

---

### 6. User Taps "Yes" Then Backs Out of Full Form

**Scenario:** SnackBar → "Yes" → Full form opens → User hits back
**Expected Behavior:**
- Entry already saved (not deleted)
- User returns to Eating page
- Quick-log card is reset, ready for another entry
- No data loss

---

### 7. Time in Future

**Scenario:** User picks exact time in future (e.g., 2 hours ahead)
**Expected Behavior:**
- **Option A (Strict):** Validation error: "Time cannot be in the future"
- **Option B (Lenient):** Allow (user may have wrong timezone or typo)

**Recommendation:** **Option B** — don't block user, log timestamps accurately for later review

---

## Accessibility

### Screen Reader Support

**Labels:**
```dart
Semantics(
  label: 'Quick log your binge in seconds',
  child: QuickLogCard(...),
)

TextField(
  decoration: InputDecoration(labelText: 'Place'),
  semanticsLabel: 'Enter the location where this occurred',
)

ElevatedButton(
  onPressed: _saveQuickLog,
  child: Text('Log It'),
  semanticsLabel: 'Save quick log entry',
)
```

**Announcements:**
```dart
// On successful save
SemanticsService.announce(
  'Entry saved successfully. Do you want to add more details?',
  TextDirection.ltr,
);
```

---

### Keyboard Navigation

- Tab order: Time dropdown → Place field → Cancel button → Log It button
- Enter key on Place field → Submit (same as tapping "Log It")
- Escape key → Cancel (if modal) or blur field (if inline)

---

### Color Contrast

- Quick-log card background: `colorScheme.primaryContainer` (AA contrast)
- Border: `primary` with 30% opacity (not relied on for info)
- Error text: `colorScheme.error` (WCAG AA compliant)

---

## Analytics Events

### Event: `quick_log_opened`
**When:** User opens Eating page and quick-log card is visible
**Parameters:**
```json
{
  "screen": "binge_eating_log",
  "timestamp": "2025-10-01T14:30:00Z"
}
```

---

### Event: `quick_log_submitted`
**When:** User taps "Log It" and entry saves successfully
**Parameters:**
```json
{
  "time_option": "now" | "5min" | "15min" | "30min" | "1hr" | "custom",
  "place_length": 8,
  "time_to_submit_seconds": 12,
  "timestamp": "2025-10-01T14:30:12Z"
}
```

---

### Event: `quick_log_expanded`
**When:** User taps "Yes" on SnackBar to add details
**Parameters:**
```json
{
  "time_since_save_seconds": 3,
  "timestamp": "2025-10-01T14:30:15Z"
}
```

---

### Event: `quick_log_validation_error`
**When:** User submits with empty Place field
**Parameters:**
```json
{
  "field": "place",
  "error_type": "empty",
  "timestamp": "2025-10-01T14:30:10Z"
}
```

---

## Testing Checklist

### Unit Tests

- [ ] `QuickLogWidget` renders correctly
- [ ] Time dropdown options generate correct DateTime
- [ ] Place validation logic (empty, too short, valid)
- [ ] `_saveQuickLog()` calls Firestore with correct data
- [ ] Guard against double-submit (`_saving` flag)

### Widget Tests

- [ ] Quick-log card appears at top of BingeEatingLogPage
- [ ] "Log It" button disabled when Place empty
- [ ] "Log It" button enabled when Place has 2+ chars
- [ ] Tapping "Log It" shows SnackBar
- [ ] SnackBar "Yes" navigates to full form
- [ ] Form pre-fills time and place

### Integration Tests

- [ ] End-to-end: Open Eating tab → Quick-log → Save → Verify in Firestore
- [ ] Offline: Quick-log → Airplane mode → Save → Online → Verify sync
- [ ] Not signed in: Quick-log → Show error
- [ ] Expand to full form: Quick-log → Yes → Add details → Save → Verify all fields

### Accessibility Tests

- [ ] Screen reader announces card, fields, buttons
- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] Color contrast meets WCAG AA

---

## Open Questions for Review

1. **Modal vs Inline:** Should quick-log be a modal sheet or inline card?
   **Recommendation:** Inline (faster), but prototype both and user test.

2. **Autocomplete Places:** Should we suggest past places?
   **Recommendation:** Not MVP, add in V2 if adoption > 70%.

3. **Time Presets:** Are 5/15/30/60min the right intervals?
   **Recommendation:** Start with these, analyze usage data, adjust.

4. **Source Tracking:** Should we add `source: "quick_log"` to Firestore?
   **Recommendation:** Yes (optional field), enables A/B test analysis.

5. **Full Form Access:** Should full form be collapsible or always visible?
   **Recommendation:** Always visible below quick-log (don't hide existing feature).

---

## Implementation Checklist

- [ ] Create `QuickLogCard` widget (lib/widgets/quick_log_card.dart)
- [ ] Add `QuickTimeOption` enum and helper methods
- [ ] Modify BingeEatingLogPage to include quick-log card at top
- [ ] Implement validation and save logic
- [ ] Add SnackBar with "Yes/No" actions
- [ ] Wire "Yes" to navigate to full form with pre-fill
- [ ] Add analytics events (if analytics_tracker.dart exists)
- [ ] Write unit tests for validation and save logic
- [ ] Write widget tests for UI interactions
- [ ] Write integration test for end-to-end flow
- [ ] Update BingeEatingLogPage tests to account for new card
- [ ] Accessibility audit with screen reader
- [ ] Performance test: Ensure quick-log doesn't slow page load

---

**Approval Required From:**
- [ ] Product (feature scope)
- [ ] Design (visual mockups)
- [ ] Engineering (technical feasibility)
- [ ] QA (test coverage)

---

**Ready for Implementation:** ✅ / ❌ (circle one)
