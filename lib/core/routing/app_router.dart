import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/about_us/ui/screens/about_us_screen.dart';
import 'package:mishkat_almasabih/features/authentication/signup/logic/signup_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/signup/ui/screens/signup_screen.dart';
import 'package:mishkat_almasabih/features/book_data/logic/cubit/book_data_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/delete_cubit/cubit/delete_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/get_cubit/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/screens/bookmark_screen.dart';
import 'package:mishkat_almasabih/features/chapters/logic/cubit/chapters_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/ui/screens/chapters_screen.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/logic/cubit/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/ui/screen/daily_hadith_screen.dart';
import 'package:mishkat_almasabih/features/hadith_details/ui/screens/hadith_details_screen.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_all_books_with_categories_cubit.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/home/ui/home_screen.dart';
import 'package:mishkat_almasabih/features/library_books_screen.dart';
import 'package:mishkat_almasabih/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/ui/prayer_times_screen.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/cubit/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/ui/profile_screen.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/logic/cubit/qiblah_cubit.dart'
    show QiblahCubit;
import 'package:mishkat_almasabih/features/qiblah_finder/ui/qiblah_finder_screen.dart';
import 'package:mishkat_almasabih/features/random_ahadith/logic/cubit/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/remaining_questions/logic/cubit/remaining_questions_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/logic/cubit/enhanced_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/search_screen/logic/cubit/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/logic/cubit/search_with_filters_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/ui/screens/filter_serch_result_screen.dart';
import 'package:mishkat_almasabih/features/search_with_filters/ui/screens/search_with_filters_screen.dart';
import 'package:mishkat_almasabih/features/send_suggestion/send_suggestion_screen.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/logic/chat_history/chat_history_cubit.dart';
import 'package:mishkat_almasabih/features/serag/logic/cubit/serag_cubit.dart';
import 'package:mishkat_almasabih/features/serag/ui/serag_chat_screen.dart';
import '../../features/home/ui/widgets/public_search_result.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';
import '../../features/authentication/login/logic/cubit/login_cubit.dart';
import '../../features/authentication/login/ui/screens/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'package:mishkat_almasabih/features/daily_zekr/ui/screen/daily_zekr_screen.dart';
import 'package:mishkat_almasabih/features/daily_zekr/logic/cubit/daily_zekr_cubit.dart';
import 'package:mishkat_almasabih/features/daily_zekr/logic/cubit/personal_tasks_cubit.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/presentation/pages/ramadan_tasks_page.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/presentation/cubit/ramadan_tasks_cubit.dart';

class AppRouter {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  void _logScreenView(String screenName) {
    analytics.logScreenView(screenName: screenName, screenClass: screenName);
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
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
                            getIt<GetAllBooksWithCategoriesCubit>()
                              ..emitGetAllBooksWithCategories(),
                  ),
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
                            customGetIt<RandomAhadithCubit>()
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
                    create:
                        (context) => getIt<GetAllBooksWithCategoriesCubit>(),
                  ),
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
        return MaterialPageRoute(builder: (_) => SuggestionForm());

      case Routes.hadithOfTheDay:
        _logScreenView('HadithOfTheDay');
        final query = settings.arguments as NewDailyHadithModel;

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
                child: HadithDailyScreen(dailyHadithModel: query),
              ),
        );
      case Routes.aboutUs:
        _logScreenView('AboutUsScreen');
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());
      case Routes.serag:
        _logScreenView('SeragScreen');
        final query = settings.arguments as SeragRequestModel;

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
                    create: (context) => ChatHistoryCubit()..clearMessages(),
                  ),
                ],
                child: SeragChatScreen(model: query),
              ),
        );

      case Routes.dailyZekrScreen:
        _logScreenView('DailyZekrScreen');
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => getIt<DailyZekrCubit>()..init(),
                  ),
                  BlocProvider(
                    create: (context) => getIt<PersonalTasksCubit>()..init(),
                  ),
                ],
                child: const DailyZekrScreen(),
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

      case Routes.ramadanTasksScreen:
        _logScreenView('RamadanTasksScreen');
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<RamadanTasksCubit>()..init(),
                child: const RamadanTasksPage(),
              ),
        );

      default:
        return null;
    }
  }
}
