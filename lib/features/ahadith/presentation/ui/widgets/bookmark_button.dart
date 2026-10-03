import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

class BookmarkButton extends StatelessWidget {
  final String bookSlug;
  final String arabicBookName;
  final String arabicChapterName;
  final int? chapterNumber;

  const BookmarkButton({
    super.key,
    required this.bookSlug,
    required this.arabicBookName,
    required this.arabicChapterName,
    required this.chapterNumber,
  });

  Future<void> _checkToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken != null) {
      context.read<AddCubitCubit>().addBookmark(
            Bookmark(
              id: chapterNumber,
              chapterNumber: chapterNumber,
              bookName: arabicBookName,
              chapterName: arabicChapterName,
              type: 'chapter',
              bookSlug: bookSlug,
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                textDirection: TextDirection.rtl,
              ),
              IconButton(
                onPressed: () => context.pushNamed(Routes.loginScreen),
                icon: const Icon(Icons.login,color: ColorsManager.secondaryBackground,),
              ),
            ],
          ),
          backgroundColor: ColorsManager.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarActionButton(
      icon: Icons.bookmark_border_rounded,
      onPressed: () => _checkToken(context),
    );
  }
}
