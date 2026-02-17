# Hijri Date Offset System - Quick Start Guide

## ✅ Implementation Complete

All code has been successfully implemented following Clean Architecture principles and your project's conventions.

## 📦 What Was Created

### 1. Data Layer
- **[hijri_remote_datasource.dart](data/datasources/hijri_remote_datasource.dart)**: Firebase Remote Config integration with safe fallbacks
- **[hijri_repository_impl.dart](data/repositories/hijri_repository_impl.dart)**: Repository implementation

### 2. Domain Layer
- **[hijri_repository.dart](domain/repositories/hijri_repository.dart)**: Repository interface (abstraction)
- **[get_hijri_date_usecase.dart](domain/usecases/get_hijri_date_usecase.dart)**: Business logic for getting adjusted Hijri dates

### 3. Presentation Layer
- **[hijri_date_state.dart](logic/states/hijri_date_state.dart)**: State classes
- **[hijri_date_cubit.dart](logic/cubit/hijri_date_cubit.dart)**: Cubit for state management
- **[hijri_date_usage_examples.dart](ui/examples/hijri_date_usage_examples.dart)**: 5 complete usage examples

### 4. Infrastructure
- **Updated [pubspec.yaml](../../../../pubspec.yaml)**: Added `firebase_remote_config: ^6.0.3`
- **Updated [dependency_injection.dart](../../../../core/di/dependency_injection.dart)**: Registered all components
- **Updated [main.dart](../../../../main.dart)**: Added Remote Config initialization

## 🚀 Next Steps

### Step 1: Install Dependencies
```bash
# Already done! But if you need to run again:
flutter pub get
```

### Step 2: Setup Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **Mishkat Al-Masabih**
3. Navigate to **Remote Config** in the left sidebar
4. Click **Add parameter**
5. Configure:
   - **Parameter key**: `hijri_offset`
   - **Default value**: `0`
   - **Description**: "Hijri date offset in days (0=no change, 1=add day, -1=subtract day)"
6. Click **Publish changes**

### Step 3: Use in Your Code

#### Option A: Simple Direct Usage (Recommended for most cases)
```dart
import 'package:mishkat_almasabih/features/hijri_date/domain/usecases/get_hijri_date_usecase.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';

// In your widget:
final hijriDate = getIt<GetHijriDateUseCase>().call();
Text('${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear} هـ');
```

#### Option B: With Cubit (For reactive UI)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/cubit/hijri_date_cubit.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/states/hijri_date_state.dart';

BlocProvider(
  create: (context) => getIt<HijriDateCubit>()..loadHijriDate(),
  child: BlocBuilder<HijriDateCubit, HijriDateState>(
    builder: (context, state) {
      if (state is HijriDateLoaded) {
        return Text('${state.hijriDate.hDay} ${state.hijriDate.getLongMonthName()}');
      }
      return CircularProgressIndicator();
    },
  ),
);
```

## 🎯 Real-World Scenario

### When Ramadan Starts 1 Day Earlier Than Calculated:

1. **User reports**: "Ramadan started yesterday, but app shows today"
2. **You**: Open Firebase Console → Remote Config
3. **You**: Change `hijri_offset` from `0` to `1`
4. **You**: Click "Publish changes"
5. **Result**: Within 1 hour (or on next app restart), all users see the correct date
6. **No app update needed!** ✅

### When to Reset:
After Ramadan, change `hijri_offset` back to `0` so calculated dates work normally again.

## 📁 File Structure Created

```
lib/features/hijri_date/
├── data/
│   ├── datasources/
│   │   └── hijri_remote_datasource.dart
│   └── repositories/
│       └── hijri_repository_impl.dart
├── domain/
│   ├── repositories/
│   │   └── hijri_repository.dart
│   └── usecases/
│       └── get_hijri_date_usecase.dart
├── logic/
│   ├── cubit/
│   │   └── hijri_date_cubit.dart
│   └── states/
│       └── hijri_date_state.dart
├── ui/
│   └── examples/
│       └── hijri_date_usage_examples.dart
├── README.md (comprehensive documentation)
└── QUICK_START.md (this file)
```

## 🧪 Testing It Out

### Test in Development Mode:

1. **Temporary change for testing**: In [main.dart](../../../../main.dart), find `_initializeRemoteConfig()` and change:
   ```dart
   minimumFetchInterval: const Duration(hours: 1),
   ```
   to:
   ```dart
   minimumFetchInterval: Duration.zero,  // Instant fetch for testing
   ```

2. **In Firebase Console**: Set `hijri_offset` to `1`

3. **In your app**: Call `refreshHijriDate()` or restart app

4. **Expected**: Hijri date shows tomorrow's date

5. **Don't forget**: Revert `Duration.zero` back to `Duration(hours: 1)` for production!

## ⚠️ Important Production Notes

1. ✅ **Default is 0**: Keep offset at 0 in Firebase until adjustment is needed
2. ✅ **Fetch interval**: Set to 1 hour for production (already done)
3. ✅ **No crashes**: System has complete fallback - never crashes if Firebase is down
4. ✅ **Offline support**: Last fetched value is cached locally
5. ✅ **RTL ready**: All example UI code is RTL-aware using `EdgeInsetsDirectional`

## 📚 Where to Learn More

- **Complete documentation**: [README.md](README.md)
- **Usage examples**: [hijri_date_usage_examples.dart](ui/examples/hijri_date_usage_examples.dart)
- **Firebase Remote Config**: https://firebase.google.com/docs/remote-config

## 💡 Integration Ideas

You can now integrate Hijri dates into:
- Home screen header (show current Hijri date)
- Prayer times screen (Islamic calendar context)
- Daily Hadith screen (Hijri date stamp)
- Profile screen (user's activity by Hijri date)
- Ramadan tasks (already has Hijri, can use centralized system)
- Any feature needing Islamic calendar

## ✨ Key Benefits

1. **No App Updates**: Change dates for all users instantly
2. **Production Ready**: Comprehensive error handling and fallbacks
3. **Clean Architecture**: Easy to test, maintain, and extend
4. **Type Safe**: Full Dart type safety with null-safety
5. **Performance**: Minimal overhead, cached values
6. **Documentation**: Extensively commented code

## 🎉 You're Ready!

The system is fully implemented and ready to use. Just set up the Firebase parameter and start using it in your UI!

For any questions, refer to the [comprehensive README](README.md).
