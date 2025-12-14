import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mishkat_almasabih/features/about_us/data/repos/about_us_repo.dart';
import 'package:mishkat_almasabih/features/about_us/logic/cubit/about_us_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/repo/signup_repo.dart';
import 'package:mishkat_almasabih/features/authentication/signup/logic/signup_cubit.dart';
import 'package:mishkat_almasabih/features/book_data/data/repos/book_data_repo.dart';
import 'package:mishkat_almasabih/features/book_data/logic/cubit/book_data_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/data/repos/book_mark_repo.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/add_cubit/cubit/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/cubit/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/delete_cubit/cubit/delete_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/logic/get_cubit/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/data/repos/chapters_repo.dart';
import 'package:mishkat_almasabih/features/chapters/logic/cubit/chapters_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith/data/repos/ahadiths_repo.dart';
import 'package:mishkat_almasabih/features/ahadith/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/repos/hadith_analysis_repo.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/logic/cubit/hadith_analysis_cubit.dart';

import 'package:mishkat_almasabih/features/home/data/repos/get_all_books_with_categories_repo.dart';
import 'package:mishkat_almasabih/features/home/data/repos/get_library_statistics_repo.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_all_books_with_categories_cubit.dart';
import 'package:mishkat_almasabih/features/home/logic/cubit/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/navigation/data/repos/navigation_repo.dart';
import 'package:mishkat_almasabih/features/navigation/logic/cubit/navigation_cubit.dart';
import 'package:mishkat_almasabih/features/navigation/logic/local/cubit/local_hadith_navigation_cubit.dart';
import 'package:mishkat_almasabih/features/profile/data/repos/user_response_repo.dart';
import 'package:mishkat_almasabih/features/profile/edit_profile/data/repos/edit_profile_repo.dart';
import 'package:mishkat_almasabih/features/profile/edit_profile/logic/cubit/edit_profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/cubit/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/profile_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/custom_api_service.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/repos/random_ahadith_repo.dart';
import 'package:mishkat_almasabih/features/random_ahadith/logic/cubit/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/remaining_questions/data/repos/remaining_questions_repo.dart';
import 'package:mishkat_almasabih/features/remaining_questions/logic/cubit/remaining_questions_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/repos/enhanced_search_repo.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/repos/public_search_repo.dart';
import 'package:mishkat_almasabih/features/search/home_screen/logic/cubit/public_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/logic/cubit/enhanced_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/search_screen/data/repos/shared_pref_history_item_repo.dart';
import 'package:mishkat_almasabih/features/search/search_screen/logic/cubit/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/repos/search_with_filters_repo.dart';
import 'package:mishkat_almasabih/features/search_with_filters/logic/cubit/search_with_filters_cubit.dart';
import 'package:mishkat_almasabih/features/serag/data/repos/serag_repo.dart';
import 'package:mishkat_almasabih/features/serag/logic/cubit/serag_cubit.dart';
import '../../features/authentication/login/logic/cubit/login_cubit.dart';
import '../networking/api_service.dart';
import '../networking/dio_factory.dart';
import '../../features/authentication/login/data/repo/login_repo.dart';

final getIt = GetIt.instance;
final customGetIt = GetIt.instance;

