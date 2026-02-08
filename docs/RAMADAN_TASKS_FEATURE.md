# Ramadan Tasks & Progress Feature — Technical Documentation

> **Version:** 1.2.0  
> **Last Updated:** February 8, 2026  
> **Platform:** Flutter (Dart ≥ 3.7.0)  
> **Architecture:** Clean Architecture + Cubit (BLoC)  
> **Persistence:** Hive (local, offline-first)

---

## Table of Contents
1. [Feature Overview](#1-feature-overview)
2. [Architecture & Folder Structure](#2-architecture--folder-structure)
3. [Domain Layer (Business Logic)](#3-domain-layer-business-logic)
   - 3.1 [Entity: RamadanTaskEntity](#31-entity-ramadantaskentity)
   - 3.2 [Repository Interface](#32-repository-interface)
   - 3.3 [Use Cases](#33-use-cases)
4. [Data Layer (Persistence)](#4-data-layer-persistence)
   - 4.1 [Hive Model & TypeAdapter](#41-hive-model--typeadapter)
   - 4.2 [Local DataSource](#42-local-datasource)
   - 4.3 [Repository Implementation](#43-repository-implementation)
5. [Presentation Layer (UI & State)](#5-presentation-layer-ui--state)
   - 5.1 [Cubit & State](#51-cubit--state)
   - 5.2 [Main Page](#52-main-page-ramadantaskspage)
   - 5.3 [Widgets](#53-widgets)
6. [Integration Points](#6-integration-points)
   - 6.1 [Dependency Injection (GetIt)](#61-dependency-injection-getit)
   - 6.2 [Routing](#62-routing)
   - 6.3 [Home Screen Entry](#63-home-screen-entry)
   - 6.4 [Hive Initialization](#64-hive-initialization)
7. [Data Flow Diagrams](#7-data-flow-diagrams)
8. [Progress Calculation Formulas](#8-progress-calculation-formulas)
9. [View Modes & Filtering Logic](#9-view-modes--filtering-logic)
10. [Calendar Sheet Feature](#10-calendar-sheet-feature)
11. [Bug Fixes & Design Decisions](#11-bug-fixes--design-decisions)
12. [Performance Considerations](#12-performance-considerations)
13. [RTL & Theming](#13-rtl--theming)
14. [Known Limitations & Future Improvements](#14-known-limitations--future-improvements)

---

## 1. Feature Overview

The **Ramadan Tasks** feature allows users to define, track, and review personal Islamic tasks throughout the 30 days of Ramadan. Users can create:

- **Daily tasks** — repeat every day (e.g., "قراءة جزء من القرآن", "صلاة التراويح")
- **Monthly tasks** — one-time goals for the entire month (e.g., "ختم القرآن", "إخراج زكاة الفطر")

The feature provides:

| Capability | Description |
|---|---|
| Task CRUD | Add, view, toggle completion, delete tasks |
| Three view modes | Today (editable), History (read-only, any day), All (full list) |
| Progress tracking | Daily %, monthly %, weekly % with animated indicators |
| Calendar view | 30-day heatmap grid with completion ratios, stats, streaks |
| Motivational messages | Shown when all daily tasks are completed |
| History browsing | Week selector → day selector to inspect any past day |
| Offline-first | All data persisted locally via Hive — no internet required |

---

## 2. Architecture & Folder Structure

The feature follows **Clean Architecture** with three layers:

```
lib/features/ramadan_tasks/
├── domain/                          ← Business rules (no Flutter imports)
│   ├── entities/
│   │   └── ramadan_task_entity.dart     ← Core entity + TaskType enum
│   ├── repositories/
│   │   └── ramadan_tasks_repository.dart ← Abstract interface
│   └── usecases/
│       ├── add_task.dart
│       ├── delete_task.dart
│       ├── get_tasks.dart
│       ├── update_task.dart
│       ├── toggle_daily_completion.dart
│       ├── set_monthly_completed.dart
│       ├── ensure_daily_reset.dart
│       └── compute_progress.dart        ← Pure progress math
│
├── data/                            ← Persistence layer
│   ├── models/
│   │   └── ramadan_task_model.dart      ← Hive model + TypeAdapter
│   ├── datasources/
│   │   └── ramadan_tasks_local_datasource.dart ← Hive box CRUD
│   └── repositories/
│       └── ramadan_tasks_repository_impl.dart   ← Concrete impl
│
└── presentation/                    ← UI layer
    ├── cubit/
    │   ├── ramadan_tasks_cubit.dart      ← State management
    │   └── ramadan_tasks_state.dart      ← State classes
    ├── pages/
    │   └── ramadan_tasks_page.dart       ← Main screen (865 lines)
    └── widgets/
        ├── ramadan_progress.dart         ← Animated progress card
        ├── ramadan_task_item.dart        ← Single task card
        └── ramadan_calendar_sheet.dart   ← 30-day calendar bottom sheet
```

**Dependency direction:** `presentation → domain ← data`  
The domain layer has zero dependency on Flutter or Hive.

---

## 3. Domain Layer (Business Logic)

### 3.1 Entity: RamadanTaskEntity

**File:** `domain/entities/ramadan_task_entity.dart`

```dart
enum TaskType { daily, monthly }

class RamadanTaskEntity {
  final String id;             // Unique ID (microsecondsSinceEpoch)
  final String title;          // User-visible name
  final TaskType type;         // daily or monthly
  final Set<int> completedDays; // Days (1..30) when completed
}
```

**Key design decisions:**

| Aspect | Decision | Rationale |
|---|---|---|
| `completedDays` type | `Set<int>` | O(1) lookup for "is completed on day X?" |
| ID generation | `DateTime.now().microsecondsSinceEpoch` | Unique enough for local-only storage |
| `operator ==` | Deep set comparison | So Cubit can detect meaningful changes |
| `hashCode` | `Object.hashAll(sorted)` on `completedDays` | Consistent with deep equality (bug fix) |
| `copyWith` | Full immutable copy | Required for state updates without mutation |

**The `_setEquals` helper** performs element-by-element comparison since Dart's default `Set` equality is identity-based.

### 3.2 Repository Interface

**File:** `domain/repositories/ramadan_tasks_repository.dart`

```dart
abstract class RamadanTasksRepository {
  Future<List<RamadanTaskEntity>> getTasks();
  Future<void> addTask(RamadanTaskEntity task);
  Future<void> updateTask(RamadanTaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> toggleDailyCompletion({required String id, required int day});
  Future<void> setMonthlyCompleted({required String id, required bool completed, required int day});
  Future<void> ensureDailyReset(int day);
}
```

7 methods covering the full task lifecycle. The interface lives in the domain layer so the Cubit never knows about Hive.

### 3.3 Use Cases

Each use case is a single-purpose callable class following the `call()` convention:

| Use Case | Signature | Purpose |
|---|---|---|
| `GetTasks` | `() → Future<List<RamadanTaskEntity>>` | Fetch all tasks from storage |
| `AddTask` | `(RamadanTaskEntity) → Future<void>` | Persist a new task (ID auto-generated if empty) |
| `UpdateTask` | `(RamadanTaskEntity) → Future<void>` | Update an existing task |
| `DeleteTask` | `(String id) → Future<void>` | Remove a task by ID |
| `ToggleDailyCompletion` | `({id, day}) → Future<void>` | Add/remove a day from completedDays |
| `SetMonthlyCompleted` | `({id, completed, day}) → Future<void>` | Mark/unmark a monthly task |
| `EnsureDailyReset` | `(int day) → Future<void>` | No-op (preserves history — see §11) |
| `ComputeProgress` | `({tasks, day, weekStart, weekEnd}) → ProgressResult` | Pure math — no I/O (see §8) |

**`ComputeProgress`** is the only use case that doesn't touch the repository — it's a pure function that takes a task list and returns computed percentages.

---

## 4. Data Layer (Persistence)

### 4.1 Hive Model & TypeAdapter

**File:** `data/models/ramadan_task_model.dart`

```
RamadanTaskModel
├── id: String              (field 0)
├── title: String           (field 1)
├── typeIndex: int          (field 2)  → 0=daily, 1=monthly
└── completedDays: List<int> (field 3) → stored as List for Hive compat
```

**TypeAdapter** (`typeId: 33`):
- **Manual implementation** — no `hive_generator` code-gen dependency
- Reads/writes 4 fields with explicit byte field indices
- Converts between `List<int>` (Hive) ↔ `Set<int>` (Entity) via `fromEntity()` / `toEntity()`

**Conversion methods:**

| Method | Direction | Notes |
|---|---|---|
| `fromEntity(e)` | Entity → Model | Sorts `completedDays` before storing |
| `toEntity()` | Model → Entity | Converts `List` back to `Set` |

### 4.2 Local DataSource

**File:** `data/datasources/ramadan_tasks_local_datasource.dart`

Thin wrapper around a Hive `Box<RamadanTaskModel>`:

```dart
class RamadanTasksLocalDataSource {
  Box<RamadanTaskModel>? _box;

  Future<void> init()              // Register adapter + open box (lazy)
  Future<List<RamadanTaskModel>> getAll()  // Read all values
  Future<void> put(model)          // Put by model.id key
  Future<void> delete(String id)   // Delete by key
}
```

**Lazy initialization:** `init()` is called before every operation, but the adapter registration and box opening only happen once (guarded by `_box ??=` and `Hive.isAdapterRegistered(33)`).

**Box name:** `'ramadan_tasks'` (defined in `HiveService.ramadanTasksBox`).

### 4.3 Repository Implementation

**File:** `data/repositories/ramadan_tasks_repository_impl.dart`

The concrete `RamadanTasksRepositoryImpl` adds business logic on top of the raw datasource:

#### `addTask`
- If `task.id` is empty, generates a unique ID from `DateTime.now().microsecondsSinceEpoch`
- Converts entity → model and persists via `_ds.put()`

#### `toggleDailyCompletion`
1. Fetches all tasks, finds the target by ID
2. Validates it's a `daily` type (throws `StateError` otherwise)
3. **Adds** the day if not present, **removes** if already present
4. Preserves all other days' completions (history-safe)

#### `setMonthlyCompleted`
1. Fetches all tasks, finds the target by ID
2. Validates it's a `monthly` type
3. If `completed=true`: adds the day to `completedDays`
4. If `completed=false`: clears all days (uncompletes)

#### `ensureDailyReset`
- **Intentionally a no-op** — see [Bug Fixes §11](#11-bug-fixes--design-decisions)
- Previously wiped all past completions, destroying history
- Daily "completed today?" check is handled at the UI/Cubit level instead

---

## 5. Presentation Layer (UI & State)

### 5.1 Cubit & State

**File:** `presentation/cubit/ramadan_tasks_cubit.dart`

#### ViewMode enum:
```dart
enum ViewMode { today, history, all }
```

#### State classes:
```
RamadanTasksState (abstract)
├── RamadanTasksLoading        — Initial/refresh loading
├── RamadanTasksError          — Error with Arabic message
└── RamadanTasksLoaded         — All UI data
    ├── allTasks               — Full unfiltered list
    ├── filteredTasks          — Filtered by current viewMode
    ├── todayDay               — Current Ramadan day (1..30)
    ├── selectedDay            — Day being inspected in History
    ├── selectedWeek           — Active week tab (1..4)
    ├── weekStart / weekEnd    — Day range for selected week
    ├── viewMode               — today | history | all
    ├── dailyPercent           — 0.0–1.0
    ├── monthlyPercent         — 0.0–1.0
    ├── weeklyPercent          — 0.0–1.0
    ├── dailyCompleted         — Count for summary
    ├── dailyTotal             — Count for summary
    ├── motivationalText       — Nullable string
    ├── isReadOnly (getter)    — true when viewMode == history
    └── displayDay (getter)    — selectedDay in history, todayDay otherwise
```

#### Cubit public API:

| Method | Triggers I/O | Description |
|---|---|---|
| `init()` | ✅ Hive read | Initial load — sets todayDay, fetches tasks, emits loaded |
| `addNewTask({title, type})` | ✅ Hive write+read | Creates new task, refreshes cache |
| `deleteById(id)` | ✅ Hive delete+read | Deletes task, refreshes cache |
| `toggleDaily(id)` | ✅ Hive write+read | Toggles today's completion for a daily task |
| `setMonthly(id, completed)` | ✅ Hive write+read | Marks/unmarks monthly task |
| `setViewMode(mode)` | ❌ Cache only | Switches view, resets selectedDay for history |
| `setSelectedWeek(week)` | ❌ Cache only | Changes week, clamps selectedDay |
| `setSelectedDay(day)` | ❌ Cache only | Changes inspected day in history |

#### Internal caching strategy:

```
_allTasks (cached in memory)
    │
    ├─ I/O operations (init, add, delete, toggle, setMonthly)
    │   └─ _allTasks = await _getTasks()  ← re-fetches from Hive
    │
    └─ Filter/selection changes (setViewMode, setSelectedWeek, setSelectedDay)
        └─ Uses cached _allTasks directly ← no Hive I/O
```

This means switching tabs, selecting weeks, or browsing history days is **instant** — no disk reads.

#### `_emitLoaded()` flow:
1. Get `todayDay` from `DateTime.now().day.clamp(1, 30)`
2. Compute week range from `_selectedWeek`
3. Run `ComputeProgress` with appropriate day (today or selected)
4. Filter tasks based on current `_viewMode`
5. Generate motivational text if all daily tasks are done
6. Emit `RamadanTasksLoaded` with all computed fields

#### `_filterTasks()` logic:

| ViewMode | Filter Rule |
|---|---|
| `today` | All daily tasks + monthly tasks where `completedDays.isEmpty` |
| `history` | All tasks (unmodifiable copy) |
| `all` | All tasks (unmodifiable copy) |

#### `_todayDayNumber()`:
```dart
int _todayDayNumber() => DateTime.now().day.clamp(1, 30);
```
Returns the day-of-month clamped to 1–30 (Ramadan has 29–30 days).

#### Week mapping:
| Week | Days |
|---|---|
| 1 | 1 – 7 |
| 2 | 8 – 14 |
| 3 | 15 – 21 |
| 4 | 22 – 30 |

### 5.2 Main Page: RamadanTasksPage

**File:** `presentation/pages/ramadan_tasks_page.dart` (865 lines)

A `StatelessWidget` that builds the entire screen using `BlocBuilder`.

#### Screen layout (top to bottom):

```
┌─────────────────────────────────┐
│  BuildHeaderAppBar              │  ← Purple gradient header
│  "مهام رمضان"                   │
├─────────────────────────────────┤
│  RamadanProgress                │  ← Circular + bar progress
│  (gradient purple card)         │
├─────────────────────────────────┤
│  [اليوم] [السجل] [الكل]  📅    │  ← View tabs + calendar button
├─────────────────────────────────┤
│  (History only:)                │
│  [الأسبوع ١] [٢] [٣] [٤]      │  ← Week selector
│  [1] [2] [3] [4] [5] [6] [7]   │  ← Day selector
├─────────────────────────────────┤
│  قائمة المهام          [count]  │  ← Section header
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │ ○  Task title     [حذف]  │  │  ← RamadanTaskItem cards
│  │    يومية  غير مكتملة     │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ ✓  Task title     [حذف]  │  │
│  │    شهرية  تم الإنجاز     │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│                    [+ إضافة مهمة]│  ← FAB (hidden in history mode)
└─────────────────────────────────┘
```

#### Key private widgets inside the page:

| Widget | Purpose |
|---|---|
| `_ViewTabs` | iOS-style segmented control for Today/History/All |
| `_WeekSelector` | Horizontal scrollable week pills (1–4) |
| `_DaySelector` | Horizontal scrollable day chips with today highlight |
| `_SectionHeader` | Title + count badge |
| `_EmptyState` | Contextual empty illustration per view mode |
| `_ErrorView` | Error message + retry button |
| `_CalendarButton` | Purple icon button that opens the calendar sheet |
| `_AddTaskSheetBody` | StatefulWidget for the add-task bottom sheet |
| `_TypePill` | Pill-style task type selector (daily/monthly) |

#### Add task bottom sheet:

The bottom sheet is a `StatefulWidget` (`_AddTaskSheetBody`) to properly manage the radio button state for task type selection. This avoids the old hack of calling `(context as Element).markNeedsBuild()` which used the wrong context.

**Flow:**
1. User taps FAB → `_showAddTaskSheet(parentContext)` called
2. `cubit` reference captured from `parentContext` (not sheet context)
3. `TextEditingController` created for task title
4. `_AddTaskSheetBody` manages `_selectedType` via `setState`
5. On "إضافة" press: calls `cubit.addNewTask(title, type)` and pops sheet

#### Delete confirmation:

A `Directionality`-wrapped `AlertDialog` with cancel/delete buttons. Uses `dialogCtx` for Navigator.pop to avoid context issues.

### 5.3 Widgets

#### RamadanProgress

**File:** `presentation/widgets/ramadan_progress.dart` (232 lines)

A gradient purple card with:

```
┌──────────────────────────────────┐
│  ┌──────┐                        │
│  │ 75%  │  اليوم 8 من رمضان      │  ← Circular progress + day info
│  │ ○○○○ │  3 من 4 مهمة يومية     │
│  └──────┘                        │
│                                  │
│  تقدّم الشهر     ███████░░ 70%   │  ← Monthly bar
│  تقدّم الأسبوع   ████░░░░░ 50%   │  ← Weekly bar
│                                  │
│  ✨ ما شاء الله! أتممت جميع...   │  ← Motivational (optional)
└──────────────────────────────────┘
```

- `TweenAnimationBuilder<double>` for smooth animated fill on both circular and linear indicators
- `strokeCap: StrokeCap.round` for polished circular progress
- Gold accent for daily ring and monthly bar
- Motivational banner only shown in Today mode when `dailyPercent >= 1.0`

#### RamadanTaskItem

**File:** `presentation/widgets/ramadan_task_item.dart` (225 lines)

```
┌─────────────────────────────────────┐
│  ●   Task Title              🗑️    │
│      [يومية]  مكتملة               │
└─────────────────────────────────────┘
```

Features:
- **Whole card tappable** via `InkWell` (not just checkbox)
- **Animated circular checkbox** — `AnimatedContainer` for color + `AnimatedSwitcher` with `ScaleTransition` for check icon
- **Line-through** text decoration when completed
- **Soft pill badges** — purple for daily, gold for monthly
- **Delete icon** hidden in read-only mode
- **Proper keys** — `ValueKey('task_${t.id}_${s.displayDay}')` avoids collisions

#### RamadanCalendarSheet

**File:** `presentation/widgets/ramadan_calendar_sheet.dart` (705 lines)

A `DraggableScrollableSheet` opened via `RamadanCalendarSheet.show()`:

```
┌─────────────────────────────────┐
│  ─── (drag handle) ───          │
│  📅 تقويم رمضان    ● مكتمل ● جزئي │
│                                 │
│  س   ح   ن   ث   ر   خ   ج    │  ← Weekday labels
│  ┌──┬──┬──┬──┬──┬──┬──┐        │
│  │ 1│ 2│ 3│ 4│ 5│ 6│ 7│        │  ← 30-day grid (color-coded)
│  ├──┼──┼──┼──┼──┼──┼──┤        │
│  │ 8│ 9│10│11│12│13│14│        │
│  ├──┼──┼──┼──┼──┼──┼──┤        │
│  │15│16│17│18│19│20│21│        │
│  ├──┼──┼──┼──┼──┼──┼──┤        │
│  │22│23│24│25│26│27│28│        │
│  ├──┼──┴──┴──┴──┴──┴──┘        │
│  │29│30│                        │
│  └──┴──┘                        │
│                                 │
│  ⭐ المهام الشهرية   2/3        │  ← Monthly tasks section
│  ✓ ختم القرآن                   │
│  ○ إخراج الزكاة                 │
│                                 │
│  ┌─ اليوم 5 من رمضان ─── 80% ─┐│  ← Day detail (on tap)
│  │ ✓ قراءة جزء من القرآن       ││
│  │ ✓ صلاة التراويح              ││
│  │ ○ الدعاء قبل الإفطار         ││
│  └─────────────────────────────┘│
│                                 │
│  🔥 التوالي │ 🏆 أيام مثالية │ ✅ إنجازات │  ← Stats bar
│    3 يوم   │      5        │    42     │
└─────────────────────────────────┘
```

**Cell color coding:**

| State | Background | Indicator |
|---|---|---|
| Future day | Light gray (50% opacity) | Dimmed text |
| 0% completed | Light gray | — |
| Partial (0 < ratio < 1) | Gold (opacity scales with ratio) | Gold dot |
| 100% completed | Green (success) | White ✓ |
| Selected | Purple | White text |
| Today (not selected) | Normal + purple border | Bold text |

**Stats computed:**
- **Streak** — consecutive perfect days ending at today (counts backward)
- **Perfect days** — total days where all daily tasks were completed
- **Total completions** — sum of all daily task completions across all days

**Performance note:** `_dailyTasks` and `_monthlyTasks` are computed getters called multiple times during build. For large task lists, consider caching. Current scale (typical user: 5–15 tasks) makes this negligible.

---

## 6. Integration Points

### 6.1 Dependency Injection (GetIt)

**File:** `lib/core/di/dependency_injection.dart` (lines 219–228)

```dart
// Ramadan Tasks feature (Hive-based)
getIt.registerLazySingleton<RamadanTasksLocalDataSource>(
  () => RamadanTasksLocalDataSource(),
);
getIt.registerLazySingleton<RamadanTasksRepository>(
  () => RamadanTasksRepositoryImpl(getIt<RamadanTasksLocalDataSource>()),
);
getIt.registerFactory<RamadanTasksCubit>(
  () => RamadanTasksCubit(getIt<RamadanTasksRepository>()),
);
```

| Registration | Type | Rationale |
|---|---|---|
| `RamadanTasksLocalDataSource` | `registerLazySingleton` | One shared Hive box across the app |
| `RamadanTasksRepository` | `registerLazySingleton` | Stateless — safe to share |
| `RamadanTasksCubit` | `registerFactory` | New instance per screen visit (owns state) |

### 6.2 Routing

**File:** `lib/core/routing/routes.dart`
```dart
static const String ramadanTasksScreen = '/ramadanTasks';
```

**File:** `lib/core/routing/app_router.dart` (lines 356–362)
```dart
case Routes.ramadanTasksScreen:
  _logScreenView('RamadanTasksScreen');
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (context) => getIt<RamadanTasksCubit>()..init(),
      child: const RamadanTasksPage(),
    ),
  );
```

The Cubit is created and `init()` is called immediately when the route is pushed. `BlocProvider` auto-disposes the Cubit when the page is popped.

### 6.3 Home Screen Entry

**File:** `lib/features/home/ui/home_screen.dart` (line 154)

A `_RamadanTasksEntry` widget (card) on the home screen navigates to the feature:
```dart
Navigator.pushNamed(context, Routes.ramadanTasksScreen);
```

### 6.4 Hive Initialization

**File:** `lib/core/services/hive_service.dart`

```dart
class HiveService {
  static const String ramadanTasksBox = 'ramadan_tasks';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapters registered in feature datasources
  }
}
```

Called once in `main.dart` during app startup. The `RamadanTaskModelAdapter` is registered lazily in `RamadanTasksLocalDataSource.init()`.

---

## 7. Data Flow Diagrams

### Adding a new task:

```
User taps "إضافة"
    │
    ▼
_AddTaskSheetBody.onAdd(title, type)
    │
    ▼
RamadanTasksCubit.addNewTask(title, type)
    │
    ├─ Creates RamadanTaskEntity(id: '', title, type, completedDays: {})
    ├─ Calls AddTask use case → Repository.addTask()
    │     └─ Generates ID from microsecondsSinceEpoch
    │     └─ Converts to RamadanTaskModel
    │     └─ Hive: _box.put(id, model)
    │
    ├─ Re-fetches: _allTasks = await _getTasks()
    └─ Calls _emitLoaded() → UI rebuilds
```

### Toggling a daily task:

```
User taps task card
    │
    ▼
RamadanTasksCubit.toggleDaily(id)
    │
    ├─ Gets todayDay = DateTime.now().day.clamp(1,30)
    ├─ Calls ToggleDailyCompletion(id, day) → Repository
    │     ├─ Finds task by ID
    │     ├─ Copies completedDays set
    │     ├─ If day in set → remove (uncomplete)
    │     ├─ If day not in set → add (complete)
    │     └─ Saves updated task via updateTask()
    │
    ├─ Re-fetches: _allTasks = await _getTasks()
    └─ _emitLoaded() → computes progress → UI rebuilds
```

### Switching view mode:

```
User taps "السجل" tab
    │
    ▼
RamadanTasksCubit.setViewMode(ViewMode.history)
    │
    ├─ _viewMode = history
    ├─ _selectedDay = todayDay (meaningful starting point)
    ├─ _selectedWeek = week containing todayDay
    └─ _emitLoaded() ← NO Hive I/O, uses cached _allTasks
        └─ Filters tasks, computes progress → UI rebuilds instantly
```

---

## 8. Progress Calculation Formulas

**File:** `domain/usecases/compute_progress.dart`

### Daily Progress
$$\text{dailyPercent} = \frac{\text{dailyCompletedOnDay}}{\text{totalDailyTasks}}$$

Only counts completions for the specific day being viewed.

### Monthly (Overall Ramadan) Progress
$$\text{monthlyPercent} = \frac{\sum_{d=1}^{\text{daysSoFar}} \text{dailyCompletions}(d) + \text{completedMonthlyTasks}}{\text{dailyTasksCount} \times \text{daysSoFar} + \text{monthlyTasksCount}}$$

**Key insight:** Uses `daysSoFar` (= current day number) instead of `30` as the daily multiplier. This means:
- On Day 1 with 4 daily tasks: denominator = `4×1 + monthlyCount` (achievable)
- On Day 30 with 4 daily tasks: denominator = `4×30 + monthlyCount` (full month)

This prevents the progress from appearing stuck near 0% early in Ramadan.

### Weekly Progress
$$\text{weeklyPercent} = \frac{\sum_{d=\text{weekStart}}^{\text{weekEnd}} \text{dailyCompletions}(d)}{\text{dailyTasksCount} \times \text{weekDays}}$$

Only counts daily task completions within the selected week range.

### All values are clamped to `[0.0, 1.0]`.

### `ProgressResult` carries:
- `dailyPercent`, `monthlyPercent`, `weeklyPercent` — 0.0–1.0 fractions
- `dailyCompleted`, `dailyTotal` — integer counts for the summary label

---

## 9. View Modes & Filtering Logic

### Today Mode (`ViewMode.today`)

| Aspect | Behavior |
|---|---|
| Tasks shown | All daily tasks + monthly tasks where `completedDays.isEmpty` |
| Editable | ✅ Yes — toggle completion, delete |
| FAB visible | ✅ Yes |
| Day context | Uses `todayDay` (from `DateTime.now()`) |
| Progress shows | Today's daily %, overall Ramadan %, current week's % |
| Motivational text | Shown when `dailyPercent >= 1.0` |

### History Mode (`ViewMode.history`)

| Aspect | Behavior |
|---|---|
| Tasks shown | All tasks (unmodifiable) |
| Editable | ❌ No — read-only, no toggle/delete |
| FAB visible | ❌ Hidden |
| Day context | Uses `selectedDay` (user picks from day selector) |
| Selectors visible | Week selector (1–4) + day selector (within week) |
| Progress shows | Selected day's daily %, overall %, selected week's % |

### All Mode (`ViewMode.all`)

| Aspect | Behavior |
|---|---|
| Tasks shown | All tasks (unmodifiable list reference, but editable via card tap) |
| Editable | ✅ Yes |
| FAB visible | ✅ Yes |
| Day context | Uses `todayDay` |
| Progress shows | Today's stats |

---

## 10. Calendar Sheet Feature

**Opened via:** Calendar icon button (📅) next to view tabs  
**Implementation:** `RamadanCalendarSheet.show(context, allTasks, todayDay)`

### Components:

1. **30-day grid** — 7 columns × 5 rows, color-coded by daily completion ratio
2. **Day detail card** — appears on day tap, shows per-task breakdown with mini progress ring
3. **Monthly tasks section** — lists one-time tasks with completion status
4. **Stats summary** — streak, perfect days, total completions

### Stat calculations:

```dart
// Perfect day: all daily tasks completed on that day
perfectDays = count(d in 1..todayDay where dailyCompleted(d) == dailyTasks.length)

// Streak: consecutive perfect days ending at todayDay
streak = countBackward from todayDay while day is perfect

// Total completions: sum of all daily completions across all days
totalCompletions = sum(dailyCompleted(d) for d in 1..todayDay)
```

### The grid is **read-only** — tapping a day shows detail but doesn't modify data. The sheet receives a snapshot of `allTasks` from the Cubit state.

---

## 11. Bug Fixes & Design Decisions

### Fixed bugs (historical):

| # | Bug | Root Cause | Fix |
|---|---|---|---|
| 1 | `ensureDailyReset` destroyed history | Wiped all past completions for daily tasks on each new day | Made it a no-op; daily "completed today?" is checked via `completedDays.contains(todayDay)` |
| 2 | `toggleDailyCompletion` cleared history | Used `completed..clear()..add(day)` which erased past days | Changed to `add(day)` / `remove(day)` preserving other entries |
| 3 | `void` async methods | `setViewMode`, `setSelectedWeek`, `setSelectedDay` were `void` with hidden `await` | Changed to proper `Future<void>` signatures |
| 4 | Today filter hid completed monthly tasks | Monthly tasks disappeared after completion | Filter now shows uncompleted monthly tasks only (completed ones still visible in All/History) |
| 5 | Bottom sheet radio buttons didn't rebuild | Used `(context as Element).markNeedsBuild()` on the wrong context | Extracted to `_AddTaskSheetBody` StatefulWidget with proper `setState` |
| 6 | Week ranges inconsistent | Some places used `(8,15)` vs `(8,14)` | Standardized to `(1,7), (8,14), (15,21), (22,30)` |
| 7 | Progress formula always ≈0% | Denominator was `30 × dailyCount + monthlyCount` (too large early on) | Uses `daysSoFar × dailyCount` instead |
| 8 | WeekSelector overflowed | 4 `ChoiceChip` in `Wrap` inside `Row` caused horizontal overflow | Replaced with horizontal `ListView` |
| 9 | AnimatedSwitcher key collisions | Key was `sum of lengths` — non-unique | Each task uses `ValueKey('task_${t.id}_${s.displayDay}')` |
| 10 | `hashCode` inconsistent with `==` | `hashCode` used `completedDays.length` but `==` did deep comparison | Now uses `Object.hashAll(sorted)` on completedDays content |

### Design decisions:

| Decision | Rationale |
|---|---|
| Hive over SharedPreferences | Tasks have complex structure (lists, sets); SharedPreferences only does key-value strings |
| Manual TypeAdapter over code-gen | Avoids `build_runner` + `hive_generator` dependency; only one model |
| `Set<int>` for completedDays | O(1) contains() check; natural "no duplicates" guarantee |
| Cubit over Bloc | Simpler API for this feature's needs; no event classes needed |
| Factory registration for Cubit | Fresh state on each screen visit; no stale data |
| `_allTasks` cache in Cubit | Avoids Hive reads on every filter/selection change |
| `ensureDailyReset` as no-op | Preserving history is more valuable than auto-cleanup |
| `daysSoFar` in progress formula | Makes early-Ramadan progress feel meaningful |

---

## 12. Performance Considerations

| Area | Strategy |
|---|---|
| Hive reads | Only on `init()` and after mutations; filter/selection changes use cached `_allTasks` |
| Progress computation | Pure function over in-memory list; O(n) where n = task count (typically < 20) |
| UI rebuilds | `BlocBuilder` with `buildWhen` on FAB to avoid unnecessary rebuilds |
| Calendar stats | Computed once per sheet build; O(30 × taskCount) — negligible |
| Widget keys | Unique `ValueKey` per task + day prevents unnecessary widget recycling |
| Lazy Hive init | Box opened on first access, not at app startup |
| Adapter registration | Guarded by `Hive.isAdapterRegistered(33)` — safe to call multiple times |

### Potential bottlenecks (at current scale: NOT an issue):

- `_dailyTasks` / `_monthlyTasks` in calendar sheet are computed getters called per build → could cache if task count grows past ~100
- `_buildCalendarGrid()` creates 30+ widgets per build → fine for current scope; could use `GridView.builder` for lazy rendering if needed

---

## 13. RTL & Theming

### RTL Support

- Root `Directionality(textDirection: TextDirection.rtl)` wraps the entire page
- All padding uses `EdgeInsetsDirectional` (never `EdgeInsets.only(left/right)`)
- Bottom sheets and dialogs wrapped in their own `Directionality` widget
- Horizontal lists (`ListView`) naturally reverse in RTL mode

### Theming

| Element | Style |
|---|---|
| Fonts | Cairo / Amiri (inherited from app theme) |
| Primary color | `ColorsManager.primaryPurple` (#7440E9) |
| Accent color | `ColorsManager.primaryGold` (#FFB300) |
| Success color | `ColorsManager.success` (#4CAF50) |
| Text styles | `TextStyles.*` (from `core/theming/styles.dart`) |
| Responsive sizing | `flutter_screenutil` — all `.w`, `.h`, `.sp`, `.r` |
| Progress card | `LinearGradient(primaryPurple → darkPurple)` |
| Cards | White with subtle shadow (`0.03` opacity) |
| Tabs | iOS-style segmented control with animated container |
| Animations | `TweenAnimationBuilder`, `AnimatedContainer`, `AnimatedSwitcher` |

---

## 14. Known Limitations & Future Improvements

### Current limitations:

| Limitation | Impact | Workaround |
|---|---|---|
| `_todayDayNumber()` uses `DateTime.now().day` | Not aligned with Hijri calendar | Would need a Hijri date package for accurate Ramadan day mapping |
| No task reordering | Tasks appear in insertion order | Could add a `sortOrder` field |
| No task editing (title) | Users must delete + re-add to change title | Add `updateTask` flow in UI |
| Calendar sheet is a snapshot | Doesn't update if tasks change while open | Could listen to Cubit stream |
| No data export/sync | Data locked to device | Could add backup/restore or cloud sync |
| No notifications | No reminders for incomplete tasks | Could integrate `flutter_local_notifications` |

### Potential improvements:

1. **Hijri calendar integration** — Use a Hijri date library for accurate day mapping
2. **Task categories/tags** — Group tasks (Quran, Prayer, Charity, etc.)
3. **Cloud backup** — Optional Firebase sync for multi-device
4. **Notifications** — Daily reminders for incomplete tasks
5. **Widgets (home screen)** — Show daily progress as an Android/iOS widget
6. **Gamification** — Badges for streaks, achievements for perfect weeks
7. **Sharing** — Export progress as an image for social sharing

---

## File Reference Table

| File | Lines | Layer | Purpose |
|---|---|---|---|
| `ramadan_task_entity.dart` | 65 | Domain | Core entity, TaskType enum, equality |
| `ramadan_tasks_repository.dart` | 20 | Domain | Abstract interface (7 methods) |
| `get_tasks.dart` | 9 | Domain | Fetch all tasks use case |
| `add_task.dart` | 9 | Domain | Add task use case |
| `delete_task.dart` | 8 | Domain | Delete task use case |
| `update_task.dart` | 9 | Domain | Update task use case |
| `toggle_daily_completion.dart` | 9 | Domain | Toggle daily completion use case |
| `set_monthly_completed.dart` | 12 | Domain | Set monthly completion use case |
| `ensure_daily_reset.dart` | 8 | Domain | No-op reset use case |
| `compute_progress.dart` | 83 | Domain | Pure progress calculation |
| `ramadan_task_model.dart` | 69 | Data | Hive model + manual TypeAdapter |
| `ramadan_tasks_local_datasource.dart` | 33 | Data | Hive box CRUD wrapper |
| `ramadan_tasks_repository_impl.dart` | 96 | Data | Concrete repository |
| `ramadan_tasks_cubit.dart` | 226 | Presentation | Cubit state management |
| `ramadan_tasks_state.dart` | 68 | Presentation | State classes |
| `ramadan_tasks_page.dart` | 865 | Presentation | Main screen + private widgets |
| `ramadan_progress.dart` | 232 | Presentation | Animated progress card |
| `ramadan_task_item.dart` | 225 | Presentation | Single task card |
| `ramadan_calendar_sheet.dart` | 705 | Presentation | 30-day calendar bottom sheet |
| **Total** | **~2,721** | | |

---

*This documentation reflects the codebase as of February 8, 2026.*
