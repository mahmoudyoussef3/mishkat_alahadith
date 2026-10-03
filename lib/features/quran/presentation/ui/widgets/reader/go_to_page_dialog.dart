import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// Asks for a page number; resolves to it, or null if dismissed.
Future<int?> showGoToPageDialog(
  BuildContext context, {
  required MushafColors colors,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _GoToPageDialog(colors: colors),
  );
}

class _GoToPageDialog extends StatefulWidget {
  final MushafColors colors;

  const _GoToPageDialog({required this.colors});

  @override
  State<_GoToPageDialog> createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<_GoToPageDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final page = int.tryParse(toWesternDigits(_controller.text.trim()));
    if (page == null || !QuranMetrics.isValidPage(page)) {
      setState(
        () =>
            _error =
                'أدخل رقمًا من ${toArabicNumerals(QuranMetrics.firstPage)} '
                'إلى ${toArabicNumerals(QuranMetrics.pageCount)}',
      );
      return;
    }
    Navigator.of(context).pop(page);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: colors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'الانتقال إلى صفحة',
          style: QuranTextStyles.sheetTitle(colors.ink),
        ),
        content: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.go,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]')),
            LengthLimitingTextInputFormatter(3),
          ],
          style: QuranTextStyles.filterField(colors.ink),
          cursorColor: colors.accent,
          decoration: InputDecoration(
            hintText:
                'رقم الصفحة (${toArabicNumerals(QuranMetrics.firstPage)}–'
                '${toArabicNumerals(QuranMetrics.pageCount)})',
            errorText: _error,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.accent, width: 1.5),
            ),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: colors.accent),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.paper,
            ),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
  }
}
