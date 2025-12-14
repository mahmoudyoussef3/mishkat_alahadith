import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/section_title.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;

import '../../../../core/theming/colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: 
       Directionality(
        textDirection: TextDirection.rtl,
        child: 
      Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "من نحن"),
                    SizedBox(height: 12.h),
                    _buildSection(
                      icon: Icons.info_outline,
                      text:
                          "مشروع متخصص في نشر العلوم الإسلامية والحديثية بأسلوب معاصر وسلس. نهدف إلى تقريب تراث الإسلام وعلومه للمسلمين والمهتمين بطريقة سهلة وموثوقة.",
                    ),
                    SizedBox(height: 12.h),
      
                    const SectionTitle(title: "رؤيتنا"),
                    SizedBox(height: 12.h),
                    _buildSection(
                      icon: Icons.visibility_outlined,
                      text:
                          "أن نكون المرجع الأول والأكثر موثوقية في تقديم العلوم الحديثية بشكل سهل ومفهوم للجميع.",
                    ),
                    SizedBox(height: 12.h),
      
                    const SectionTitle(title: "رسالتنا"),
                    SizedBox(height: 12.h),
                    _buildSection(
                      icon: Icons.lightbulb_outline,
                      text:
                          "توفير مصادر علمية دقيقة للأحاديث النبوية وشروحها، مع الحرص على الوضوح والدقة العلمية.",
                    ),
                    SizedBox(height: 12.h),
      
                    const SectionTitle(title: "قيمنا"),
                    SizedBox(height: 12.h),
                    _buildSection(
                      icon: Icons.favorite_outline,
                      text:
                          "الأمانة العلمية، الموثوقية، الابتكار، والسهولة في تقديم المعلومة.",
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
         )  ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorsManager.primaryPurple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsManager.white,
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'منصة رقمية متكاملة لدراسة الأحاديث النبوية الشريفة مع تحليل ذكي وفوائد عملية',
              style: TextStyle(color: ColorsManager.secondaryBackground),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Divider(color: ColorsManager.gray, endIndent: 50.w, indent: 50.w),
            SizedBox(height: 8.h),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 18.w,
              children: [
                _socialIcon(
                  FontAwesomeIcons.whatsapp,
                  'https://whatsapp.com/channel/0029VazdI4N84OmAWA8h4S2F',
                ),
                _socialIcon(
                  FontAwesomeIcons.instagram,
                  'https://www.instagram.com/mishkahcom1',
                ),
                _socialIcon(
                  FontAwesomeIcons.twitter,
                  'https://x.com/mishkahcom1',
                ),
                _socialIcon(
                  FontAwesomeIcons.facebook,
                  'https://facebook.com/mishkahcom1',
                ),
                _socialIcon(
                  FontAwesomeIcons.envelope,
                  'mailto:Meshkah@hadith-shareef.com',
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              "© جميع الحقوق محفوظة لتطبيق مشكاة الأحاديث 2025",
              style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 26.r,
        child: Icon(
          icon,
          color: ColorsManager.secondaryBackground,
          size: 22.sp,
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.mediumGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorsManager.primaryGreen),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
