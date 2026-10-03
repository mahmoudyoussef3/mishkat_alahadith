import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/session_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/widgets/hadith_categories_section.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/widgets/similar_ahadith_section.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/add_bookmark_dialogs.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/widgets/hadith_content_card.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/widgets/hadith_attribution_and_grade.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/widgets/hadith_tabs.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/widgets/hadith_tab_content.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';

class HadithDailyScreen extends StatefulWidget {
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
  State<HadithDailyScreen> createState() => _HadithDailyScreenState();
}

class _HadithDailyScreenState extends State<HadithDailyScreen> {
  String selectedTab = "شرح";

  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.dailyHadithModel;

    return BlocProvider(
      create: (context) => getIt<CategoriesCubit>()..getCategories(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
        bottom: true,
        child: Scaffold(
          floatingActionButton: Builder(
            builder: (context) {
              return SessionBuilder(
                builder: (context, isSignedIn) => FloatingActionButton.extended(
                onPressed:
                    !isSignedIn
                        ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                                    textDirection: TextDirection.rtl,
                                    style: DailyHadithTextStyles.snackText,
                                  ),
                                  IconButton(
                                    onPressed:
                                        () => context.pushNamed(
                                          Routes.loginScreen,
                                        ),
                                    icon: Icon(
                                      Icons.login,
                                      color: ColorsManager.white,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: ColorsManager.primaryGreen,
                            ),
                          );
                        }
                        : () {
                          context.pushNamed(
                            Routes.serag,
                            arguments: SeragHadithContext(
                              hadeeth: widget.dailyHadithModel.hadeeth ?? '',
                              gradeAr: widget.dailyHadithModel.grade ?? '',
                              source: '',
                              takhrijAr: widget.dailyHadithModel.attribution ?? '',
                            ),
                          );
                        },
                backgroundColor: ColorsManager.primaryPurple,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const AssetImage(
                    'assets/images/serag_logo.jpg',
                  ),
                  backgroundColor: Colors.transparent,
                ),
                label: Text("اسأل سراج", style: DailyHadithTextStyles.fabLabel),
              ),
              );
            },
          ),
          backgroundColor: ColorsManager.primaryBackground,
          body: CustomScrollView(
            slivers: [
              BuildHeaderAppBar(
                title: widget.title,
                description: widget.description,
                actions: [
                  AppBarActionButton(
                    icon: Icons.bookmark_border_rounded,
                    onPressed: () {
                      if (!context.read<SessionCubit>().isSignedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: ColorsManager.primaryGreen,
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  onPressed:
                                      () =>
                                          context.pushNamed(Routes.loginScreen),
                                  icon: const Icon(
                                    Icons.login,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: context.read<AddCubitCubit>(),
                                ),
                                BlocProvider.value(
                                  value:
                                      context
                                          .read<GetCollectionsBookmarkCubit>()
                                        ..getBookMarkCollections(),
                                ),
                              ],
                              child: AddToFavoritesDialog(
                                chapter: "",
                                bookSlug: "",
                                hadithNumber: "",
                                id: (Random().nextInt(10000000) + 1).toString(),
                                bookName: '',
                                hadithText:
                                    widget.dailyHadithModel.hadeeth ?? "",
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(child: SizedBox(height: 16.h)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (data.hadeeth != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          child: HadithContentCard(
                            data: widget.dailyHadithModel,
                          ),
                        ),
                      Column(
                        children: [
                          SizedBox(height: 5.h),
                          Divider(
                            endIndent: 30.w,
                            indent: 30.w,
                            color: ColorsManager.gray,
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),
                      HadithAttributionAndGrade(data: widget.dailyHadithModel),

                      Column(
                        children: [
                          SizedBox(height: 5.h),
                          Divider(
                            endIndent: 30.w,
                            indent: 30.w,
                            color: ColorsManager.gray,
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.only(bottom: 20.h),
                        child: _buildEnhancedTabsSection(),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration:
                            DailyHadithDecorations.tabContentContainer(),
                        child: HadithTabContent(
                          selectedTab: selectedTab,
                          data: widget.dailyHadithModel,
                        ),
                      ),

                      if ((data.categories ?? const []).isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        BlocBuilder<CategoriesCubit, CategoriesState>(
                          builder: (context, state) {
                            return switch (state) {
                              CategoriesLoaded(categories: final categories) =>
                                Column(
                                  children: [
                                    HadithCategoriesSection(
                                      categoryIds: data.categories ?? const [],
                                      categories: categories,
                                    ),
                                    SizedBox(height: 14.h),
                                    SimilarAhadithSection(
                                      categoryIds: data.categories ?? const [],
                                      categories: categories,
                                    ),
                                  ],
                                ),
                              CategoriesInitial() || CategoriesLoading() =>
                                _buildCategoriesLoadingSection(),
                              CategoriesError() => const SizedBox.shrink(),
                            };
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 120.h)),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildEnhancedTabsSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: DailyHadithDecorations.tabsContainer(),
      child: HadithTabs(
        selectedTab: selectedTab,
        onTabSelected: (tab) {
          setState(() => selectedTab = tab);
        },
      ),
    );
  }

  Widget _buildCategoriesLoadingSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsManager.secondaryBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.primaryPurple.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ColorsManager.primaryPurple,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'جاري تحميل التصنيفات...',
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
