import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/chapters/ui/widgets/get_chapters_bloc_builder.dart';

class BookChaptersScreen extends StatelessWidget {
  const BookChaptersScreen({super.key, required this.args});
  final List<dynamic>? args;

  @override
  Widget build(BuildContext context) {
    final String bookSlug = args![0];
    final Map<String, dynamic> bookData = args![1];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorsManager.secondaryBackground,
          body: GetBookChaptersBlocBuilder(
            
            bookSlug: bookSlug,
            bookData: bookData,
          ),
        ),
      ),
    );
  }
}