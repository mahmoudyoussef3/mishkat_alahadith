import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../theming/colors.dart';
import '../../theming/styles.dart';

const _kBgPresets = <Color>[
  Colors.white,
  Color(0xFFFFF8E1), 
  Color(0xFFF3E5F5), 
  Color(0xFFE8F5E9), 
  Color(0xFF263238), 
  Color(0xFF1A1A2E), 
  Color(0xFF0D1B2A), 
  Colors.black,
];

const _kTextPresets = <Color>[
  Color(0xFF212121), // primary text
  Colors.white,
  Color(0xFFFFB300), // gold
  Color(0xFF7440E9), // purple
  Color(0xFF4CAF50), // green
  Color(0xFFE53935), // red
  Color(0xFF2196F3), // blue
  Color(0xFF795548), // brown
];

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
    this.appName = 'مشكاة الأحاديث',
    this.appIconAsset = 'assets/images/app_logo.png',
    this.assetBackgrounds = const [
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
    extends State<ShareImageEditorBottomSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey _exportKey = GlobalKey();

  // Background state
  Color _backgroundColor = Colors.white;
  String? _backgroundAssetPath;
  File? _backgroundFile;

  // Text state
  double _fontSize = 28;
  String _fontFamily = 'Amiri';
  FontWeight _fontWeight = FontWeight.w500;
  double _lineHeight = 1.7;
  Color _textColor = ColorsManager.primaryText;
  TextAlign _textAlign = TextAlign.justify;

  // UI state
  int _selectedTab = 0; // 0 = background, 1 = text
  bool _isExporting = false;

  late final AnimationController _tabFadeCtrl;
  late final Animation<double> _tabFadeAnim;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
    _fontFamily = widget.initialFontFamily;
    _tabFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _tabFadeAnim = CurvedAnimation(
      parent: _tabFadeCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabFadeCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int tab) {
    if (tab == _selectedTab) return;
    _tabFadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _selectedTab = tab);
      _tabFadeCtrl.forward();
    });
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(bottom: bottom),
        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                _buildHeader(),
                SizedBox(height: 8.h),
                _buildPreview(),
                SizedBox(height: 14.h),
                _buildTabBar(),
                SizedBox(height: 8.h),
                _buildTabContent(),
                SizedBox(height: 12.h),
                _buildActionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
      child: Center(
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: ColorsManager.mediumGray,
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مشاركة كصورة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColorsManager.primaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'خصّص المظهر ثم شارك الصورة',
                  style: TextStyles.bodySmall.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          if (widget.allowShareTextOnly)
            _HeaderAction(
              icon: Icons.text_snippet_outlined,
              label: 'نص فقط',
              onTap: _shareTextOnly,
            ),
          SizedBox(width: 4.w),
          _HeaderAction(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: ColorsManager.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'معاينة',
              style: TextStyles.labelSmall.copyWith(
                color: ColorsManager.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: ColorsManager.cardBackground,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: RepaintBoundary(
                  key: _exportKey,
                  child: _buildCanvas(),
                ),
              ),
            ),
          ),
        ],
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
    final bool hasImageBg = bgImage != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImageBg
                ? Image(image: bgImage, fit: BoxFit.cover)
                : ColoredBox(color: _backgroundColor),
          ),
          if (hasImageBg)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                      Colors.black.withOpacity(0.20),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Text(
                      widget.text,
                      textAlign: _textAlign,
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
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Image.asset(
                      widget.appIconAsset,
                      width: 20.w,
                      height: 20.w,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        widget.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.titleSmall.copyWith(
                          color: hasImageBg
                              ? Colors.white.withOpacity(0.9)
                              : ColorsManager.primaryPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'الخلفية',
              icon: Icons.wallpaper_rounded,
              selected: _selectedTab == 0,
              onTap: () => _switchTab(0),
            ),
            _TabItem(
              label: 'النص',
              icon: Icons.text_fields_rounded,
              selected: _selectedTab == 1,
              onTap: () => _switchTab(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return FadeTransition(
      opacity: _tabFadeAnim,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _selectedTab == 0
              ? _buildBackgroundControls()
              : _buildTextControls(),
        ),
      ),
    );
  }

  // BACKGROUND CONTROLS
  Widget _buildBackgroundControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        const _MiniLabel(text: 'لون الخلفية'),
        SizedBox(height: 8.h),
        Row(
          children: [
            ..._kBgPresets.map(
              (c) => Expanded(
                child: _ColorDot(
                  color: c,
                  selected: _backgroundAssetPath == null &&
                      _backgroundFile == null &&
                      _backgroundColor == c,
                  onTap: () => setState(() {
                    _backgroundColor = c;
                    _backgroundAssetPath = null;
                    _backgroundFile = null;
                  }),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            _ColorDot(
              color: _backgroundColor,
              isCustom: true,
              selected: false,
              onTap: () => _openColorPicker(forText: false),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const _MiniLabel(text: 'صورة خلفية'),
        SizedBox(height: 8.h),
        SizedBox(
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.only(end: 4.w),
            itemCount: widget.assetBackgrounds.length + 2,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, index) {
              if (index == 0) {
                return _ImagePickerTile(onPick: _pickBackgroundImage);
              }
              if (index == widget.assetBackgrounds.length + 1) {
                return _AssetThumb(
                  label: 'بدون',
                  selected:
                      _backgroundAssetPath == null && _backgroundFile == null,
                  onTap: () => setState(() {
                    _backgroundAssetPath = null;
                    _backgroundFile = null;
                  }),
                  child: Icon(
                    Icons.hide_image_rounded,
                    color: ColorsManager.secondaryText,
                    size: 22.sp,
                  ),
                );
              }
              final path = widget.assetBackgrounds[index - 1];
              return _AssetThumb(
                label: 'صورة',
                assetPath: path,
                selected: _backgroundAssetPath == path,
                onTap: () => setState(() {
                  _backgroundAssetPath = path;
                  _backgroundFile = null;
                }),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  // TEXT CONTROLS
  Widget _buildTextControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        const _MiniLabel(text: 'لون النص'),
        SizedBox(height: 8.h),
        Row(
          children: [
            ..._kTextPresets.map(
              (c) => Expanded(
                child: _ColorDot(
                  color: c,
                  selected: _textColor == c,
                  onTap: () => setState(() => _textColor = c),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            _ColorDot(
              color: _textColor,
              isCustom: true,
              selected: false,
              onTap: () => _openColorPicker(forText: true),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const _MiniLabel(text: 'نوع الخط'),
        SizedBox(height: 8.h),
        Row(
          children: [
            _FontChip(
              label: 'أميري (تراثي)',
              fontFamily: 'Amiri',
              selected: _fontFamily == 'Amiri',
              onTap: () => setState(() => _fontFamily = 'Amiri'),
            ),
            SizedBox(width: 10.w),
            _FontChip(
              label: 'القاهرة (عصري)',
              fontFamily: 'Cairo',
              selected: _fontFamily == 'Cairo',
              onTap: () => setState(() => _fontFamily = 'Cairo'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MiniLabel(text: 'السُمك'),
                  SizedBox(height: 8.h),
                  _ToggleRow(
                    items: const [
                      _ToggleItem(Icons.format_bold_rounded, 'عريض'),
                      _ToggleItem(Icons.text_format_rounded, 'عادي'),
                      _ToggleItem(Icons.format_italic_rounded, 'رفيع'),
                    ],
                    selectedIndex: _fontWeight == FontWeight.w700
                        ? 0
                        : _fontWeight == FontWeight.w500
                            ? 1
                            : 2,
                    onChanged: (i) => setState(() {
                      _fontWeight = [
                        FontWeight.w700,
                        FontWeight.w500,
                        FontWeight.w300,
                      ][i];
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MiniLabel(text: 'المحاذاة'),
                  SizedBox(height: 8.h),
                  _ToggleRow(
                    items: const [
                      _ToggleItem(Icons.format_align_right_rounded, 'يمين'),
                      _ToggleItem(Icons.format_align_center_rounded, 'وسط'),
                      _ToggleItem(Icons.format_align_justify_rounded, 'ضبط'),
                    ],
                    selectedIndex: _textAlign == TextAlign.right
                        ? 0
                        : _textAlign == TextAlign.center
                            ? 1
                            : 2,
                    onChanged: (i) => setState(() {
                      _textAlign = [
                        TextAlign.right,
                        TextAlign.center,
                        TextAlign.justify,
                      ][i];
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _LabeledSlider(
          label: 'حجم الخط',
          valueText: _fontSize.toInt().toString(),
          value: _fontSize,
          min: 16,
          max: 48,
          onChanged: (v) => setState(() => _fontSize = v),
        ),
        SizedBox(height: 6.h),
        _LabeledSlider(
          label: 'تباعد الأسطر',
          valueText: _lineHeight.toStringAsFixed(1),
          value: _lineHeight,
          min: 1.2,
          max: 2.4,
          onChanged: (v) => setState(() => _lineHeight = v),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 16.w,
        end: 16.w,
        bottom: 16.h,
      ),
      child: Row(
        children: [
          SizedBox(
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ColorsManager.mediumGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              icon: Icon(
                Icons.restart_alt_rounded,
                size: 18.sp,
                color: ColorsManager.secondaryText,
              ),
              label: Text(
                'إعادة الضبط',
                style: TextStyles.labelLarge.copyWith(
                  color: ColorsManager.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: const LinearGradient(
                    colors: [
                      ColorsManager.primaryPurple,
                      ColorsManager.accentPurple,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primaryPurple.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: _isExporting
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.ios_share_rounded, size: 20.sp),
                  label: Text(
                    _isExporting ? 'جارٍ التصدير…' : 'مشاركة الصورة',
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ACTIONS
  void _openColorPicker({required bool forText}) {
    final initial = forText ? _textColor : _backgroundColor;
    Color tempColor = initial;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
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
    HapticFeedback.lightImpact();
    setState(() {
      _backgroundColor = Colors.white;
      _backgroundAssetPath = null;
      _backgroundFile = null;
      _fontSize = widget.initialFontSize;
      _fontFamily = widget.initialFontFamily;
      _fontWeight = FontWeight.w500;
      _lineHeight = 1.7;
      _textColor = ColorsManager.primaryText;
      _textAlign = TextAlign.justify;
    });
  }

  Future<void> _exportAndShare() async {
    try {
      setState(() => _isExporting = true);
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _exportKey.currentContext?.findRenderObject()
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

      await Share.shareXFiles([XFile(file.path)], text: 'شارك من تطبيق ${widget.appName}');
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

// REUSABLE PRIVATE WIDGETS

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.lightGray,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 12.w : 8.w,
            vertical: 8.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.sp, color: ColorsManager.secondaryText),
              if (label != null) ...[
                SizedBox(width: 6.w),
                Text(
                  label!,
                  style: TextStyles.labelMedium.copyWith(
                    color: ColorsManager.primaryPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.labelMedium.copyWith(
        color: ColorsManager.secondaryText,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: selected ? ColorsManager.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ColorsManager.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: selected
                    ? ColorsManager.primaryPurple
                    : ColorsManager.secondaryText,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyles.labelLarge.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected
                      ? ColorsManager.primaryPurple
                      : ColorsManager.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final bool isCustom;
  final VoidCallback onTap;
  const _ColorDot({
    required this.color,
    required this.selected,
    this.isCustom = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: selected ? 30.r : 26.r,
          height: selected ? 30.r : 26.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCustom ? null : color,
            gradient: isCustom
                ? const SweepGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  )
                : null,
            border: Border.all(
              color: selected
                  ? ColorsManager.primaryPurple
                  : Colors.black.withOpacity(0.12),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: isCustom
              ? Center(
                  child: Icon(
                    Icons.colorize_rounded,
                    size: 13.sp,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String label;
  final String fontFamily;
  final bool selected;
  final VoidCallback onTap;
  const _FontChip({
    required this.label,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? ColorsManager.primaryPurple.withOpacity(0.08)
                : ColorsManager.lightGray,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected
                  ? ColorsManager.primaryPurple
                  : ColorsManager.mediumGray,
              width: selected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 14.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? ColorsManager.primaryPurple
                  : ColorsManager.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleItem {
  final IconData icon;
  final String tooltip;
  const _ToggleItem(this.icon, this.tooltip);
}

class _ToggleRow extends StatelessWidget {
  final List<_ToggleItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _ToggleRow({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final sel = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: sel ? ColorsManager.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: ColorsManager.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Tooltip(
                  message: items[i].tooltip,
                  child: Icon(
                    items[i].icon,
                    size: 18.sp,
                    color: sel
                        ? ColorsManager.primaryPurple
                        : ColorsManager.secondaryText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
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
          width: 80.w,
          child: Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: ColorsManager.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
              activeTrackColor: ColorsManager.primaryPurple,
              inactiveTrackColor: ColorsManager.mediumGray,
              thumbColor: ColorsManager.primaryPurple,
              overlayColor: ColorsManager.primaryPurple.withOpacity(0.12),
            ),
            child: Slider(
              min: min,
              max: max,
              value: value.clamp(min, max),
              onChanged: onChanged,
            ),
          ),
        ),
        Container(
          width: 38.w,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: ColorsManager.lightGray,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            valueText,
            textAlign: TextAlign.center,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 74.w,
        height: 74.h,
        decoration: BoxDecoration(
          color: ColorsManager.lightGray,
          borderRadius: BorderRadius.circular(12.r),
          image: assetPath != null
              ? DecorationImage(
                  image: AssetImage(assetPath!),
                  fit: BoxFit.cover,
                )
              : null,
          border: Border.all(
            color: selected ? ColorsManager.primaryPurple : Colors.black12,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: assetPath == null
            ? Center(child: child ?? const SizedBox.shrink())
            : Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.40),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(selected ? 10.r : 11.r),
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.primaryPurple,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
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
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: 74.w,
        height: 74.h,
        decoration: BoxDecoration(
          color: ColorsManager.primaryPurple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorsManager.primaryPurple.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                size: 24.sp,
                color: ColorsManager.primaryPurple,
              ),
              SizedBox(height: 4.h),
              Text(
                'المعرض',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}