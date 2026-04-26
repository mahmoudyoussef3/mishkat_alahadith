import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/logic/cubit/hadith_analysis_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/ui/widgets/hadith_analysis.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/hadith_books_section.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/hadith_grade_title.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/hadith_text_card.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/navigation/logic/cubit/navigation_cubit.dart';
import 'package:mishkat_almasabih/features/navigation/logic/local/cubit/local_hadith_navigation_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/hadith_header_info.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/divider_section.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/navigation_container.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/bookmark_appbar_action.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/widgets/serag_fab_button.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';

// ignore: must_be_immutable
class HadithDetailScreen extends StatefulWidget {
  final String? hadithText;
  final String? narrator;
  final String? grade;
  final String? bookName;
  final String? author;
  final String? chapter;
  final String? authorDeath;
  final String? hadithNumber;
  final String? bookSlug;
  final bool isBookMark;
  final String chapterNumber;
  final bool isLocal;
  bool showNavigation;

  HadithDetailScreen({
    super.key,
    required this.hadithText,
    required this.chapterNumber,
    required this.narrator,
    required this.grade,
    required this.bookName,
    required this.author,
    required this.chapter,
    required this.authorDeath,
    required this.hadithNumber,
    required this.bookSlug,
    this.isBookMark = false,
    required this.isLocal,
    this.showNavigation = true,
  });

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  bool prev = false;
  bool isNavigated = false;
  String newTextOfHadith = '';

  String newHadithId = '';
  late String _currentHadithId;
  bool _hasPrev = true;
  bool _hasNext = true;

  bool _isValid(String? text) => text != null && text.trim().isNotEmpty;

  @override
  void initState() {
    _currentHadithId = widget.hadithNumber ?? '';
    getToken();
    super.initState();
  }

  String? token;
  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    setState(() {
      token = storedToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AddCubitCubit>()),
        BlocProvider(create: (context) => getIt<NavigationCubit>()),
        BlocProvider(create: (context) => getIt<LocalHadithNavigationCubit>()),
        BlocProvider(create: (context) => getIt<GetCollectionsBookmarkCubit>()),

        BlocProvider(
          create:
              (context) =>
                  getIt<HadithAnalysisCubit>()..analyzeHadith(
                    hadith:
                        newTextOfHadith.isEmpty
                            ? widget.hadithText ?? ''
                            : newTextOfHadith,
                    attribution: widget.author ?? '',
                    grade: widget.grade ?? '',

                    reference: widget.bookName ?? '',
                  ),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: true,
          bottom: true,
          child: Scaffold(
            floatingActionButton: SeragFabButton(
              token: token,
              hadithText:
                  (isNavigated && newTextOfHadith.isNotEmpty)
                      ? newTextOfHadith
                      : (widget.hadithText ?? ''),
              grade: widget.grade ?? '',
              bookName: widget.bookName ?? '',
              narrator: widget.narrator ?? '',
            ),
            backgroundColor: ColorsManager.secondaryBackground,
            body: CustomScrollView(
              slivers: [
                BuildHeaderAppBar(
                  title: 'تفاصيل الحديث',
                  actions:
                      widget.isBookMark
                          ? []
                          : [
                            BookmarkAppBarAction(
                              token: token,
                              bookName: widget.bookName ?? '',
                              bookSlug: widget.bookSlug ?? '',
                              chapter: widget.chapter ?? '',
                              hadithNumber: widget.hadithNumber ?? '',
                              hadithText:
                                  (isNavigated && newTextOfHadith.isNotEmpty)
                                      ? newTextOfHadith
                                      : (widget.hadithText ?? ''),
                            ),
                          ],
                ),

                if (_isValid(widget.hadithNumber) || _isValid(widget.bookName))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 16.h,
                      ),
                      child: HadithHeaderInfo(
                        hadithId:
                            newHadithId.isNotEmpty
                                ? newHadithId
                                : _currentHadithId,
                        bookName: widget.bookName,
                      ),
                    ),
                  ),

                if (_isValid(widget.hadithText))
                  SliverToBoxAdapter(
                    child: HadithTextCard(
                      hadithText:
                          isNavigated
                              ? newTextOfHadith
                              : widget.hadithText ?? "الحديث غير متوفر",
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                if (widget.showNavigation && !widget.isBookMark)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child:
                          widget.isLocal
                              ? _buildLocalNavigation()
                              : _buildRemoteNavigation(),
                    ),
                  ),

                HadithAnalysis(
                  attribution: widget.narrator ?? '',
                  hadith:
                      newTextOfHadith.isEmpty
                          ? widget.hadithText ?? ''
                          : newTextOfHadith,
                  grade: widget.grade ?? '',
                  reference: widget.bookName ?? '',
                ),

                if (_isValid(widget.grade)) const DividerSection(),

                if (_isValid(widget.grade))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: HadithGradeTile(
                        grade: widget.grade ?? '',
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.hadithText ?? ''),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: ColorsManager.success,
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "تم نسخ الحديث بنجاح",
                                    style: HadithDetailsTextStyles.snackText
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                if (_isValid(widget.bookName) ||
                    _isValid(widget.author) ||
                    _isValid(widget.chapter))
                  const DividerSection(),

                if (_isValid(widget.bookName) ||
                    _isValid(widget.author) ||
                    _isValid(widget.chapter))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: HadithBookSection(
                        bookName: widget.bookName ?? '',
                        author: widget.author,
                        authorDeath: widget.authorDeath,
                        chapter: widget.chapter ?? '',
                      ),
                    ),
                  ),

