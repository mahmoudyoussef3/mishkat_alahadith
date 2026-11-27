import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../helpers/hadith_text.dart';
import '../../theming/colors.dart';
import '../../theming/styles.dart';
import '../../widgets/hero_surface.dart';
import '../../widgets/segmented_tabs.dart';
import 'share/share_card.dart';
import 'share/share_card_style.dart';

/// Turns a hadith into an image to share: pick a template, background and
/// type, preview it live, then share the picture or just the text.
class ShareImageEditorBottomSheet extends StatefulWidget {
  const ShareImageEditorBottomSheet({
    super.key,
    required this.text,
    this.deepLink,
    this.source,
  });

  final String text;

  /// Link back into the app, added to the shared caption.
  final String? deepLink;

  /// Where the hadith is recorded, printed at the foot of the card.
  final String? source;

  @override
  State<ShareImageEditorBottomSheet> createState() =>
      _ShareImageEditorBottomSheetState();
}

enum _Tab { templates, background, text }

class _ShareImageEditorBottomSheetState
    extends State<ShareImageEditorBottomSheet> {
  final _exportKey = GlobalKey();
  late final HadithTextParts _parts = HadithTextParts.split(widget.text);

  ShareCardStyle _style = const ShareCardStyle();
  _Tab _tab = _Tab.templates;
  bool _exporting = false;

  void _update(ShareCardStyle style) => setState(() => _style = style);

  String get _caption {
    final link = widget.deepLink;
    return [
      'من تطبيق مشكاة الأحاديث',
      if (link != null && link.isNotEmpty) link,
    ].join('\n');
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      _update(_style.withPhoto(File(picked.path)));
    } catch (_) {
      if (mounted) _notify('تعذر فتح معرض الصور');
    }
  }

  Future<void> _shareImage() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final boundary =
          _exportKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      // Export about 1080 pixels wide whatever the preview size.
      final image = await boundary.toImage(
        pixelRatio: 1080 / boundary.size.width,
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('No image data');

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/mishkat_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: _caption),
      );
    } catch (_) {
      if (mounted) _notify('تعذر إنشاء الصورة، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareText() async {
    final source = widget.source;
    await SharePlus.instance.share(
      ShareParams(
        text: [
          HadithTextParts.typeset(widget.text),
          if (source != null && source.isNotEmpty) '— $source',
          '',
          _caption,
        ].join('\n'),
      ),
    );
  }

  void _notify(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: ColorsManager.mediumGray,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            _Header(
              source: widget.source,
              onShareText: _shareText,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            Expanded(child: _Preview(exportKey: _exportKey, style: _style, parts: _parts, source: widget.source)),
            _AspectRow(
              style: _style,
              hasIsnad: _parts.isnad != null,
              onChanged: _update,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: SegmentedTabs(
                labels: const ['القوالب', 'الخلفية', 'النص'],
                selectedIndex: _tab.index,
                onChanged: (index) => setState(() => _tab = _Tab.values[index]),
              ),
            ),
            SizedBox(
              height: 170.h,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                child: switch (_tab) {
                  _Tab.templates => _TemplatePicker(
                    style: _style,
                    onChanged: _update,
                  ),
                  _Tab.background => _BackgroundPicker(
                    style: _style,
                    onChanged: _update,
                    onPickPhoto: _pickPhoto,
                  ),
                  _Tab.text => _TextControls(style: _style, onChanged: _update),
                },
              ),
            ),
            _ActionBar(
              exporting: _exporting,
              onReset: () => _update(const ShareCardStyle()),
              onShare: _shareImage,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.source,
    required this.onShareText,
    required this.onClose,
  });

  final String? source;
  final VoidCallback onShareText;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final source = this.source;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مشاركة كصورة',
                  style: TextStyles.sectionTitle.copyWith(height: 1.3),
                ),
                Text(
                  source == null || source.isEmpty
                      ? 'اختر قالباً وشارك الحديث'
                      : source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.caption,
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onShareText,
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorsManager.primaryText,
              backgroundColor: ColorsManager.cardBackground,
              side: BorderSide(color: ColorsManager.border),
              minimumSize: Size(0, 38.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              textStyle: TextStyles.chipLabel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.notes_rounded, size: 18.r),
            label: const Text('نص فقط'),
          ),
          SizedBox(width: 8.w),
          IconButton.filledTonal(
            tooltip: 'إغلاق',
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: ColorsManager.lightGray,
              foregroundColor: ColorsManager.primaryText,
              fixedSize: Size.square(38.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.close_rounded, size: 20.r),
          ),
        ],
      ),
    );
  }
}

