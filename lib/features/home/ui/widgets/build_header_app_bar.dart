import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class BuildHeaderAppBar extends StatelessWidget {
  const BuildHeaderAppBar({
    super.key,
    this.description,
    required this.title,
    this.home = false,
    this.pinned = false,
    this.actions,
    this.bottomNav = false,
  });

  final String title;
  final String? description;
  final bool home;
  final bool pinned;
  final bool bottomNav;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: const SizedBox.shrink(),
      automaticallyImplyLeading: false,
      expandedHeight: 100.h,
      floating: true,
      pinned: pinned,
      backgroundColor: ColorsManager.primaryPurple,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/islamic_pattern.jpg'),
                      repeat: ImageRepeat.repeat,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // Gradient overlay for better contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorsManager.primaryPurple.withOpacity(0.3),
                      ColorsManager.primaryPurple,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row with leading and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Leading button
                      _buildIconButton(
                        icon:
                            home
                                ? Icons.menu_rounded
                                : Icons.arrow_back_ios_new_rounded,
                        onPressed: () {
                          if (home) {
                            Scaffold.of(context).openDrawer();
                          } else {
                            context.pop();
                          }
                        },
                      ),

                      // Actions
                      if (actions != null && actions!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              actions!.map((action) {
                                return Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: action,
                                );
                              }).toList(),
                        )
                      else
                        SizedBox(width: 40.w),
                    ],
                  ),

                  // Title section (centered)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyles.displaySmall.copyWith(
                                color: ColorsManager.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24.sp,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          if (description != null &&
                              description!.isNotEmpty) ...[
                            //   SizedBox(height: 3.h),
                            Flexible(
                              child: Text(
                                description!,
                                style: TextStyles.bodyMedium.copyWith(
                                  color: ColorsManager.white.withOpacity(0.85),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}

// Optional: Wrapper widget for actions to maintain consistency
class AppBarActionButton extends StatelessWidget {
  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}
