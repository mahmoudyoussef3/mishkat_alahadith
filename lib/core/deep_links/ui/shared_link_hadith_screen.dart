import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_details/hadith_by_category_details_cubit.dart';

/// Loads a hadith by id, then resets the stack to Home → hadith.
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
            // A newer link opened on top owns navigation now.
            if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
              return;
            }
            final navigator = Navigator.of(context);
            navigator.pushNamedAndRemoveUntil(
              Routes.homeScreen,
              (route) => false,
            );
            navigator.pushNamed(
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ErrorState(
                        error: 'تعذر فتح الرابط: ${state.message}',
                        onRetry:
                            () => context
                                .read<HadithByCategoryDetailsCubit>()
                                .fetchById(widget.hadithId),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.homeScreen,
                              (route) => false,
                            ),
                        child: const Text('العودة إلى الرئيسية'),
                      ),
                    ],
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
