import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
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
    Future.microtask(() {
      context.read<QiblahCubit>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: true,
          child: BlocBuilder<QiblahCubit, QiblahState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  const BuildHeaderAppBar(
                    title: 'محدد القبلة',
                    description: 'وجّه هاتفك حتى تصبح الإبرة للأعلى',
                    pinned: true,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverToBoxAdapter(
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
        message: 'جهازك لا يدعم مستشعر البوصلة.',
        buttonText: 'إعادة المحاولة',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    if (state is QiblahLocationDisabled) {
      return _MessageCard(
        title: 'خدمة الموقع متوقفة',
        message: 'يرجى تفعيل GPS.',
        buttonText: 'إعادة المحاولة',
        onPressed: () => context.read<QiblahCubit>().refresh(),
      );
    }

    if (state is QiblahPermissionDenied ||
        state is QiblahPermissionDeniedForever) {
      return _MessageCard(
        title: 'إذن الموقع مطلوب',
        message: 'يرجى تفعيل إذن الموقع من الإعدادات.',
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

    return const _QiblahCompassCard();
  }
}

class _QiblahCompassCard extends StatefulWidget {
  const _QiblahCompassCard();

  @override
  State<_QiblahCompassCard> createState() => _QiblahCompassCardState();
}

class _QiblahCompassCardState extends State<_QiblahCompassCard> {
  bool _wasAligned = false;

  void _checkAlignment(double offset) {
    final isAligned = offset.abs() <= 5;
    if (isAligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
      _wasAligned = true;
    } else if (!isAligned && _wasAligned) {
      _wasAligned = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: QiblahFinderDecorations.compassCard(),
      child: StreamBuilder<QiblahDirection>(
        stream: FlutterQiblah.qiblahStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16.h),
                  Text('جاري تحديد الموقع...', style: TextStyles.bodyMedium),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          _checkAlignment(data.offset);
          final isAligned = data.offset.abs() <= 5;

          return Column(
            children: [
              /// Big Success Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isAligned ? 20.r : 12.r),
                decoration: BoxDecoration(
                  color:
                      isAligned
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isAligned ? Colors.green : Colors.grey.shade300,
                    width: isAligned ? 3 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedScale(
                      scale: isAligned ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isAligned ? Icons.check_circle : Icons.explore,
                        size: isAligned ? 48.r : 36.r,
                        color: isAligned ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isAligned ? 'تم ضبط اتجاه القبلة ✓' : 'اتجاه القبلة',
                      style: TextStyles.headlineMedium.copyWith(
                        color:
                            isAligned
                                ? Colors.green
                                : ColorsManager.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isAligned) ...{
                      SizedBox(height: 4.h),
                      Text(
                        'حرّك الهاتف حتى تصبح الإبرة للأعلى',
                        style: TextStyles.bodySmall.copyWith(
                          color: ColorsManager.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    },
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// Compass with circular progress indicator and arrows
              Stack(
                alignment: Alignment.center,
                children: [
                  // Circular Progress Indicator
                  SizedBox(
                    width: 310.r,
                    height: 310.r,
                    child: AnimatedRotation(
                      turns: isAligned ? 0.25 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: CircularProgressIndicator(
                        value: _getProgressValue(data.offset),
                        strokeWidth: 8.w,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(data.offset),
                        ),
                      ),
                    ),
                  ),

                  // Direction Arrow (when not aligned)
                  if (!isAligned)
                    Positioned(
                      top: data.offset > 0 ? null : 10.h,
                      bottom: data.offset > 0 ? 10.h : null,
                      child: AnimatedOpacity(
                        opacity: data.offset.abs() > 10 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          data.offset > 0
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          size: 40.r,
                          color: _getProgressColor(data.offset),
                        ),
                      ),
                    ),

                  // Compass with glow effect when aligned
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow:
                          isAligned
                              ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 40.r,
                                  spreadRadius: 8.r,
                                ),
                              ]
                              : [
                                BoxShadow(
                                  color: _getProgressColor(
                                    data.offset,
                                  ).withOpacity(0.2),
                                  blurRadius: 20.r,
                                  spreadRadius: 3.r,
                                ),
                              ],
                    ),
                    child: SizedBox(
                      width: 280.r,
                      height: 280.r,
                      child: _QiblahDial(
                        directionDegrees: data.direction,
                        qiblahDegrees: data.qiblah,
                        offsetDegrees: data.offset,
                        isAligned: isAligned,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              /// Large Offset Display with dynamic colors
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isAligned
                            ? [
                              Colors.green.shade50,
                              Colors.green.shade100,
                              Colors.green.shade50,
                            ]
                            : [
                              _getProgressColor(data.offset).withOpacity(0.1),
                              _getProgressColor(data.offset).withOpacity(0.2),
                              _getProgressColor(data.offset).withOpacity(0.1),
                            ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color:
                        isAligned
                            ? Colors.green
                            : _getProgressColor(data.offset),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isAligned
                              ? Colors.green
                              : _getProgressColor(data.offset))
                          .withOpacity(0.2),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isAligned ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isAligned
                                ? Icons.check_circle_rounded
                                : Icons.my_location,
                            color:
                                isAligned
                                    ? Colors.green
                                    : _getProgressColor(data.offset),
                            size: 28.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            isAligned
                                ? 'أنت الآن متجه نحو القبلة'
                                : 'الانحراف: ${data.offset.abs().toStringAsFixed(1)}°',
                            style: TextStyles.titleLarge.copyWith(
                              color:
                                  isAligned
                                      ? Colors.green.shade900
                                      : Colors.deepOrange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    if (!isAligned) ...{
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              data.offset > 0
                                  ? Icons.arrow_forward_rounded
                                  : Icons.arrow_back_rounded,
                              color: _getProgressColor(data.offset),
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                _getDirectionHint(data.offset),
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.deepOrange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    // Progress percentage
                    if (!isAligned) ...{
                      SizedBox(height: 10.h),
                      Text(
                        'دقة الاتجاه: ${(_getProgressValue(data.offset) * 100).toStringAsFixed(0)}%',
                        style: TextStyles.bodySmall.copyWith(
                          color: ColorsManager.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    },
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              _QiblahInfoRow(
                qiblahDegrees: data.qiblah,
                directionDegrees: data.direction,
                offsetDegrees: data.offset,
                isAligned: isAligned,
              ),
            ],
          );
        },
      ),
    );
  }

  String _getDirectionHint(double offset) {
    if (offset.abs() <= 5) return 'تم الضبط بنجاح';
    if (offset > 0) {
      if (offset > 45) return 'حرّك الهاتف كثيراً لليمين';
      if (offset > 15) return 'حرّك الهاتف لليمين';
      return 'حرّك الهاتف قليلاً لليمين';
    } else {
      if (offset < -45) return 'حرّك الهاتف كثيراً لليسار';
      if (offset < -15) return 'حرّك الهاتف لليسار';
      return 'حرّك الهاتف قليلاً لليسار';
    }
  }

  Color _getProgressColor(double offset) {
    final absOffset = offset.abs();
    if (absOffset <= 5) return Colors.green;
    if (absOffset <= 15) return Colors.lightGreen;
    if (absOffset <= 30) return Colors.amber;
    if (absOffset <= 60) return Colors.orange;
    return Colors.red;
  }

  double _getProgressValue(double offset) {
    final absOffset = offset.abs();
    if (absOffset >= 90) return 0.0;
    return 1.0 - (absOffset / 90);
  }
}

class _QiblahInfoRow extends StatelessWidget {
  final double qiblahDegrees;
  final double directionDegrees;
  final double offsetDegrees;
  final bool isAligned;

  const _QiblahInfoRow({
    required this.qiblahDegrees,
    required this.directionDegrees,
    required this.offsetDegrees,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.mosque,
            label: 'زاوية القبلة',
            value: '${qiblahDegrees.toStringAsFixed(0)}°',
            isAligned: isAligned,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _InfoChip(
            icon: Icons.explore,
            label: 'اتجاهك الحالي',
            value: '${directionDegrees.toStringAsFixed(0)}°',
            isAligned: isAligned,
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
  final bool isAligned;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isAligned
                  ? [
                    Colors.green.shade50,
                    Colors.green.shade100,
                    Colors.green.shade50,
                  ]
                  : [
                    Colors.white,
                    ColorsManager.primaryPurple.withOpacity(0.05),
                    Colors.white,
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color:
              isAligned
                  ? Colors.green.shade400
                  : ColorsManager.primaryPurple.withOpacity(0.3),
          width: isAligned ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAligned ? Colors.green : ColorsManager.primaryPurple)
                .withOpacity(isAligned ? 0.2 : 0.1),
            blurRadius: isAligned ? 12.r : 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedScale(
            scale: isAligned ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color:
                    isAligned
                        ? Colors.green.withOpacity(0.15)
                        : ColorsManager.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26.r,
                color:
                    isAligned
                        ? Colors.green.shade700
                        : ColorsManager.primaryPurple,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: ColorsManager.secondaryText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color:
                  isAligned ? Colors.green.shade900 : ColorsManager.primaryText,
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
  final bool isAligned;

  const _QiblahDial({
    required this.directionDegrees,
    required this.qiblahDegrees,
    required this.offsetDegrees,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(decoration: QiblahFinderDecorations.dialOuterRing()),

        /// Dial - rotates opposite to phone direction
        AnimatedRotation(
          turns: directionDegrees / 360,
          duration: const Duration(milliseconds: 300),
          child: CustomPaint(
            painter: _CompassDialPainter(isAligned: isAligned),
            child: const SizedBox.expand(),
          ),
        ),

        /// Needle - points to Qiblah direction relative to the dial
        AnimatedRotation(
          turns: (directionDegrees - qiblahDegrees) / 360,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: CustomPaint(
            painter: _NeedlePainter(isAligned: isAligned),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

/// Message Card Widget for errors and states
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
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
        padding: EdgeInsets.all(24.r),
        decoration: QiblahFinderDecorations.compassCard(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 64.r,
              color: ColorsManager.primaryPurple,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compass Dial Painter
class _CompassDialPainter extends CustomPainter {
  final bool isAligned;

  _CompassDialPainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    final directions = [
      {'angle': 0.0, 'label': 'ش', 'color': Colors.red},
      {'angle': math.pi / 2, 'label': 'ق', 'color': Colors.white},
      {'angle': math.pi, 'label': 'ج', 'color': Colors.white},
      {'angle': 3 * math.pi / 2, 'label': 'غ', 'color': Colors.white},
    ];

    for (var dir in directions) {
      final angle = dir['angle'] as double;
      final label = dir['label'] as String;
      final color = dir['color'] as Color;

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      );
      textPainter.layout();

      final x = center.dx + (radius - 30.r) * math.sin(angle);
      final y = center.dy - (radius - 30.r) * math.cos(angle);

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw tick marks
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 2.w;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * math.pi / 180;
      final isMajor = i % 6 == 0;
      final lineLength = isMajor ? 15.r : 8.r;

      final startRadius = radius - lineLength;
      final x1 = center.dx + startRadius * math.sin(angle);
      final y1 = center.dy - startRadius * math.cos(angle);
      final x2 = center.dx + radius * math.sin(angle);
      final y2 = center.dy - radius * math.cos(angle);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint..strokeWidth = isMajor ? 3.w : 1.5.w,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Needle Painter for Qiblah direction
class _NeedlePainter extends CustomPainter {
  final bool isAligned;

  _NeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw needle shadow
    final shadowPath =
        Path()
          ..moveTo(center.dx, center.dy - radius * 0.65)
          ..lineTo(center.dx - 12.w, center.dy + 10.h)
          ..lineTo(center.dx + 12.w, center.dy + 10.h)
          ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.r),
    );

    // Draw needle (green/gold top based on alignment)
    final needlePath =
        Path()
          ..moveTo(center.dx, center.dy - radius * 0.65)
          ..lineTo(center.dx - 10.w, center.dy)
          ..lineTo(center.dx + 10.w, center.dy)
          ..close();

    final topGradient =
        Paint()
          ..shader = LinearGradient(
            colors:
                isAligned
                    ? [Colors.green.shade600, Colors.lightGreenAccent]
                    : [Colors.amber.shade700, Colors.amber.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(needlePath, topGradient);

    // Draw needle border with glow effect when aligned
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = isAligned ? Colors.green : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = isAligned ? 2.5.w : 1.5.w,
    );

    // Draw needle (red bottom)
    final needleBottomPath =
        Path()
          ..moveTo(center.dx, center.dy + radius * 0.25)
          ..lineTo(center.dx - 10.w, center.dy)
          ..lineTo(center.dx + 10.w, center.dy)
          ..close();

    canvas.drawPath(needleBottomPath, Paint()..color = Colors.red.shade700);

    // Draw center circle
    canvas.drawCircle(
      center,
      12.r,
      Paint()
        ..color = ColorsManager.primaryPurple
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      12.r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.w,
    );

    // Draw center dot
    canvas.drawCircle(center, 4.r, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
