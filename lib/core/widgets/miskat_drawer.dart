import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/session_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';

class MishkatDrawer extends StatefulWidget {
  const MishkatDrawer({super.key});

  @override
  State<MishkatDrawer> createState() => _MishkatDrawerState();
}

class _MishkatDrawerState extends State<MishkatDrawer> {
  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorsManager.primaryBackground,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorsManager.headerStart, ColorsManager.headerEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: ColorsManager.secondaryBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'مشكاة الأحاديث',
                      style: TextStyle(
                        color: ColorsManager.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'نُحْيِي السُّنَّةَ... فَتُحْيِينَا',
                      style: TextStyle(
                        color: ColorsManager.white.withOpacity(0.9),
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'الرئيسية',
                  onTap: () => _openTab(context, MainTab.home),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.auto_stories_rounded,
                  title: 'القرآن الكريم',
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(Routes.quranScreen);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bookmark_rounded,
                  title: 'المحفوظات',
                  onTap: () => _openTab(context, MainTab.saved),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bookmark_rounded,
                  title: 'تصنيفات الأحاديث',
                  onTap: () {
                    context.pushNamed(Routes.categoriesScreen);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.menu_book_rounded,
                  title: 'مكتبة مشكاة',
                  onTap: () => _openTab(context, MainTab.library),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.access_time_rounded,
                  title: 'مواقيت الصلاة',
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(Routes.prayerTimesScreen);
                  },
                ),

                _buildDrawerItem(
                  context,

                  icon: Icons.explore_rounded,
                  title: 'القبلة',
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(Routes.qiblahFinder);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_rounded,
                  title: 'الملف الشخصي',
                  onTap: () => _openTab(context, MainTab.profile),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_rounded,
                  title: 'من نحن',
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(Routes.aboutUs);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_rounded,
                  title: 'إضافة مقترحات',
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed(Routes.usersSuggestions);
                  },
                ),
              ],
            ),
          ),

          Divider(
            color: ColorsManager.mediumGray,
            thickness: 0.6,
            indent: 20.w,
            endIndent: 20.w,
          ),
          SessionBuilder(
            builder:
                (context, isSignedIn) =>
                    isSignedIn
                        ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: _buildDrawerItem(
                            context,
                            icon: Icons.logout_rounded,
                            title: 'تسجيل الخروج',
                            color: ColorsManager.error,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        )
                        : const SizedBox.shrink(),
          ),
          SizedBox(height: 64.h),
        ],
      ),
    );
  }

  /// Closes the drawer and switches the app shell to [tab].
  void _openTab(BuildContext context, MainTab tab) {
    final navigation = context.read<MainNavigationCubit>();
    Navigator.pop(context);
    navigation.select(tab);
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          splashColor: ColorsManager.primaryPurple.withOpacity(0.1),
          highlightColor: ColorsManager.primaryPurple.withOpacity(0.05),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: ColorsManager.secondaryBackground,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.mediumGray.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color ?? ColorsManager.primaryPurple,
                  size: 22.sp,
                ),
                SizedBox(width: 14.w),
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: color ?? ColorsManager.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج؟',
              style: TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.start,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final signedOut =
                      await context.read<SessionCubit>().signOut();
                  if (!context.mounted) return;
                  if (!signedOut) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تعذر تسجيل الخروج، حاول مرة أخرى'),
                      ),
                    );
                    return;
                  }
                  context.pushReplacementNamed(Routes.loginScreen);
                },
                child: const Text('نعم', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 12.w),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorsManager.primaryPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: ColorsManager.primaryPurple),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
