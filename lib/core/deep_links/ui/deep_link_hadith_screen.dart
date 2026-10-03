import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/ui/screens/public_search_result.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/logic/enhanced_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/ui/screens/hadith_result_details.dart';

class DeepLinkHadithScreen extends StatefulWidget {
  final String hadithId;

  const DeepLinkHadithScreen({super.key, required this.hadithId});

  @override
  State<DeepLinkHadithScreen> createState() => _DeepLinkHadithScreenState();
}

class _DeepLinkHadithScreenState extends State<DeepLinkHadithScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnhancedSearchCubit, EnhancedSearchState>(
      listener: (context, state) {
        if (_navigated) return;
        if (state is! EnhancedSearchLoaded) return;

        final results = state.results;
        if (results.isEmpty) return;

        final exact =
            results
                .where((e) => (e.id ?? '').trim() == widget.hadithId.trim())
                .toList();

        if (exact.length == 1) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create:
                              (context) =>
                                  getIt<GetCollectionsBookmarkCubit>()
                                    ..getBookMarkCollections(),
                        ),
                        BlocProvider(
                          create: (context) => getIt<AddCubitCubit>(),
                        ),
                      ],
                      child: HadithResultDetails(
                        enhancedHadithModel: exact.first,
                      ),
                    ),
              ),
            );
          });
        }
      },
      builder: (context, state) {
        if (state is EnhancedSearchLoading) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: ColorsManager.primaryBackground,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is EnhancedSearchError) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: ColorsManager.primaryBackground,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'تعذر فتح الرابط: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return PublicSearchResult(searchQuery: widget.hadithId);
      },
    );
  }
}
