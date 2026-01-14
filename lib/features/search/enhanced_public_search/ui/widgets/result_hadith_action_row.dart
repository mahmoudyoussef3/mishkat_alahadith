import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_decorations.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/core/widgets/loading_progress_indicator.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/widgets/add_bookmark_dialogs.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultHadithActionRow extends StatefulWidget {
  final String hadith;
  final String bookName;
  final String bookSlug;
  final String chapter;
  final String hadithNumber;
  final String id;
  final String? author;
  final String? authorDeath;
  final String? grade;
  final bool isBookmarked;
  ResultHadithActionRow({
    super.key,
    required this.hadith,
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
    required this.id,
    this.isBookmarked = false,
    required this.author,
    required this.authorDeath,
    required this.grade,
  });

  @override
  State<ResultHadithActionRow> createState() => _ResultHadithActionRowState();
}

class _ResultHadithActionRowState extends State<ResultHadithActionRow> {
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
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      decoration: EnhancedSearchDecorations.actionRowContainer(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.copy,
            label: "نسخ",
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.hadith));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("تم نسخ الحديث"),
                ),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.share,
            label: "مشاركة",
            onTap: () async {
              await Share.share(widget.hadith, subject: "شارك الحديث");
            },
          ),
          if (!widget.isBookmarked)
            BlocConsumer<AddCubitCubit, AddCubitState>(
              listener: (context, state) {
                ScaffoldMessenger.of(context).clearSnackBars();
                if (state is AddLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          EnhancedSearchDecorations.snackBarLoadingColor,
                      content: loadingProgressIndicator(
                        size: 30,
                        color: EnhancedSearchDecorations.snackBarIconColor,
                      ),
                    ),
                  );
                } else if (state is AddSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          EnhancedSearchDecorations.snackBarSuccessColor,
                      content: Text("تم حفظ الحديث"),
                    ),
                  );
                } else if (state is AddFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          EnhancedSearchDecorations.snackBarErrorColor,
                      content: Text("حدث خطأ. حاول مرة أخرى"),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return _buildActionButton(
                  icon: Icons.bookmark,
                  label: "حفظ",
                  onTap: () {
                    token == null
                        ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            //  behavior: SnackBarBehavior.floating,
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                                  textDirection: TextDirection.rtl,
                                  style: EnhancedSearchTextStyles.snackBarText,
                                ),
                                IconButton(
                                  onPressed:
                                      () =>
                                          context.pushNamed(Routes.loginScreen),
                                  icon: Icon(
                                    Icons.login,
                                    color:
                                        EnhancedSearchDecorations
                                            .snackBarIconColor,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor:
                                EnhancedSearchDecorations.snackBarLoginColor,
                          ),
                        )
                        : showDialog(
                          context: context,
                          builder:
                              (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create:
                                        (_) =>
                                            getIt<
                                              GetCollectionsBookmarkCubit
                                            >(),
                                  ),
                                  BlocProvider(
                                    create: (_) => getIt<AddCubitCubit>(),
                                  ),
                                ],
                                child: AddToFavoritesDialog(
                                  bookName: widget.bookName,
                                  bookSlug: widget.bookSlug,
                                  chapter: widget.chapter,
                                  hadithNumber: widget.hadithNumber,
                                  hadithText: widget.hadith,
                                  id: widget.id,
                                ),
                              ),
                        );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      //   borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: EnhancedSearchDecorations.actionButtonBackground,
            child: Icon(
              icon,
              color: EnhancedSearchDecorations.actionButtonIconColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(label, style: EnhancedSearchTextStyles.actionButtonLabel),
        ],
      ),
    );
  }
}
