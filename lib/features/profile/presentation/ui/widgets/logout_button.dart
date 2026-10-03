import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/widgets/app_text_button.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove("token");
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
