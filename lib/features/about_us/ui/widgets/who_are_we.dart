import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/about_us/ui/widgets/build_info_section.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/section_title.dart';

class WhoAreWe extends StatelessWidget {
  const WhoAreWe({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
 const SectionTitle(title: "من نحن"),
 IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_forward))
         ],),
          SizedBox(height: 12.h),
          BuildInfoSection(
            icon: Icons.info_outline,
            text:
                "مشروع متخصص في نشر العلوم الإسلامية والحديثية بأسلوب معاصر وسلس. نهدف إلى تقريب تراث الإسلام وعلومه للمسلمين والمهتمين بطريقة سهلة وموثوقة.",
          ),
          SizedBox(height: 12.h),

          const SectionTitle(title: "رؤيتنا"),
          SizedBox(height: 12.h),
          BuildInfoSection(
            icon: Icons.visibility_outlined,
            text:
                "أن نكون المرجع الأول والأكثر موثوقية في تقديم العلوم الحديثية بشكل سهل ومفهوم للجميع.",
          ),
          SizedBox(height: 12.h),

          const SectionTitle(title: "رسالتنا"),
          SizedBox(height: 12.h),
          BuildInfoSection(
            icon: Icons.lightbulb_outline,
            text:
                "توفير مصادر علمية دقيقة للأحاديث النبوية وشروحها، مع الحرص على الوضوح والدقة العلمية.",
          ),
          SizedBox(height: 12.h),

          const SectionTitle(title: "قيمنا"),
          SizedBox(height: 12.h),
          BuildInfoSection(
            icon: Icons.favorite_outline,
            text:
                "الأمانة العلمية، الموثوقية، الابتكار، والسهولة في تقديم المعلومة.",
          ),
        ],
      ),
    );
  }
}