                const DividerSection(),

                SliverToBoxAdapter(child: SizedBox(height: 120.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Local Navigation
  Widget _buildLocalNavigation() {
    return BlocConsumer<LocalHadithNavigationCubit, LocalHadithNavigationState>(
      listener: (context, state) {
        if (state is LocalHadithNavigationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorsManager.error,
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.errMessage,
                style: HadithDetailsTextStyles.snackText,
              ),
            ),
          );
        }
        if (state is LocalHadithNavigationSuccess) {
          setState(() {
            isNavigated = true;
            final hadith =
                prev
                    ? state.navigationHadithResponse.prevHadith
                    : state.navigationHadithResponse.nextHadith;

            if (hadith != null) {
              newTextOfHadith = hadith.title ?? "الحديث غير متوفر";
              newHadithId = hadith.id.toString();
              _currentHadithId = newHadithId;
              _hasPrev = state.navigationHadithResponse.prevHadith != null;
              _hasNext = state.navigationHadithResponse.nextHadith != null;
            }
          });
        }
      },
      builder: (context, state) {
        return NavigationContainer(
          isLoading: state is NavigationLoading,
          hadithId: newHadithId.isNotEmpty ? newHadithId : _currentHadithId,
          onPrev:
              _hasPrev
                  ? () {
                    prev = true;
                    context
                        .read<LocalHadithNavigationCubit>()
                        .emitLocalNavigation(
                          _currentHadithId,
                          widget.bookSlug ?? "",
                        );
                  }
                  : null,
          onNext:
              _hasNext
                  ? () {
                    prev = false;
                    context
                        .read<LocalHadithNavigationCubit>()
                        .emitLocalNavigation(
                          _currentHadithId,
                          widget.bookSlug ?? "",
                        );
                  }
                  : null,
        );
      },
    );
  }

  /// Remote Navigation
  Widget _buildRemoteNavigation() {
    return BlocConsumer<NavigationCubit, NavigationState>(
      listener: (context, state) {
        if (state is NavigationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorsManager.error,
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.errMessage,
                style: HadithDetailsTextStyles.snackText,
              ),
            ),
          );
        }
        if (state is NavigationSuccess) {
          setState(() {
            isNavigated = true;
            final hadith =
                prev
                    ? state.navigationHadithResponse.prevHadith
                    : state.navigationHadithResponse.nextHadith;

            if (hadith != null) {
              newTextOfHadith = hadith.title ?? "الحديث غير متوفر";
              newHadithId = hadith.id!;
              _currentHadithId = newHadithId;
              _hasPrev = state.navigationHadithResponse.prevHadith != null;
              _hasNext = state.navigationHadithResponse.nextHadith != null;
            }
          });
        }
      },
      builder: (context, state) {
        return NavigationContainer(
          isLoading: state is NavigationLoading,
          hadithId: newHadithId.isNotEmpty ? newHadithId : _currentHadithId,
          onPrev:
              _hasPrev
                  ? () {
                    prev = true;
                    context.read<NavigationCubit>().emitNavigationStates(
                      _currentHadithId,
                      widget.bookSlug ?? "",
                      widget.chapterNumber,
                    );
                  }
                  : null,
          onNext:
              _hasNext
                  ? () {
                    prev = false;
                    context.read<NavigationCubit>().emitNavigationStates(
                      _currentHadithId,
                      widget.bookSlug ?? "",
                      widget.chapterNumber,
                    );
                  }
                  : null,
        );
      },
    );
  }
}
