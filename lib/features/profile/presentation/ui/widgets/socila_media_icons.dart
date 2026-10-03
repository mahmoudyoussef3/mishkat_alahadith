import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';
import 'package:url_launcher/url_launcher.dart';

class SocilaMediaIcons extends StatelessWidget {
  const SocilaMediaIcons({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final socialLinks = [
      {
        'icon': FontAwesomeIcons.whatsapp,
        'url': 'https://whatsapp.com',
        'color': Colors.green,
      },
      {
        'icon': FontAwesomeIcons.instagram,
        'url': 'https://instagram.com',
        'color': Colors.purple,
      },
      {
        'icon': FontAwesomeIcons.twitter,
        'url': 'https://twitter.com',
        'color': Colors.black,
      },
      {
        'icon': FontAwesomeIcons.facebook,
        'url': 'https://facebook.com',
        'color': Colors.blue,
      },
      {
        'icon': FontAwesomeIcons.envelope,
        'url': 'mailto:test@test.com',
        'color': Colors.redAccent,
      },
    ];

    return Scaffold(
      backgroundColor: ProfileDecorations.socialMediaBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            /// Header with Logo
            Column(
              children: [
                CircleAvatar(
                  radius: 45.r,
                  backgroundImage: const AssetImage(
                    "assets/images/app_logo.png",
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "مشكاة الأحاديث",
                  style: ProfileTextStyles.socialMediaAppName,
                ),
                SizedBox(height: 6.h),
                Text(
                  "الأحاديث النبوية الشريفة بين يديك",
                  style: ProfileTextStyles.socialMediaTagline,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 30.h),

            /// رسالتنا
            _buildCard(
              title: "رسالتنا",
              icon: Icons.lightbulb_outline,
              text:
                  "تسهيل وصول المسلمين إلى سنة النبي ﷺ الصحيحة عبر التقنيات الحديثة والتصميم السهل.",
            ),

            SizedBox(height: 20.h),

            /// قيمنا
            _buildCard(
              title: "قيمنا",
              icon: Icons.favorite_border,
              text:
                  "الأمانة العلمية، الموثوقية، الابتكار، والسهولة في تقديم المعلومة.",
            ),

            SizedBox(height: 40.h),

            /// Footer
            Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16.w,
                  children:
                      socialLinks.map((link) {
                        return GestureDetector(
                          onTap: () => _launchUrl(link['url'] as String),
                          child: CircleAvatar(
                            radius: 24.r,
                            backgroundColor: (link['color'] as Color)
                                .withOpacity(0.15),
                            child: Icon(
                              link['icon'] as IconData,
                              color: link['color'] as Color,
                              size: 22.sp,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "شروط الاستخدام",
                        style: ProfileTextStyles.socialMediaLinks,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "سياسة الخصوصية",
                        style: ProfileTextStyles.socialMediaLinks,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  "© جميع الحقوق محفوظة لتطبيق مشكاة الأحاديث 2025",
                  style: ProfileTextStyles.copyrightText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required String text,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ProfileTextStyles.socialMediaCardTitle),
                  SizedBox(height: 8.h),
                  Text(
                    text,
                    style: ProfileTextStyles.socialMediaCardDescription,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
