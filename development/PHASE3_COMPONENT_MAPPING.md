# Holos App - Phase 3: Health Platform Integrations

## Implementation Summary

Phase 3 adds real health platform integrations to the Holos app, connecting to Apple Health (iOS), Google Fit (Android), and Samsung Health (Android). This enables personalized AI suggestions based on real user health data.

---

## Files Created

### Services

| File | Description |
|------|-------------|
| `lib/services/health_service.dart` | Unified wrapper service for all health platforms (Apple, Google, Samsung) |
| `lib/services/apple_health_service.dart` | iOS HealthKit integration using `health` package |
| `lib/services/google_fit_service.dart` | Android Google Fit integration using `health` package |
| `lib/services/samsung_health_service.dart` | Android Samsung Health integration (stub implementation) |

### Screens

| File | Description |
|------|-------------|
| `lib/screens/health_integration/health_permissions_screen.dart` | Permissions screen for connecting health apps |

### Platform Configuration

| File | Description |
|------|-------------|
| `ios/Runner/Info.plist` | iOS HealthKit usage descriptions and permissions |
| `android/app/src/main/AndroidManifest.xml` | Android permissions for Google Fit access |

---

## Files Updated

| File | Changes |
|------|---------|
| `lib/screens/health_data/health_data_screen.dart` | Now uses real data from `HealthService` instead of mock |
| `lib/screens/ai_suggestion/ai_suggestion_screen.dart` | Uses health data for contextual AI suggestions |
| `lib/main.dart` | Added `/health-permissions` route |
| `pubspec.yaml` | Updated health package comments |

---

## Architecture

### Health Service Architecture

```
HealthService (Unified Interface)
    │
    ├── AppleHealthService (iOS only)
    │   └── Uses `health` package → HealthKit
    │
    ├── GoogleFitService (Android only)
    │   └── Uses `health` package → Google Fit API
    │
    └── SamsungHealthService (Android only)
        └── Stub implementation (uses health package indirectly)
```

### Data Flow

```
User grants permissions via HealthPermissionsScreen
    ↓
HealthService.requestPermission(platform)
    ↓
Platform-specific service requests authorization
    ↓
HealthService.getTodayData()
    ↓
Fetches data from all connected platforms
    ↓
Aggregates and returns HealthData object
    ↓
Screens display real metrics (steps, sleep, heart rate, workouts)
    ↓
AI suggestions are personalized based on health context
```

---

## Health Data Model

The `HealthData` model includes:

```dart
class HealthData {
  final String userId;
  final DateTime date;

  // Sleep Data
  final double? sleepDuration;      // in hours
  final double? sleepQuality;        // 0.0 to 1.0
  final double? deepSleepPercent;

  // Activity Data
  final int? steps;
  final int? activeCalories;
  final int? totalCaloriesBurned;
  final List<Workout>? workouts;

  // Stress/Heart Data
  final int? avgHeartRate;
  final int? heartRateVariability;
  final double? stressLevel;         // 0.0 to 1.0
}
```

---

## Key Features

### 1. Health Permissions Screen
- Lists all available platforms on the device
- One-tap connection for each platform
- Visual status indicators (Connected, Connecting, Not Connected)
- Explanatory text about why health data is needed

### 2. Real Health Data Display
- **Sleep Quality**: Duration, deep sleep %, quality score
- **Activity Level**: Steps, active/total calories, workouts
- **Stress Levels**: Heart rate, HRV, resting heart rate
- **Workouts**: List of today's workouts with icons

### 3. Contextual AI Suggestions
- Post-workout recovery meals (high protein)
- Light meals for low-activity days
- Sleep recovery meals (tryptophan-rich)
- Balanced meals for active days

### 4. Real-time Updates
- Subscribes to health data changes via platform observers
- Auto-refreshes when new data is available
- Manual "Sync Now" button

---

## Platform-Specific Notes

### iOS (Apple Health)
- Uses HealthKit via `health` package
- Requires HealthKit capability in Xcode
- Requires usage descriptions in Info.plist
- Background updates via HealthKitObserver

### Android (Google Fit)
- Uses Google Fit API via `health` package
- Requires OAuth consent from user
- Background updates via foreground service
- Requires Android 14+ Health Service API

### Android (Samsung Health)
- Stub implementation (package not mature)
- Recommend using Google Fit API instead
- Samsung Health data often syncs to Google Fit

---

## Testing Instructions

### iOS (iPhone/iPad)
1. Open app on iOS device/simulator
2. Navigate to Health Data screen
3. Grant HealthKit permissions when prompted
4. Verify real data appears (steps, sleep, etc.)
5. Add a workout in Apple Health → verify it appears in Holos

### Android (Phone/Tablet)
1. Open app on Android device/emulator
2. Navigate to Health Data screen
3. Grant Google Fit permissions when prompted
4. Verify real data appears
5. Add steps/workout in Google Fit → verify sync

### AI Suggestions
1. With health data connected, go to AI Suggestion screen
2. Verify contextual message based on:
   - Steps count (active day vs sedentary)
   - Sleep quality (poor sleep vs good sleep)
   - Workouts (post-workout recovery)

---

## Dependencies

```yaml
dependencies:
  health: ^10.1.0              # Apple Health, Google Fit
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
```

---

## Next Steps (Phase 4)

1. **Firebase Backend Integration**
   - User authentication
   - Cloud Firestore for data sync
   - User preferences sync across devices

2. **Enhanced AI Integration**
   - Connect GeminiService with real health data
   - Generate actual AI meal suggestions
   - Personalized recipe recommendations

3. **Notification Triggers**
   - "Hydrate reminder" after high activity
   - "Recovery meal" after workout detected
   - "Sleep improvement tips" after poor sleep

---

## Component Mapping (Phase 3)

### Screens Created/Updated

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Health Permissions | `/health-permissions` | `health_permissions_screen.dart` | ✅ NEW |
| Health Data | `/health-data` | `health_data_screen.dart` | ✅ UPDATED |
| AI Suggestion | `/ai-suggestion` | `ai_suggestion_screen.dart` | ✅ UPDATED |

### Services Created

| Service | Description | Status |
|---------|-------------|--------|
| HealthService | Unified interface for all platforms | ✅ NEW |
| AppleHealthService | iOS HealthKit integration | ✅ NEW |
| GoogleFitService | Google Fit integration | ✅ NEW |
| SamsungHealthService | Samsung Health integration (stub) | ✅ NEW |

### Models Used

| Model | Description | Status |
|-------|-------------|--------|
| HealthData | Main health data container | ✅ EXISTING |
| Workout | Workout sub-model | ✅ EXISTING |

### Widgets Used

| Widget | Usage |
|--------|-------|
| BaseCard | Platform option cards, metric cards |
| PrimaryButton | Connect, sync, continue buttons |
| DetailedHealthMetricCard | Health metrics display |
| ProgressBar | Metric progress visualization |
| AppTextStyles | Consistent typography |
| AppColors | Consistent colors |

---

## Error Handling

- Permission denied → Show user-friendly message with option to retry
- Platform not available → Hide platform option
- Data fetch failed → Show error snackbar, retry option
- Empty state → Friendly message prompting to connect apps

---

## Accessibility

- All buttons have descriptive labels
- Loading states with progress indicators
- Error messages in clear, simple language
- Color-blind friendly progress indicators (icon + color)
