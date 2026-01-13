import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/loading_progress_indicator.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/delete_cubit/cubit/delete_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/get_cubit/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_decorations.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';
import 'package:mishkat_almasabih/core/theming/hadith_styles.dart';

class BookmarkHadithCard extends StatelessWidget {
  const BookmarkHadithCard({
    super.key,
    required this.hadithNumber,
    required this.hadithText,
    required this.bookName,
    required this.chapterName,
    this.collection,
    this.notes,
  });

  final int hadithNumber;
  final String hadithText;
  final String bookName;
  final String? chapterName;
  final String? collection;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeleteCubitCubit>(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BookmarkDecorations.hadithCard(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: ColorsManager.primaryGreen,
                        size: 18.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'حديث رقم $hadithNumber',
                        style: BookmarkTextStyles.headerLabel,
                      ),
                    ],
                  ),

                  BlocConsumer<DeleteCubitCubit, DeleteCubitState>(
                    listener: (context, state) {
                      if (state is DeleteLoading) {
                                                ScaffoldMessenger.of(context).clearSnackBars();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: ColorsManager.primaryGreen,
                            content: loadingProgressIndicator(
                              size: 30,
                              color: ColorsManager.offWhite,
                            ),
                          ),
                        );
                      } else if (state is DeleteSuccess) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(

                            backgroundColor: ColorsManager.primaryGreen,
                            content: const Text(
                              'تم حذف الحديث من المحفوظات',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        context.read<GetBookmarksCubit>().getUserBookmarks();
                      } else if (state is DeleteFaliure) {
                                                ScaffoldMessenger.of(context).clearSnackBars();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(

                            backgroundColor: ColorsManager.primaryGreen,
                            content: const Text(
                              'حدث خطأ. حاول مرة اخري',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap:
                            () => context.read<DeleteCubitCubit>().delete(
                              hadithNumber,
                            ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: ColorsManager.error,
                              size: 18.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'حذف الحديث',
                              style: BookmarkTextStyles.deleteAction,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Text(
                maxLines: 4,
                hadithText,
                textAlign: TextAlign.right,
                style: HadithTextStyles.hadithArabic,
              ),

              SizedBox(height: 12.h),

              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildGradientPill(
                    text: bookName,
                    colors: [
                      ColorsManager.primaryGreen.withOpacity(0.7),
                      ColorsManager.primaryGreen.withOpacity(0.5),
                    ],
                    textColor: ColorsManager.offWhite,
                  ),
                  if (chapterName != null && chapterName!.isNotEmpty)
                    _buildGradientPill(
                      text: chapterName!,
                      colors: [
                        ColorsManager.hadithAuthentic.withOpacity(0.7),
                        ColorsManager.hadithAuthentic.withOpacity(0.5),
                      ],
                      textColor: ColorsManager.offWhite,
                    ),
                ],
              ),

              if (notes != null && notes!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  "ملاحظة: ${notes!}",
                  textAlign: TextAlign.right,
                  style: BookmarkTextStyles.pillLabel(
                    ColorsManager.primaryGreen,
                    size: 13.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientPill({
    required String text,
    required List<Color> colors,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BookmarkDecorations.pill(colors),
      child: Text(
        text,
        style: BookmarkTextStyles.pillLabel(textColor),
      ),
    );
  }
}
