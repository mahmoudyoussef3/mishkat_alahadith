import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';

class SeragFabButton extends StatelessWidget {
  final String hadithText;
  final String grade;
  final String bookName;
  final String narrator;

  const SeragFabButton({
    super.key,
    required this.hadithText,
    required this.grade,
    required this.bookName,
    required this.narrator,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        if (!context.read<SessionCubit>().isSignedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
                    icon: Icon(Icons.login, color: ColorsManager.white),
                  ),
                ],
              ),
              backgroundColor: ColorsManager.primaryGreen,
            ),
          );
        } else {
          context.pushNamed(
            Routes.serag,
            arguments: SeragHadithContext(
              hadeeth: hadithText,
              gradeAr: grade,
              source: bookName,
              takhrijAr: narrator,
            ),
          );
        }
      },
      backgroundColor: ColorsManager.primaryPurple,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: CircleAvatar(
        radius: 20.r,
        backgroundImage: const AssetImage('assets/images/serag_logo.jpg'),
        backgroundColor: Colors.transparent,
      ),
      label: Text('اسأل سراج', style: HadithDetailsTextStyles.fabLabel),
    );
  }
}
