# MVP Feature Plan — Lyforia

**Date:** October 1, 2025
**Sprint Goal:** Ship 3 high-impact features that transform Lyforia from a tracking app to a prevention & intervention tool
**Target Delivery:** 3-4 weeks (1 feature/week + 1 week buffer for QA)

---

## Selection Criteria

From the backlog of 15 features, we selected the top 3 by RICE score with strategic balance:

1. **F02: Quick-Log Binge** (RICE: 171.0) — **Capture/UX** — Reduces friction, increases data volume
2. **F01: Urge Logging + Coping Prompts** (RICE: 108.0) — **Retention/Intervention** — Core value prop, prevents binges
3. **F03: Insight Engine** (RICE: 59.5) — **Analytics/Value** — Turns data into actionable recommendations

**Balanced Mix:**
- **Immediate Value** (F02): Improves existing flow, ships fast
- **Differentiation** (F01): Unique feature, sets us apart from generic trackers
- **Long-term Stickiness** (F03): Personalized insights drive retention

---

## Feature 1: Quick-Log Binge ⚡

### Acceptance Criteria

**Must Have:**
1. ✅ New "Quick Log" button/card prominently displayed at top of Binge Eating Log page
2. ✅ Quick-log form contains ONLY: Time picker (default: Now), Place text field
3. ✅ "Log It" button saves entry to `binge_entries` with empty food/comments, v=false, l=false, starred=false
4. ✅ After save, show SnackBar with "Entry saved. Want to add details?" [Yes] [No]
5. ✅ If "Yes", navigate to full binge log form with time+place pre-filled
6. ✅ Full binge log form remains accessible (tab or "Add Details" button)
7. ✅ Quick-log respects existing calendar date selection (if user picked a past date)

**Should Have:**
8. ⏸️ Analytics event: `binge_quicklog_used` with timestamp
9. ⏸️ A/B test flag: `quick_log_enabled` (default: true) for gradual rollout

**Won't Have (V1):**
- Voice logging ("Just say 'I binged at home'")
- Photo attachment (too complex for "quick")

### Edge Cases & Handling

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| User not signed in | Show "Sign in required" error (existing pattern) | Consistent with other features |
| Network offline | Entry saved locally, synced when online (Firestore SDK) | Leverage existing offline capability |
| Time picker not touched (default "Now") | Use `DateTime.now()` | Most common case, reduce taps |
| Place field empty | Validation error: "Place required" | Minimum viable data for insights |
| User abandons mid-log | No entry created (no autosave) | Avoid cluttering DB with incomplete entries |

### KPIs & Success Metrics

**Primary:**
- **Quick-log Adoption Rate:** % of total binge logs using quick-log (target: >60% within 2 weeks)
- **Completion Rate:** % of quick-logs that go to full detail (target: 20-30% = good balance)

**Secondary:**
- **Time to Log:** Median seconds from opening page to save (target: <30s vs current ~120s)
- **Entry Volume:** Total binge logs/week (expect +20-30% increase)

**Instrumentation:**
```dart
// lib/utils/analytics_tracker.dart (new file)
void logQuickLogUsed() {
  // Firebase Analytics or custom
  analytics.logEvent('binge_quicklog_used', parameters: {
    'timestamp': DateTime.now().toIso8601String(),
  });
}
```

### Rollback Plan

**Feature Flag:**
```dart
// lib/utils/feature_flags.dart (new)
class FeatureFlags {
  static bool quickLogEnabled = true; // Toggle remotely via Firebase Remote Config
}
```

**If adoption < 40% after 1 week:**
1. Survey users: "Why didn't you use quick-log?"
2. Iterate on UX (maybe place not needed, just time?)
3. If fundamentally broken, hide feature via flag, revert in next release

**Rollback Trigger:**
- Critical bug (e.g., data loss, crash on save)
- User complaints > 10 in first 48h
- Completion rate < 10% (users not engaging)

---

## Feature 2: Urge Logging + Coping Prompts 💭

### Acceptance Criteria