Future<void> setUpGetIt() async {
  Dio dio = await DioFactory.getDio();

  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));

  getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));

  getIt.registerLazySingleton<SignupRepo>(() => SignupRepo(getIt()));
  getIt.registerFactory<SignupCubit>(() => SignupCubit(getIt()));

  getIt.registerLazySingleton<GetAllBooksWithCategoriesRepo>(
    () => GetAllBooksWithCategoriesRepo(getIt()),
  );
  getIt.registerFactory<GetAllBooksWithCategoriesCubit>(
    () => GetAllBooksWithCategoriesCubit(getIt()),
  );

  getIt.registerLazySingleton<GetLibraryStatisticsRepo>(
    () => GetLibraryStatisticsRepo(getIt()),
  );
  getIt.registerFactory<GetLibraryStatisticsCubit>(
    () => GetLibraryStatisticsCubit(getIt()),
  );

  getIt.registerLazySingleton<GetBookDataRepo>(() => GetBookDataRepo(getIt()));
  getIt.registerFactory<BookDataCubit>(() => BookDataCubit(getIt()));

  getIt.registerLazySingleton<BookChaptersRepo>(
    () => BookChaptersRepo(getIt()),
  );
  getIt.registerFactory<ChaptersCubit>(() => ChaptersCubit(getIt()));

  getIt.registerLazySingleton<AhadithsRepo>(() => AhadithsRepo(getIt()));
  getIt.registerFactory<AhadithsCubit>(() => AhadithsCubit(getIt()));

  getIt.registerLazySingleton<BookMarkRepo>(() => BookMarkRepo(getIt()));
  getIt.registerFactory<GetBookmarksCubit>(() => GetBookmarksCubit(getIt()));
  getIt.registerFactory<GetCollectionsBookmarkCubit>(
    () => GetCollectionsBookmarkCubit(getIt()),
  );

  getIt.registerFactory<AddCubitCubit>(() => AddCubitCubit(getIt()));
  getIt.registerFactory<DeleteCubitCubit>(() => DeleteCubitCubit(getIt()));

  getIt.registerLazySingleton<PublicSearchRepo>(
    () => PublicSearchRepo(getIt()),
  );
  getIt.registerFactory<PublicSearchCubit>(() => PublicSearchCubit(getIt()));

  //getIt.registerLazySingleton<SaveHadithDailyRepo>(() => SaveHadithDailyRepo(getIt()));
  //getIt.registerFactory<DailyHadithCubit>(() => DailyHadithCubit(getIt()));

  getIt.registerLazySingleton<NavigationRepo>(() => NavigationRepo(getIt()));
  getIt.registerFactory<NavigationCubit>(() => NavigationCubit(getIt()));

  getIt.registerFactory<LocalHadithNavigationCubit>(
    () => LocalHadithNavigationCubit(getIt()),
  );

  getIt.registerLazySingleton<SearchWithFiltersRepo>(
    () => SearchWithFiltersRepo(getIt()),
  );
  getIt.registerFactory<SearchWithFiltersCubit>(
    () => SearchWithFiltersCubit(getIt()),
  );

  getIt.registerLazySingleton<EnhancedSearchRepo>(
    () => EnhancedSearchRepo(getIt()),
  );
  getIt.registerFactory<EnhancedSearchCubit>(
    () => EnhancedSearchCubit(getIt()),
  );

  getIt.registerLazySingleton<UserResponseRepo>(
    () => UserResponseRepo(getIt()),
  );
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt()));

  getIt.registerLazySingleton<EditProfileRepo>(() => EditProfileRepo(getIt()));
  getIt.registerFactory<EditProfileCubit>(() => EditProfileCubit(getIt()));

//  getIt.registerLazySingleton<UserStatsRepo>(() => UserStatsRepo(getIt()));
  getIt.registerFactory<UserStatsCubit>(() => UserStatsCubit(getIt()));

  getIt.registerLazySingleton<HadithAnalysisRepo>(
    () => HadithAnalysisRepo(getIt()),
  );
  getIt.registerFactory<HadithAnalysisCubit>(
    () => HadithAnalysisCubit(getIt()),
  );

  getIt.registerLazySingleton<RemainingQuestionsRepo>(
    () => RemainingQuestionsRepo(getIt()),
  );
  getIt.registerFactory<RemainingQuestionsCubit>(
    () => RemainingQuestionsCubit(getIt()),
  );

  getIt.registerLazySingleton<SeragRepo>(() => SeragRepo(getIt()));
  getIt.registerFactory<SeragCubit>(() => SeragCubit(getIt()));

  getIt.registerLazySingleton<AboutUsRepo>(() => AboutUsRepo(getIt()));
  getIt.registerFactory<AboutUsCubit>(() => AboutUsCubit(getIt()));


///customApi
  customGetIt.registerLazySingleton<CustomApiService>(() => CustomApiService(dio));
  customGetIt.registerLazySingleton<RandomAhadithRepo>(() => RandomAhadithRepo(customGetIt()));
  customGetIt.registerFactory<RandomAhadithCubit>(() => RandomAhadithCubit(customGetIt()));


    customGetIt.registerLazySingleton<SearchHistoryRepo>(() => SearchHistoryRepo(getIt()));
  customGetIt.registerFactory<SearchHistoryCubit>(() => SearchHistoryCubit(getIt()));
  
}
