import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Search field with a soft focus ring and a clear button that appears
/// while there is text.
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final String? hintText;
  final VoidCallback? onTap;

  /// Focuses the field, and so opens the keyboard, as soon as it is shown.
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSearch,
    this.onChanged,
    this.onTap,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _focused = false;

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final radius = BorderRadius.circular(16.r);

    return Focus(
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52.h,
        decoration: BoxDecoration(
          color: palette.cardBackground,
          borderRadius: radius,
          border: Border.all(
            color: _focused ? palette.primaryPurple : palette.border,
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: [
            if (_focused)
              BoxShadow(color: palette.primarySoft, spreadRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 16.w, end: 10.w),
              child: Icon(
                Icons.search_rounded,
                color: palette.purpleText,
                size: 22.r,
              ),
            ),
            Expanded(
              child: TextField(
                onTap: widget.onTap,
                controller: widget.controller,
                autofocus: widget.autofocus,
                onSubmitted: widget.onSearch,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.search,
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  color: palette.primaryText,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: widget.hintText ?? 'ابحث في الأحاديث…',
                  hintStyle: TextStyles.bodyMedium.copyWith(
                    color: palette.gray,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder:
                  (context, value, _) =>
                      value.text.isEmpty
                          ? SizedBox(width: 16.w)
                          : IconButton(
                            tooltip: 'مسح',
                            onPressed: _clear,
                            icon: Icon(
                              Icons.close_rounded,
                              color: palette.gray,
                              size: 20.r,
                            ),
                          ),
            ),
          ],
        ),
      ),
    );
  }
}
