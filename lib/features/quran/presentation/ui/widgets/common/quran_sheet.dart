import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';

/// A draggable, right-to-left bottom sheet drawn in [colors].
Future<T?> showQuranSheet<T>({
  required BuildContext context,
  required QuranSurfaceColors colors,
  required Widget Function(BuildContext context, ScrollController controller)
  builder,
  double initialChildSize = 0.6,
  double maxChildSize = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: colors.background,
    isScrollControlled: true,
    useSafeArea: true,
    shape: QuranDecorations.sheetShape(),
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

class QuranSheetHandle extends StatelessWidget {
  final QuranSurfaceColors colors;

  const QuranSheetHandle({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
        decoration: QuranDecorations.sheetHandle(colors),
      ),
    );
  }
}
