import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/widgets/next_prayer_card.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/widgets/prayer_times_grid.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/widgets/location_selection_dialog.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_decorations.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_styles.dart';

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

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _showLocationDialog() {
    final cubit = context.read<PrayerTimesCubit>();
    showDialog(
      context: context,
      builder:
          (context) => LocationSelectionDialog(
            currentLocation: cubit.currentLocation,
            onLocationSelected: (location) {
              cubit.updateLocation(location);
            },
            onUseCurrentLocation: () {
              cubit.useCurrentLocation();
            },
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
          top: true,
          bottom: true,
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
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'حسناً',
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
              builder: (context, state) {
                DateTime? currentDate;
                String cityName =
                    context.read<PrayerTimesCubit>().currentLocation.cityName;

                if (state is PrayerTimesLoaded) currentDate = state.date;

                return CustomScrollView(
                  slivers: [
                    BuildHeaderAppBar(
                      title: 'مواقيت الصلاة',
                      description:
                          'مواقيت اليوم في $cityName – ${_formatDate(currentDate ?? DateTime.now())}',
                      pinned: true,
                      actions: [_buildLocationButton()],
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                    if (state is PrayerTimesLoaded &&
                        state.nextPrayerLabel != null &&
                        state.nextPrayerTime != null &&
                        state.remaining != null)
                      SliverToBoxAdapter(
                        child: NextPrayerCard(
                          nextPrayerLabel: state.nextPrayerLabel!,
                          nextPrayerTime: state.nextPrayerTime!,
                          remaining: state.remaining!,
                        ),
                      )
                    else
                      const SliverToBoxAdapter(child: SizedBox.shrink()),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    SliverToBoxAdapter(child: _buildDivider()),
                    SliverToBoxAdapter(child: SizedBox(height: 8.h)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 16.w,
                          end: 16.w,
                        ),
                        child: Text(
                          'مواقيت اليوم',
                          style: PrayerTimesTextStyles.sectionHeaderLabel,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                    if (state is PrayerTimesLoaded)
                      SliverToBoxAdapter(
                        child: PrayerTimesGrid(times: state.times),
                      )
                    else
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: EdgeInsetsDirectional.only(
      start: 30.w,
      end: 30.w,
      top: 8.h,
      bottom: 8.h,
    ),
    child: Container(
      height: 2.h,
      decoration: PrayerTimesDecorations.sectionDivider(),
    ),
  );

  Widget _buildLocationButton() {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 8.w),
      child: InkWell(
        onTap: _showLocationDialog,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Icon(Icons.location_on, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}
