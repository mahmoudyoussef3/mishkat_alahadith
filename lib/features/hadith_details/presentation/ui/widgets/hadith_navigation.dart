import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/navigation/logic/cubit/navigation_cubit.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';

class HadithNavigation extends StatefulWidget {
  final String hadithNumber;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
  final String bookSlug;
  final String chapterNumber;
  final bool isLocal;

  const HadithNavigation({
    super.key,
    required this.hadithNumber,

    this.onNext,
    this.onPrev,
    required this.bookSlug,
    required this.isLocal,
    required this.chapterNumber,
  });

  @override
  State<HadithNavigation> createState() => _HadithNavigationState();
}

class _HadithNavigationState extends State<HadithNavigation> {
  @override
  void initState() {
    context.read<NavigationCubit>().emitNavigationStates(
      widget.hadithNumber,
      widget.bookSlug,
      widget.chapterNumber,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.isLocal
        ? BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
            if (state is NavigationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NavigationFailure) {
              return Center(child: Text(state.errMessage));
            } else if (state is NavigationSuccess) {
              final data = state.navigationHadithResponse;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: HadithDetailsDecorations.actionRow(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed:
                            data.prevHadith != null
                                ? () {
                                  // call onPrev لو حابب
                                  if (widget.onPrev != null) widget.onPrev!();

                                  // تجيب الحديث السابق
                                  context
                                      .read<NavigationCubit>()
                                      .emitNavigationStates(
                                        data.prevHadith!.id.toString(),
                                        widget.bookSlug,
                                        widget.chapterNumber,
                                      );
                                }
                                : null,
                      ),
                      Text(
                        "الحديث رقم ${data.currentHadithNumber} / ${data.totalHadiths}",
                        style: HadithDetailsTextStyles.navigationLabel,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed:
                            data.nextHadith != null
                                ? () {
                                  if (widget.onNext != null) widget.onNext!();

                                  context
                                      .read<NavigationCubit>()
                                      .emitNavigationStates(
                                        data.nextHadith!.id.toString(),
                                        widget.bookSlug,
                                        widget.chapterNumber,
                                      );
                                }
                                : null,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        )
        : SizedBox();
  }
}
