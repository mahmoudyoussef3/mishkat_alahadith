import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/widgets/location_selection_dialog.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/widgets/next_prayer_card.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/widgets/prayer_times_grid.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerTimesCubit>().init();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showLocationDialog() {
    final cubit = context.read<PrayerTimesCubit>();
    showDialog(
      context: context,
      builder:
          (_) => LocationSelectionDialog(
            currentLocation: cubit.currentLocation,
            onLocationSelected: cubit.updateLocation,
            onUseCurrentLocation: cubit.useCurrentLocation,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          child: BlocListener<PrayerTimesCubit, PrayerTimesState>(
            listener: (context, state) {
              if (state is PrayerTimesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: ColorsManager.error,
                  ),
                );
              }
            },
            child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
              builder: (context, state) {
                final cubit = context.read<PrayerTimesCubit>();
                final date =
                    state is PrayerTimesLoaded ? state.date : DateTime.now();

                return CustomScrollView(
                  slivers: [
                    BuildHeaderAppBar(
                      title: 'مواقيت الصلاة',
                      description:
                          '${cubit.currentLocation.cityName} • ${_formatDate(date)}',
                      actions: [
                        AppBarActionButton(
                          icon: Icons.location_on_rounded,
                          onPressed: _showLocationDialog,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                    if (state is PrayerTimesLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state is PrayerTimesLoaded) ...[
                      if (state.nextPrayerLabel != null &&
                          state.nextPrayerTime != null &&
                          state.remaining != null)
                        SliverToBoxAdapter(
                          child: NextPrayerCard(
                            nextPrayerLabel: state.nextPrayerLabel!,
                            nextPrayerTime: state.nextPrayerTime!,
                            remaining: state.remaining!,
                          ),
                        ),
                      SliverToBoxAdapter(child: SizedBox(height: 22.h)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 16.w,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'مواقيت اليوم',
                                style: PrayerTimesTextStyles.sectionHeaderLabel,
                              ),
                              const Spacer(),
                              Text(
                                'حسب طريقة الحساب المصرية',
                                style: TextStyles.bodySmall.copyWith(
                                  color: ColorsManager.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                      SliverToBoxAdapter(
                        child: PrayerTimesGrid(times: state.times),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    ] else
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyPrayerTimesState(
                          onRetry: () => cubit.init(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPrayerTimesState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyPrayerTimesState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_rounded,
            color: ColorsManager.secondaryText,
            size: 42.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'تعذر عرض مواقيت الصلاة',
            style: TextStyles.titleLarge.copyWith(
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
