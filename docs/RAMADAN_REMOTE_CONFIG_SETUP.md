# Ramadan Remote Config System - Setup Guide

## 🌙 Overview

This system allows you to control Ramadan dates and progress remotely via Firebase Remote Config. It solves the critical issue that **Islamic months (Shaban & Ramadan) can be 29 or 30 days** based on moon sighting, which isn't known until official announcements.

### Why This Matters for Production Apps

- **Shaban**: Can be 29 or 30 days → affects when Ramadan starts
- **Ramadan**: Can be 29 or 30 days → affects progress calculations
- **Moon Sighting**: Not known until official announcement
- **Your Solution**: Adjust dates instantly for all users without app updates!

---

## 🚀 Firebase Console Setup

### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **Mishkat Al-Masabih**
3. Navigate to **Remote Config** in the left sidebar

### Step 2: Add Parameters

#### Parameter 1: `ramadan_start_offset`
- **Key**: `ramadan_start_offset`
- **Type**: Number
- **Default value**: `0`
- **Description**: "Days to adjust Ramadan start date (0=no change, +1=start earlier, -1=start later)"

**When to use:**
- **0**: Shaban has 30 days (use calculated date) - DEFAULT
- **+1**: Shaban has 29 days (Ramadan starts 1 day earlier)
- **-1**: Manual correction if needed

#### Parameter 2: `ramadan_total_days`
- **Key**: `ramadan_total_days`
- **Type**: Number
- **Default value**: `30`
- **Description**: "Total days in Ramadan (29 or 30 based on moon sighting)"

**When to use:**
- **30**: Ramadan has 30 days (full month) - DEFAULT
- **29**: Ramadan has 29 days (announced after moon sighting)

### Step 3: Publish Changes
Click **"Publish changes"** to make the configuration live.

---

## 📅 Real-World Scenarios

### Scenario 1: Shaban is Announced to Have 29 Days

**Problem**: App calculated Shaban as 30 days, but official announcement says 29 days.
**Result**: Ramadan starts 1 day earlier than calculated.

**Solution**:
1. Open Firebase Console → Remote Config
2. Change `ramadan_start_offset` from `0` to `1`
3. Keep `ramadan_total_days` at `30`
4. Publish changes
5. **All users see correct date within 1 hour (or on app restart)**

### Scenario 2: Ramadan is Announced to Have 29 Days

**Problem**: After 28 days of Ramadan, moon sighting confirms Eid is tomorrow (29th day).
**Result**: Ramadan has only 29 days, not 30.

**Solution**:
1. Open Firebase Console → Remote Config
2. Change `ramadan_total_days` from `30` to `29`
3. Publish changes
4. **All users see correct progress and total days**
5. Progress calculations adjust automatically

### Scenario 3: Both Shaban and Ramadan are 29 Days

