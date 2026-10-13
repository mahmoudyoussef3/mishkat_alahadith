import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/sign_in_prompt.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';

/// Saves the open chapter to the user's bookmarks; guests are asked to
/// sign in first.
class SaveChapterButton extends StatelessWidget {
  const SaveChapterButton({
    super.key,
    required this.bookSlug,
    required this.arabicBookName,
    required this.arabicChapterName,
    required this.chapterNumber,
  });

  final String bookSlug;
  final String arabicBookName;
  final String arabicChapterName;
  final int? chapterNumber;

  Future<void> _save(BuildContext context) async {
    final signedIn = await context.read<SessionCubit>().checkSession();
    if (!context.mounted) return;
    if (!signedIn) {
      showSignInRequired(context, action: 'حفظ الأبواب');
      return;
    }
    context.read<AddCubitCubit>().addBookmark(
      UserBookmark(
        id: chapterNumber,
        chapterNumber: chapterNumber,
        bookName: arabicBookName,
        chapterName: arabicChapterName,
        type: 'chapter',
        bookSlug: bookSlug,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      tooltip: 'حفظ الباب',
      icon: Icons.bookmark_add_outlined,
      onPressed: () => _save(context),
    );
  }
}
