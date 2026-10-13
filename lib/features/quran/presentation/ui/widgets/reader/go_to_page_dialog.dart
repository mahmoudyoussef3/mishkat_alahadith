import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// Asks for a page number; resolves to it, or null if dismissed.
Future<int?> showGoToPageDialog(
  BuildContext context, {
  required int currentPage,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _GoToPageDialog(currentPage: currentPage),
  );
}

class _GoToPageDialog extends StatefulWidget {
  final int currentPage;

  const _GoToPageDialog({required this.currentPage});

  @override
  State<_GoToPageDialog> createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<_GoToPageDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Selected, so typing replaces it and submitting it stays on the page.
    final current = toArabicNumerals(widget.currentPage);
    _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: current,
        selection: TextSelection(baseOffset: 0, extentOffset: current.length),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _range =>
      'من ${toArabicNumerals(QuranMetrics.firstPage)} '
      'إلى ${toArabicNumerals(QuranMetrics.pageCount)}';

  void _submit() {
    final page = int.tryParse(toWesternDigits(_controller.text.trim()));
    if (page == null || !QuranMetrics.isValidPage(page)) {
      setState(() => _error = 'أدخل رقمًا $_range');
      return;
    }
    Navigator.of(context).pop(page);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide.none,
    );
    OutlineInputBorder ring(Color color) => fieldBorder.copyWith(
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('الانتقال إلى صفحة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل رقم صفحة $_range',
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                color: palette.secondaryText,
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.go,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]')),
                LengthLimitingTextInputFormatter(3),
              ],
              style: TextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.primaryText,
              ),
              decoration: InputDecoration(
                errorText: _error,
                filled: true,
                fillColor: palette.lightGray,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                border: fieldBorder,
                enabledBorder: fieldBorder,
                focusedBorder: ring(palette.primaryPurple),
                errorBorder: ring(palette.error),
                focusedErrorBorder: ring(palette.error),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(onPressed: _submit, child: const Text('انتقال')),
        ],
      ),
    );
  }
}
