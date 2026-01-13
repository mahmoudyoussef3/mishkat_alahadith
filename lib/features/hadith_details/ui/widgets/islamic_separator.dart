import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_decorations.dart';

class IslamicSeparator extends StatelessWidget {
  const IslamicSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.h,
      decoration: HadithDetailsDecorations.separator(),
    );
  }
}
