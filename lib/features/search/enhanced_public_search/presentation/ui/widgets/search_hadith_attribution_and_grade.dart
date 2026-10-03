import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_styles.dart';
import 'package:mishkat_almasabih/core/theming/enhanced_search_decorations.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';

class searchHadithAttributionAndGrade extends StatelessWidget {
  final EnhancedHadithModel enhancedHadithModel;
  const searchHadithAttributionAndGrade({
    super.key,
    required this.enhancedHadithModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (enhancedHadithModel.attribution != null)
          Flexible(
            child: Text(
              "📖 ${enhancedHadithModel.attribution!}",
              style: EnhancedSearchTextStyles.attribution,
              textAlign: TextAlign.start,
            ),
          ),
        if (enhancedHadithModel.grade != null)
          Chip(
            backgroundColor: EnhancedSearchDecorations.gradeChipBackground(
              getGradeColor(enhancedHadithModel.grade),
            ),
            label: Text(
              enhancedHadithModel.grade ?? "",
              style: EnhancedSearchTextStyles.gradeChipText(
                getGradeColor(enhancedHadithModel.grade),
              ),
            ),
          ),
      ],
    );
  }
}
