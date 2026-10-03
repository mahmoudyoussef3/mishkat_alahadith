import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/widgets/add_bookmark_dialogs.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/build_header_app_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppBarActionButton(
      icon: Icons.bookmark_border_rounded,
      onPressed: () {
        if (!context.read<SessionCubit>().isSignedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorsManager.primaryGreen,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'يجب تسجيل الدخول أولاً لاستخدام هذه الميزة',
                    textDirection: TextDirection.rtl,
                    style: HadithDetailsTextStyles.snackText,
                  ),
                  IconButton(
                    onPressed: () => context.pushNamed(Routes.loginScreen),
                    icon: const Icon(Icons.login, color: Colors.white),
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
              );
            },
          );
        }
      },
    );
  }
}
