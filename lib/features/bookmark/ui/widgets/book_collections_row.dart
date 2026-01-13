import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_decorations.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';

class BookmarkCollectionsRow extends StatelessWidget {
  final String selectedCollection;
  final ValueChanged<String> onCollectionSelected;

  const BookmarkCollectionsRow({
    super.key,
    required this.selectedCollection,
    required this.onCollectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GetCollectionsBookmarkCubit,
      GetCollectionsBookmarkState
    >(
      builder: (context, state) {
        if (state is GetCollectionsBookmarkLoading) {
          return _buildLoadingShimmer();
        } else if (state is GetCollectionsBookmarkSuccess) {
          final collections = state.collectionsResponse.collections;

          // فلترة العناصر الفارغة أو null
          final filteredCollections =
              collections!
                  .where(
                    (e) =>
                        (e.collection != null &&
                            e.collection!.trim().isNotEmpty),
                  )
                  .toList();

          final allCollections = [
            "الكل",
            ...filteredCollections.map((e) => e.collection!),
          ];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BookmarkDecorations.collectionsContainer(),
              child: SizedBox(
                height: 40.h,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  itemCount: allCollections.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final c = allCollections[index];
                    final isSelected = selectedCollection == c;

                    return GestureDetector(
                      onTap: () => onCollectionSelected(c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BookmarkDecorations.collectionChip(isSelected: isSelected),
                        child: Center(
                          child: Text(
                            c,
                            style: BookmarkTextStyles.collectionChipText(isSelected: isSelected),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// shimmer أثناء التحميل
  Widget _buildLoadingShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),

        decoration: BoxDecoration(
          color: ColorsManager.secondaryBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          height: 50.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemCount: 5,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder:
                (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 90.w,
                      height: 34.h,
                      decoration: BookmarkDecorations.shimmerItem(),
                    ),
                ),
          ),
        ),
      ),
    );
  }
}
