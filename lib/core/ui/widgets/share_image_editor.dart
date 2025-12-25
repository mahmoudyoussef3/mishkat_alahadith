import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../theming/colors.dart';
import '../../theming/styles.dart';

class ShareImageEditorBottomSheet extends StatefulWidget {
  final String text;
  final String appName;
  final String appIconAsset;
  final List<String> assetBackgrounds;
  final bool allowShareTextOnly;
  final double initialFontSize;
  final String initialFontFamily;

  const ShareImageEditorBottomSheet({
    super.key,
    required this.text,
    this.appName = 'مشكاة المصابيح',
    this.appIconAsset = 'assets/images/app_logo.png',
    this.assetBackgrounds = const [
      'assets/images/islamic_pattern.jpg',
      'assets/images/moon-light-shine-through-window-into-islamic-mosque-interior.jpg',
      'assets/images/first_onboardin.jpeg',
      'assets/images/search_logo.jpg',
    ],
    this.allowShareTextOnly = true,
    this.initialFontSize = 28,
    this.initialFontFamily = 'Amiri',
  });

  @override
  State<ShareImageEditorBottomSheet> createState() =>
      _ShareImageEditorBottomSheetState();
}

class _ShareImageEditorBottomSheetState
    extends State<ShareImageEditorBottomSheet> {
  final GlobalKey _exportKey = GlobalKey();

  Color _backgroundColor = Colors.white;
  String? _backgroundAssetPath;
  File? _backgroundFile;

  double _fontSize = 28;
  String _fontFamily = 'Amiri';
  FontWeight _fontWeight = FontWeight.w500;
  double _lineHeight = 1.7;
  Color _textColor = ColorsManager.primaryText;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
    _fontFamily = widget.initialFontFamily;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.mediumGray,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),

                // Header (Islamic pattern + gradient)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.w,
                    end: 16.w,
                    bottom: 12.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          ColorsManager.primaryPurple.withOpacity(0.12),
                          ColorsManager.primaryGold.withOpacity(0.10),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Opacity(
                              opacity: 0.06,
                              child: Image.asset(
                                'assets/images/islamic_pattern.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تخصيص صورة المشاركة',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.titleLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: ColorsManager.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'اختر خلفية وخطًا مناسبين للنص',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.bodySmall.copyWith(
                                        color: ColorsManager.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.allowShareTextOnly) ...[
                                TextButton.icon(
                                  onPressed: _shareTextOnly,
                                  icon: Icon(
                                    Icons.text_snippet_outlined,
                                    size: 18.sp,
                                    color: ColorsManager.primaryPurple,
                                  ),
                                  label: Text(
                                    'النص فقط',
                                    style: TextStyles.labelLarge.copyWith(
                                      color: ColorsManager.primaryPurple,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                              IconButton(
                                tooltip: 'إغلاق',
                                onPressed:
                                    () => Navigator.of(context).maybePop(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Preview
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsManager.cardBackground,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: ColorsManager.primaryGold.withOpacity(0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorsManager.primaryPurple.withOpacity(0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: RepaintBoundary(
                          key: _exportKey,
                          child: _buildCanvas(),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Controls
                _buildControls(),

                SizedBox(height: 8.h),

                // Action row
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.w,
                    end: 16.w,
                    bottom: 16.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('إعادة الضبط'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isExporting ? null : _exportAndShare,
                          icon:
                              _isExporting
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.ios_share_rounded),
                          label: Text(
                            _isExporting ? 'جارٍ التصدير...' : 'مشاركة الصورة',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    ImageProvider? bgImage;
    if (_backgroundFile != null) {
      bgImage = FileImage(_backgroundFile!);
    } else if (_backgroundAssetPath != null) {
      bgImage = AssetImage(_backgroundAssetPath!);
    }

    final bool hasImageBackground = bgImage != null;

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorsManager.primaryGold.withOpacity(0.20),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Background color/image
            Positioned.fill(
              child:
                  hasImageBackground
                      ? Image(image: bgImage, fit: BoxFit.cover)
                      : Container(color: _backgroundColor),
            ),

            // Islamic pattern when no image selected
            if (!hasImageBackground)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.10,
                  child: Image.asset(
                    'assets/images/islamic_pattern.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            // Contrast overlay (helps readability on photos)
            if (hasImageBackground)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.30),
                        Colors.transparent,
                        Colors.black.withOpacity(0.18),
                      ],
                    ),
                  ),
                ),
              ),

            // Foreground content
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title chip
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            hasImageBackground
                                ? Colors.black.withOpacity(0.20)
                                : ColorsManager.primaryGold.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(
                          color: ColorsManager.primaryGold.withOpacity(0.30),
                        ),
                      ),
                      child: Text(
                        'حديث نبوي شريف',
                        style: TextStyles.labelLarge.copyWith(
                          color:
                              hasImageBackground
                                  ? ColorsManager.white
                                  : ColorsManager.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Hadith text on a soft card for readability
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color:
                            hasImageBackground
                                ? ColorsManager.white.withOpacity(0.82)
                                : ColorsManager.white.withOpacity(0.90),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: ColorsManager.primaryPurple.withOpacity(0.10),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontWeight: _fontWeight,
                            color: _textColor,
                            height: _lineHeight,
                            fontSize: _fontSize.sp,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Branding footer
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [
                          ColorsManager.primaryPurple.withOpacity(0.22),
                          ColorsManager.white.withOpacity(0.92),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: ColorsManager.primaryPurple.withOpacity(0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          widget.appIconAsset,
                          width: 22.w,
                          height: 22.w,
                          errorBuilder: (_, __, ___) {
                            return const SizedBox.shrink();
                          },
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.titleSmall.copyWith(
                              color: ColorsManager.primaryGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.verified_rounded,
                          size: 18.sp,
                          color: ColorsManager.primaryGold,
                        ),
                      ],
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

  Widget _buildControls() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryPurple.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: ColorsManager.lightGray),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(
                icon: Icons.wallpaper_rounded,
                title: 'الخلفية',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ColorSwatch(color: _backgroundColor),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      onPressed: () => _openColorPicker(forText: false),
                      icon: const Icon(Icons.color_lens_rounded),
                      label: const Text('لون'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              SizedBox(
                height: 64.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.only(start: 4.w, end: 4.w),
                  itemCount:
                      widget.assetBackgrounds.length +
                      2, // + device pick + clear
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return _ImagePickerTile(onPick: _pickBackgroundImage);
                    }
                    if (index == widget.assetBackgrounds.length + 1) {
                      return _AssetThumb(
                        label: 'بدون',
                        child: const Icon(Icons.hide_image_rounded),
                        selected:
                            _backgroundAssetPath == null &&
                            _backgroundFile == null,
                        onTap:
                            () => setState(() {
                              _backgroundAssetPath = null;
                              _backgroundFile = null;
                            }),
                      );
                    }
                    final assetPath = widget.assetBackgrounds[index - 1];
                    return _AssetThumb(
                      label: 'صورة',
                      assetPath: assetPath,
                      selected: _backgroundAssetPath == assetPath,
                      onTap:
                          () => setState(() {
                            _backgroundAssetPath = assetPath;
                            _backgroundFile = null;
                          }),
                    );
                  },
                ),
              ),

              SizedBox(height: 12.h),
              Divider(color: ColorsManager.lightGray, height: 20.h),

              _SectionTitle(
                icon: Icons.tune_rounded,
                title: 'النص',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ColorSwatch(color: _textColor),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      onPressed: () => _openColorPicker(forText: true),
                      icon: const Icon(Icons.brush_rounded),
                      label: const Text('لون'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              _LabeledSlider(
                label: 'حجم الخط',
                valueText: _fontSize.toInt().toString(),
                value: _fontSize,
                min: 18,
                max: 50,
                onChanged: (v) => setState(() => _fontSize = v),
              ),

              SizedBox(height: 8.h),

              _LabeledSlider(
                label: 'تباعد الأسطر',
                valueText: _lineHeight.toStringAsFixed(1),
                value: _lineHeight,
                min: 1.2,
                max: 2.2,
                onChanged: (v) => setState(() => _lineHeight = v),
              ),

              SizedBox(height: 10.h),

              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ChoiceChip(
                    selected: _fontFamily == 'Amiri',
                    label: const Text('خط تراثي (أميري)'),
                    onSelected: (_) => setState(() => _fontFamily = 'Amiri'),
                  ),
                  ChoiceChip(
                    selected: _fontFamily == 'Cairo',
                    label: const Text('خط عصري (Cairo)'),
                    onSelected: (_) => setState(() => _fontFamily = 'Cairo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openColorPicker({required bool forText}) {
    final initial = forText ? _textColor : _backgroundColor;
    Color tempColor = initial;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            forText ? 'اختر لون النص' : 'اختر لون الخلفية',
            style: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initial,
              onColorChanged: (c) => tempColor = c,
              enableAlpha: false,
              labelTypes: const [],
              portraitOnly: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  if (forText) {
                    _textColor = tempColor;
                  } else {
                    _backgroundColor = tempColor;
                    _backgroundAssetPath = null;
                    _backgroundFile = null;
                  }
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (file == null) return;
      setState(() {
        _backgroundFile = File(file.path);
        _backgroundAssetPath = null;
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _reset() {
    setState(() {
      _backgroundColor = Colors.white;
      _backgroundAssetPath = null;
      _backgroundFile = null;
      _fontSize = widget.initialFontSize;
      _fontFamily = widget.initialFontFamily;
      _fontWeight = FontWeight.w500;
      _lineHeight = 1.7;
      _textColor = ColorsManager.primaryText;
    });
  }

  Future<void> _exportAndShare() async {
    try {
      setState(() => _isExporting = true);
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary =
          _exportKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'شارك الحديث المبارك');
    } catch (e) {
      debugPrint('Error exporting: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareTextOnly() async {
    try {
      await Share.share(widget.text);
    } catch (e) {
      debugPrint('Error sharing text: $e');
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  const _ColorSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: ColorsManager.primaryGold.withOpacity(0.12),
          ),
          child: Icon(icon, color: ColorsManager.primaryGold, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: TextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: ColorsManager.primaryText,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _LabeledSlider({
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92.w,
          child: Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: ColorsManager.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            value: value.clamp(min, max),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 42.w,
          child: Text(
            valueText,
            textAlign: TextAlign.end,
            style: TextStyles.labelLarge.copyWith(
              color: ColorsManager.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssetThumb extends StatelessWidget {
  final String? assetPath;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget? child;
  const _AssetThumb({
    this.assetPath,
    required this.selected,
    required this.label,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(8.r),
          image:
              assetPath != null
                  ? DecorationImage(
                    image: AssetImage(assetPath!),
                    fit: BoxFit.cover,
                  )
                  : null,
          border: Border.all(
            color: selected ? ColorsManager.primaryPurple : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
        child:
            assetPath == null
                ? Center(child: child ?? const SizedBox.shrink())
                : Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    color: Colors.black.withOpacity(0.35),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final Future<void> Function() onPick;
  const _ImagePickerTile({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onPick,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_rounded),
              SizedBox(height: 4.h),
              Text(
                'المعرض',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
