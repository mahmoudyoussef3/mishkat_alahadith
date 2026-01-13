import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/action_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';

class HadithActions extends StatelessWidget {
  final String hadithText;
  final bool isBookMark;
  final String bookName;
  final String bookSlug;
  final String chapter;
  final String hadithNumber;

  const HadithActions({
    super.key,
    required this.hadithText,
    required this.isBookMark,
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: HadithDetailsDecorations.actionRow(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ActionButton(
              icon: Icons.copy,
              label: "نسخ",
              onTap: () {
                Clipboard.setData(ClipboardData(text: hadithText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      "تم نسخ الحديث",
                      style: HadithDetailsTextStyles.snackText,
                    ),
                  ),
                );
              },
            ),
            ActionButton(
              icon: Icons.share,
              label: "مشاركة",
              onTap: () async {
                await Share.share(hadithText, subject: "شارك الحديث");
              },
            ),
            if (!isBookMark)
              ActionButton(icon: Icons.bookmark, label: "حفظ", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
