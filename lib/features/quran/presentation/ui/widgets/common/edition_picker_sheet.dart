import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_editions/quran_editions_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';

import 'quran_sheet.dart';

/// What the reader picked: an edition, or none at all when the sheet
/// offered that.
class EditionSelection {
  final QuranEdition? edition;

  const EditionSelection(this.edition);
}

/// The editions of [type] to choose from, [selectedId] ticked. Resolves to
/// null when dismissed.
Future<EditionSelection?> showEditionPickerSheet(
  BuildContext context, {
  required QuranEditionType type,
  required String? selectedId,
  bool allowNone = false,
}) {
  return showQuranSheet<EditionSelection>(
    context: context,
    initialChildSize: 0.7,
    builder:
        (context, controller) => BlocProvider(
          create: (_) => getIt<QuranEditionsCubit>()..load(type),
          child: _EditionPicker(
            controller: controller,
            type: type,
            selectedId: selectedId,
            allowNone: allowNone,
          ),
        ),
  );
}

/// Shows the editions of [type], hands what the reader picked to [apply],
/// and tells them if it could not be kept for next time. Does nothing when
/// the sheet is dismissed.
Future<void> pickEdition(
  BuildContext context, {
  required QuranEditionType type,
  required String? selectedId,
  required Future<bool> Function(QuranEdition? edition) apply,
  bool allowNone = false,
}) async {
  final picked = await showEditionPickerSheet(
    context,
    type: type,
    selectedId: selectedId,
    allowNone: allowNone,
  );
  if (picked == null || !context.mounted) return;
  if (picked.edition == null && !allowNone) return;
  final saved = await apply(picked.edition);
  if (!saved && context.mounted) {
    showErrorSnackbar(context, 'تعذر حفظ اختيارك لمرة قادمة');
  }
}

class _EditionPicker extends StatelessWidget {
  /// Lists longer than this get a filter field.
  static const int _filterThreshold = 12;

  final ScrollController controller;
  final QuranEditionType type;
  final String? selectedId;
  final bool allowNone;

  const _EditionPicker({
    required this.controller,
    required this.type,
    required this.selectedId,
    required this.allowNone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranEditionsCubit, QuranEditionsState>(
      builder: (context, state) {
        final header = [
          const QuranSheetHandle(),
          QuranSheetHeader(
            title: editionPickerTitle(type),
            subtitle: switch (type) {
              QuranEditionType.recitation =>
                'تُبثّ التلاوة من الإنترنت، آيةً آية',
              QuranEditionType.tafsir => 'يظهر التفسير مع كل آية تختارها',
              QuranEditionType.translation =>
                'تظهر ترجمة معاني الآية تحت تفسيرها',
            },
          ),
          SizedBox(height: 14.h),
        ];
        return switch (state) {
          QuranEditionsLoading() => ListView(
            controller: controller,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              ...header,
              SizedBox(height: 60.h),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
          QuranEditionsFailure(:final message) => ListView(
            controller: controller,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              ...header,
              StateMessage.error(
                message: message,
                onRetry: () => context.read<QuranEditionsCubit>().load(type),
              ),
            ],
          ),
          QuranEditionsLoaded(:final editions, :final visible, :final query) =>
            ListView(
              controller: controller,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              children: [
                ...header,
                if (editions.length > _filterThreshold) ...[
                  _FilterField(
                    onChanged: context.read<QuranEditionsCubit>().filter,
                  ),
                  SizedBox(height: 12.h),
                ],
                if (allowNone && query.trim().isEmpty)
                  _EditionTile(
                    title: 'بدون ترجمة',
                    subtitle: 'يظهر التفسير وحده',
                    selected: selectedId == null,
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pop(const EditionSelection(null)),
                  ),
                if (visible.isEmpty)
                  StateMessage(
                    icon: Icons.search_off_rounded,
                    title: 'لا توجد نتائج',
                    subtitle: 'لا يوجد ما يطابق «${query.trim()}»',
                  ),
                for (final edition in visible)
                  _EditionTile(
                    title: edition.name,
                    subtitle: _subtitle(edition),
                    selected: edition.identifier == selectedId,
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pop(EditionSelection(edition)),
                  ),
              ],
            ),
        };
      },
    );
  }

  String _subtitle(QuranEdition edition) {
    final english = edition.englishName.trim();
    return [
      if (english.isNotEmpty && english != edition.name) ltrIsolate(english),
      if (type == QuranEditionType.translation) languageName(edition.language),
    ].join(' · ');
  }
}

class _FilterField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _FilterField({required this.onChanged});

  @override
  State<_FilterField> createState() => _FilterFieldState();
}

class _FilterFieldState extends State<_FilterField> {
  late final TextEditingController _controller;

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

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyles.bodyMedium.copyWith(color: palette.primaryText),
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم أو اللغة…',
        prefixIcon: const Icon(Icons.search_rounded),
        isDense: true,
        filled: true,
        fillColor: palette.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _EditionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _EditionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? palette.primarySoft : palette.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: selected ? palette.primaryPurple : palette.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                selected
                                    ? palette.purpleText
                                    : palette.primaryText,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.caption.copyWith(
                              color: palette.secondaryText,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (selected) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 22.r,
                      color: palette.primaryPurple,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
