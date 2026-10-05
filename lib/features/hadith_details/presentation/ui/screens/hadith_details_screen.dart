import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/deep_links/hadith_link.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/presentation/ui/siraj_analysis_args.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/logic/hadith_reader_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/bookmark_appbar_action.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/hadith_reader_bar.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/hadith_reading_card.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/hadith_source_card.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/widgets/siraj_prompt_card.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_font_size_sheet.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/open_siraj.dart';

/// A hadith from a book at full length, with its source, Siraj, and steps
/// to the neighbouring hadiths of the chapter.
class HadithDetailScreen extends StatelessWidget {
  final String? hadithText;
  final String? narrator;
  final String? grade;
  final String? bookName;
  final String? author;
  final String? chapter;
  final String? authorDeath;
  final String? hadithNumber;
  final String? bookSlug;
  final bool isBookMark;
  final String chapterNumber;
  final bool isLocal;
  final bool showNavigation;

  const HadithDetailScreen({
    super.key,
    required this.hadithText,
    required this.chapterNumber,
    required this.narrator,
    required this.grade,
    required this.bookName,
    required this.author,
    required this.chapter,
    required this.authorDeath,
    required this.hadithNumber,
    required this.bookSlug,
    this.isBookMark = false,
    required this.isLocal,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    final withNavigation = showNavigation && !isBookMark;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AddCubitCubit>()),
        BlocProvider(create: (_) => getIt<GetCollectionsBookmarkCubit>()),
        BlocProvider(
          create:
              (_) =>
                  getIt<HadithReaderCubit>()..start(
                    hadithId: hadithNumber ?? '',
                    text: hadithText ?? '',
                    bookSlug: bookSlug ?? '',
                    chapterNumber: chapterNumber,
                    isLocal: isLocal,
                    withNavigation: withNavigation,
                  ),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _HadithDetailView(screen: this, withNavigation: withNavigation),
      ),
    );
  }
}

class _HadithDetailView extends StatelessWidget {
  const _HadithDetailView({required this.screen, required this.withNavigation});

  final HadithDetailScreen screen;
  final bool withNavigation;

  String? get _bookName => _nonEmpty(screen.bookName);

  String _sourceLine(String hadithId) => [
    _bookName,
    // "حديث ٩" rather than a bare "٩": next to "·" a lone Arabic digit
    // reads like it has a trailing zero.
    if (hadithId.isNotEmpty) toArabicDigits('حديث $hadithId'),
  ].nonNulls.join(' · ');

  SeragHadithContext _sirajContext(String text) => SeragHadithContext(
    hadeeth: text,
    gradeAr: screen.grade ?? '',
    source: screen.bookName ?? '',
    takhrijAr: screen.narrator ?? '',
  );

  @override
  Widget build(BuildContext context) {
    final grade = HadithGrade.tryParse(screen.grade);
    final author = _nonEmpty(screen.author);
    final narrator = _nonEmpty(screen.narrator);

    return Scaffold(
      backgroundColor: ColorsManager.secondaryBackground,
      bottomNavigationBar: withNavigation ? const HadithReaderBar() : null,
      body: SafeArea(
        bottom: !withNavigation,
        child: BlocBuilder<HadithReaderCubit, HadithReaderState>(
          buildWhen:
              (previous, current) =>
                  previous.hadithId != current.hadithId ||
                  previous.text != current.text,
          builder: (context, reader) {
            final text = reader.text;
            final hadithId = reader.hadithId;

            return Column(
              children: [
                DetailHeader(
                  title: 'تفاصيل الحديث',
                  subtitle: [
                    _bookName,
                    _nonEmpty(screen.chapter),
                  ].nonNulls.join(' · '),
                  actions: [
                    AppIconButton(
                      tooltip: 'حجم الخط',
                      icon: Icons.text_increase_rounded,
                      onPressed: () => showHadithFontSizeSheet(context),
                    ),
                    if (!screen.isBookMark)
                      BookmarkAppBarAction(
                        bookName: screen.bookName ?? '',
                        bookSlug: screen.bookSlug ?? '',
                        chapter: screen.chapter ?? '',
                        hadithNumber: hadithId,
                        hadithText: text,
                      ),
                  ],
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: ListView(
                      key: ValueKey(hadithId),
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                      children: [
                        HadithReadingCard(
                          text: text.isEmpty ? 'نص الحديث غير متوفر' : text,
                          number: hadithId,
                          grade: grade,
                          actions: [
                            HadithCardAction(
                              icon: Icons.content_copy_rounded,
                              label: 'نسخ',
                              onTap:
                                  () => copyHadithText(
                                    context,
                                    HadithTextParts.typeset(text),
                                  ),
                            ),
                            HadithCardAction(
                              icon: Icons.share_rounded,
                              label: 'مشاركة',
                              onTap:
                                  () => shareHadithText(
                                    context,
                                    text: HadithTextParts.typeset(text),
                                    source: _sourceLine(hadithId),
                                    hadithId: hadithId.isEmpty ? null : hadithId,
                                  ),
                            ),
                            HadithCardAction(
                              icon: Icons.image_outlined,
                              label: 'بطاقة',
                              onTap:
                                  () => shareHadithAsImage(
                                    context,
                                    text: text,
                                    source: _sourceLine(hadithId),
                                    deepLink:
                                        hadithId.isEmpty
                                            ? null
                                            : HadithLink.build(
                                              hadithId,
                                            )?.toString(),
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SirajPromptCard(
                          onAnalyze:
                              () => openSirajAnalysis(
                                context,
                                SirajAnalysisArgs(
                                  hadith: text,
                                  attribution: screen.author ?? '',
                                  grade: screen.grade ?? '',
                                  reference: screen.bookName ?? '',
                                  title: _sourceLine(hadithId),
                                ),
                              ),
                          onAsk:
                              () => openSiraj(
                                context,
                                hadith: _sirajContext(text),
                                title: _sourceLine(hadithId),
                              ),
                        ),
                        SizedBox(height: 16.h),
                        HadithSourceCard(
                          rows: [
                            HadithSourceRow(
                              Icons.menu_book_rounded,
                              'الكتاب',
                              _bookName ?? '',
                            ),
                            HadithSourceRow(
                              Icons.person_rounded,
                              'المؤلف',
                              author ?? '',
                            ),
                            HadithSourceRow(
                              Icons.event_rounded,
                              'وفاة المؤلف',
                              _nonEmpty(screen.authorDeath) ?? '',
                            ),
                            HadithSourceRow(
                              Icons.folder_rounded,
                              'الباب',
                              _nonEmpty(screen.chapter) ?? '',
                            ),
                            // Some lists pass the author as the narrator;
                            // only show a real narrator.
                            HadithSourceRow(
                              Icons.record_voice_over_rounded,
                              'الراوي',
                              narrator == null || narrator == author
                                  ? ''
                                  : narrator,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
