import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/widgets/filter_pill.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_collection.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

/// Narrows the chapter list to one theme, or shows them all.
class AzkarCollectionFilter extends StatelessWidget {
  const AzkarCollectionFilter({super.key});

  static const List<AzkarCollection?> _options = [
    null,
    ...AzkarCollection.values,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AzkarHomeCubit, AzkarHomeState, AzkarCollection?>(
      selector: (state) => state is AzkarHomeLoaded ? state.collection : null,
      builder: (context, selected) {
        return SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _options.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final option = _options[i];
              return Center(
                child: FilterPill(
                  label: option?.label ?? 'الكل',
                  selected: option == selected,
                  onTap:
                      () => context.read<AzkarHomeCubit>().selectCollection(
                        option,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
