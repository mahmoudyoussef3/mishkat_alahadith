import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildSocialIcon extends StatelessWidget {
  const BuildSocialIcon({super.key, required this.icon, required this.url});
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
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
}
