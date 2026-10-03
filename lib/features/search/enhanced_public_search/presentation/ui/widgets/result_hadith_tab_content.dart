import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';

class ResultHadithTabContent extends StatelessWidget {
  final String selectedTab;
  final EnhancedHadithModel? data;

  const ResultHadithTabContent({
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
                style: EnhancedSearchTextStyles.explanationText,
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
                                style: EnhancedSearchTextStyles.hintsCounter,
                              ),
                              TextSpan(
                                text: hint,

                                style: EnhancedSearchTextStyles.hintsContent,
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
        if (data?.words_meanings != null && data!.words_meanings!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                data!.words_meanings!
                    .map<Widget>(
                      (wm) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: wm.word,
                                style: EnhancedSearchTextStyles.wordMeaningWord,
                              ),
                              TextSpan(
                                text: ": ",
                                style:
                                    EnhancedSearchTextStyles
                                        .wordMeaningSeparator,
                              ),
                              TextSpan(
                                text: wm.meaning,
                                style: EnhancedSearchTextStyles.wordMeaningText,
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
