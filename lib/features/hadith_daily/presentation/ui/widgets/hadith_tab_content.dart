import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/theming/daily_hadith_styles.dart';

class HadithTabContent extends StatelessWidget {
  final String selectedTab;
  final ExplainedHadith? data;

  const HadithTabContent({
    super.key,
    required this.selectedTab,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    int count = 1;

    switch (selectedTab) {
      case "شرح":
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: data?.explanation ?? "لا يوجد شرح",
                style: DailyHadithTextStyles.explanation,
              ),
            ],
          ),
        );

      case "الدروس المستفادة":
        if (data?.hints != null && data!.hints!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                data!.hints!
                    .map<Widget>(
                      (hint) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${count++}- ".toString(),
                                style: DailyHadithTextStyles.hintNumber,
                              ),
                              TextSpan(
                                text: hint,
                                style: DailyHadithTextStyles.hintText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          );
        }
        return const Text("لا توجد فوائد");

      case "معاني الكلمات":
        if (data?.wordsMeanings != null && data!.wordsMeanings!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                data!.wordsMeanings!
                    .map<Widget>(
                      (wm) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: wm.word ?? "",
                                style: DailyHadithTextStyles.wordStyle,
                              ),
                              TextSpan(
                                text: ": ",
                                style: DailyHadithTextStyles.colonStyle,
                              ),
                              TextSpan(
                                text: wm.meaning ?? "",
                                style: DailyHadithTextStyles.meaningStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          );
        }
        return const Text("لا توجد معاني");

      default:
        return const SizedBox.shrink();
    }
  }
}
