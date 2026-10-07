import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushaf_text/mushaf_text.dart';

class QuranTextStyles {
  static const String _mushafFontPackage = 'mushaf_text';

  /// Quran text in the bundled King Fahd Complex face.
  static TextStyle mushafText({required Color color, required double size}) {
    return TextStyle(
      fontFamily: mushafFontFamily,
      package: _mushafFontPackage,
      fontSize: size,
      color: color,
      height: 1.9,
    );
  }

  /// A line of the didactic poem a tajweed rule is taken from: Amiri with
  /// room between lines for its diacritics.
  static TextStyle matnVerse(Color color) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 16.sp,
    height: 2.0,
    color: color,
  );
}
