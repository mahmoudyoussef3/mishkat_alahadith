import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';

class BookmarkListener extends StatelessWidget {
  const BookmarkListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCubitCubit, AddCubitState>(
      listener: (context, state) {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (state is AddLoading) {
          showBookmarkSnackbar(context, 'جاري التحميل...');
        } else if (state is AddSuccess) {
          showBookmarkSnackbar(context, 'تم إضافة الباب بنجاح.');
        } else if (state is AddFailure) {
          showErrorSnackbar(context, 'حدث خطأ. حاول مرة أخري.');
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
