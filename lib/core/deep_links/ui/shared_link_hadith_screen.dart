import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_details/hadith_by_category_details_cubit.dart';

class SharedLinkHadithScreen extends StatefulWidget {
  final String hadithId;

  const SharedLinkHadithScreen({super.key, required this.hadithId});

  @override
  State<SharedLinkHadithScreen> createState() => _SharedLinkHadithScreenState();
}

class _SharedLinkHadithScreenState extends State<SharedLinkHadithScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HadithByCategoryDetailsCubit, HadithByCategoryDetailsState>(
      listener: (context, state) {
        if (_navigated) return;
        
        if (state is HadithByCategoryDetailsLoaded) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.homeScreen,
              (route) => false,
            );
            Navigator.of(context).pushNamed(
              Routes.hadithOfTheDay,
              arguments: {
                'model': state.dailyHadithModel,
                'title': 'تفاصيل الحديث',
                'description': 'نص حديث نبوي شريف مع شرحه',
              },
            );
          });
        }
      },
      builder: (context, state) {
        if (state is HadithByCategoryDetailsError) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: ColorsManager.primaryBackground,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'تعذر فتح الرابط: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ColorsManager.primaryBackground,
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
