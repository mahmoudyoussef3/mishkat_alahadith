import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theming/colors.dart';

class ProfileShimmerScreen extends StatelessWidget {
  const ProfileShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Match the SliverAppBar structure from ProfileHeader
    return SliverAppBar(
      foregroundColor: ColorsManager.secondaryBackground,
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorsManager.primaryPurple,
                ColorsManager.secondaryPurple,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),

                // ✅ Avatar Shimmer
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.6),
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ✅ Username Shimmer
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.6),
                  child: Container(
                    width: 150.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // ✅ Email Shimmer
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.6),
                  child: Container(
                    width: 180.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // ✅ Edit Button Shimmer
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.6),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ],
    );
  }
}