**Solution**:
1. Set `ramadan_start_offset` = `1` (for Shaban's 29 days)
2. Set `ramadan_total_days` = `29` (for Ramadan's 29 days)
3. Publish changes

### Scenario 4: Back to Normal (After Ramadan)

**Solution**:
1. Reset `ramadan_start_offset` to `0`
2. Reset `ramadan_total_days` to `30`
3. Publish changes

---

## 🔧 How It Works

### Architecture

```
User Opens App
    ↓
main.dart initializes Remote Config
    ↓
Fetches ramadan_start_offset & ramadan_total_days
    ↓
RamadanTasksCubit uses config values
    ↓
Calculates current day with offset
    ↓
Displays correct dates and progress
```

### Key Components

1. **RamadanConfigRemoteDataSource**: Fetches from Firebase
2. **RamadanConfigRepository**: Provides data to domain layer
3. **RamadanTasksCubit**: Uses config for calculations
4. **All Widgets**: Automatically use correct values from state

---

## 📊 What Gets Adjusted

### ✅ Automatically Adjusted:
- Current Ramadan day calculation
- Progress percentage (daily, weekly, overall)
- Calendar display (shows 29 or 30 days)
- Week ranges (last week ends at day 29 or 30)
- Task completion tracking
- All date displays

### ✅ Safe Fallbacks:
If Remote Config fails:
- `ramadan_start_offset` defaults to `0`
- `ramadan_total_days` defaults to `30`
- App continues to work normally

---

## 🧪 Testing Before Production

### Test Scenario 1: Ramadan Starts Earlier
1. **In Firebase Console**:
   - Set `ramadan_start_offset` = `1`
   - Keep `ramadan_total_days` = `30`
   - Publish

2. **Expected Result**:
   - If current Hijri date is 1 Ramadan, app shows 2 Ramadan
   - If current Hijri date is 15 Ramadan, app shows 16 Ramadan

3. **Verify**:
   - Open Ramadan Tasks screen
   - Check date display matches expected
   - Check progress calculations are correct

### Test Scenario 2: Ramadan Has 29 Days
1. **In Firebase Console**:
   - Set `ramadan_start_offset` = `0`
   - Set `ramadan_total_days` = `29`
   - Publish

2. **Expected Result**:
   - Calendar shows 29 days (not 30)
   - Progress calculated out of 29 days
   - Last week (week 4) ends at day 29

3. **Verify**:
   - Open Ramadan Tasks screen
   - Check calendar has 29 days
   - Check progress shows "X/29" not "X/30"

---

## ⚙️ Configuration Details

### Fetch Settings
- **Fetch Timeout**: 10 seconds
- **Minimum Fetch Interval**: 1 hour (production)
- **Cache**: Values cached locally for offline use

### When Values Update
- **On app start**: Always fetches latest
- **During use**: Re-fetches every 1 hour (if app is open)
- **Offline**: Uses last cached values

### For Testing (Instant Updates)
Temporarily change in `main.dart`:
```dart
minimumFetchInterval: Duration.zero, // For testing only!
```
**⚠️ Don't forget to revert to `Duration(hours: 1)` for production!**

---

## 📱 User Impact

### What Users See:
✅ Correct Ramadan dates always
✅ Accurate progress calculations
✅ Proper calendar display (29 or 30 days)
✅ No app update required
✅ Changes take effect within 1 hour

### What Users DON'T See:
❌ No loading delays
❌ No broken features if config fails
❌ No crashes
❌ No need to manually update app

---

## 🔍 Monitoring & Verification

### How to Verify It's Working:
1. After changing config in Firebase, wait 1 hour
2. OR restart the app immediately
3. Check Ramadan Tasks screen
4. Verify:
   - Date displays match expected
   - Progress calculations are correct
   - Calendar shows correct total days

### Logs to Check:
If there are issues, check logs for:
```
Failed to fetch Ramadan Remote Config: [error]
Failed to read ramadan_start_offset: [error]
Failed to read ramadan_total_days: [error]
```

---

## ✅ Production Checklist

Before Ramadan starts:
- [ ] Verify Firebase Remote Config is set up
- [ ] Parameters exist: `ramadan_start_offset`, `ramadan_total_days`
- [ ] Default valuesset: `0` and `30`
- [ ] Test with different values
- [ ] Verify fallback works (disable Firebase temporarily)
- [ ] Document the process for your team

During Ramadan:
- [ ] Monitor moon sighting announcements
- [ ] Be ready to update `ramadan_start_offset` before Ramadan
- [ ] Be ready to update `ramadan_total_days` on 29th day
- [ ] Verify changes propagate to users
- [ ] Reset values after Ramadan ends

---

## 🎯 Quick Reference

### Common Firebase Config Values

| Situation | ramadan_start_offset | ramadan_total_days |
|-----------|---------------------|-------------------|
| Normal (default) | 0 | 30 |
| Shaban is 29 days | +1 | 30 |
| Ramadan is 29 days | 0 | 29 |
| Both are 29 days | +1 | 29 |
| Manual correction needed | -1 or +1 | 29 or 30 |

---

## 💡 Pro Tips

1. **Set values BEFORE Ramadan starts**: Update `ramadan_start_offset` as soon as Shaban moon sighting is announced.

2. **Update on day 28**: On 28th of Ramadan, be ready to update `ramadan_total_days` based on moon sighting.

3. **Reset after Ramadan**: Don't forget to reset both values to defaults after Eid.

4. **Test first**: Always test config changes in a test project first if possible.

5. **Monitor Firebase quota**: Remote Config is free but has limits. Current settings (1 hour fetch) are well within limits.

---

## 🆘 Troubleshooting

### Problem: Values not updating
**Solution**: 
- Wait 1 hour for automatic fetch
- OR restart the app
- OR (for testing) set `minimumFetchInterval: Duration.zero`

### Problem: App crashes on startup
**Solution**: This shouldn't happen (fallbacks in place), but check:
- Firebase is properly initialized
- Dependencies are registered in GetIt
- Default values are set in `main.dart`

### Problem: Wrong dates showing
**Solution**:
- Verify Firebase Console values are correct
- Check values are published (not just saved)
- Verify device/emulator date is correct
- Check logs for config fetch errors

---

## 📚 Technical Details

### Files Modified:
1. `ramadan_config_remote_datasource.dart` - Firebase integration
2. `ramadan_config_repository_impl.dart` - Repository implementation
3. `ramadan_config_repository.dart` - Repository interface
4. `ramadan_tasks_cubit.dart` - Uses config for calculations
5. `ramadan_tasks_state.dart` - Includes totalDays in state
6. `compute_progress.dart` - Updated to use totalDays
7. `dependency_injection.dart` - Registers config components
8. `main.dart` - Initializes Remote Config

### Dependencies:
- `firebase_remote_config: ^6.0.3` (already in pubspec.yaml)

---

## 🎉 You're Ready!

The system is fully implemented and production-ready. Just configure the parameters in Firebase Console and you're good to go!

For any questions, refer to the code comments or this documentation.
