import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:flutter/services.dart';

class HadithTextCard extends StatefulWidget {
  final String hadithText;
  const HadithTextCard({super.key, required this.hadithText});

  @override
  State<HadithTextCard> createState() => _HadithTextCardState();
}

class _HadithTextCardState extends State<HadithTextCard> {
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: RepaintBoundary(
        key: _repaintKey,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                ColorsManager.secondaryBackground,
                ColorsManager.primaryPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: ColorsManager.primaryPurple.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryPurple.withOpacity(0.08),
                blurRadius: 20.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              /// الخلفية الزخرفية
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(
                      'assets/images/islamic_pattern.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              /// المحتوى
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// عنوان الكارد
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: ColorsManager.primaryPurple.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          color: ColorsManager.primaryPurple,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "نص الحديث",
                          style: TextStyle(
                            color: ColorsManager.primaryPurple,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// نص الحديث
                  Text(
                    widget.hadithText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20.sp,
                      height: 1.8,
                      color: ColorsManager.primaryText,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// أيقونات النسخ والمشاركة
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Wrap(
                      spacing: 10.w,
                      children: [
                        _buildActionIcon(
                          context,
                          icon: Icons.copy_rounded,
                          color: ColorsManager.primaryPurple,
                          tooltip: "نسخ الحديث",
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: widget.hadithText),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text("تم نسخ الحديث"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        _buildActionIcon(
                          context,
                          icon: Icons.share_rounded,
                          color: ColorsManager.primaryGreen,
                          tooltip: "مشاركة الحديث",
                          onTap: _shareHadithAsImage,
                        ),
                      ],
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

  Widget _buildActionIcon(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    );
  }

  Future<void> _shareHadithAsImage() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/hadith_share.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "شارك الحديث المبارك 🌿");
    } catch (e) {
      debugPrint("Error sharing hadith: $e");
    }
  }
}
