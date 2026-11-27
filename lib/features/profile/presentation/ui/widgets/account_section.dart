import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/sign_out_dialog.dart';

/// About, feedback and, when signed in, signing out.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key, required this.isSignedIn});

  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: isSignedIn ? 'الحساب' : 'التطبيق',
      children: [
        SettingsTile(
          icon: Icons.info_outline_rounded,
          iconBackground: ColorsManager.lightGray,
          iconColor: ColorsManager.primaryText,
          title: 'عن التطبيق',
          onTap: () => context.pushNamed(Routes.aboutUs),
        ),
        SettingsTile(
          icon: Icons.rate_review_outlined,
          iconBackground: ColorsManager.lightGray,
          iconColor: ColorsManager.primaryText,
          title: 'أرسل اقتراحاً',
          subtitle: 'ساعدنا في تحسين مشكاة',
          onTap: () => context.pushNamed(Routes.usersSuggestions),
        ),
        if (isSignedIn)
          SettingsTile(
            icon: Icons.logout_rounded,
            title: 'تسجيل الخروج',
            destructive: true,
            onTap: () => confirmSignOut(context),
          ),
      ],
    );
  }
}
