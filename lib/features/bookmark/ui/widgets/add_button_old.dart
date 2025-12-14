import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/loading_progress_indicator.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';

class AddButton extends StatelessWidget {
  final String bookName;
  final String bookSlug;
  final String chapter;
  final String hadithNumber;
  final String hadithText;
  final TextEditingController notesController;
  final String collection;

  const AddButton({
    required this.bookName,
    required this.bookSlug,
    required this.chapter,
    required this.hadithNumber,
    required this.hadithText,
    required this.notesController,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCubitCubit, AddCubitState>(
      listener: (context, state) {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (state is AddLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: ColorsManager.primaryGreen,
              content: loadingProgressIndicator(
                size: 30.r,
                color: ColorsManager.offWhite,
              ),
            ),
          );
        } else if (state is AddSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              backgroundColor: ColorsManager.hadithAuthentic,
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.addBookmarkResponse.message??"تمت إضافة الحديث إلي المحفوظات.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          context.pop();
        } else if (state is AddFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
                            backgroundColor: ColorsManager.error,

              content: Text(
                state.message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        return ElevatedButton.icon(
          onPressed: () {
            context.read<AddCubitCubit>().addBookmark(
              Bookmark(
                notes: notesController.text,
                collection: collection,
                bookName: bookName,
                chapterName: chapter,
                hadithId: hadithNumber,
                hadithText: hadithText,
                type: 'hadith',
                bookSlug: bookSlug,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.primaryPurple,
            foregroundColor: ColorsManager.inverseText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text(
            "حفظ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
