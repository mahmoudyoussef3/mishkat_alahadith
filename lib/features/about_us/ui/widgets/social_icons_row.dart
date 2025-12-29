import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/features/about_us/ui/widgets/build_social_icon.dart';

class SocialIconsRow extends StatelessWidget {
  const SocialIconsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18.w,
      children: [
        BuildSocialIcon(
          icon: FontAwesomeIcons.whatsapp,
          url: 'https://whatsapp.com/channel/0029VazdI4N84OmAWA8h4S2F',
        ),
        BuildSocialIcon(
          icon: FontAwesomeIcons.instagram,
          url: 'https://www.instagram.com/mishkahcom1',
        ),
        BuildSocialIcon(
          url: 'https://x.com/mishkahcom1',
          icon: FontAwesomeIcons.twitter,
        ),
        BuildSocialIcon(
          icon: FontAwesomeIcons.facebook,
          url: 'https://facebook.com/mishkahcom1',
        ),
        BuildSocialIcon(
          icon: FontAwesomeIcons.envelope,
          url: 'mailto:Meshkah@hadith-shareef.com',
        ),
      ],
    );
  }
}