**Must Have:**
1. ✅ New "Feeling an urge?" card displayed at top of Check-in page
2. ✅ Card has two buttons: [Log Urge] [I'm OK]
3. ✅ On "Log Urge", show modal/sheet with:
   - Multi-select trigger checklist (Emotion, Location, Social, Physical)
   - Intensity slider (1-5)
   - [Save Urge] button
4. ✅ On save, create entry in new `urge_logs` collection with uid, dateTime, triggers, intensity
5. ✅ After save, show coping prompt screen:
   - "✅ Urge logged. Try this:" heading
   - 3 coping suggestions (hardcoded MVP: breathing, call friend, walk)
   - [Start] [Not now] buttons
6. ✅ If "Start" on breathing → navigate to Check-in tab (or placeholder screen: "Breathing exercise coming soon")
7. ✅ 30min after urge log, send local notification: "How did it go?" [Update] [Dismiss]
8. ✅ If user taps "Update", re-open urge log entry with outcome field (resisted | gave_in)

**Should Have:**
9. ⏸️ Coping suggestions personalized (e.g., if user has "Evening walk" habit, suggest that)
10. ⏸️ Weekly summary: "You logged 5 urges and resisted 4 this week 🎉"

**Won't Have (V1):**
- Full coping toolkit (F07) — just suggest, don't implement exercises yet
- Predictive urge alerts (F04) — reactive only for now

### Edge Cases & Handling

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| User closes app before saving urge | No entry created (no autosave) | Avoid incomplete data |
| User taps "I'm OK" | Dismisses card for current session, reappears next open | Not annoying |
| Notification sent, user doesn't respond | Mark urge as `outcome: null` | Acceptable, still useful data |
| User logs 10 urges/day | No limit, but analytics flag for review | May indicate crisis → future intervention |
| Multiple urges logged same hour | Allowed (each is distinct) | Don't artificially constrain |

### KPIs & Success Metrics

**Primary:**
- **Urge Log Rate:** # urge logs per user per week (target: >2, indicates feature adoption)
- **Outcome Completion Rate:** % of urges with outcome marked (target: >50%)
- **Resistance Rate:** % of urges marked "resisted" (target: >60%, indicates app helping)

**Secondary:**
- **Time to Coping:** Seconds from urge log to tapping "Start" on coping (engagement)
- **Notification Response Rate:** % of 30min notifications acted on (target: >30%)

**Instrumentation:**
```dart
// Analytics events
analytics.logEvent('urge_logged', parameters: {
  'triggers': triggerList.join(','),
  'intensity': intensityValue,
});
analytics.logEvent('urge_outcome_updated', parameters: {
  'outcome': 'resisted', // or 'gave_in'
  'time_since_log_minutes': elapsedMinutes,
});
```

### Rollback Plan

**Feature Flag:**
```dart
FeatureFlags.urgeLoggingEnabled = true;
```

**If resistance rate < 40% after 2 weeks:**
- Hypothesis 1: Coping prompts not helpful → A/B test different suggestions
- Hypothesis 2: Users not seeing notifications → check permissions, improve UX
- Hypothesis 3: Feature not needed → survey users, potentially sunset

**Rollback Trigger:**
- Bug causing notification spam
- Privacy concern (users feel "monitored")
- Resistance rate < 30% (not working)

---

## Feature 3: Insight Engine (Trigger Patterns) 💡

### Acceptance Criteria

**Must Have:**
1. ✅ New "Insights" section added to Analytics page (below existing charts)
2. ✅ Insights calculated from:
   - `binge_entries` (time, day of week)
   - `check_ins` (mood)
   - `urge_logs` (if F02 shipped first)
3. ✅ Display 3 key insights:
   - **Time Pattern:** "Most binges occur at [hour]" (mode of all binge times)
   - **Day Pattern:** "You binge more on [day]" (if frequency > avg by 50%)
   - **Mood Correlation:** "Low mood (<3) precedes 75% of binges" (if statistically significant)
4. ✅ If < 10 total entries, show: "Not enough data yet. Keep logging!"
5. ✅ Insights updated weekly (not real-time, to reduce compute cost)
6. ✅ "See Recommendations" button navigates to new Recommendations page with 3 actionable tips:
   - "Schedule a habit at [hour - 1h] on [day]"
   - "Check in daily when mood drops below 3"
   - "Review your [longest binge-free streak] days in [month] — what worked then?"

**Should Have:**
7. ⏸️ Confidence intervals on insights (e.g., "78% correlation, medium confidence")
8. ⏸️ User can dismiss/hide insights they disagree with
9. ⏸️ Insights cached in Firestore (not recomputed on every page load)

**Won't Have (V1):**
- ML predictions ("You're at high risk today")
- Multi-variate analysis (mood × habits × binges interaction)
- Graph visualizations (just text for MVP)

### Edge Cases & Handling

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Ties (2 hours with same frequency) | Show both: "Most binges at 8pm or 10pm" | More info = better |
| No clear pattern (uniform distribution) | "No dominant pattern yet" | Honest, not misleading |
| User's data changes significantly | Re-run analysis weekly, old insights replaced | Adaptive |
| User has 100+ entries | Sample last 90 days (not all-time) | Recent patterns more relevant |
| Mood data missing | Skip mood correlation insight, show only time/day | Graceful degradation |

### KPIs & Success Metrics

**Primary:**
- **Insight View Rate:** % of users who view Insights section (target: >70%)
- **Recommendation Action Rate:** % of users who create a habit/check-in after viewing recs (target: >20%)

**Secondary:**
- **Perceived Value:** Survey question: "Insights helped me understand my triggers" (Likert 1-5, target: >4.0)
- **Data Quality Proxy:** Users with insights have 30% more logs than users without (correlation, not causation)

**Instrumentation:**
```dart
analytics.logEvent('insight_viewed', parameters: {
  'pattern_types': ['time_of_day', 'mood_correlation'],
  'data_points_analyzed': entryCount,
});
analytics.logEvent('recommendation_acted_on', parameters: {
  'type': 'scheduled_habit',
});
```

### Rollback Plan

**Feature Flag:**
```dart
FeatureFlags.insightsEnabled = true;
```

**If view rate < 40% after 2 weeks:**
- Hypothesis 1: Insights not prominent enough → move to top of Analytics page
- Hypothesis 2: Insights not trustworthy → add confidence scores
- Hypothesis 3: Users don't care → A/B test removal, measure retention impact

**Rollback Trigger:**
- Algorithm error (false insights)
- Performance issue (insights calculation lags UI)
- User complaints about "inaccurate" insights > 5

---

## Implementation Order & Dependencies

### Phase 1: Quick-Log (Week 1)
**No dependencies**, can start immediately
- Refactor BingeEatingLogPage to accept optional pre-fill
- Create QuickLogWidget (time + place)
- Wire up to Firestore, add SnackBar flow
- **Tests:** Widget test (form renders), integration test (save flow)

### Phase 2: Urge Logging (Week 2)
**Depends on:** Firebase Cloud Messaging setup (for notifications)
- Create `urge_logs` collection schema
- Build UrgeLogSheet (trigger checklist, intensity slider)
- Implement coping prompt screen (hardcoded suggestions)
- Add local notification (30min delayed)
- **Tests:** Unit test (urge model), widget test (sheet), integration test (notification)

### Phase 3: Insight Engine (Week 3)
**Depends on:** F01 & F02 data (ideally 1+ weeks of real usage, but can mock)
- Create `insights` collection (or compute on-demand)
- Implement pattern detection algorithms (time clustering, mood correlation)
- Build Insights UI (Analytics page section)
- Create Recommendations page
- **Tests:** Unit tests (algorithm logic), integration test (end-to-end)

### Phase 4: QA & Polish (Week 4)
- Fix bugs from user testing
- Performance optimization (lazy-load insights)
- Accessibility audit (screen reader labels)
- Update README, ARCHITECTURE.md
- Write ReleaseNotes.md

---

## Cross-Feature Considerations

### 1. Data Model Consistency
- All new collections use `uid` (not `userId`) for consistency
- All timestamps use `FieldValue.serverTimestamp()` for accuracy
- Common fields: `createdAt`, `dateTime`, `uid`

### 2. Error Handling
- Reuse ErrorHandlerMixin across all new features
- Standard error messages from AppStrings
- Graceful degradation (e.g., insights load error → show "Try again later")

### 3. Offline Support
- Firestore SDK handles offline writes automatically
- Test: Enable airplane mode, log urge, re-enable → should sync
- Add offline banner (future): "Offline — changes will sync when online"

### 4. Analytics Privacy
- All analytics events are opt-in (add privacy toggle in Settings)
- No PII in event parameters (use IDs, not names/emails)
- Comply with GDPR: allow users to export/delete analytics data

---

## Risk Mitigation Matrix

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Firebase quota exceeded** | Low | High | Monitor usage dashboard, upgrade plan if needed |
| **Notification permissions denied** | Medium | Medium | Graceful prompt, fallback to in-app banner |
| **Insights algorithm inaccurate** | Medium | High | Start conservative (show only high-confidence patterns), A/B test |
| **Users don't adopt quick-log** | Medium | Medium | Feature flag, iterate on UX based on feedback |
| **Urge logging feels intrusive** | Low | High | Make opt-in, add "Disable urge prompts" setting |

---

## Success Definition (Overall)

**MVP Success = All 3 features shipped + 2 of 3 KPIs met:**

1. **Engagement:** DAU/MAU ratio increases by 10% (more daily usage)
2. **Value:** Binge frequency decreases 15% for users who log 3+ urges/week (app is working)
3. **Retention:** 7-day retention increases by 20% (users keep coming back)

**Measurement Window:** 4 weeks post-launch

---

## Next Actions

1. ✅ Create detailed UX specs in `docs/specs/` (F01, F02, F03)
2. ⏳ Set up feature flags (Firebase Remote Config or local flags)
3. ⏳ Mock Firebase in tests (fake_cloud_firestore, firebase_auth_mocks)
4. ⏳ Implement F02 (Quick-Log) first — fastest win
5. ⏳ Alpha test with 5-10 users before full rollout

---

**End of Plan**
