import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/ui/screens/ahadith_screen.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/models/book_chapters_args.dart';

/// Opens [chapter] of the book described by [book].
Future<void> openChapter(
  BuildContext context, {
  required BookChaptersArgs book,
  required BookChapter chapter,
}) {
  final number = chapter.chapterNumber ?? 0;
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (_) => MultiBlocProvider(
            providers: [
              // The screen loads the first page itself.
              BlocProvider(create: (_) => getIt<AhadithsCubit>()),
              BlocProvider(create: (_) => getIt<AddCubitCubit>()),
            ],
            child: ChapterAhadithScreen(
              chapterNumber: number,
              authorDeath: '',
              grade: '',
              narrator: '',
              bookSlug: book.bookSlug,
              bookId: number,
              arabicBookName: book.bookName,
              arabicWriterName: book.writerName ?? '',
              arabicChapterName: chapter.chapterArabic ?? '',
              chapterHadithsCount: chapter.hadithsCount,
            ),
          ),
    ),
  );
}
