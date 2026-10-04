import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mishkat_almasabih/core/deep_links/hadith_link.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/ui/widgets/share_image_editor.dart';
import 'package:share_plus/share_plus.dart';
import '../theming/styles.dart';


void setupErrorState(BuildContext context, String error) {
  context.pop();
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: ColorsManager.elevatedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorsManager.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: ColorsManager.purpleText,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              error,
              style: TextStyles.font15DarkBlueMedium.copyWith(
                color: ColorsManager.primaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  backgroundColor: ColorsManager.primaryPurple.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'حسناً',
                  style: TextStyles.font14BlueSemiBold.copyWith(
                    color: ColorsManager.purpleText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Color getGradeColor(String? g) {
    switch (g?.toLowerCase()) {
      case "sahih":
      case "صحيح":
        return ColorsManager.hadithAuthentic;
      case "hasan":
      case "حسن":
        return ColorsManager.hadithGood;
      case "daif":
      case "ضعيف":
        return ColorsManager.hadithWeak;
      default:
        return ColorsManager.hadithAuthentic;
    }
    
  }
  void showToast(String msg, Color? color) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 8,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
}
String convertToArabicNumber(int number) => toArabicDigits('$number');


  String normalizeArabic(String text) {
    final diacritics = RegExp(r'[\u0617-\u061A\u064B-\u0652]');
    String result = text.replaceAll(diacritics, '');

    result = result.replaceAll(RegExp('[إأآ]'), 'ا');

    result = result.replaceAll('ـ', '');

    result = result.toLowerCase();

    return result.trim();
  }
Future<void> shareHadithAsImage(
  BuildContext context, {
  required String text,
  String? deepLink,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return ShareImageEditorBottomSheet(
        text: text,
        deepLink: deepLink,
      );
    },
  );
}

Future<void> shareHadithLink(
  BuildContext context, {
  required String? hadithId,
}) async {
  final link = hadithId == null ? null : HadithLink.build(hadithId);
  if (link == null) return;
  final shareText = "اقرأ هذا الحديث عبر الرابط:\n$link";

  try {
    await SharePlus.instance.share(
      ShareParams(text: shareText, sharePositionOrigin: _shareOrigin(context)),
    );
  } on PlatformException {
    showToast('تعذر مشاركة الرابط', ColorsManager.error);
  }
}

/// iPad shows the share sheet as a popover anchored to this rect, and
/// share_plus rejects a rect that is not inside the screen.
Rect _shareOrigin(BuildContext context) {
  final screen = Offset.zero & MediaQuery.sizeOf(context);
  final box = context.findRenderObject();
  if (box is RenderBox && box.hasSize) {
    final visible = (box.localToGlobal(Offset.zero) & box.size).intersect(
      screen,
    );
    if (!visible.isEmpty) return visible;
  }
  return Rect.fromCenter(center: screen.center, width: 1, height: 1);
}

  bool checkBookSlug(String bookSlug) {
    if (bookSlug == 'sahih-bukhari' ||
        bookSlug == 'sahih-muslim' ||
        bookSlug == 'al-tirmidhi' ||
        bookSlug == 'abu-dawood' ||
        bookSlug == 'ibn-e-majah' ||
        bookSlug == 'sunan-nasai' ||
        bookSlug == 'mishkat') {
      return false;
    } else {
      return true;
    }
  }

  bool checkThreeBooks(String bookSlug) {
    if (bookSlug == 'qudsi40' ||
        bookSlug == 'nawawi40' ||
        bookSlug == 'riyadiah40' ||
        bookSlug == 'shahwaliullah40') {
      return true;
    } else {
      return false;
    }
  }
