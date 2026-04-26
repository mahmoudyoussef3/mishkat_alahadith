import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_decorations.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/add_bookmark_dialogs.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/widgets/hadith_content_card.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/widgets/hadith_attribution_and_grade.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/widgets/hadith_tabs.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/widgets/hadith_tab_content.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithDailyScreen extends StatefulWidget {
  const HadithDailyScreen({super.key, required this.dailyHadithModel});
  final NewDailyHadithModel dailyHadithModel;

  @override
  State<HadithDailyScreen> createState() => _HadithDailyScreenState();
}

class _HadithDailyScreenState extends State<HadithDailyScreen> {
  String selectedTab = "شرح";
  String? token;
  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    setState(() {
      token = storedToken;
    });
  }

  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.dailyHadithModel;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
          top: true,
        bottom: true,
        child: Scaffold(
          floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton.extended(
                onPressed:
                    token == null
                        ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              //  behavior: SnackBarBehavior.floating,
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
                                      color: ColorsManager.secondaryBackground,
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
                            arguments: SeragRequestModel(
                              hadith: Hadith(
                                hadeeth: widget.dailyHadithModel.hadeeth ?? '',
                                grade_ar: widget.dailyHadithModel.grade ?? '',
                                source: '',
                                takhrij_ar:
                                    widget.dailyHadithModel.attribution ?? '',
                              ),
                              messages: [Message(role: 'user', content: '')],
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
              );
            },
          ),
          backgroundColor: ColorsManager.primaryBackground,
          body: CustomScrollView(
            slivers: [
              BuildHeaderAppBar(
                title: 'حديث اليوم',
                description: 'نص حديث نبوي شريف مع شرحه',
                actions: [
                  AppBarActionButton(
                    icon: Icons.bookmark_border_rounded,
                    onPressed: () {
                      if (token == null) {
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

                      // Enhanced tabs section
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
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 120.h)),
            ],
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
}
