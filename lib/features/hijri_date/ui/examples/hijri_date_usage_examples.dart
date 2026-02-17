import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/cubit/hijri_date_cubit.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/states/hijri_date_state.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/usecases/get_hijri_date_usecase.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';

/// Example 1: Using Hijri Date with BlocBuilder (Recommended for reactive UI)
///
/// This approach is best when:
/// - You need the UI to update when date changes
/// - You want loading/error states
/// - You need pull-to-refresh functionality
class HijriDateWithCubitExample extends StatelessWidget {
  const HijriDateWithCubitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HijriDateCubit>()..loadHijriDate(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تاريخ هجري'),
          actions: [
            // Refresh button to fetch latest offset from Remote Config
            BlocBuilder<HijriDateCubit, HijriDateState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed:
                      state is HijriDateLoading
                          ? null
                          : () =>
                              context.read<HijriDateCubit>().refreshHijriDate(),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HijriDateCubit, HijriDateState>(
          builder: (context, state) {
            if (state is HijriDateLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HijriDateError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => context.read<HijriDateCubit>().loadHijriDate(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is HijriDateLoaded) {
              final hijriDate = state.hijriDate;
              final offset = state.appliedOffset;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display Hijri date in Arabic
                    Text(
                      '${hijriDate.hDay}',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hijriDate.getLongMonthName(),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${hijriDate.hYear} هـ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Show offset info (for debugging/admin)
                    if (offset != 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'إزاحة مطبقة: $offset ${offset.abs() == 1 ? 'يوم' : 'أيام'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Example 2: Direct UseCase Usage (For simple one-time date display)
///
/// This approach is best when:
/// - You just need the date once
/// - No need for loading states
/// - Building a simple widget
class HijriDateDirectExample extends StatelessWidget {
  const HijriDateDirectExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the use case from DI
    final getHijriDate = getIt<GetHijriDateUseCase>();

    // Get the current Hijri date with offset applied
    final hijriDate = getHijriDate.call();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التاريخ الهجري',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear} هـ',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Using in AppBar subtitle
class HijriDateInAppBarExample extends StatelessWidget {
  const HijriDateInAppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final hijriDate = getIt<GetHijriDateUseCase>().call();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مشكاة المصابيح'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear} هـ',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: const Center(child: Text('محتوى التطبيق')),
    );
  }
}

/// Example 4: Helper widget for reusable Hijri date display
class HijriDateWidget extends StatelessWidget {
  final TextStyle? style;
  final bool showYear;

  const HijriDateWidget({super.key, this.style, this.showYear = true});

  @override
  Widget build(BuildContext context) {
    final hijriDate = getIt<GetHijriDateUseCase>().call();

    final dateText =
        showYear
            ? '${hijriDate.hDay} ${hijriDate.getLongMonthName()} ${hijriDate.hYear} هـ'
            : '${hijriDate.hDay} ${hijriDate.getLongMonthName()}';

    return Text(dateText, style: style);
  }
}

/// Example 5: Using in Home Screen
/// This is how you might integrate it into your existing home screen
class HomeScreenHijriExample extends StatelessWidget {
  const HomeScreenHijriExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Hijri date
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade600, Colors.teal.shade400],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'اليوم',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  HijriDateWidget(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Rest of your home screen content
            Expanded(child: Center(child: Text('محتوى الشاشة الرئيسية'))),
          ],
        ),
      ),
    );
  }
}
