import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';

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
    // When the header is drawn under the status bar, it collapses to a strip
    // behind the status bar instead of scrolling away, so page content never
    // scrolls underneath the status bar icons.
    final underStatusBar = MediaQuery.paddingOf(context).top > 0;
    return SliverAppBar(
      leading: const SizedBox.shrink(),
      automaticallyImplyLeading: false,
      expandedHeight: 110.h,
      floating: true,
      pinned: pinned || underStatusBar,
      toolbarHeight: pinned ? kToolbarHeight : 0,
      backgroundColor: ColorsManager.headerEnd,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
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

            Positioned.fill(
              child: Container(
                decoration: HomeDecorations.appBarGradientOverlay(),
              ),
            ),

            Padding(
              // The header may extend under the status bar; keep its
              // content below it.
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 12.h + MediaQuery.paddingOf(context).top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                fontSize: 22.sp,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          if (description != null &&
                              description!.isNotEmpty) ...[
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
      color: HomeDecorations.appBarIconButtonBg(),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: HomeDecorations.appBarIconButtonBorder(),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}

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
      color: HomeDecorations.appBarIconButtonBg(),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: HomeDecorations.appBarIconButtonBorder(),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}
