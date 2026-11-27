import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/presentation/logic/qiblah_cubit.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/presentation/ui/widgets/qibla_dial.dart';

/// Within this many degrees the phone counts as facing the Qibla.
const double _kAlignedWithin = 5;

/// Points the reader to the Qibla with a live compass, once location and
/// the compass sensor are available.
class QiblahFinderScreen extends StatefulWidget {
  const QiblahFinderScreen({super.key});

  @override
  State<QiblahFinderScreen> createState() => _QiblahFinderScreenState();
}

class _QiblahFinderScreenState extends State<QiblahFinderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<QiblahCubit>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final retry = context.read<QiblahCubit>().refresh;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              const DetailHeader(
                title: 'اتجاه القبلة',
                subtitle: 'وجّه أعلى الهاتف نحو الكعبة',
                showDivider: false,
              ),
              Expanded(
                child: BlocBuilder<QiblahCubit, QiblahState>(
                  builder:
                      (context, state) => switch (state) {
                        QiblahReady() => const _LiveCompass(),
                        QiblahSensorUnsupported() => StateMessage(
                          icon: Icons.sensors_off_rounded,
                          title: 'البوصلة غير مدعومة',
                          subtitle:
                              'جهازك لا يحتوي على مستشعر البوصلة اللازم لتحديد اتجاه القبلة.',
                          actionLabel: 'إعادة المحاولة',
                          actionIcon: Icons.refresh_rounded,
                          onAction: retry,
                        ),
                        QiblahLocationDisabled() => StateMessage(
                          icon: Icons.location_off_rounded,
                          title: 'خدمة الموقع متوقفة',
                          subtitle:
                              'فعّل خدمة تحديد الموقع ليُحسب اتجاه القبلة بدقة.',
                          actionLabel: 'إعادة المحاولة',
                          actionIcon: Icons.refresh_rounded,
                          onAction: retry,
                        ),
                        QiblahPermissionDenied() ||
                        QiblahPermissionDeniedForever() => StateMessage(
                          icon: Icons.lock_outline_rounded,
                          title: 'إذن الموقع مطلوب',
                          subtitle:
                              'نحتاج موقعك لحساب اتجاه القبلة. فعّل الإذن من إعدادات الهاتف ثم أعد المحاولة.',
                          actionLabel: 'إعادة المحاولة',
                          actionIcon: Icons.refresh_rounded,
                          onAction: retry,
                        ),
                        QiblahError(:final message) => StateMessage.error(
                          message: message,
                          onRetry: retry,
                        ),
                        _ => const _Calibrating(),
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Calibrating extends StatelessWidget {
  const _Calibrating();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text('جاري تهيئة البوصلة…', style: TextStyles.caption.copyWith(fontSize: 14.sp)),
        ],
      ),
    );
  }
}

/// Follows the compass and gives a gentle tap when the phone lines up.
class _LiveCompass extends StatefulWidget {
  const _LiveCompass();

  @override
  State<_LiveCompass> createState() => _LiveCompassState();
}

class _LiveCompassState extends State<_LiveCompass> {
  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const _Calibrating();

        final readout = QiblaReadout(heading: data.direction, qiblaBearing: data.offset);
        if (readout.aligned && !_wasAligned) HapticFeedback.mediumImpact();
        _wasAligned = readout.aligned;
        return readout;
      },
    );
  }
}

/// The compass for a given heading and Qibla bearing: which way to turn,
/// the dial, the angles, and calibration advice.
class QiblaReadout extends StatelessWidget {
  const QiblaReadout({
    super.key,
    required this.heading,
    required this.qiblaBearing,
  });

  final double heading;
  final double qiblaBearing;

  /// Degrees to turn: positive means clockwise (to the right).
  double get turn {
    var value = (qiblaBearing - heading) % 360;
    if (value > 180) value -= 360;
    return value;
  }

  bool get aligned => turn.abs() <= _kAlignedWithin;

  static String _degrees(double value) =>
      toArabicDigits('${value.round() % 360}°');

  @override
  Widget build(BuildContext context) {
    final turn = this.turn;
    final hint =
        aligned
            ? 'أنت على اتجاه القبلة'
            : 'أدِر الهاتف ${toArabicDigits('${turn.abs().round()}°')} '
                '${turn > 0 ? 'لليمين' : 'لليسار'}';
    final dialSize = (MediaQuery.sizeOf(context).width - 80).clamp(220.0, 310.0);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        Center(
          child: Semantics(
            liveRegion: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              decoration: ShapeDecoration(
                color: aligned ? ColorsManager.successSoft : ColorsManager.goldSoft,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    aligned
                        ? Icons.check_circle_rounded
                        : turn > 0
                        ? Icons.rotate_right_rounded
                        : Icons.rotate_left_rounded,
                    size: 20.r,
                    color: aligned ? ColorsManager.success : ColorsManager.primaryGold,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    hint,
                    style: TextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: aligned ? ColorsManager.success : ColorsManager.goldInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Center(
          child: QiblaDial(
            heading: heading,
            qiblaBearing: qiblaBearing,
            aligned: aligned,
            size: dialSize,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: ColorsManager.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: ColorsManager.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _Stat(
                  label: 'زاوية القبلة',
                  value: _degrees(qiblaBearing),
                  color: ColorsManager.primaryGold,
                ),
                VerticalDivider(width: 1, color: ColorsManager.lightGray),
                _Stat(label: 'اتجاه الهاتف', value: _degrees(heading)),
                VerticalDivider(width: 1, color: ColorsManager.lightGray),
                _Stat(
                  label: 'الانحراف',
                  value: toArabicDigits('${turn.abs().round()}°'),
                  color: aligned ? ColorsManager.success : null,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: ColorsManager.lightGray,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.screen_rotation_rounded,
                size: 20.r,
                color: ColorsManager.secondaryText,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'ضع الهاتف أفقياً وبعيداً عن المعادن. إن ضعفت الدقة، حرّك الهاتف على شكل ٨.',
                  style: TextStyles.caption.copyWith(
                    height: 1.7,
                    color: ColorsManager.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: TextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: color ?? ColorsManager.primaryText,
            ),
          ),
          Text(label, style: TextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
