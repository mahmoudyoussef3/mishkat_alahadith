import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:transparent_image/transparent_image.dart';

/// Photograph shown, dimmed, behind featured panels.
const String kMosqueImage =
    'assets/images/moon-light-shine-through-window-into-islamic-mosque-interior.jpg';

/// Which way the scrim over the photograph darkens.
enum HeroScrim {
  /// Light at the top, nearly opaque at the bottom where text sits.
  vertical,

  /// Darkest on the reading side (start), lighter towards the end.
  horizontal,
}

/// Deep night-indigo panel, optionally over a dimmed mosque photograph,
/// for featured content: the hadith of the day, the next prayer, the user's
/// account. Text drawn on it should be light.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.showImage = true,
    this.imageOpacity = 0.3,
    this.scrim = HeroScrim.vertical,
    this.onTap,
  });

  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final bool showImage;
  final double imageOpacity;
  final HeroScrim scrim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final night = ColorsManager.heroBackground;
    final content = Padding(padding: padding ?? EdgeInsets.all(18.r), child: child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 24.r),
      child: ColoredBox(
        color: night,
        child: Stack(
          children: [
            if (showImage) ...[
              Positioned.fill(
                child: Opacity(
                  opacity: imageOpacity,
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: const AssetImage(kMosqueImage),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 400),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: switch (scrim) {
                      HeroScrim.vertical => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          night.withValues(alpha: 0.4),
                          night.withValues(alpha: 0.95),
                        ],
                      ),
                      HeroScrim.horizontal => LinearGradient(
                        begin: AlignmentDirectional.centerEnd,
                        end: AlignmentDirectional.centerStart,
                        colors: [
                          night.withValues(alpha: 0.55),
                          night.withValues(alpha: 0.92),
                        ],
                      ),
                    },
                  ),
                ),
              ),
            ],
            if (onTap == null)
              content
            else
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap, child: content),
              ),
          ],
        ),
      ),
    );
  }
}
