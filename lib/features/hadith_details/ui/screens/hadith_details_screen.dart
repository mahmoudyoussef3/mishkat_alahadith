import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/loading_progress_indicator.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/add_bookmark_dialogs.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/logic/cubit/hadith_analysis_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/widgets/hadith_action_row.dart';
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
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        child:SafeArea(
              top: false,
        bottom: true,
          child: Scaffold(
            floatingActionButton: Builder(
              builder: (context) {
                return FloatingActionButton.extended(
                  onPressed: () {
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: ColorsManager.secondaryBackground,
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    () => context.pushNamed(Routes.loginScreen),
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
                    } else {
                      context.pushNamed(
                        Routes.serag,
                        arguments: SeragRequestModel(
                          hadith: Hadith(
                            hadeeth: widget.hadithText ?? '',
                            grade_ar: widget.grade ?? '',
                            source: widget.bookName ?? '',
                            takhrij_ar: widget.narrator ?? '',
                          ),
                          messages: [Message(role: 'user', content: '')],
                        ),
                      );
                    }
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
                  label: Text(
                    "اسأل سراج",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.secondaryBackground,
                    ),
                  ),
                );
              },
            ),
            backgroundColor: ColorsManager.secondaryBackground,
            body: CustomScrollView(
              slivers: [
                BuildHeaderAppBar(
                  title: 'تفاصيل الحديث',
                  actions:                  widget.isBookMark ?[]:
 [
                    AppBarActionButton(
                      icon: Icons.bookmark_border_rounded,
                      onPressed: () {
                        if (token == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: ColorsManager.primaryGreen,
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed:
                                        () => context.pushNamed(
                                          Routes.loginScreen,
                                        ),
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
                                  bookName: widget.bookName ?? "",
                                  bookSlug: widget.bookSlug ?? '',
                                  chapter: widget.chapter ?? '',
                                  hadithNumber: widget.hadithNumber ?? "",
                                  hadithText: widget.hadithText ?? '',
                                  id: widget.hadithNumber ?? ' ',
                                ),
                              );
                            },
                          );
                        }
                      },
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
                      child: _buildHadithHeader(),
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

                if (_isValid(widget.grade)) _buildDividerSection(),

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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                  _buildDividerSection(),

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

                _buildDividerSection(),

                    SliverToBoxAdapter(child: SizedBox(height: 120.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHadithHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: ColorsManager.primaryGreen,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isValid(widget.hadithNumber) || isNavigated)
                  Text(
                    "حديث رقم ${newHadithId.isNotEmpty ? newHadithId : _currentHadithId}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.primaryText,
                    ),
                  ),
                if (_isValid(widget.bookName))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(endIndent: 60.w),
                      Text(
                        'من ${widget.bookName}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: ColorsManager.secondaryText,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicSeparator() {
    return Container(
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.3),
            ColorsManager.primaryGold.withOpacity(0.6),
            ColorsManager.primaryPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }

  Widget _buildDividerSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
        child: _buildIslamicSeparator(),
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
                style: TextStyle(color: ColorsManager.secondaryBackground),
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
        return _buildNavigationContainer(
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
                style: TextStyle(color: ColorsManager.secondaryBackground),
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
        return _buildNavigationContainer(
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

  Widget _buildNavigationContainer({
    required bool isLoading,
    required String hadithId,
    required VoidCallback? onPrev,
    required VoidCallback? onNext,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsManager.primaryPurple.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: onPrev,
            color: onPrev == null ? Colors.grey : ColorsManager.primaryPurple,
          ),
          isLoading
              ? Row(
                children: [
                  loadingProgressIndicator(size: 16),
                  SizedBox(width: 8.w),
                  Text(
                    "جاري التحميل...",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.primaryPurple,
                    ),
                  ),
                ],
              )
              : Text(
                "الحديث رقم $hadithId",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.primaryPurple,
                ),
              ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: onNext,
            color: onNext == null ? Colors.grey : ColorsManager.primaryPurple,
          ),
        ],
      ),
    );
  }
}
