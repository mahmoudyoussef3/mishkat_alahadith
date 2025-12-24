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

class ShareImageEditorBottomSheet extends StatefulWidget {
  final String text;
  final String appName;
  final String appIconAsset;
  final List<String> assetBackgrounds;
  final bool allowShareTextOnly;
  final double initialFontSize;
  final String initialFontFamily;

  const ShareImageEditorBottomSheet({
    Key? key,
    required this.text,
    this.appName = 'مشكاة المصابيح',
    this.appIconAsset = 'assets/images/app_logo.png',
    this.assetBackgrounds = const [],
    this.allowShareTextOnly = true,
    this.initialFontSize = 28,
    this.initialFontFamily = 'Amiri',
  }) : super(key: key);

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
    return Container(
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
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Text(
                      'تخصيص صورة المشاركة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.primaryText,
                      ),
                    ),
                    const Spacer(),
                    if (widget.allowShareTextOnly)
                      TextButton.icon(
                        onPressed: _shareTextOnly,
                        icon: const Icon(Icons.text_fields_rounded),
                        label: const Text('نص فقط'),
                      ),
                    IconButton(
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              // Preview
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: RepaintBoundary(
                    key: _exportKey,
                    child: _buildCanvas(),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Controls
              _buildControls(),

              SizedBox(height: 8.h),

              // Action row
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('إعادة الضبط'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorsManager.primaryPurple,
                        ),
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
    );
  }

  Widget _buildCanvas() {
    ImageProvider? bgImage;
    if (_backgroundFile != null) {
      bgImage = FileImage(_backgroundFile!);
    } else if (_backgroundAssetPath != null) {
      bgImage = AssetImage(_backgroundAssetPath!);
    }

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        image:
            bgImage != null
                ? DecorationImage(image: bgImage, fit: BoxFit.cover)
                : null,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Optional header chip
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'نص الحديث',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color: ColorsManager.primaryText,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Hadith text
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
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

              SizedBox(height: 12.h),

              // Branding footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    widget.appIconAsset,
                    width: 20.w,
                    height: 20.w,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.appName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Background section
          Row(
            children: [
              Icon(Icons.wallpaper_rounded, color: ColorsManager.purpleText),
              SizedBox(width: 8.w),
              Text(
                'الخلفية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _ColorSwatch(color: _backgroundColor),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                onPressed: () => _openColorPicker(forText: false),
                icon: const Icon(Icons.color_lens_rounded),
                label: const Text('اختيار اللون'),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Background images: assets + device
          SizedBox(
            height: 60.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsetsDirectional.only(start: 8.w, end: 8.w),
              itemCount:
                  widget.assetBackgrounds.length + 2, // + device pick + clear
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, index) {
                if (index == 0) {
                  // Pick from device
                  return _ImagePickerTile(onPick: _pickBackgroundImage);
                }
                if (index == widget.assetBackgrounds.length + 1) {
                  // Clear
                  return _AssetThumb(
                    label: 'بدون',
                    child: const Icon(Icons.hide_image_rounded),
                    selected:
                        _backgroundAssetPath == null && _backgroundFile == null,
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

          SizedBox(height: 10.h),

          Divider(color: ColorsManager.mediumGray, height: 24.h),

          // Font size
          Row(
            children: [
              Text(
                'حجم الخط',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
              ),
              Expanded(
                child: Slider(
                  min: 18,
                  max: 50,
                  value: _fontSize,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
              ),
              Text(
                _fontSize.toInt().toString(),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
              ),
            ],
          ),

          // Line height
          Row(
            children: [
              Text(
                'تباعد الأسطر',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
              ),
              Expanded(
                child: Slider(
                  min: 1.2,
                  max: 2.2,
                  value: _lineHeight,
                  onChanged: (v) => setState(() => _lineHeight = v),
                ),
              ),
              Text(
                _lineHeight.toStringAsFixed(1),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Font family + weight (Amiri/Cairo only)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ChoiceChip(
                selected: _fontFamily == 'Amiri',
                label: const Text('Amiri'),
                onSelected: (_) => setState(() => _fontFamily = 'Amiri'),
              ),
              ChoiceChip(
                selected: _fontFamily == 'Cairo',
                label: const Text('Cairo'),
                onSelected: (_) => setState(() => _fontFamily = 'Cairo'),
              ),
              ChoiceChip(
                selected: _fontWeight == FontWeight.w400,
                label: const Text('رفيع'),
                onSelected:
                    (_) => setState(() => _fontWeight = FontWeight.w400),
              ),
              ChoiceChip(
                selected: _fontWeight == FontWeight.w700,
                label: const Text('عريض'),
                onSelected:
                    (_) => setState(() => _fontWeight = FontWeight.w700),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Text color section (picker only)
          Row(
            children: [
              const Icon(Icons.format_color_text_rounded),
              SizedBox(width: 8.w),
              Text(
                'لون النص',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _ColorSwatch(color: _textColor),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                onPressed: () => _openColorPicker(forText: true),
                icon: const Icon(Icons.brush_rounded),
                label: const Text('اختيار اللون'),
              ),
            ],
          ),
        ],
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
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
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

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'شارك الحديث المبارك 🌿');
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
