# Ramadan Remote Config - Bug Fix

## 🐛 The Problem You Reported

When setting:
- **`ramadan_start_offset`** = 1
- **`ramadan_total_days`** = 30

You saw:
- ❌ UI showed "اليوم 29 شعبان" (Day 29 Shaban) - WRONG
- ❌ Calendar selected date was 30 - WRONG
- ✅ Progress screen showed 30 days - CORRECT

## 🔍 Root Cause

The issue was that **the UI widgets were calculating the Hijri date directly** from `HijriCalendar.now()` without applying the Remote Config offset. 

The cubit's `_todayDayNumber()` method was applying the offset internally for calculations, but the `_hijriDateString()` method was NOT applying it when displaying the date.

## ✅ The Fix

### What Was Changed:

1. **In `ramadan_tasks_cubit.dart`**:
   - Created new method `_getAdjustedHijriDate()` that properly applies the offset
   - This method converts Hijri → Gregorian → adds offset days → converts back to Hijri
   - This properly handles month transitions (e.g., 30 Shaban → 1 Ramadan)
   - Updated `_hijriDateString()` to use the adjusted date
   - Updated `_todayDayNumber()` to use the adjusted date

2. **In `calendar_button.dart`**:
   - Removed the local `_hijriDateString()` method that was calculating date independently
   - Added `hijriDateString` as a required parameter
   - Now receives the adjusted date from the cubit state

3. **In `ramadan_progress.dart`**:
   - Removed the local `_hijriDateString()` method
   - Added `hijriDateString` as a required parameter
   - Now uses the adjusted date from the cubit state

4. **In `ramadan_tasks_screen.dart`**:
   - Updated to pass `state.hijriDateString` to `CalendarButton`

## 🧪 How to Test

### Scenario 1: Shaban Has 29 Days (Not 30)

**Setup in Firebase Console:**
```
ramadan_start_offset = 1
ramadan_total_days = 30
```

**Expected Behavior:**
- If actual date is 29 Shaban → App should show **30 Shaban**
- If actual date is 30 Shaban → App should show **1 Ramadan**
- Calendar should show the same adjusted date
- Progress should calculate based on adjusted dates

### Scenario 2: Normal Ramadan (30 Days)

**Setup in Firebase Console:**
```
ramadan_start_offset = 0
ramadan_total_days = 30
```

**Expected Behavior:**
- App shows actual Hijri date without adjustment
- All features work normally

### Scenario 3: Ramadan Has 29 Days

**Setup in Firebase Console:**
```
ramadan_start_offset = 0
ramadan_total_days = 29
```

**Expected Behavior:**
- Dates show normally
- Progress calculated out of 29 days (not 30)
- Calendar shows 29 days total

## 🎯 How It Works Now

```
User Opens App
    ↓
Cubit initializes
    ↓
`_getAdjustedHijriDate()` called
    ↓
1. Gets current Hijri date
2. Reads offset from Remote Config
3. Converts: Hijri → Gregorian
4. Adds offset days
5. Converts: Gregorian → Hijri (properly handles month change!)
    ↓
Adjusted date used for:
- Display string (_hijriDateString)
- Day number (_todayDayNumber)
- All calculations
    ↓
State includes correct hijriDateString
    ↓
Widgets display adjusted date
```

## 📋 Files Modified

1. `lib/features/ramadan_tasks/presentation/cubit/ramadan_tasks_cubit.dart`
2. `lib/features/ramadan_tasks/presentation/widgets/calendar_button.dart`
3. `lib/features/ramadan_tasks/presentation/widgets/ramadan_progress.dart`
4. `lib/features/ramadan_tasks/presentation/screens/ramadan_tasks_screen.dart`

## ✅ Verification Steps

After the fix:

1. **Set Remote Config**:
   - `ramadan_start_offset` = 1
   - `ramadan_total_days` = 30
   - Publish changes

2. **Restart the app** (or wait 1 hour for auto-fetch)

3. **Check Ramadan Tasks Screen**:
   - ✅ Date display should show **1 day ahead** of actual Hijri date
   - ✅ Calendar button should show the same adjusted date
   - ✅ Selected date in calendar should match displayed date

4. **Check Progress Screen**:
   - ✅ Date should match the adjusted date
   - ✅ Progress bars should calculate correctly
   - ✅ Total days shown should be 30

## 🎉 Expected Results

With `ramadan_start_offset = 1`:
- If today is **29 Shaban** → App shows **30 Shaban** ✅
- If today is **30 Shaban** → App shows **1 Ramadan** ✅
- All calculations use the adjusted day number ✅
- No inconsistencies between widgets ✅

## 🔄 Reset After Ramadan

Don't forget to reset after Ramadan:
```
ramadan_start_offset = 0
ramadan_total_days = 30
```

---

**Fix Date**: February 17, 2026  
**Status**: ✅ Implemented and Ready for Testing
