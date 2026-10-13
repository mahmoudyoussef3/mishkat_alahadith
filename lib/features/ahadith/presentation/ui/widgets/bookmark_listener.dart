import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';

/// Reports the outcome of saving the chapter.
class BookmarkListener extends StatelessWidget {
  const BookmarkListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCubitCubit, AddCubitState>(
      listener: (context, state) {
        if (state is AddSuccess) {
          showInfoSnackbar(context, 'تم حفظ الباب في محفوظاتك');
        } else if (state is AddFailure) {
          showErrorSnackbar(context, 'تعذر حفظ الباب، حاول مرة أخرى');
        }
      },
      child: child,
    );
  }
}
