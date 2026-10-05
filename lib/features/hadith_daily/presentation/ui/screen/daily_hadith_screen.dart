import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/deep_links/hadith_link.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_details/hadith_by_category_details_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/widgets/hadith_categories_section.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/widgets/similar_ahadith_section.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/widgets/hadith_tabs.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/bookmark_appbar_action.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/hadith_reading_card.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_font_size_sheet.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/open_siraj.dart';

/// A hadith with its explanation, lessons and word meanings: the hadith of
/// the day, a topic's hadith, or one opened from a link.
class HadithDailyScreen extends StatelessWidget {
  const HadithDailyScreen({
    super.key,
    required this.dailyHadithModel,
    this.title = 'حديث اليوم',
    this.description = 'نص حديث نبوي شريف مع شرحه',
  });

  final ExplainedHadith dailyHadithModel;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..getCategories()),
        BlocProvider(create: (_) => getIt<HadithByCategoryDetailsCubit>()),
        BlocProvider(create: (_) => getIt<AddCubitCubit>()),
        BlocProvider(create: (_) => getIt<GetCollectionsBookmarkCubit>()),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _ExplainedHadithView(
          hadith: dailyHadithModel,
          title: title,
          description: description,
        ),
      ),
    );
  }
}

class _ExplainedHadithView extends StatelessWidget {
  const _ExplainedHadithView({
    required this.hadith,
    required this.title,
    required this.description,
  });

  final ExplainedHadith hadith;
  final String title;
  final String description;

  String get _text => hadith.hadeeth?.trim() ?? '';

  String? get _attribution {
    final value = hadith.attribution?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? get _id {
    final value = hadith.id?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  void _askSiraj(BuildContext context) => openSiraj(
    context,
    hadith: SeragHadithContext(
      hadeeth: _text,
      gradeAr: hadith.grade ?? '',
      source: hadith.reference ?? '',
      takhrijAr: hadith.attribution ?? '',
    ),
    title: _attribution,
  );

  List<CategoryEntity> _topics(CategoriesState state) {
    final ids = hadith.categories ?? const <String>[];
    if (state is! CategoriesLoaded) return const [];
    final byId = {for (final c in state.categories) c.id: c};
    return [for (final id in ids) if (byId[id] case final category?) category];
  }

  @override
  Widget build(BuildContext context) {
    final grade = hadith.grade?.trim();
    final id = _id;

    return BlocListener<HadithByCategoryDetailsCubit, HadithByCategoryDetailsState>(
      listener: (context, state) {
        if (state is HadithByCategoryDetailsLoaded) {
          Navigator.of(context).pushNamed(
            Routes.hadithOfTheDay,
            arguments: {
              'model': state.dailyHadithModel,
              'title': 'حديث مشابه',
              'description': description,
            },
          );
        } else if (state is HadithByCategoryDetailsError) {
          showErrorSnackbar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        bottomNavigationBar:
            _text.isEmpty ? null : _SirajBar(onTap: () => _askSiraj(context)),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DetailHeader(
                title: title,
                subtitle: description,
                actions: [
                  AppIconButton(
                    tooltip: 'حجم الخط',
                    icon: Icons.text_increase_rounded,
                    onPressed: () => showHadithFontSizeSheet(context),
                  ),
                  BookmarkAppBarAction(
                    bookName: '',
                    bookSlug: '',
                    chapter: '',
                    hadithNumber: '',
                    bookmarkId: id,
                    hadithText: _text,
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  children: [
                    HadithReadingCard(
                      text: _text.isEmpty ? 'نص الحديث غير متوفر' : _text,
                      grade: HadithGrade.tryParse(grade),
                      gradeLabel: grade == null || grade.isEmpty ? null : grade,
                      footer:
                          _attribution == null
                              ? null
                              : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 17.r,
                                    color: ColorsManager.purpleText,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      _attribution!,
                                      style: TextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      actions:
                          _text.isEmpty
                              ? const []
                              : [
                                HadithCardAction(
                                  icon: Icons.content_copy_rounded,
                                  label: 'نسخ',
                                  onTap: () => copyHadithText(context, _text),
                                ),
                                HadithCardAction(
                                  icon: Icons.share_rounded,
                                  label: 'مشاركة',
                                  onTap:
                                      () => shareHadithText(
                                        context,
                                        text: _text,
                                        source: _attribution,
                                        hadithId: id,
                                      ),
                                ),
                                HadithCardAction(
                                  icon: Icons.image_outlined,
                                  label: 'بطاقة',
                                  onTap:
                                      () => shareHadithAsImage(
                                        context,
                                        text: _text,
                                        source: _attribution,
                                        deepLink:
                                            id == null
                                                ? null
                                                : HadithLink.build(id)?.toString(),
                                      ),
                                ),
                              ],
                    ),
                    SizedBox(height: 16.h),
                    ExplanationTabs(hadith: hadith),
                    BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        final topics = _topics(state);
                        if (topics.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20.h),
                            HadithCategoriesSection(categories: topics),
                            BlocSelector<
                              HadithByCategoryDetailsCubit,
                              HadithByCategoryDetailsState,
                              bool
                            >(
                              selector:
                                  (details) =>
                                      details is HadithByCategoryDetailsLoading,
                              builder:
                                  (context, opening) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      for (final topic in topics.take(2)) ...[
                                        SizedBox(height: 20.h),
                                        SimilarAhadithSection(
                                          category: topic,
                                          excludeId: id,
                                          busy: opening,
                                          onOpen:
                                              (similar) => context
                                                  .read<
                                                    HadithByCategoryDetailsCubit
                                                  >()
                                                  .fetchById(similar.id),
                                        ),
                                      ],
                                    ],
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "اسأل سراج عن الحديث", pinned under the content.
class _SirajBar extends StatelessWidget {
  const _SirajBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        border: Border(top: BorderSide(color: ColorsManager.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: HeroSurface(
            showImage: false,
            radius: 14.r,
            padding: EdgeInsets.zero,
            onTap: onTap,
            child: SizedBox(
              height: 46.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 19.r,
                    color: ColorsManager.goldBright,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'اسأل سراج عن الحديث',
                    style: TextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ColorsManager.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
