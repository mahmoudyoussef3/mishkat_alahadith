import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/app_text_button.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextButton(
      backgroundColor: ColorsManager.primaryGreen,
      buttonText: "تسجيل الخروج",
      textStyle: const TextStyle(color: Colors.white),
      onPressed: () => _showLogoutDialog(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final signedOut =
                      await context.read<SessionCubit>().signOut();
                  if (!context.mounted) return;
                  if (!signedOut) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تعذر تسجيل الخروج، حاول مرة أخرى'),
                      ),
                    );
                    return;
                  }
                  context.pushReplacementNamed(Routes.loginScreen);
                },
                child: const Text('نعم'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        );
      },
    );
  }
}
