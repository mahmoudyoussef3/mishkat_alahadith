import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/ui/sign_in_prompt.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';

/// What the Siraj chat opens with.
class SeragChatArgs {
  const SeragChatArgs({required this.hadith, this.title, this.question});

  final SeragHadithContext hadith;

  /// Short source line for the header ("صحيح البخاري · ٦٦٤٤").
  final String? title;

  /// Sent as soon as the chat opens.
  final String? question;
}

/// Opens a conversation with Siraj about [hadith]. Siraj needs an account,
/// so guests are asked to sign in instead.
Future<void> openSiraj(
  BuildContext context, {
  required SeragHadithContext hadith,
  String? title,
  String? question,
}) async {
  final signedIn = await context.read<SessionCubit>().checkSession();
  if (!context.mounted) return;
  if (!signedIn) {
    showSignInRequired(context, action: 'سؤال سراج');
    return;
  }
  await context.pushNamed(
    Routes.serag,
    arguments: SeragChatArgs(hadith: hadith, title: title, question: question),
  );
}
