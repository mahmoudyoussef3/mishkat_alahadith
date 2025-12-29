import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/hadith_list_builder.dart';
import 'package:mishkat_almasabih/features/ahadith/ui/widgets/local_hadith_list_builder.dart';

class AhadithListBlocBuilder extends StatelessWidget {
  const AhadithListBlocBuilder({super.key, required this.bookSlug, required this.arabicBookName, required this.pageNumber});
  final String bookSlug;
  final String arabicBookName;
  final int pageNumber  ;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AhadithsCubit, AhadithsState>(
      builder: (context, state) {
        if (state is AhadithsSuccess) {
          return HadithListBuilder(
            arabicBookName: arabicBookName,
            bookSlug: bookSlug,
            state: state,
          );
        } else if (state is LocalAhadithsSuccess) {
          return LocalHadithListBuilder(
            arabicChapterName: '',
            arabicWriterName: '',
            authorDeath: '',
            grade: '',

            narrator: '',
            arabicBookName: arabicBookName,
            bookSlug: bookSlug,
            state: state,
          );
        } else if (state is AhadithsLoading && pageNumber == 1) {
          return SliverList.builder(
            itemCount: 6,
            itemBuilder: (context, index) => const HadithCardShimmer(),
          );
        } else if (state is AhadithsFailure) {
          return SliverToBoxAdapter(child: ErrorState(error: state.error));
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
