# Hijri Date Offset System

A production-ready system for managing Hijri (Islamic) dates with remote configuration using Firebase Remote Config and Clean Architecture.

## 🎯 Purpose

Islamic calendar dates are traditionally based on moon sighting, but mobile apps use astronomical calculations. These calculations can differ from official announcements by 1-2 days, especially for important dates like Ramadan and Eid.

This system allows you to **instantly adjust Hijri dates for all users without updating the app** by changing a single value in Firebase Remote Config.

## 📁 Architecture

The implementation follows Clean Architecture principles:

```
lib/features/hijri_date/
├── data/
│   ├── datasources/
│   │   └── hijri_remote_datasource.dart    # Firebase Remote Config integration
│   └── repositories/
│       └── hijri_repository_impl.dart       # Repository implementation
├── domain/
│   ├── repositories/
│   │   └── hijri_repository.dart            # Repository interface
│   └── usecases/
│       └── get_hijri_date_usecase.dart      # Business logic
├── logic/
│   ├── cubit/
│   │   └── hijri_date_cubit.dart            # State management
│   └── states/
│       └── hijri_date_state.dart            # UI states
└── ui/
    └── examples/
        └── hijri_date_usage_examples.dart   # 5+ usage examples
```

## 🚀 Setup

### 1. Install Dependencies

The package is already added to `pubspec.yaml`:
```yaml
dependencies:
  firebase_remote_config: ^6.0.3
  hijri: ^3.0.0
```

Run:
```bash
flutter pub get
```

### 2. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Remote Config** in the left sidebar
4. Click **Add parameter**
5. Configure:
   - **Parameter key**: `hijri_offset`
   - **Value**: `0` (default, no adjustment)
   - **Data type**: Number
6. Click **Publish changes**

### 3. Dependency Injection

Already configured in `lib/core/di/dependency_injection.dart`:
```dart
// Hijri Date feature (Firebase Remote Config)
getIt.registerLazySingleton<FirebaseRemoteConfig>(
  () => FirebaseRemoteConfig.instance,
);
getIt.registerLazySingleton<HijriRemoteDataSource>(
  () => HijriRemoteDataSourceImpl(remoteConfig: getIt()),
);
getIt.registerLazySingleton<HijriRepository>(
  () => HijriRepositoryImpl(remoteDataSource: getIt()),
);
getIt.registerLazySingleton<GetHijriDateUseCase>(
  () => GetHijriDateUseCase(repository: getIt()),
);
getIt.registerFactory<HijriDateCubit>(
  () => HijriDateCubit(
    getHijriDateUseCase: getIt(),
    repository: getIt(),
  ),
);
```

### 4. Initialization

Already configured in `lib/main.dart`:
```dart
Future<void> main() async {
  // ... other initialization ...
  
  // Initialize Firebase Remote Config for Hijri date offset
  await _initializeRemoteConfig();
  
  // ... rest of app initialization ...
}
```

## 📖 Usage

### Method 1: Direct UseCase (Simplest)

Use this for simple, one-time date display:

```dart
import 'package:mishkat_almasabih/features/hijri_date/domain/usecases/get_hijri_date_usecase.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hijriDate = getIt<GetHijriDateUseCase>().call();
    
    return Text(
      '${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear} هـ',
    );
  }
}
```

### Method 2: With Cubit (Full Features)

