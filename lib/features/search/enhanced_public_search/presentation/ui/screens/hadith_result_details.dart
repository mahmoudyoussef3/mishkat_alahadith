import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/screen/daily_hadith_screen.dart';

/// A search result opened in full: the same reading view as the hadith of
/// the day.
class HadithResultDetails extends StatelessWidget {
  const HadithResultDetails({super.key, required this.enhancedHadithModel});

  final ExplainedHadith enhancedHadithModel;

  @override
  Widget build(BuildContext context) {
    return HadithDailyScreen(
      dailyHadithModel: enhancedHadithModel,
      title: 'تفاصيل الحديث',
    );
  }
}
