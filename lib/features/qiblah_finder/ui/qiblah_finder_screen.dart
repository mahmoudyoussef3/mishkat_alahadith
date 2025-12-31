import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/logic/cubit/qiblah_cubit.dart';

class QiblahFinderScreen extends StatefulWidget {
  const QiblahFinderScreen({super.key});

  @override
  State<QiblahFinderScreen> createState() => _QiblahFinderScreenState();
}

class _QiblahFinderScreenState extends State<QiblahFinderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QiblahCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          top: false,
          bottom: true,
          child: BlocBuilder<QiblahCubit, QiblahState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  const BuildHeaderAppBar(
                    title: 'محدد القبلة',
                    description: 'وجّه هاتفك لتظهر جهة القبلة',
                    pinned: true,
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 16.w,
                        end: 16.w,
                      ),
                      child: _buildBody(context, state),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, QiblahState state) {
    if (state is QiblahLoading || state is QiblahInitial) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state is QiblahSensorUnsupported) {
      return _MessageCard(
        title: 'البوصلة غير مدعومة',
        message: 'جهازك لا يدعم مستشعر البوصلة المطلوب لعرض اتجاه القبلة.',
        buttonText: 'إعادة المحاولة',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    if (state is QiblahLocationDisabled) {
      return _MessageCard(
        title: 'خدمة الموقع متوقفة',
        message: 'يرجى تفعيل الموقع (GPS) ثم إعادة المحاولة.',
        buttonText: 'إعادة المحاولة',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    if (state is QiblahPermissionDenied) {
      return _MessageCard(
        title: 'صلاحية الموقع مطلوبة',
        message: 'لا يمكن تحديد القبلة بدون إذن الموقع.',
        buttonText: 'المحاولة مرة أخرى',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    if (state is QiblahPermissionDeniedForever) {
      return _MessageCard(
        title: 'تم رفض الصلاحية نهائيًا',
        message: 'فعّل إذن الموقع من إعدادات النظام ثم أعد المحاولة.',
        buttonText: 'إعادة المحاولة',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    if (state is QiblahError) {
      return _MessageCard(
        title: 'حدث خطأ',
        message: state.message,
        buttonText: 'إعادة المحاولة',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    return _QiblahCompassCard();
  }
}

class _QiblahCompassCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.mediumGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.mediumGray.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اتجاه القبلة',
            style: TextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final size =
                  (constraints.maxWidth < 360) ? constraints.maxWidth : 360.0;
              final dialSize = size.clamp(260.0, 380.0).r;

              return Center(
                child: SizedBox(
                  width: dialSize,
                  height: dialSize,
                  child: StreamBuilder<QiblahDirection>(
                    stream: FlutterQiblah.qiblahStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text(
                            'جاري قراءة المستشعرات...',
                            style: TextStyles.bodyMedium.copyWith(
                              color: ColorsManager.secondaryText,
                            ),
                          ),
                        );
                      }

                      final data = snapshot.data!;
                      return _QiblahDial(
                        directionDegrees: data.direction,
                        qiblahDegrees: data.qiblah,
                        offsetDegrees: data.offset,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: ColorsManager.primaryPurple.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryGold.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: ColorsManager.primaryGold,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'لأفضل دقة: حرّك الهاتف على شكل رقم 8 ثم وجّهه للأمام.',
                    style: TextStyles.bodyMedium.copyWith(
                      color: ColorsManager.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
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

class _QiblahDial extends StatelessWidget {
  final double directionDegrees;
  final double qiblahDegrees;
  final double offsetDegrees;

  const _QiblahDial({
    required this.directionDegrees,
    required this.qiblahDegrees,
    required this.offsetDegrees,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorsManager.primaryPurple.withOpacity(0.22),
                ColorsManager.primaryPurple.withOpacity(0.10),
              ],
            ),
          ),
        ),

        // Inner surface
        Padding(
          padding: EdgeInsets.all(14.r),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorsManager.cardBackground,
              border: Border.all(color: ColorsManager.mediumGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.mediumGray.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),

        // Dial + ticks rotated by device heading
        Transform.rotate(
          angle: (directionDegrees * (math.pi / 180) * -1),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: CustomPaint(
              painter: _CompassDialPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Qiblah needle (rotated by qiblah direction)
        Transform.rotate(
          angle: (qiblahDegrees * (math.pi / 180) * -1),
          child: Padding(
            padding: EdgeInsets.all(30.r),
            child: CustomPaint(
              painter: _NeedlePainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Center hub
        Container(
          width: 18.r,
          height: 18.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsManager.primaryPurple,
            border: Border.all(color: ColorsManager.white, width: 2),
          ),
        ),

        // Offset label
        PositionedDirectional(
          bottom: 10.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: ColorsManager.secondaryBackground,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: ColorsManager.mediumGray, width: 1),
            ),
            child: Text(
              'الانحراف: ${offsetDegrees.toStringAsFixed(1)}°',
              style: TextStyles.bodySmall.copyWith(
                color: ColorsManager.secondaryText,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final ringPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.06
          ..color = ColorsManager.primaryPurple.withOpacity(0.18);

    canvas.drawCircle(center, radius * 0.98, ringPaint);

    final minorPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.012
          ..strokeCap = StrokeCap.round
          ..color = ColorsManager.mediumGray.withOpacity(0.75);

    final majorPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.02
          ..strokeCap = StrokeCap.round
          ..color = ColorsManager.primaryPurple.withOpacity(0.55);

    for (int deg = 0; deg < 360; deg += 10) {
      final isMajor = deg % 30 == 0;
      final paint = isMajor ? majorPaint : minorPaint;
      final outer = radius * 0.98;
      final inner = radius * (isMajor ? 0.84 : 0.88);
      final angle = (deg * (math.pi / 180));

      final p1 = Offset(
        center.dx + outer * math.cos(angle),
        center.dy + outer * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + inner * math.cos(angle),
        center.dy + inner * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint);
    }

    // Cardinal labels (Arabic abbreviations)
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'ش',
      angleDegrees: 0,
      color: ColorsManager.primaryPurple,
    );
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'ق',
      angleDegrees: 90,
      color: ColorsManager.secondaryText,
    );
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'ج',
      angleDegrees: 180,
      color: ColorsManager.secondaryText,
    );
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'غ',
      angleDegrees: 270,
      color: ColorsManager.secondaryText,
    );
  }

  void _drawLabel({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required String text,
    required int angleDegrees,
    required Color color,
  }) {
    final angle = angleDegrees * (math.pi / 180);
    final labelRadius = radius * 0.70;
    final pos = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: (radius * 0.14).clamp(14.0, 22.0),
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout();

    painter.paint(
      canvas,
      Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final needlePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = ColorsManager.primaryGold;

    final shadowPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = ColorsManager.black.withOpacity(0.10);

    final needleLength = radius * 0.88;
    final needleWidth = radius * 0.09;

    final path =
        Path()
          ..moveTo(center.dx, center.dy - needleLength)
          ..lineTo(center.dx + needleWidth / 2, center.dy)
          ..lineTo(center.dx, center.dy + needleLength * 0.12)
          ..lineTo(center.dx - needleWidth / 2, center.dy)
          ..close();

    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _MessageCard({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.mediumGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyles.bodyMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryPurple,
                foregroundColor: ColorsManager.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyles.labelLarge.copyWith(
                  color: ColorsManager.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
