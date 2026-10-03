import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_decorations.dart';

class ResultHadithRichText extends StatelessWidget {
  final String hadith;
  final List wordsMeanings;

  const ResultHadithRichText({
    super.key,
    required this.hadith,
    required this.wordsMeanings,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> wordMap = {
      for (var wm in wordsMeanings) normalizeArabic(wm.word!): wm.meaning ?? "",
    };

    final words = hadith.split(" ");

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children:
            words.map((word) {
              final cleaned = word.replaceAll(
                RegExp(r'[^\u0600-\u06FFa-zA-Z0-9]'),
                "",
              );
              final finalWord = normalizeArabic(cleaned);
              final isSpecial = wordMap.containsKey(finalWord.trim());

              if (isSpecial) {
                return WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                backgroundColor:
                                    EnhancedSearchDecorations
                                        .wordDialogBackground,
                                title: Text(
                                  cleaned,
                                  style:
                                      EnhancedSearchTextStyles.wordDialogTitle,
                                ),
                                content: Text(
                                  wordMap[finalWord] ?? "لا يوجد معنى",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("إغلاق"),
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                    child: Text(
                      "$word ",
                      style: EnhancedSearchTextStyles.specialWord,
                    ),
                  ),
                );
              }

              return TextSpan(
                text: "$word ",
                style: EnhancedSearchTextStyles.regularWord,
              );
            }).toList(),
      ),
    );
  }

  String normalizeArabic(String text) {
    final diacritics = RegExp(r'[\u0617-\u061A\u064B-\u0652]');
    String result = text.replaceAll(diacritics, '');
    result = result.replaceAll(RegExp('[إأآ]'), 'ا');
    result = result.replaceAll('ـ', '');
    result = result.toLowerCase();
    return result;
  }
}
