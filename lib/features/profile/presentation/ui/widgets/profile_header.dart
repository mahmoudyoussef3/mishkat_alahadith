import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';
import 'package:mishkat_almasabih/features/profile/domain/entities/user_profile.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/edit_profile/edit_profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      foregroundColor: ColorsManager.white,
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: ProfileDecorations.profileHeaderGradient,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),

                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(getAvatarUrl(user)),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    user.username ?? "المستخدم",
                    style: ProfileTextStyles.profileHeaderUsername,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? "user@example.com",
                  style: ProfileTextStyles.profileHeaderEmail,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider(
                      create: (context) => getIt<EditProfileCubit>(),
                      child: EditProfileScreen(userData: user),
                    ),
              ),
            );
          },
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
      ],
    );
  }

  String getAvatarUrl(UserProfile? user) {
    const String defaultAvatar =
        "https://api.hadith-shareef.com/api/uploads/avatars/default-avatar.jpg";
    if (user == null) {
      return defaultAvatar;
    }

    final String? url = user.avatarUrl;

    if (url != null && url.isNotEmpty) {
      if (url.startsWith("http")) {
        return url;
      } else if (url.startsWith("/uploads/avatars")) {
        final String baseUrl = "https://api.hadith-shareef.com/";
        return '$baseUrl/api$url';
      }
    }

    return defaultAvatar;
  }
}