Use this for reactive UI with loading states and refresh:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/cubit/hijri_date_cubit.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/states/hijri_date_state.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HijriDateCubit>()..loadHijriDate(),
      child: BlocBuilder<HijriDateCubit, HijriDateState>(
        builder: (context, state) {
          if (state is HijriDateLoaded) {
            return Text(
              '${state.hijriDate.hDay} ${state.hijriDate.getLongMonthName()} ${state.hijriDate.hYear} هـ',
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### Method 3: Reusable Widget

Create a simple widget for consistent usage:

```dart
class HijriDateWidget extends StatelessWidget {
  final TextStyle? style;
  
  const HijriDateWidget({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final hijriDate = getIt<GetHijriDateUseCase>().call();
    
    return Text(
      '${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear} هـ',
      style: style,
    );
  }
}
```

## 🎛️ Adjusting Dates

### Scenario 1: Ramadan starts 1 day earlier than calculated

1. Open Firebase Console > Remote Config
2. Change `hijri_offset` from `0` to `1`
3. Publish changes
4. Users will see the adjusted date within 1 hour (or on next app restart)

### Scenario 2: Date is 1 day ahead of official announcement

1. Change `hijri_offset` to `-1`
2. Publish changes

### Scenario 3: Date matches calculations

1. Keep `hijri_offset` at `0`

## 🔧 Configuration Details

### Remote Config Settings

**Fetch Interval**: 1 hour
```dart
minimumFetchInterval: const Duration(hours: 1)
```

**Timeout**: 10 seconds
```dart
fetchTimeout: const Duration(seconds: 10)
```

**Default Value**: 0 (no offset)
```dart
'hijri_offset': 0
```

### Fallback Behavior

The system is designed to **never crash**:

1. If Remote Config fetch fails → uses offset = 0
2. If the key doesn't exist → uses offset = 0
3. If Firebase is down → continues with cached value or 0
4. All errors are caught and logged, app continues normally

## 🧪 Testing

### Test with Different Offsets

1. **In Development**: 
   - Set `minimumFetchInterval: Duration.zero` for instant testing
   - Change offset in Firebase Console
   - Call `refreshHijriDate()` in your Cubit

2. **Test Scenarios**:
   ```dart
   // Test +1 day offset
   // Firebase: hijri_offset = 1
   // Expected: Tomorrow's Hijri date
   
   // Test -1 day offset
   // Firebase: hijri_offset = -1
   // Expected: Yesterday's Hijri date
   
   // Test 0 offset
   // Firebase: hijri_offset = 0
   // Expected: Today's calculated date
   ```

### Mock for Unit Tests

```dart
class MockHijriRepository extends Mock implements HijriRepository {}

void main() {
  test('GetHijriDateUseCase applies offset correctly', () {
    final mockRepo = MockHijriRepository();
    when(() => mockRepo.getHijriDateOffset()).thenReturn(1);
    
    final useCase = GetHijriDateUseCase(repository: mockRepo);
    final result = useCase.call();
    
    // Assert result is tomorrow's date
  });
}
```

## 📊 Complete Example Files

See these files for complete working examples:

1. **5 Usage Patterns**: [hijri_date_usage_examples.dart](ui/examples/hijri_date_usage_examples.dart)
   - BlocBuilder with full states
   - Direct UseCase usage
   - AppBar integration
   - Reusable widget
   - Home screen example

## ⚠️ Important Notes

### For Production

1. ✅ **Always keep default offset at 0** in Remote Config until adjustment is needed
2. ✅ **Test offset changes** before publishing during non-critical times
3. ✅ **Monitor Firebase quota** - Remote Config is free but has limits
4. ✅ **Set proper fetch intervals** - Current: 1 hour (good for production)
5. ✅ **Don't rely on instant updates** - Users get new offset within 1 hour or on restart

### Security

- Remote Config is **read-only** from the app
- Only Firebase Console admins can modify values
- No API keys or secrets in client code
- All values are cached locally for offline use

### Performance

- **First fetch**: ~100-500ms (on app start)
- **Subsequent calls**: Instant (uses cached value)
- **Memory**: Negligible (~1KB for config data)
- **Battery**: Minimal impact (fetches every 1 hour at most)

## 🐛 Troubleshooting

### Issue: Date not updating after changing Remote Config

**Solution**: 
- Wait up to 1 hour (fetch interval)
- OR restart the app
- OR call `refreshHijriDate()` in UI

### Issue: Getting offset = 0 when it should be different

**Check**:
1. Firebase Console: Is parameter named exactly `hijri_offset`?
2. Firebase Console: Is value published (not just saved as draft)?
3. Is Firebase initialized in `main.dart`?
4. Check logs for Remote Config errors

### Issue: App crashes on startup

**Check**:
1. Firebase is initialized before Remote Config
2. All dependencies registered in GetIt
3. Check error logs - the system should never crash due to Remote Config

## 📝 Maintenance

### Regular Tasks

- **Monthly**: Review if offset adjustments are still needed
- **Before Ramadan**: Set offset to 0, monitor for announcements
- **Before Eid**: Adjust offset based on moon sighting announcements
- **After Events**: Reset offset to 0 if it was adjusted

### Monitoring

Add to your Firebase Crashlytics custom logs:
```dart
FirebaseCrashlytics.instance.log('Hijri offset applied: $offset');
```

## 🎓 Learning Resources

- [Firebase Remote Config Docs](https://firebase.google.com/docs/remote-config)
- [Hijri Package](https://pub.dev/packages/hijri)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📄 License

Part of the Mishkat Al-Masabih app.
