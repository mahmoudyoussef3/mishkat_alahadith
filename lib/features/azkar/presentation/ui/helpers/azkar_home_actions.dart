import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/models/azkar_reader_args.dart';

/// Opens a chapter from the azkar home. Reading changes today's counts and
/// may change the favourites and translation, so they are re-read on the way
/// back.
Future<void> openAzkarReader(
  BuildContext context, {
  required int categoryId,
  int? zikrId,
}) async {
  final cubit = context.read<AzkarHomeCubit>();
  FocusManager.instance.primaryFocus?.unfocus();
  await context.pushNamed(
    Routes.azkarReader,
    arguments: AzkarReaderArgs(categoryId: categoryId, zikrId: zikrId),
  );
  await cubit.refresh();
}

/// Stars or unstars a chapter, saying so when the change could not be saved.
Future<void> toggleAzkarFavorite(BuildContext context, int categoryId) async {
  final saved = await context.read<AzkarHomeCubit>().toggleFavorite(categoryId);
  if (!saved && context.mounted) {
    showErrorSnackbar(context, 'تعذر تحديث المفضلة، حاول مرة أخرى');
  }
}
