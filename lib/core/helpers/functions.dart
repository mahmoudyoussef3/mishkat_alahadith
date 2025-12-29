import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/ui/widgets/share_image_editor.dart';
import '../theming/styles.dart';


void setupErrorState(BuildContext context, String error) {
  context.pop();
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Colors.white,
          icon: const Icon(Icons.error, color: Colors.red, size: 32),
          content: Text(error, style: TextStyles.font15DarkBlueMedium),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text('حسنا', style: TextStyles.font14BlueSemiBold),
            ),
          ],
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
String convertToArabicNumber(int number) {
  const englishToArabic = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  String english = number.toString();
  String arabic = english.split('').map((digit) => englishToArabic[digit] ?? digit).join();
  return arabic;
}


  String normalizeArabic(String text) {
    final diacritics = RegExp(r'[\u0617-\u061A\u064B-\u0652]');
    String result = text.replaceAll(diacritics, '');

    // 2. توحيد الهمزات: أ إ آ -> ا
    result = result.replaceAll(RegExp('[إأآ]'), 'ا');

    // 3. شيل المدّة "ـ"
    result = result.replaceAll('ـ', '');

    // 4. Optional: lowercase (عشان لو فيه انجليزي)
    result = result.toLowerCase();

    return result.trim();
  }
Future<void> shareHadithAsImage(
  BuildContext context, {
  required String text,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return ShareImageEditorBottomSheet(text: text);
    },
  );
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
