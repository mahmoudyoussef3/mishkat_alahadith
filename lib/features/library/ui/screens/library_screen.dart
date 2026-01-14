import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/library_decorations.dart';
import 'package:mishkat_almasabih/core/widgets/error_dialg.dart';
import 'package:mishkat_almasabih/features/book_data/logic/cubit/book_data_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
import 'package:mishkat_almasabih/features/library/ui/widgets/book_grid.dart';

class LibraryScreen extends StatefulWidget {
  final String id;
  final String name;

  const LibraryScreen({super.key, required this.id, required this.name});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const crossAxisCount = 2;
    final spacing = 12 * (crossAxisCount - 1);
    final itemWidth = (screenWidth - spacing) / crossAxisCount;
    final itemHeight = itemWidth * 1.5;
    final aspectRatio = itemWidth / itemHeight;

    return BlocProvider(
      create: (context) => getIt<BookDataCubit>()..emitGetBookData(widget.id),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: LibraryDecorations.libraryScreenBackground,
            body: CustomScrollView(
              slivers: [
                BuildHeaderAppBar(title: widget.name),

                BlocBuilder<BookDataCubit, BookDataState>(
                  builder: (context, state) {
                    if (state is BookDataLoading) {
                      return BookGrid.shimmer(aspectRatio: aspectRatio);
                    } else if (state is BookDataSuccess) {
                      final books = state.categoryResponse.books ?? [];
                      return BookGrid.success(
                        books: books,
                        aspectRatio: aspectRatio,
                      );
                    } else if (state is BookDataFailure) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: ErrorState(error: state.errorMessage),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
