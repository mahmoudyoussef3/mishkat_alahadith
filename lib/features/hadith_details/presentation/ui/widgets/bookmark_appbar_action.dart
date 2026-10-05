import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/sign_in_prompt.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/add_bookmark_dialogs.dart';

/// Saves the hadith into one of the user's collections; guests are asked
/// to sign in first.
class BookmarkAppBarAction extends StatelessWidget {
  final String bookName;
  final String bookSlug;
  final String chapter;
  final String hadithNumber;
  final String hadithText;

  const BookmarkAppBarAction({
    super.key,
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
    required this.hadithText,
  });

  Future<void> _save(BuildContext context) async {
    final signedIn = await context.read<SessionCubit>().checkSession();
    if (!context.mounted) return;
    if (!signedIn) {
      showSignInRequired(context);
      return;
    }
    showDialog<void>(
      context: context,
      builder:
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AddCubitCubit>()),
              BlocProvider.value(
                value:
                    context.read<GetCollectionsBookmarkCubit>()
                      ..getBookMarkCollections(),
              ),
            ],
            child: AddToFavoritesDialog(
              bookName: bookName,
              bookSlug: bookSlug,
              chapter: chapter,
              hadithNumber: hadithNumber,
              hadithText: hadithText,
              id: hadithNumber.isEmpty ? ' ' : hadithNumber,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      tooltip: 'حفظ الحديث',
      icon: Icons.bookmark_rounded,
      variant: AppIconButtonVariant.tonal,
      onPressed: () => _save(context),
    );
  }
}
