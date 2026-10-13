import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// A draggable, right-to-left bottom sheet in the theme around [context]:
/// over the mushaf, the reader's palette rather than the app's.
Future<T?> showQuranSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, ScrollController controller)
  builder,
  double initialChildSize = 0.6,
  double maxChildSize = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.antiAlias,
    builder:
        (sheetContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: initialChildSize,
            minChildSize: 0.3,
            maxChildSize: maxChildSize,
            builder: builder,
          ),
        ),
  );
}

/// The grip at the top of a [showQuranSheet], drawn like the theme's own.
///
/// It scrolls with the sheet's content, so dragging it drags the sheet.
class QuranSheetHandle extends StatelessWidget {
  const QuranSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32.w,
        height: 4.h,
        margin: EdgeInsets.only(top: 12.h, bottom: 14.h),
        decoration: BoxDecoration(
          color: AppPaletteOverride.of(context).mediumGray,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

/// A sheet's title with an optional line under it and a trailing widget.
class QuranSheetHeader extends StatelessWidget {
  const QuranSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final subtitle = this.subtitle;
    final trailing = this.trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: TextStyles.sectionTitle.copyWith(
                    color: palette.primaryText,
                  ),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyles.caption.copyWith(
                    fontSize: 13.sp,
                    height: 1.6,
                    color: palette.secondaryText,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 12.w), trailing],
      ],
    );
  }
}
