import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';

/// Asks for confirmation, signs out, then returns to the login screen with
/// nothing left behind it. Reports a failed sign-out in place.
Future<void> confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text(
              'هل تريد تسجيل الخروج؟ ستبقى أحاديثك ومجموعاتك محفوظة في حسابك.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ColorsManager.error,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        ),
  );
  if (confirmed != true || !context.mounted) return;

  final signedOut = await context.read<SessionCubit>().signOut();
  if (!context.mounted) return;
  if (!signedOut) {
    showErrorSnackbar(context, 'تعذر تسجيل الخروج، حاول مرة أخرى');
    return;
  }
  await context.pushNamedAndRemoveUntil(
    Routes.loginScreen,
    predicate: (_) => false,
  );
}
