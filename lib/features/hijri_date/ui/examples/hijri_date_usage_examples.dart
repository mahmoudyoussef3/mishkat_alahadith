import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/cubit/hijri_date_cubit.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/states/hijri_date_state.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/usecases/get_hijri_date_usecase.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';

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

class HijriDateDirectExample extends StatelessWidget {
  const HijriDateDirectExample({super.key});

  @override
  Widget build(BuildContext context) {
    final getHijriDate = getIt<GetHijriDateUseCase>();

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

class HomeScreenHijriExample extends StatelessWidget {
  const HomeScreenHijriExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(child: Center(child: Text('محتوى الشاشة الرئيسية'))),
          ],
        ),
      ),
    );
  }
}
