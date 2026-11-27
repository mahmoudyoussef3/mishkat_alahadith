import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/ui/widgets/share/share_card_style.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';

/// The image that gets shared: the hadith on the chosen background, with
/// its source and the app's name at the foot.
///
/// Everything is sized relative to [width], so the preview and the
/// exported image look alike; the text shrinks to fit when it is long.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.style,
    required this.parts,
    required this.width,
    this.source,
  });

  final ShareCardStyle style;
  final HadithTextParts parts;
  final double width;
  final String? source;

  /// The card width the design's sizes are written for.
  static const _designWidth = 276.0;

  @override
  Widget build(BuildContext context) {
    final scale = width / _designWidth;
    final height = width / style.aspect.ratio;
    final onDark = style.hasImage || ShareColors.isDark(style.background);
    final rule =
        onDark
            ? Colors.white.withValues(alpha: 0.18)
            : ShareColors.ink.withValues(alpha: 0.1);
    final photo = style.photo;
    final source = this.source;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: style.background),
            if (style.mosqueImage)
              Image.asset(kMosqueImage, fit: BoxFit.cover)
            else if (photo != null)
              Image.file(photo, fit: BoxFit.cover),
            if (style.hasImage)
              ColoredBox(color: ShareColors.night.withValues(alpha: 0.72)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                18 * scale,
                18 * scale,
                18 * scale,
                12 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (context, constraints) => _FittedText(
                            style: style,
                            parts: parts,
                            scale: scale,
                            maxWidth: constraints.maxWidth,
                            maxHeight: constraints.maxHeight,
                          ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: rule)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 8 * scale),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              source ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w600,
                                color: style.ink.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5 * scale),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 16 * scale,
                              height: 16 * scale,
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Text(
                            'مشكاة الأحاديث',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w800,
                              color: style.accent,
                            ),
                          ),
                        ],
                      ),
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
}

/// The isnad (when shown) above the matn, centred vertically, at the
/// chosen size or smaller when that would not fit.
class _FittedText extends StatelessWidget {
  const _FittedText({
    required this.style,
    required this.parts,
    required this.scale,
    required this.maxWidth,
    required this.maxHeight,
  });

  final ShareCardStyle style;
  final HadithTextParts parts;
  final double scale;
  final double maxWidth;
  final double maxHeight;

  static const _isnadRatio = 0.6;

  @override
  Widget build(BuildContext context) {
    final isnad = style.showIsnad ? parts.isnad : null;
    final aspectScale = style.aspect == ShareAspect.story ? 0.8 : 1.0;
    final size = _fittingSize(
      style.fontSize * aspectScale * scale,
      isnad: isnad,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isnad != null) ...[
          Text(
            isnad,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: style.align,
            style: _isnadStyle(size),
          ),
          SizedBox(height: 6 * scale),
        ],
        Text(parts.matn, textAlign: style.align, style: _matnStyle(size)),
      ],
    );
  }

  TextStyle _matnStyle(double size) => TextStyle(
    fontFamily: style.font.family,
    fontWeight: style.font.weight,
    fontSize: size,
    height: style.lineHeight,
    color: style.ink,
  );

  TextStyle _isnadStyle(double size) => TextStyle(
    fontFamily: style.font.family,
    fontSize: size * _isnadRatio,
    height: 1.8,
    color: style.ink.withValues(alpha: 0.65),
  );

  /// The largest size up to [desired] at which the text fits the space.
  double _fittingSize(double desired, {String? isnad}) {
    final minimum = 8 * scale;
    var size = desired;
    while (size > minimum && _heightAt(size, isnad) > maxHeight) {
      size -= 0.5 * scale;
    }
    return size;
  }

  double _heightAt(double size, String? isnad) {
    double measure(String text, TextStyle textStyle, {int? maxLines}) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.rtl,
        maxLines: maxLines,
      )..layout(maxWidth: maxWidth);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final matn = measure(parts.matn, _matnStyle(size));
    if (isnad == null) return matn;
    return matn + 6 * scale + measure(isnad, _isnadStyle(size), maxLines: 2);
  }
}
