import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/sign_in_prompt.dart';

/// The hadith Siraj is asked to analyse.
class SirajAnalysisArgs {
  const SirajAnalysisArgs({
    required this.hadith,
    this.attribution = '',
    this.grade = '',
    this.reference = '',
    this.title,
  });

  final String hadith;
  final String attribution;
  final String grade;

  /// The book it comes from.
  final String reference;

  /// Short source line for the header ("صحيح البخاري · حديث ٦٦٤٤").
  final String? title;
}

/// Opens Siraj's analysis of a hadith. It needs an account, so guests are
/// asked to sign in instead.
Future<void> openSirajAnalysis(BuildContext context, SirajAnalysisArgs args) async {
  final signedIn = await context.read<SessionCubit>().checkSession();
  if (!context.mounted) return;
  if (!signedIn) {
    showSignInRequired(context, action: 'تحليل الأحاديث مع سراج');
    return;
  }
  await context.pushNamed(Routes.sirajAnalysis, arguments: args);
}
