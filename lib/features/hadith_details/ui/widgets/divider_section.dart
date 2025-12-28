import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/islamic_separator.dart';

class DividerSection extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const DividerSection({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin:
            margin ?? EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
        child: const IslamicSeparator(),
      ),
    );
  }
}
