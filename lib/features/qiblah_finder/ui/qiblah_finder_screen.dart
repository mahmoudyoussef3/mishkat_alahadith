import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/logic/cubit/qiblah_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const double _kAlignmentThreshold = 5.0;
const Duration _kAnimDuration = Duration(milliseconds: 350);
const Duration _kPulseDuration = Duration(milliseconds: 1200);
const Curve _kAnimCurve = Curves.easeOutCubic;

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class QiblahFinderScreen extends StatefulWidget {
  const QiblahFinderScreen({super.key});

  @override
  State<QiblahFinderScreen> createState() => _QiblahFinderScreenState();
}

class _QiblahFinderScreenState extends State<QiblahFinderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<QiblahCubit>().init());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.primaryBackground,
        body: SafeArea(
          top: false,
          bottom: true,
          child: BlocBuilder<QiblahCubit, QiblahState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const BuildHeaderAppBar(
                    title: 'محدد القبلة',
                    description: 'وجّه هاتفك نحو اتجاه القبلة',
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: _buildBody(context, state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, QiblahState state) {
    return switch (state) {
      QiblahInitial() || QiblahLoading() => const _LoadingView(),
      QiblahSensorUnsupported() => _StateMessageView(
        icon: Icons.sensors_off_rounded,
        iconColor: ColorsManager.error,
        title: 'البوصلة غير مدعومة',
        message: 'جهازك لا يدعم مستشعر البوصلة اللازم لتحديد اتجاه القبلة.',
        buttonText: 'إعادة المحاولة',
        onRetry: () => context.read<QiblahCubit>().refresh(),
      ),
      QiblahLocationDisabled() => _StateMessageView(
        icon: Icons.location_off_rounded,
        iconColor: ColorsManager.warning,
        title: 'خدمة الموقع متوقفة',
        message:
            'يرجى تفعيل خدمة تحديد الموقع (GPS) حتى نتمكن من حساب اتجاه القبلة بدقة.',
        buttonText: 'إعادة المحاولة',
        onRetry: () => context.read<QiblahCubit>().refresh(),
      ),
      QiblahPermissionDenied() ||
      QiblahPermissionDeniedForever() => _StateMessageView(
        icon: Icons.lock_outline_rounded,
        iconColor: ColorsManager.primaryGold,
        title: 'إذن الموقع مطلوب',
        message:
            'نحتاج إذن الوصول إلى موقعك لحساب اتجاه القبلة. يرجى تفعيل الإذن من إعدادات الهاتف.',
        buttonText: 'إعادة المحاولة',
        onRetry: () => context.read<QiblahCubit>().refresh(),
      ),
      QiblahError(message: final msg) => _StateMessageView(
        icon: Icons.error_outline_rounded,
        iconColor: ColorsManager.error,
        title: 'حدث خطأ',
        message: msg,
        buttonText: 'إعادة المحاولة',
        onRetry: () => context.read<QiblahCubit>().refresh(),
      ),
      QiblahReady() => const _QiblahCompassView(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading View
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56.r,
            height: 56.r,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: const AlwaysStoppedAnimation(
                ColorsManager.primaryPurple,
              ),
              backgroundColor: ColorsManager.primaryPurple.withOpacity(0.12),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'جاري تهيئة البوصلة…',
            style: TextStyles.titleMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State Message View (errors / permissions / GPS)
// ─────────────────────────────────────────────────────────────────────────────

class _StateMessageView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onRetry;

  const _StateMessageView({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h),
        decoration: BoxDecoration(
          color: ColorsManager.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.10),
              ),
              child: Icon(icon, size: 40.r, color: iconColor),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  buttonText,
                  style: TextStyles.titleMedium.copyWith(
                    color: ColorsManager.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryPurple,
                  foregroundColor: ColorsManager.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compass View  –  StreamBuilder on FlutterQiblah.qiblahStream
// ─────────────────────────────────────────────────────────────────────────────

class _QiblahCompassView extends StatefulWidget {
  const _QiblahCompassView();

  @override
  State<_QiblahCompassView> createState() => _QiblahCompassViewState();
}

class _QiblahCompassViewState extends State<_QiblahCompassView>
    with SingleTickerProviderStateMixin {
  bool _wasAligned = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _kPulseDuration,
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _checkAlignment(double offset) {
    final aligned = offset.abs() <= _kAlignmentThreshold;
    if (aligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
      _wasAligned = true;
    } else if (!aligned && _wasAligned) {
      _wasAligned = false;
    }
  }

  // Helpers ───────────────────────────────────────────────────────────────

  Color _progressColor(double offset) {
    final a = offset.abs();
    if (a <= 5) return ColorsManager.success;
    if (a <= 15) return const Color(0xFF8BC34A); // light green
    if (a <= 30) return ColorsManager.warning;
    if (a <= 60) return const Color(0xFFFF5722); // deep orange
    return ColorsManager.error;
  }

  double _progressValue(double offset) =>
      (1.0 - (offset.abs().clamp(0, 90) / 90));

  String _directionHint(double offset) {
    if (offset.abs() <= _kAlignmentThreshold) return 'أنت على اتجاه القبلة';
    if (offset > 0) {
      if (offset > 45) return 'أدِر الهاتف كثيراً لليمين ←';
      if (offset > 15) return 'أدِر الهاتف لليمين ←';
      return 'أدِر قليلاً لليمين ←';
    } else {
      if (offset < -45) return '→ أدِر الهاتف كثيراً لليسار';
      if (offset < -15) return '→ أدِر الهاتف لليسار';
      return '→ أدِر قليلاً لليسار';
    }
  }

  String _cardinalName(double deg) {
    const names = [
      'شمال',
      'شمال شرق',
      'شرق',
      'جنوب شرق',
      'جنوب',
      'جنوب غرب',
      'غرب',
      'شمال غرب',
    ];
    final i = ((deg % 360 + 22.5) / 45).floor() % 8;
    return names[i];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _LoadingView();
        }

        final data = snapshot.data!;
        _checkAlignment(data.offset);

        final isAligned = data.offset.abs() <= _kAlignmentThreshold;
        final color = _progressColor(data.offset);
        final progress = _progressValue(data.offset);

        return Column(
          children: [
            SizedBox(height: 8.h),

            // ── Status banner ──
            _StatusBanner(
              isAligned: isAligned,
              hint: _directionHint(data.offset),
              color: color,
            ),

            SizedBox(height: 20.h),

            // ── Compass ──
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width - 40.w;
                final compassSize = math.min(screenWidth, 340.0);
                return Center(
                  child: _CompassWidget(
                    size: compassSize,
                    directionDeg: data.direction,
                    qiblahDeg: data.qiblah,
                    offsetDeg: data.offset,
                    isAligned: isAligned,
                    progressColor: color,
                    progress: progress,
                    pulseAnim: _pulseAnim,
                  ),
                );
              },
            ),

            SizedBox(height: 20.h),

            // ── Offset pill ──
            _OffsetPill(
              offset: data.offset,
              progress: progress,
              color: color,
              isAligned: isAligned,
            ),

            SizedBox(height: 16.h),

            // ── Info chips row ──
            _InfoRow(
              qiblahDeg: data.qiblah,
              directionDeg: data.direction,
              cardinalName: _cardinalName(data.direction),
              isAligned: isAligned,
            ),

            SizedBox(height: 12.h),

            // ── Tip ──
            _TipBar(isAligned: isAligned),

            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Banner
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final bool isAligned;
  final String hint;
  final Color color;

  const _StatusBanner({
    required this.isAligned,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: _kAnimCurve,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isAligned ? Icons.check_circle_rounded : Icons.explore_outlined,
              key: ValueKey(isAligned),
              color: color,
              size: 24.r,
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                hint,
                key: ValueKey(hint),
                style: TextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compass Widget
// ─────────────────────────────────────────────────────────────────────────────

class _CompassWidget extends StatelessWidget {
  final double size;
  final double directionDeg;
  final double qiblahDeg;
  final double offsetDeg;
  final bool isAligned;
  final Color progressColor;
  final double progress;
  final Animation<double> pulseAnim;

  const _CompassWidget({
    required this.size,
    required this.directionDeg,
    required this.qiblahDeg,
    required this.offsetDeg,
    required this.isAligned,
    required this.progressColor,
    required this.progress,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Pulsing glow ring ──
          if (isAligned)
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) {
                return Container(
                  width: size * pulseAnim.value,
                  height: size * pulseAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorsManager.success.withOpacity(
                        0.35 * pulseAnim.value,
                      ),
                      width: 4,
                    ),
                  ),
                );
              },
            ),

          // ── Progress arc ──
          SizedBox(
            width: size * 0.92,
            height: size * 0.92,
            child: AnimatedContainer(
              duration: _kAnimDuration,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: ColorsManager.lightGray,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ),

          // ── Compass dial ──
          SizedBox(
            width: size * 0.82,
            height: size * 0.82,
            child: _CompassDial(
              directionDeg: directionDeg,
              qiblahDeg: qiblahDeg,
              isAligned: isAligned,
            ),
          ),

          // ── Kaaba icon at top (fixed) ──
          Positioned(
            top: size * 0.015,
            child: AnimatedScale(
              scale: isAligned ? 1.15 : 1.0,
              duration: _kAnimDuration,
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isAligned
                          ? ColorsManager.success
                          : ColorsManager.primaryPurple,
                  boxShadow: [
                    BoxShadow(
                      color: (isAligned
                              ? ColorsManager.success
                              : ColorsManager.primaryPurple)
                          .withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mosque_rounded,
                  color: ColorsManager.white,
                  size: 18.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compass Dial  (rotates, contains needle)
// ─────────────────────────────────────────────────────────────────────────────

class _CompassDial extends StatelessWidget {
  final double directionDeg;
  final double qiblahDeg;
  final bool isAligned;

  const _CompassDial({
    required this.directionDeg,
    required this.qiblahDeg,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dial background
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsManager.cardBackground,
            border: Border.all(
              color: ColorsManager.primaryPurple.withOpacity(0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),

        // Rotating compass markings
        AnimatedRotation(
          turns: -directionDeg / 360,
          duration: const Duration(milliseconds: 280),
          curve: _kAnimCurve,
          child: CustomPaint(
            painter: _DialPainter(),
            child: const SizedBox.expand(),
          ),
        ),

        // Qiblah needle  (rotates to qiblah relative to device heading)
        AnimatedRotation(
          turns: -(directionDeg - qiblahDeg) / 360,
          duration: const Duration(milliseconds: 280),
          curve: _kAnimCurve,
          child: CustomPaint(
            painter: _NeedlePainter(isAligned: isAligned),
            child: const SizedBox.expand(),
          ),
        ),

        // Center hub
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
            ),
            border: Border.all(color: ColorsManager.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryPurple.withOpacity(0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.navigation_rounded,
            color: ColorsManager.white,
            size: 14.r,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Offset Pill
// ─────────────────────────────────────────────────────────────────────────────

class _OffsetPill extends StatelessWidget {
  final double offset;
  final double progress;
  final Color color;
  final bool isAligned;

  const _OffsetPill({
    required this.offset,
    required this.progress,
    required this.color,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: _kAnimCurve,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.22), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Accuracy badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              isAligned
                  ? 'اتجاه القبلة مضبوط بدقة'
                  : 'الانحراف ${offset.abs().toStringAsFixed(1)}°',
              style: TextStyles.titleMedium.copyWith(
                color: ColorsManager.primaryText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Row (Qiblah angle + Current heading)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final double qiblahDeg;
  final double directionDeg;
  final String cardinalName;
  final bool isAligned;

  const _InfoRow({
    required this.qiblahDeg,
    required this.directionDeg,
    required this.cardinalName,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.mosque_rounded,
            label: 'زاوية القبلة',
            value: '${qiblahDeg.toStringAsFixed(1)}°',
            accent: ColorsManager.primaryGold,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _InfoTile(
            icon: Icons.explore_rounded,
            label: cardinalName,
            value: '${directionDeg.toStringAsFixed(1)}°',
            accent: ColorsManager.primaryPurple,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accent.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 22.r, color: accent),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.labelSmall.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tip Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TipBar extends StatelessWidget {
  final bool isAligned;
  const _TipBar({required this.isAligned});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _kAnimDuration,
      child:
          isAligned
              ? const SizedBox.shrink()
              : Container(
                key: const ValueKey('tip'),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryPurple.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: ColorsManager.primaryPurple.withOpacity(0.14),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      size: 20.r,
                      color: ColorsManager.primaryGold,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'أمسك الهاتف بشكل أفقي بعيداً عن المعادن للحصول على أفضل دقة',
                        style: TextStyles.bodySmall.copyWith(
                          color: ColorsManager.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Custom Painters
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Dial Painter  — tick marks + cardinal letters
// ─────────────────────────────────────────────────────────────────────────────

class _DialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Ticks ──
    final minorPaint =
        Paint()
          ..color = ColorsManager.mediumGray.withOpacity(0.6)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;

    final majorPaint =
        Paint()
          ..color = ColorsManager.primaryPurple.withOpacity(0.55)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final tickLen = isMajor ? radius * 0.10 : radius * 0.05;
      final outerR = radius - 4;
      final innerR = outerR - tickLen;

      final p1 = Offset(
        center.dx + outerR * math.sin(angle),
        center.dy - outerR * math.cos(angle),
      );
      final p2 = Offset(
        center.dx + innerR * math.sin(angle),
        center.dy - innerR * math.cos(angle),
      );

      canvas.drawLine(p1, p2, isMajor ? majorPaint : minorPaint);
    }

    // ── Cardinal labels ──
    const labels = [
      (0.0, 'ش'), // N
      (math.pi / 2, 'ق'), // E
      (math.pi, 'ج'), // S
      (3 * math.pi / 2, 'غ'), // W
    ];

    for (final (angle, label) in labels) {
      final isNorth = angle == 0.0;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color:
                isNorth
                    ? ColorsManager.primaryPurple
                    : ColorsManager.secondaryText,
            fontSize: radius * 0.15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout();

      final labelR = radius * 0.72;
      final dx = center.dx + labelR * math.sin(angle) - tp.width / 2;
      final dy = center.dy - labelR * math.cos(angle) - tp.height / 2;

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Needle Painter  — gold arrow pointing to Qiblah
// ─────────────────────────────────────────────────────────────────────────────

class _NeedlePainter extends CustomPainter {
  final bool isAligned;
  _NeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final needleW = r * 0.09;
    final needleTopY = center.dy - r * 0.58;
    final needleBottomY = center.dy + r * 0.20;

    // ── Shadow ──
    final shadowPath =
        Path()
          ..moveTo(center.dx, needleTopY + 2)
          ..lineTo(center.dx - needleW, center.dy + 4)
          ..lineTo(center.dx + needleW, center.dy + 4)
          ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = ColorsManager.black.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // ── Top half (gold / green when aligned) ──
    final topPath =
        Path()
          ..moveTo(center.dx, needleTopY)
          ..lineTo(center.dx - needleW, center.dy)
          ..lineTo(center.dx + needleW, center.dy)
          ..close();

    final topColor =
        isAligned ? ColorsManager.success : ColorsManager.primaryGold;
    final topGradient =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, topColor.withOpacity(0.7)],
          ).createShader(
            Rect.fromLTRB(
              center.dx - needleW,
              needleTopY,
              center.dx + needleW,
              center.dy,
            ),
          );

    canvas.drawPath(topPath, topGradient);

    // Outline
    canvas.drawPath(
      topPath,
      Paint()
        ..color = ColorsManager.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── Bottom half (muted) ──
    final bottomPath =
        Path()
          ..moveTo(center.dx, needleBottomY)
          ..lineTo(center.dx - needleW, center.dy)
          ..lineTo(center.dx + needleW, center.dy)
          ..close();

    canvas.drawPath(
      bottomPath,
      Paint()..color = ColorsManager.mediumGray.withOpacity(0.55),
    );
    canvas.drawPath(
      bottomPath,
      Paint()
        ..color = ColorsManager.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter old) => old.isAligned != isAligned;
}
