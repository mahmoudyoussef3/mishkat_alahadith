import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';

class CategoryCard extends StatefulWidget {
  final CategoryEntity category;
  final VoidCallback onExploreSubcategories;
  final VoidCallback onViewAllHadiths;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onExploreSubcategories,
    required this.onViewAllHadiths,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 190;
          return _buildCard(isCompact);
        },
      ),
    );
  }

  Widget _buildCard(bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryPurple.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onViewAllHadiths,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: isCompact ? 40.w : 44.w,
                      height: isCompact ? 46.w : 56.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorsManager.primaryPurple.withOpacity(0.18),
                            ColorsManager.primaryPurple.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: ColorsManager.primaryPurple,
                          size: isCompact ? 22.sp : 24.sp,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.category.hadeethsCount}',
                            style: TextStyles.font13BlueSemiBold.copyWith(
                              color: ColorsManager.primaryPurple,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text('حديث', style: TextStyles.font12GrayRegular),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Title Section
            
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Center(
                        child: Text(
                        
                        widget.category.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font14BlueSemiBold.copyWith(
                          fontSize: 18.sp,
                          color: ColorsManager.primaryPurple,
                          height: 1.3,
                        ),
                                          ),
                      ),
                    ),                  

                
                SizedBox(height: 10.h),

Spacer(),                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 36.h : 40.h,
                  child: ElevatedButton(
                    onPressed: widget.onExploreSubcategories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 14.sp),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            isCompact
                                ? 'استكشاف الفئات'
                                : 'استكشاف التصنيفات الفرعية',
                            textDirection: TextDirection.rtl,
                            style: TextStyles.font13BlueSemiBold.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 36.h : 40.h,
                  child: OutlinedButton(
                    onPressed: widget.onViewAllHadiths,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: ColorsManager.primaryPurple.withOpacity(0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14.sp,
                          color: ColorsManager.primaryPurple,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            isCompact ? 'عرض الأحاديث' : 'عرض جميع الأحاديث',
                            textDirection: TextDirection.rtl,
                            style: TextStyles.font13BlueSemiBold.copyWith(
                              color: ColorsManager.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
