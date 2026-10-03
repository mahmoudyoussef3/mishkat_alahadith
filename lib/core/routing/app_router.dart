import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/about_us/presentation/ui/screens/about_us_screen.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_by_category/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/screens/ahadith_categories_screen.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/screens/categories_screen.dart';
import 'package:mishkat_almasabih/features/authentication/signup/presentation/logic/signup_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/signup/presentation/ui/screens/signup_screen.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/book_data/book_data_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/delete_bookmark/delete_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/screens/bookmark_screen.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/logic/cubit/chapters_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/ui/screens/chapters_screen.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/ui/screen/daily_hadith_screen.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/ui/screens/hadith_details_screen.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/home_screen.dart';
import 'package:mishkat_almasabih/features/library/presentation/ui/screens/library_books_screen.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/ui/prayer_times_screen.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/user_stats/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/profile/profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/profile_screen.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/presentation/logic/qiblah_cubit.dart'
    show QiblahCubit;
import 'package:mishkat_almasabih/features/qiblah_finder/presentation/ui/qiblah_finder_screen.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/remaining_questions/presentation/logic/cubit/remaining_questions_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/logic/enhanced_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/search_history/presentation/logic/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/presentation/logic/search_with_filters_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/presentation/ui/screens/filter_serch_result_screen.dart';
import 'package:mishkat_almasabih/features/search_with_filters/presentation/ui/screens/search_with_filters_screen.dart';
import 'package:mishkat_almasabih/features/send_suggestion/presentation/ui/send_suggestion_screen.dart';
import 'package:mishkat_almasabih/features/send_suggestion/presentation/logic/send_suggestion_cubit.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/serag_chat_screen.dart';
import '../../features/search/enhanced_public_search/presentation/ui/screens/public_search_result.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';
import '../../features/authentication/login/presentation/logic/cubit/login_cubit.dart';
import '../../features/authentication/login/presentation/ui/screens/login_screen.dart';
import '../../features/onboarding/presentation/ui/onboarding_screen.dart';
import 'package:mishkat_almasabih/features/onboarding/presentation/logic/onboarding_cubit.dart';
import '../../features/splash/presentation/ui/splash_screen.dart';

import 'package:mishkat_almasabih/features/ramadan_tasks/presentation/ui/screens/ramadan_tasks_screen.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/presentation/logic/ramadan_tasks_cubit.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/presentation/ui/screens/ramadan_progress_screen.dart';

import 'package:mishkat_almasabih/core/deep_links/ui/shared_link_hadith_screen.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_details/hadith_by_category_details_cubit.dart';

class AppRouter {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  void _logScreenView(String screenName) {
    analytics.logScreenView(screenName: screenName, screenClass: screenName);
  }

  Route? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';

