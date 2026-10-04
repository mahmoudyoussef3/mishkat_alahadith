import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/hadith_card_shimer.dart';
import 'package:mishkat_almasabih/core/widgets/section_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/widgets/chapter_ahadith_card.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/ui/screens/hadith_result_details.dart';

/// "أحاديث عامة": a refreshable selection of random hadiths.
class RandomAhadithBlocBuilder extends StatelessWidget {
  const RandomAhadithBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: BlocSelector<RandomAhadithCubit, RandomAhadithState, bool>(
            selector: (state) => state is RandomAhadithLoading,
            builder:
                (context, loading) => SectionHeader(
                  title: 'أحاديث عامة',
                  actionLabel: 'تحديث',
                  actionIcon: Icons.refresh_rounded,
                  onAction:
                      loading
                          ? null
                          : () =>
                              context
                                  .read<RandomAhadithCubit>()
                                  .emitRandomStats(),
                ),
          ),
        ),
        BlocBuilder<RandomAhadithCubit, RandomAhadithState>(
          builder:
              (context, state) => switch (state) {
                RandomAhadithSuccess(:final hadiths) when hadiths.isEmpty =>
                  const SliverToBoxAdapter(
                    child: StateMessage(
                      icon: Icons.menu_book_rounded,
                      title: 'لا توجد أحاديث لعرضها الآن',
                    ),
                  ),
                RandomAhadithSuccess(:final hadiths) => SliverList.builder(
                  itemCount: hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = hadiths[index];
                    return GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => HadithResultDetails(
                                    enhancedHadithModel: hadith,
                                  ),
                            ),
                          ),
                      child: ChapterAhadithCard(
                        hadithCategory: hadith.categories?.firstOrNull,
                        number: hadith.id ?? '',
                        text: hadith.hadeeth ?? '',
                        narrator: hadith.attribution,
                        grade: hadith.grade,
                        reference: hadith.reference,
                      ),
                    );
                  },
                ),
                RandomAhaditFailure(:final errMessage) => SliverToBoxAdapter(
                  child: StateMessage.error(
                    message: errMessage,
                    onRetry:
                        () =>
                            context
                                .read<RandomAhadithCubit>()
                                .emitRandomStats(),
                  ),
                ),
                _ => SliverList.builder(
                  itemCount: 3,
                  itemBuilder: (_, __) => const HadithCardShimmer(),
                ),
              },
        ),
      ],
    );
  }
}