/// The card, as large as the space and its shape allow.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.exportKey,
    required this.style,
    required this.parts,
    required this.source,
  });

  final GlobalKey exportKey;
  final ShareCardStyle style;
  final HadithTextParts parts;
  final String? source;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ratio = style.aspect.ratio;
          final width = [
            constraints.maxWidth,
            constraints.maxHeight * ratio,
          ].reduce((a, b) => a < b ? a : b);
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: width,
              height: width / ratio,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.coverShadow,
                    blurRadius: 30,
                    spreadRadius: -16,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: exportKey,
                child: ShareCard(
                  style: style,
                  parts: parts,
                  width: width,
                  source: source,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AspectRow extends StatelessWidget {
  const _AspectRow({
    required this.style,
    required this.hasIsnad,
    required this.onChanged,
  });

  final ShareCardStyle style;
  final bool hasIsnad;
  final ValueChanged<ShareCardStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Row(
        children: [
          _Segments<ShareAspect>(
            values: ShareAspect.values,
            selected: style.aspect,
            builder:
                (aspect, selected) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(aspect.icon, size: 16.r),
                    SizedBox(width: 4.w),
                    Text(aspect.label),
                  ],
                ),
            onSelected: (aspect) => onChanged(style.copyWith(aspect: aspect)),
          ),
          const Spacer(),
          if (hasIsnad)
            Semantics(
              toggled: style.showIsnad,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap:
                    () => onChanged(style.copyWith(showIsnad: !style.showIsnad)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Text(
                        'السند',
                        style: TextStyles.chipLabel.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Switch(
                        value: style.showIsnad,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged:
                            (value) => onChanged(style.copyWith(showIsnad: value)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({required this.style, required this.onChanged});

  final ShareCardStyle style;
  final ValueChanged<ShareCardStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final template in shareTemplates)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 10.w),
              child: _TemplateThumb(
                template: template,
                selected: style.templateId == template.id,
                onTap: () => onChanged(style.withTemplate(template)),
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplateThumb extends StatelessWidget {
  const _TemplateThumb({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final ShareTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, Color color, double height) =>
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            margin: EdgeInsets.only(top: 5.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );

    return Semantics(
      button: true,
      selected: selected,
      label: 'قالب ${template.label}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            _SelectionRing(
              selected: selected,
              radius: 14.r,
              child: Container(
                width: 76.r,
                height: 96.r,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: template.background,
                  borderRadius: BorderRadius.circular(14.r),
                  image:
                      template.mosqueImage
                          ? DecorationImage(
                            image: const AssetImage(kMosqueImage),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              ShareColors.night.withValues(alpha: 0.7),
                              BlendMode.srcOver,
                            ),
                          )
                          : null,
                  border: Border.all(color: ColorsManager.border),
                ),
                padding: EdgeInsets.all(10.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    bar(0.4, template.accent, 4.h),
                    bar(1, template.ink.withValues(alpha: 0.85), 5.h),
                    bar(1, template.ink.withValues(alpha: 0.85), 5.h),
                    bar(0.7, template.ink.withValues(alpha: 0.85), 5.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              template.label,
              style: TextStyles.chipLabel.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color:
                    selected
                        ? ColorsManager.purpleText
                        : ColorsManager.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPicker extends StatelessWidget {
  const _BackgroundPicker({
    required this.style,
    required this.onChanged,
    required this.onPickPhoto,
  });

  final ShareCardStyle style;
  final ValueChanged<ShareCardStyle> onChanged;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final photo = style.photo;
    final mosque = shareTemplates.firstWhere((t) => t.mosqueImage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ControlLabel('لون الخلفية'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            for (final color in ShareColors.backgrounds)
              _ColorDot(
                color: color,
                size: 34.r,
                selected: !style.hasImage && style.background == color,
                onTap: () => onChanged(style.withBackground(color)),
              ),
          ],
        ),
        SizedBox(height: 14.h),
        const _ControlLabel('صورة خلفية'),
        SizedBox(height: 8.h),
        Row(
          children: [
            _SelectionRing(
              selected: photo != null,
              radius: 14.r,
              child: Material(
                color: ColorsManager.cardBackground,
                borderRadius: BorderRadius.circular(14.r),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPickPhoto,
                  child: Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: ColorsManager.mediumGray, width: 1.5),
                      image:
                          photo == null
                              ? null
                              : DecorationImage(
                                image: FileImage(photo),
                                fit: BoxFit.cover,
                              ),
                    ),
                    child:
                        photo != null
                            ? null
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 22.r,
                                  color: ColorsManager.purpleText,
                                ),
                                Text('المعرض', style: TextStyles.labelSmall),
                              ],
                            ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Semantics(
              button: true,
              selected: style.mosqueImage,
              label: 'صورة المسجد',
              child: GestureDetector(
                onTap: () => onChanged(style.withTemplate(mosque)),
                child: _SelectionRing(
                  selected: style.mosqueImage,
                  radius: 14.r,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.asset(
                      kMosqueImage,
                      width: 64.r,
                      height: 64.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextControls extends StatelessWidget {
  const _TextControls({required this.style, required this.onChanged});

  final ShareCardStyle style;
  final ValueChanged<ShareCardStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10.w,
          children: [
            for (final ink in ShareColors.inks)
              _ColorDot(
                color: ink,
                size: 30.r,
                selected: style.ink == ink,
                onTap: () => onChanged(style.copyWith(ink: ink)),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _Segments<ShareFont>(
                values: ShareFont.values,
                selected: style.font,
                expand: true,
                builder:
                    (font, _) => Text(
                      font.label,
                      style: TextStyle(fontFamily: font.family),
                    ),
                onSelected: (font) => onChanged(style.copyWith(font: font)),
              ),
            ),
            SizedBox(width: 8.w),
            _Segments<TextAlign>(
              values: const [TextAlign.right, TextAlign.center, TextAlign.justify],
              selected: style.align,
              builder:
                  (align, _) => Icon(switch (align) {
                    TextAlign.center => Icons.format_align_center_rounded,
                    TextAlign.justify => Icons.format_align_justify_rounded,
                    _ => Icons.format_align_right_rounded,
                  }, size: 19.r),
              onSelected: (align) => onChanged(style.copyWith(align: align)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _Stepper(
                label: 'حجم الخط',
                value: style.fontSize.round().toString(),
                onDecrease:
                    style.fontSize > ShareCardStyle.minFontSize
                        ? () => onChanged(style.copyWith(fontSize: style.fontSize - 1))
                        : null,
                onIncrease:
                    style.fontSize < ShareCardStyle.maxFontSize
                        ? () => onChanged(style.copyWith(fontSize: style.fontSize + 1))
                        : null,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _Stepper(
                label: 'تباعد الأسطر',
                value: style.lineHeight.toStringAsFixed(1),
                onDecrease:
                    style.lineHeight > ShareCardStyle.minLineHeight + 0.01
                        ? () => onChanged(
                          style.copyWith(lineHeight: style.lineHeight - 0.1),
                        )
                        : null,
                onIncrease:
                    style.lineHeight < ShareCardStyle.maxLineHeight - 0.01
                        ? () => onChanged(
                          style.copyWith(lineHeight: style.lineHeight + 0.1),
                        )
                        : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.exporting,
    required this.onReset,
    required this.onShare,
  });

  final bool exporting;
  final VoidCallback onReset;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        border: Border(top: BorderSide(color: ColorsManager.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 48.r,
                child: OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.square(48.r),
                    foregroundColor: ColorsManager.primaryText,
                    side: BorderSide(color: ColorsManager.border),
                  ),
                  child: Tooltip(
                    message: 'إعادة الضبط',
                    child: Icon(Icons.restart_alt_rounded, size: 21.r),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FilledButton.icon(
                  onPressed: exporting ? null : onShare,
                  style: FilledButton.styleFrom(minimumSize: Size.fromHeight(48.r)),
                  icon:
                      exporting
                          ? SizedBox.square(
                            dimension: 18.r,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.ios_share_rounded, size: 20.r),
                  label: const Text('مشاركة الصورة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact segmented control for a few choices.
class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.values,
    required this.selected,
    required this.builder,
    required this.onSelected,
    this.expand = false,
  });

  final List<T> values;
  final T selected;
  final Widget Function(T value, bool selected) builder;
  final ValueChanged<T> onSelected;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final segments = [
      for (final value in values)
        _segment(value, value == selected),
    ];
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final segment in segments)
            expand ? Expanded(child: segment) : segment,
        ],
      ),
    );
  }

  Widget _segment(T value, bool isSelected) {
    final foreground =
        isSelected ? ColorsManager.purpleText : ColorsManager.secondaryText;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          alignment: expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: isSelected ? ColorsManager.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: DefaultTextStyle.merge(
              style: TextStyles.chipLabel.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: foreground,
              ),
              child: builder(value, isSelected),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String tooltip, VoidCallback? onTap) =>
        IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: ColorsManager.lightGray,
            fixedSize: Size.square(30.r),
            minimumSize: Size.square(30.r),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.r),
            ),
          ),
          icon: Icon(icon, size: 18.r),
        );

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Row(
        children: [
          button(Icons.remove_rounded, 'تقليل $label', onDecrease),
          Expanded(
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyles.labelLarge.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                Text(label, style: TextStyles.labelSmall.copyWith(fontSize: 10.sp)),
              ],
            ),
          ),
          button(Icons.add_rounded, 'زيادة $label', onIncrease),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: _SelectionRing(
          selected: selected,
          radius: size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: ShareColors.ink.withValues(alpha: 0.12)),
            ),
          ),
        ),
      ),
    );
  }
}

/// A brand outline drawn just outside the selected swatch.
class _SelectionRing extends StatelessWidget {
  const _SelectionRing({
    required this.selected,
    required this.radius,
    required this.child,
  });

  final bool selected;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius + 4.r),
        border: Border.all(
          color: selected ? ColorsManager.primaryPurple : Colors.transparent,
          width: 2,
        ),
      ),
      child: child,
    );
  }
}

class _ControlLabel extends StatelessWidget {
  const _ControlLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.chipLabel.copyWith(color: ColorsManager.secondaryText),
    );
  }
}
