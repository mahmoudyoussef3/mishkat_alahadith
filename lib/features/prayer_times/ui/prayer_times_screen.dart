import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late final PrayerCalculator _calculator;
  PrayerTimes? _times;
  DateTime _date = DateTime.now();
  Timer? _ticker;

  String _city = 'القاهرة، مصر';
  String? _nextPrayerLabel;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _calculator = PrayerCalculator(
      latitude: 30.0444,
      longitude: 31.2357,
      timezone: 2.0,
      asrMethod: AsrMethod.hanafi,
    );
    _calculateAndStartTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body:SafeArea(
              top: false,
        bottom: true,
          child: CustomScrollView(
            slivers: [
              const BuildHeaderAppBar(
                title: 'مواقيت الصلاة',
              
                description: 'مواقيت اليوم في القاهرة – حسب الهيئة المصرية',
                pinned: true,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverToBoxAdapter(child: _buildCityDateCard()),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(child: _buildNextPrayerCard()),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
                  child: Text(
                    'مواقيت اليوم',
                    style: TextStyles.headlineMedium.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(child: _buildTimesGrid()),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            ],
          ),
        ),
      ),
    );
  }

  void _calculateAndStartTicker() {
    _times = _calculator.calculate(_date);
    _updateNextPrayerInfo();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = _times?.getTimeRemaining(DateTime.now());
        _updateNextPrayerInfo();
      });
    });
  }

  void _updateNextPrayerInfo() {
    final name = _times?.getNextPrayerName(DateTime.now());
    switch (name) {
      case PrayerName.fajr:
        _nextPrayerLabel = 'الفجر';
        break;
      case PrayerName.dhuhr:
        _nextPrayerLabel = 'الظهر';
        break;
      case PrayerName.asr:
        _nextPrayerLabel = 'العصر';
        break;
      case PrayerName.maghrib:
        _nextPrayerLabel = 'المغرب';
        break;
      case PrayerName.isha:
        _nextPrayerLabel = 'العشاء';
        break;
      default:
        _nextPrayerLabel = null;
    }
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _buildCityDateCard() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: ColorsManager.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ColorsManager.mediumGray, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: ColorsManager.primaryPurple,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _city,
                    style: TextStyles.titleLarge.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'تاريخ اليوم: ${_formatDate(_date)}',
                    style: TextStyles.bodyMedium.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final nextTime = _times?.getNextPrayer(DateTime.now());
    final countdown = _remaining;
    final hours = countdown?.inHours ?? 0;
    final minutes = countdown != null ? countdown.inMinutes % 60 : 0;
    final seconds = countdown != null ? countdown.inSeconds % 60 : 0;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: ColorsManager.primaryPurple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorsManager.primaryPurple.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: ColorsManager.primaryPurple,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nextPrayerLabel != null
                        ? 'الصلـاة القادمة: $_nextPrayerLabel'
                        : 'لا توجد صلاة قادمة الآن',
                    style: TextStyles.titleLarge.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 4.h),
                  if (nextTime != null) ...[
                    Text(
                      'الوقت: ${_formatTime(nextTime)}',
                      style: TextStyles.bodyMedium.copyWith(
                        color: ColorsManager.secondaryText,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryGold.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: ColorsManager.primaryGold.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      countdown != null
                          ? 'المتبقي: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                          : '—',
                      style: TextStyles.labelMedium.copyWith(
                        color: ColorsManager.primaryGold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimesGrid() {
    final items = <_PrayerItem>[
      _PrayerItem('الفجر', _times?.fajr, Icons.nightlight_round),
      _PrayerItem('الظهر', _times?.dhuhr, Icons.wb_sunny_rounded),
      _PrayerItem('العصر', _times?.asr, Icons.wb_sunny),
      _PrayerItem('المغرب', _times?.maghrib, Icons.wb_twilight),
      _PrayerItem('العشاء', _times?.isha, Icons.dark_mode_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 3.8,
            ),
            itemCount: items.length,
            itemBuilder:
                (_, i) => _PrayerRow(
                  title: items[i].title,
                  time: _formatTime(items[i].time),
                  icon: items[i].icon,
                ),
          );
        }
        return Padding(
          padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
          child: Column(
            children: [
              ...items.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _PrayerRow(
                    title: e.title,
                    time: _formatTime(e.time),
                    icon: e.icon,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.3),
            ColorsManager.primaryGold.withOpacity(0.6),
            ColorsManager.primaryPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(1.r),
      ),
    ),
  );
}

class _PrayerItem {
  final String title;
  final DateTime? time;
  final IconData icon;
  _PrayerItem(this.title, this.time, this.icon);
}

class _PrayerRow extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  const _PrayerRow({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorsManager.mediumGray, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.titleLarge.copyWith(
                    color: ColorsManager.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: TextStyles.bodyMedium.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: ColorsManager.primaryPurple, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