    if (routeName.startsWith('/api/hadith/')) {
      final id =
          routeName
              .split('/')
              .last
              .replaceAll('%C2%A0', '')
              .replaceAll('\u00A0', '')
              .trim();
      if (id.isNotEmpty) {
        _logScreenView('ShareHadithLink (Native)');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) =>
                        getIt<HadithByCategoryDetailsCubit>()..fetchById(id),
                child: SharedLinkHadithScreen(hadithId: id),
              ),
        );
      }
    }

    if (routeName == '/') {
      return MaterialPageRoute(
        builder: (_) => Scaffold(backgroundColor: ColorsManager.secondaryBackground),
      );
    }

    switch (routeName) {
      case Routes.hadithDetail:
        _logScreenView('HadithDetail');
        final args = (settings.arguments as Map?) ?? {};
        return MaterialPageRoute(
          builder:
              (_) => HadithDetailScreen(
                hadithText: args['hadithText'] as String?,
                chapterNumber: (args['chapterNumber'] as String?) ?? '',
                narrator: args['narrator'] as String?,
                grade: args['grade'] as String?,
                bookName: args['bookName'] as String?,
                author: args['author'] as String?,
                chapter: args['chapter'] as String?,
                authorDeath: args['authorDeath'] as String?,
                hadithNumber: args['hadithNumber'] as String?,
                bookSlug: args['bookSlug'] as String?,
                isBookMark: false,
                isLocal: (args['isLocal'] as bool?) ?? false,
                showNavigation: true,
              ),
        );
      case Routes.splashScreen:
        _logScreenView('SplashScreen');
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onBoardingScreen:
        _logScreenView('OnboardingScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<OnboardingCubit>(),
                child: const OnboardingScreen(),
              ),
        );
      case Routes.signupScreen:
        _logScreenView('SignupScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<SignupCubit>(),
                child: SignupScreen(),
              ),
        );
      case Routes.loginScreen:
        _logScreenView('LoginScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<LoginCubit>(),
                child: LoginScreen(),
              ),
        );
      case Routes.homeScreen:
        _logScreenView('HomeScreen');
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create:
                        (context) =>
                            getIt<GetLibraryStatisticsCubit>()
                              ..emitGetStatisticsCubit(),
                  ),

                  BlocProvider(create: (context) => getIt<BookDataCubit>()),
                  BlocProvider(create: (context) => getIt<DailyHadithCubit>()),
                  BlocProvider(
                    create: (context) => getIt<SearchHistoryCubit>()..init(),
                  ),
                  BlocProvider(
                    create:
                        (context) =>
                            getIt<RandomAhadithCubit>()
                              ..emitRandomStats(),
                  ),
                ],
                child: const HomeScreen(),
              ),
        );
      case Routes.searchScreen:
        _logScreenView('SearchScreen');
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => getIt<SearchWithFiltersCubit>(),
                  ),
                  BlocProvider(
                    create: (context) => getIt<SearchHistoryCubit>()..init(),
                  ),

                  BlocProvider(create: (context) => getIt<GetBookmarksCubit>()),
                  BlocProvider(create: (context) => getIt<AddCubitCubit>()),
                ],
                child: const SearchWithFiltersScreen(),
              ),
        );
      case Routes.profileScreen:
        _logScreenView('ProfileScreen');
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => getIt<ProfileCubit>()),
                  BlocProvider(create: (context) => getIt<UserStatsCubit>()),
                ],
                child: const ProfileScreen(),
              ),
        );

      case Routes.bookmarkScreen:
        _logScreenView('BookmarkScreen');
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create:
                        (_) => getIt<GetBookmarksCubit>()..getUserBookmarks(),
                  ),
                  BlocProvider(
                    create:
                        (_) =>
                            getIt<GetCollectionsBookmarkCubit>()
                              ..getBookMarkCollections(),
                  ),
                  BlocProvider(create: (_) => getIt<DeleteCubitCubit>()),
                ],
                child: const BookmarkScreen(),
              ),
        );
      case Routes.libraryScreen:
        _logScreenView('LibraryScreen');
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => getIt<GetLibraryStatisticsCubit>(),
                  ),
                ],
                child: const LibraryBooksScreen(),
              ),
        );

      case Routes.bookChaptersScreen:
        _logScreenView('BookChaptersScreen');
        final args = settings.arguments as List<dynamic>;
        final bookSlug = args[0];
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) =>
                        getIt<ChaptersCubit>()
                          ..emitGetBookChapters(bookSlug: bookSlug),
                child: BookChaptersScreen(args: args),
              ),
        );
      case Routes.publicSearchSCreen:
        _logScreenView('publicSearchSCreen');

        final query = settings.arguments as String;
        log(query);

        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) =>
                        getIt<EnhancedSearchCubit>()
                          ..fetchEnhancedSearchResults(query),

                child: PublicSearchResult(searchQuery: query),
              ),
        );

      case Routes.filterResultSearch:
        _logScreenView('FilterResultSearch');

        final query = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) =>
                        getIt<SearchWithFiltersCubit>()..emitSearchWithFilters(
                          bookSlug: query['book'] ?? '',
                          category: query['category'] ?? '',
                          chapterNumber: query['chapter'] ?? '',
                          grade: query['grade'] ?? '',
                          narrator: query['narrator'] ?? '',
                          searchQuery: query['search'] ?? '',
                        ),
                child: FilterSerchResultScreen(
                  searchQuery: query['search'] ?? '',
                ),
              ),
        );

      case Routes.usersSuggestions:
        _logScreenView('UsersSuggestions');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<SendSuggestionCubit>(),
                child: const SuggestionForm(),
              ),
        );

      case Routes.hadithOfTheDay:
        _logScreenView('HadithOfTheDay');
        final args = settings.arguments;
        ExplainedHadith query;
        String title = 'حديث اليوم';
        String description = 'نص حديث نبوي شريف مع شرحه';

        if (args is ExplainedHadith) {
          query = args;
        } else if (args is Map<String, dynamic>) {
          query = args['model'] as ExplainedHadith;
          title = args['title'] as String? ?? title;
          description = args['description'] as String? ?? description;
        } else {
          return null;
        }

        return MaterialPageRoute(
          builder:
              (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => getIt<DailyHadithCubit>()),
                  BlocProvider(create: (context) => getIt<AddCubitCubit>()),
                  BlocProvider(
                    create:
                        (context) =>
                            getIt<GetCollectionsBookmarkCubit>()
                              ..getBookMarkCollections(),
                  ),
                ],
                child: HadithDailyScreen(
                  dailyHadithModel: query,
                  title: title,
                  description: description,
                ),
              ),
        );
      case Routes.aboutUs:
        _logScreenView('AboutUsScreen');
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());
      case Routes.serag:
        _logScreenView('SeragScreen');
        final query = settings.arguments as SeragHadithContext;

        return MaterialPageRoute(
          builder:
              (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create:
                        (context) =>
                            getIt<RemainingQuestionsCubit>()
                              ..emitRemainingQuestions(),
                  ),

                  BlocProvider(create: (context) => getIt<SeragCubit>()),
                  BlocProvider(
                    create: (context) => getIt<ChatHistoryCubit>()..clearMessages(),
                  ),
                ],
                child: SeragChatScreen(model: query),
              ),
        );

      case Routes.prayerTimesScreen:
        _logScreenView('PrayerTimesScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<PrayerTimesCubit>(),
                child: const PrayerTimesScreen(),
              ),
        );
      case Routes.qiblahFinder:
        _logScreenView('QiblahFinderScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<QiblahCubit>(),
                child: const QiblahFinderScreen(),
              ),
        );
      case Routes.categoriesScreen:
        _logScreenView('CategoriesScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<CategoriesCubit>()..getCategories(),
                child: const CategoriesScreen(),
              ),
        );
      case Routes.ahadithListScreen:
        _logScreenView('AhadithListScreen');
        final args = settings.arguments as Map<String, dynamic>;
        final categoryId = args['categoryId'] as String;
        final categoryTitle = args['categoryTitle'] as String?;
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) =>
                        getIt<HadithByCategoryCubit>()
                          ..getAhadithByCategory(categoryId),
                child: AhadithListScreen(
                  categoryId: categoryId,
                  categoryTitle: categoryTitle,
                ),
              ),
        );
      case Routes.shareHadithLink:
        _logScreenView('ShareHadithLink');
        final hadithId = settings.arguments as String;
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) =>
                        getIt<HadithByCategoryDetailsCubit>()
                          ..fetchById(hadithId),
                child: SharedLinkHadithScreen(hadithId: hadithId),
              ),
        );

      default:
        return null;
    }
  }
}
