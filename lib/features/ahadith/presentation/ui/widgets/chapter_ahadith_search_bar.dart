import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/search_bar_widget.dart';

class AhadithSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const AhadithSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal:12.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
        
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Card(
          elevation: 0,
                  margin: EdgeInsets.zero,

          color: ColorsManager.secondaryBackground,
          child: SearchBarWidget(
            hintText: 'ابحث في الأحاديث...',
            controller: controller,
            onChanged: (query) {
              context.read<AhadithsCubit>().filterAhadith(query);
            },
          ),
        ),
      ),
    );
  }
}
