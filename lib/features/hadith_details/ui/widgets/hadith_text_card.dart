import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';

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
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: RepaintBoundary(
          key: _repaintKey,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: HadithDetailsDecorations.contentCard(),
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
                      decoration: HadithDetailsDecorations.labelChip(),
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
                            style: HadithDetailsTextStyles.labelChip,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// نص الحديث
                    Text(
                      widget.hadithText,
                      textAlign: TextAlign.right,
                      style: HadithDetailsTextStyles.hadithText,
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
                            onTap: () => shareHadithAsImage(context, text: widget.hadithText),
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
          decoration: HadithDetailsDecorations.actionIcon(color),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    );
  }


}
