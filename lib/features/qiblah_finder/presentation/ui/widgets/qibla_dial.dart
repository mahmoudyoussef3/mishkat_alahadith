import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Compass face that turns with the phone: the top always points where the
/// phone points, a gold arc and needle run to the Qibla, and the Kaaba
/// marker sits on the rim at the Qibla's bearing.
class QiblaDial extends StatelessWidget {
  const QiblaDial({
    super.key,
    required this.heading,
    required this.qiblaBearing,
    required this.aligned,
    this.size = 300,
  });

  /// Where the phone points, in degrees clockwise from north.
  final double heading;

  /// Bearing of the Kaaba from here, in degrees clockwise from north.
  final double qiblaBearing;
  final bool aligned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = 8.0;
    final face = size - 2 * ring;
    final relative = _normalize(qiblaBearing - heading);
    final markerRadius = face / 2 - 30;
    final angle = relative * math.pi / 180;
    final marker = 44.r;

    return SizedBox(
      width: size,
      height: size + 20,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Fixed pointer: where the top of the phone points.
          CustomPaint(
            size: const Size(18, 14),
            painter: _PointerPainter(ColorsManager.primaryText),
          ),
          Positioned(
            top: 20,
            child: CustomPaint(
              size: Size.square(size),
              painter: _DialPainter(
                heading: heading,
                relative: relative,
                ring: ring,
                aligned: aligned,
                arc: aligned ? ColorsManager.success : ColorsManager.goldBright,
                face: ColorsManager.cardBackground,
                border: ColorsManager.border,
                majorTick: ColorsManager.gray,
                minorTick: ColorsManager.mediumGray,
                north: ColorsManager.purpleText,
                cardinal: ColorsManager.secondaryText,
                needle: aligned ? ColorsManager.success : ColorsManager.primaryGold,
                hub: ColorsManager.primaryText,
              ),
            ),
          ),
          Positioned(
            top: 20 + size / 2 - markerRadius * math.cos(angle) - marker / 2,
            left: size / 2 + markerRadius * math.sin(angle) - marker / 2,
            child: Container(
              width: marker,
              height: marker,
              decoration: BoxDecoration(
                color: ColorsManager.heroBackground,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.heroBackground.withValues(alpha: 0.5),
                    blurRadius: 14,
                    spreadRadius: -4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.mosque_rounded,
                size: 24.r,
                color: ColorsManager.goldBright,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [degrees] folded into (-180, 180].
  static double _normalize(double degrees) {
    var value = degrees % 360;
    if (value > 180) value -= 360;
    if (value <= -180) value += 360;
    return value;
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height)
          ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.heading,
    required this.relative,
    required this.ring,
    required this.aligned,
    required this.arc,
    required this.face,
    required this.border,
    required this.majorTick,
    required this.minorTick,
    required this.north,
    required this.cardinal,
    required this.needle,
    required this.hub,
  });

  final double heading;
  final double relative;
  final double ring;
  final bool aligned;
  final Color arc;
  final Color face;
  final Color border;
  final Color majorTick;
  final Color minorTick;
  final Color north;
  final Color cardinal;
  final Color needle;
  final Color hub;

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width / 2;
    final radius = outer - ring;

    // Arc from the phone's heading (top) round to the Qibla.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outer - ring / 2),
      -math.pi / 2,
      _rad(relative),
      false,
      Paint()
        ..color = arc
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, radius, Paint()..color = face);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke,
    );

    // Ticks every 5°, longer every 30°, turning against the heading so
    // north stays north.
    for (var degree = 0; degree < 360; degree += 5) {
      final major = degree % 30 == 0;
      final t = _rad(degree - heading);
      final direction = Offset(math.sin(t), -math.cos(t));
      final start = center + direction * (radius - 8);
      final end = center + direction * (radius - 8 - (major ? 12 : 6));
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = major ? majorTick : minorTick
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    const cardinals = [(0, 'ش'), (90, 'ق'), (180, 'ج'), (270, 'غ')];
    for (final (degree, label) in cardinals) {
      final t = _rad(degree - heading);
      final position =
          center + Offset(math.sin(t), -math.cos(t)) * (radius - 40);
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: degree == 0 ? north : cardinal,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      painter.paint(
        canvas,
        position - Offset(painter.width / 2, painter.height / 2),
      );
      painter.dispose();
    }

    // Needle towards the Qibla.
    final t = _rad(relative);
    canvas.drawLine(
      center,
      center + Offset(math.sin(t), -math.cos(t)) * (radius * 0.73),
      Paint()
        ..color = needle
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, 10, Paint()..color = face);
    canvas.drawCircle(center, 6, Paint()..color = hub);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.heading != heading ||
      old.relative != relative ||
      old.aligned != aligned ||
      old.face != face ||
      old.arc != arc;
}
