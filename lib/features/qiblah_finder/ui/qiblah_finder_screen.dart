import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/qiblah_finder_styles.dart';
import 'package:mishkat_almasabih/core/theming/qiblah_finder_decorations.dart';
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
      decoration: QiblahFinderDecorations.compassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اتجاه القبلة',
            style: QiblahFinderTextStyles.compassCardTitle,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final size =
                  (constraints.maxWidth < 360) ? constraints.maxWidth : 360.0;
              final dialSize = size.clamp(260.0, 380.0).r;

              return StreamBuilder<QiblahDirection>(
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
                        style: QiblahFinderTextStyles.loadingMessage,
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: dialSize,
                          height: dialSize,
                          child: _QiblahDial(
                            directionDegrees: data.direction,
                            qiblahDegrees: data.qiblah,
                            offsetDegrees: data.offset,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _QiblahInfoRow(
                        qiblahDegrees: data.qiblah,
                        directionDegrees: data.direction,
                        offsetDegrees: data.offset,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: QiblahFinderDecorations.tipsContainer(),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: QiblahFinderDecorations.tipsIconContainer(),
                  child: const Icon(
                    QiblahFinderDecorations.tipsIcon,
                    color: QiblahFinderDecorations.tipsIconColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'نصائح لنتيجة أدق',
                        style: QiblahFinderTextStyles.tipsSectionTitle,
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 6.h),
                      _TipLine(text: 'حرّك الهاتف على شكل رقم 8 للمعايرة.'),
                      _TipLine(text: 'أبعد الهاتف عن المعادن/المغناطيس.'),
                      _TipLine(text: 'أمسك الهاتف بشكل مسطّح قدر الإمكان.'),
                    ],
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

class _QiblahInfoRow extends StatelessWidget {
  final double qiblahDegrees;
  final double directionDegrees;
  final double offsetDegrees;

  const _QiblahInfoRow({
    required this.qiblahDegrees,
    required this.directionDegrees,
    required this.offsetDegrees,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.mosque,
            label: 'زاوية القبلة',
            value: '${qiblahDegrees.toStringAsFixed(1)}°',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _InfoChip(
            icon: Icons.explore_rounded,
            label: 'اتجاه الشمال',
            value: '${directionDegrees.toStringAsFixed(1)}°',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _InfoChip(
            icon: Icons.tune_rounded,
            label: 'الانحراف',
            value: '${offsetDegrees.toStringAsFixed(1)}°',
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 10.w,
        end: 10.w,
        top: 10.h,
        bottom: 10.h,
      ),
      decoration: QiblahFinderDecorations.infoChip(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: QiblahFinderDecorations.infoChipIconColor,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: QiblahFinderTextStyles.infoChipLabel,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: QiblahFinderTextStyles.infoChipValue,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  final String text;

  const _TipLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            QiblahFinderDecorations.tipsCheckIcon,
            size: 16.sp,
            color: QiblahFinderDecorations.tipsCheckIconColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: QiblahFinderTextStyles.tipText,
              textAlign: TextAlign.right,
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
        Container(decoration: QiblahFinderDecorations.dialOuterRing()),

        // Inner surface
        Padding(
          padding: EdgeInsets.all(14.r),
          child: Container(
            decoration: QiblahFinderDecorations.dialInnerSurface(),
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
          decoration: QiblahFinderDecorations.dialCenterHub(),
        ),

        // Qiblah badge
        PositionedDirectional(
          top: 14.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: QiblahFinderDecorations.qiblahBadgeContainer(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: QiblahFinderDecorations.qiblahIconContainer(),
                  child: const Icon(
                    QiblahFinderDecorations.qiblahIcon,
                    color: QiblahFinderDecorations.qiblahIconColor,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('القبلة', style: QiblahFinderTextStyles.qiblahBadgeText),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: QiblahFinderDecorations.qiblahDegreeBadge(),
                  child: Text(
                    '${qiblahDegrees.toStringAsFixed(0)}°',
                    style: QiblahFinderTextStyles.qiblahDegreeBadge,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Offset label
        PositionedDirectional(
          bottom: 10.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: QiblahFinderDecorations.offsetLabelContainer(),
            child: Text(
              'الانحراف: ${offsetDegrees.toStringAsFixed(1)}°',
              style: QiblahFinderTextStyles.offsetLabel,
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

    final ringPaint = QiblahFinderDecorations.dialRingPaint(radius);

    canvas.drawCircle(center, radius * 0.98, ringPaint);

    final minorPaint = QiblahFinderDecorations.dialMinorTickPaint(radius);

    final majorPaint = QiblahFinderDecorations.dialMajorTickPaint(radius);

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
      color: QiblahFinderDecorations.dialNorthLabelColor,
    );
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'ق',
      angleDegrees: 90,
      color: QiblahFinderDecorations.dialOtherLabelColor,
    );
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'ج',
      angleDegrees: 180,
      color: QiblahFinderDecorations.dialOtherLabelColor,
    );
    _drawLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      text: 'غ',
      angleDegrees: 270,
      color: QiblahFinderDecorations.dialOtherLabelColor,
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

    final needlePaint = QiblahFinderDecorations.needlePaint();

    final shadowPaint = QiblahFinderDecorations.needleShadowPaint();

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
      decoration: QiblahFinderDecorations.messageCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: QiblahFinderTextStyles.messageCardTitle,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: QiblahFinderTextStyles.messageCardDescription,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: QiblahFinderDecorations.messageCardButton(),
              child: Text(
                buttonText,
                style: QiblahFinderTextStyles.messageCardButtonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
