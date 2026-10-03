import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';

import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/networking/categories_api_service.dart';
import 'package:mishkat_almasabih/core/networking/dio_factory.dart';
import 'package:mishkat_almasabih/core/data/datasources/hadeethenc_datasource.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/ahadith/data/repos/ahadith_repo_impl.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/repos/ahadith_repo.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/cache_chapter_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_arbain_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_cached_chapter_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_chapter_ahadith_page_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_local_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/logic/cubit/ahadiths_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/datasources/categories_datasource.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/repos/categories_repository_impl.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/repos/categories_repository.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_ahadith_by_category_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_cached_hadith_details_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_categories_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_hadith_details_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/categories/categories_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_by_category/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_details/hadith_by_category_details_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/datasources/google_auth_datasource.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/repos/login_repo_impl.dart';
import 'package:mishkat_almasabih/features/authentication/login/domain/repos/login_repo.dart';
import 'package:mishkat_almasabih/features/authentication/login/domain/usecases/google_login_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/login/domain/usecases/login_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/login/presentation/logic/cubit/login_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/session/data/repos/session_repo_impl.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/repos/session_repo.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/is_signed_in_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/sign_out_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/repos/signup_repo_impl.dart';
import 'package:mishkat_almasabih/features/authentication/signup/domain/repos/signup_repo.dart';
import 'package:mishkat_almasabih/features/authentication/signup/domain/usecases/signup_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/signup/presentation/logic/signup_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/data/repos/bookmark_repo_impl.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/repos/bookmark_repo.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/add_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/delete_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_bookmark_collections_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_cached_bookmark_collections_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_cached_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/add_bookmark/add_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/delete_bookmark/delete_cubit_cubit.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/get_bookmarks/user_bookmarks_cubit.dart';
import 'package:mishkat_almasabih/features/chapters/data/repos/chapters_repo_impl.dart';
import 'package:mishkat_almasabih/features/chapters/domain/repos/chapters_repo.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_book_chapters_use_case.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_cached_book_chapters_use_case.dart';
import 'package:mishkat_almasabih/features/chapters/presentation/logic/cubit/chapters_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/repos/hadith_analysis_repo_impl.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/domain/repos/hadith_analysis_repo.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/domain/usecases/analyze_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/presentation/logic/cubit/hadith_analysis_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/datasources/daily_hadith_local_datasource.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/daily_hadith_repo_impl.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/repos/daily_hadith_repo.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/fetch_daily_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/get_saved_daily_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/library/data/repos/library_repo_impl.dart';
import 'package:mishkat_almasabih/features/library/domain/repos/library_repo.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_cached_category_books_use_case.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_cached_library_statistics_use_case.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_category_books_use_case.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_library_statistics_use_case.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/book_data/book_data_cubit.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/navigation/data/repos/navigation_repo_impl.dart';
import 'package:mishkat_almasabih/features/navigation/domain/repos/navigation_repo.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_cached_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_local_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/presentation/logic/local/local_hadith_navigation_cubit.dart';
import 'package:mishkat_almasabih/features/navigation/presentation/logic/remote/navigation_cubit.dart';
import 'package:mishkat_almasabih/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:mishkat_almasabih/features/onboarding/data/repos/onboarding_repo_impl.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/repos/onboarding_repo.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/usecases/is_first_launch_use_case.dart';
import 'package:mishkat_almasabih/features/onboarding/presentation/logic/onboarding_cubit.dart';
import 'package:mishkat_almasabih/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:mishkat_almasabih/features/theme/data/repos/theme_repo_impl.dart';
import 'package:mishkat_almasabih/features/theme/domain/repos/theme_repo.dart';
import 'package:mishkat_almasabih/features/theme/domain/usecases/get_theme_mode_use_case.dart';
import 'package:mishkat_almasabih/features/theme/domain/usecases/save_theme_mode_use_case.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/datasources/device_location_datasource.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/datasources/prayer_location_local_datasource.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_times_calculator.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/repos/prayer_times_repo_impl.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/repos/prayer_notifications_repo_impl.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/repos/prayer_notifications_repo.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_prayer_notification_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/open_battery_optimization_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/set_prayer_notifications_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_notifications_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/repos/prayer_times_repo.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/calculate_prayer_times_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_device_position_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_next_prayer_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_saved_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/refresh_prayer_home_widget_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/request_location_access_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/reschedule_prayer_notifications_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/save_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/prayer_times_cubit.dart';
import 'package:mishkat_almasabih/features/profile/data/repos/profile_repo_impl.dart';
import 'package:mishkat_almasabih/features/profile/domain/repos/profile_repo.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/get_cached_profile_use_case.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/get_user_stats_use_case.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/edit_profile/edit_profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/profile/profile_cubit.dart';
import 'package:mishkat_almasabih/features/profile/presentation/logic/user_stats/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/data/repos/qiblah_repo_impl.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/repos/qiblah_repo.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/usecases/check_qiblah_readiness_use_case.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/usecases/dispose_qiblah_compass_use_case.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/presentation/logic/qiblah_cubit.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/data/datasources/ramadan_config_remote_datasource.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/data/datasources/ramadan_tasks_local_datasource.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/data/repos/ramadan_config_repository_impl.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/data/repos/ramadan_tasks_repository_impl.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/repos/ramadan_config_repository.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/repos/ramadan_tasks_repository.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/add_task.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/compute_progress.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/delete_task.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/ensure_daily_reset.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/get_ramadan_calendar_use_case.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/get_tasks.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/initialize_ramadan_config_use_case.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/toggle_daily_completion.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/toggle_today_only_completion.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/update_task.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/presentation/logic/ramadan_tasks_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/datasources/custom_api_service.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/repos/random_ahadith_repo_impl.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/repos/random_ahadith_repo.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_random_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/remaining_questions/data/repos/remaining_questions_repo_impl.dart';
import 'package:mishkat_almasabih/features/remaining_questions/domain/repos/remaining_questions_repo.dart';
import 'package:mishkat_almasabih/features/remaining_questions/domain/usecases/get_remaining_questions_use_case.dart';
import 'package:mishkat_almasabih/features/remaining_questions/presentation/logic/cubit/remaining_questions_cubit.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/repos/enhanced_search_repo_impl.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/domain/repos/enhanced_search_repo.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/domain/usecases/enhanced_search_use_case.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/domain/usecases/get_cached_enhanced_search_use_case.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/logic/enhanced_search_cubit.dart';
import 'package:mishkat_almasabih/features/search/search_history/data/repos/search_history_repo_impl.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/repos/search_history_repo.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/add_search_history_entry_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/clear_search_history_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/delete_search_history_entry_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/get_search_history_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/presentation/logic/search_history_cubit.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/repos/search_with_filters_repo_impl.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/repos/search_with_filters_repo.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/usecases/get_cached_filtered_search_use_case.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/usecases/search_with_filters_use_case.dart';
import 'package:mishkat_almasabih/features/search_with_filters/presentation/logic/search_with_filters_cubit.dart';
import 'package:mishkat_almasabih/features/send_suggestion/data/datasources/suggestion_remote_datasource.dart';
import 'package:mishkat_almasabih/features/send_suggestion/data/repos/suggestion_repo_impl.dart';
import 'package:mishkat_almasabih/features/send_suggestion/domain/repos/suggestion_repo.dart';
import 'package:mishkat_almasabih/features/send_suggestion/domain/usecases/send_suggestion_use_case.dart';
import 'package:mishkat_almasabih/features/send_suggestion/presentation/logic/send_suggestion_cubit.dart';
import 'package:mishkat_almasabih/features/serag/data/repos/chat_history_repo_impl.dart';
import 'package:mishkat_almasabih/features/serag/data/repos/serag_repo_impl.dart';
import 'package:mishkat_almasabih/features/serag/domain/repos/chat_history_repo.dart';
import 'package:mishkat_almasabih/features/serag/domain/repos/serag_repo.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/ask_serag_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/clear_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/load_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/domain/usecases/save_chat_history_use_case.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/chat_history/chat_history_cubit.dart';
import 'package:mishkat_almasabih/features/serag/presentation/logic/serag/serag_cubit.dart';

final getIt = GetIt.instance;

Future<void> setUpGetIt() async {
  _registerCore();
  _registerSession();
  _registerAuthentication();
  _registerProfile();
  _registerLibrary();
  _registerChapters();
  _registerAhadith();
  _registerNavigation();
  _registerBookmarks();
  _registerDailyHadith();
  _registerCategories();
  _registerSearch();
  _registerRandomAhadith();
  _registerHadithAnalysis();
  _registerSerag();
  _registerPrayerTimes();
  _registerQiblah();
  _registerRamadanTasks();
  _registerOnboarding();
  _registerSuggestions();
  _registerTheme();
}

void _registerCore() {
  final Dio dio = DioFactory.getDio();

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );
  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));
  getIt.registerLazySingleton<CategoryApiService>(
    () => CategoryApiService(dio),
  );
  getIt.registerLazySingleton<CustomApiService>(() => CustomApiService(dio));
  getIt.registerLazySingleton<HadeethEncDataSource>(
    () => HadeethEncDataSource(),
  );
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<GenericCacheService>(
    () => GenericCacheService.instance,
  );
  getIt.registerLazySingleton<FirebaseRemoteConfig>(
    () => FirebaseRemoteConfig.instance,
  );
}

void _registerSession() {
  getIt.registerLazySingleton<SessionRepo>(
    () => SessionRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<IsSignedInUseCase>(
    () => IsSignedInUseCase(getIt()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(getIt()));
  getIt.registerFactory<SessionCubit>(() => SessionCubit(getIt(), getIt()));
}

void _registerAuthentication() {
  getIt.registerLazySingleton<GoogleAuthDataSource>(
    () => GoogleAuthDataSourceImpl(),
  );
  getIt.registerLazySingleton<LoginRepo>(
    () => LoginRepoImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton<GoogleLoginUseCase>(
    () => GoogleLoginUseCase(getIt()),
  );
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt(), getIt()));

  getIt.registerLazySingleton<SignupRepo>(() => SignupRepoImpl(getIt()));
  getIt.registerLazySingleton<SignupUseCase>(() => SignupUseCase(getIt()));
  getIt.registerFactory<SignupCubit>(() => SignupCubit(getIt()));
}

void _registerProfile() {
  getIt.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedProfileUseCase>(
    () => GetCachedProfileUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetUserStatsUseCase>(
    () => GetUserStatsUseCase(getIt()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt()),
  );
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt(), getIt()));
  getIt.registerFactory<UserStatsCubit>(() => UserStatsCubit(getIt()));
  getIt.registerFactory<EditProfileCubit>(() => EditProfileCubit(getIt()));
}

void _registerLibrary() {
  getIt.registerLazySingleton<LibraryRepo>(
    () => LibraryRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedLibraryStatisticsUseCase>(
    () => GetCachedLibraryStatisticsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetLibraryStatisticsUseCase>(
    () => GetLibraryStatisticsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetCachedCategoryBooksUseCase>(
    () => GetCachedCategoryBooksUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetCategoryBooksUseCase>(
    () => GetCategoryBooksUseCase(getIt()),
  );
  getIt.registerFactory<GetLibraryStatisticsCubit>(
    () => GetLibraryStatisticsCubit(getIt(), getIt()),
  );
  getIt.registerFactory<BookDataCubit>(() => BookDataCubit(getIt(), getIt()));
}

void _registerChapters() {
  getIt.registerLazySingleton<ChaptersRepo>(
    () => ChaptersRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedBookChaptersUseCase>(
    () => GetCachedBookChaptersUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetBookChaptersUseCase>(
    () => GetBookChaptersUseCase(getIt()),
  );
  getIt.registerFactory<ChaptersCubit>(() => ChaptersCubit(getIt(), getIt()));
}

void _registerAhadith() {
  getIt.registerLazySingleton<AhadithRepo>(
    () => AhadithRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedChapterAhadithUseCase>(
    () => GetCachedChapterAhadithUseCase(getIt()),
  );
  getIt.registerLazySingleton<CacheChapterAhadithUseCase>(
    () => CacheChapterAhadithUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetChapterAhadithPageUseCase>(
    () => GetChapterAhadithPageUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetLocalAhadithUseCase>(
    () => GetLocalAhadithUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetArbainAhadithUseCase>(
    () => GetArbainAhadithUseCase(getIt()),
  );
  getIt.registerFactory<AhadithsCubit>(
    () => AhadithsCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
}

void _registerNavigation() {
  getIt.registerLazySingleton<NavigationRepo>(
    () => NavigationRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedHadithNavigationUseCase>(
    () => GetCachedHadithNavigationUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetHadithNavigationUseCase>(
    () => GetHadithNavigationUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetLocalHadithNavigationUseCase>(
    () => GetLocalHadithNavigationUseCase(getIt()),
  );
  getIt.registerFactory<NavigationCubit>(
    () => NavigationCubit(getIt(), getIt()),
  );
  getIt.registerFactory<LocalHadithNavigationCubit>(
    () => LocalHadithNavigationCubit(getIt()),
  );
}

void _registerBookmarks() {
  getIt.registerLazySingleton<BookmarkRepo>(
    () => BookmarkRepoImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedBookmarksUseCase>(
    () => GetCachedBookmarksUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetBookmarksUseCase>(
    () => GetBookmarksUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetCachedBookmarkCollectionsUseCase>(
    () => GetCachedBookmarkCollectionsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetBookmarkCollectionsUseCase>(
    () => GetBookmarkCollectionsUseCase(getIt()),
  );
  getIt.registerLazySingleton<AddBookmarkUseCase>(
    () => AddBookmarkUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteBookmarkUseCase>(
    () => DeleteBookmarkUseCase(getIt()),
  );
  getIt.registerFactory<GetBookmarksCubit>(
    () => GetBookmarksCubit(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<GetCollectionsBookmarkCubit>(
    () => GetCollectionsBookmarkCubit(getIt(), getIt()),
  );
  getIt.registerFactory<AddCubitCubit>(() => AddCubitCubit(getIt()));
  getIt.registerFactory<DeleteCubitCubit>(() => DeleteCubitCubit(getIt()));
}

void _registerDailyHadith() {
  getIt.registerLazySingleton<DailyHadithLocalDataSource>(
    () => DailyHadithLocalDataSource(),
  );
  getIt.registerLazySingleton<DailyHadithRepo>(
    () => DailyHadithRepoImpl(getIt(), getIt(), networkInfo: getIt()),
  );
  getIt.registerLazySingleton<GetSavedDailyHadithUseCase>(
    () => GetSavedDailyHadithUseCase(getIt()),
  );
  getIt.registerLazySingleton<FetchDailyHadithUseCase>(
    () => FetchDailyHadithUseCase(getIt()),
  );
  getIt.registerFactory<DailyHadithCubit>(
    () => DailyHadithCubit(getIt(), getIt()),
  );
}

void _registerCategories() {
  getIt.registerLazySingleton<CategoriesDatasource>(
    () => CategoriesDatasourceImpl(getIt<CategoryApiService>()),
  );
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetAhadithByCategoryUseCase>(
    () => GetAhadithByCategoryUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetCachedHadithDetailsUseCase>(
    () => GetCachedHadithDetailsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetHadithDetailsUseCase>(
    () => GetHadithDetailsUseCase(getIt()),
  );
  getIt.registerFactory<CategoriesCubit>(() => CategoriesCubit(getIt()));
  getIt.registerFactory<HadithByCategoryCubit>(
    () => HadithByCategoryCubit(getIt()),
  );
  getIt.registerFactory<HadithByCategoryDetailsCubit>(
    () => HadithByCategoryDetailsCubit(getIt(), getIt()),
  );
}

void _registerSearch() {
  getIt.registerLazySingleton<EnhancedSearchRepo>(
    () => EnhancedSearchRepoImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedEnhancedSearchUseCase>(
    () => GetCachedEnhancedSearchUseCase(getIt()),
  );
  getIt.registerLazySingleton<EnhancedSearchUseCase>(
    () => EnhancedSearchUseCase(getIt()),
  );
  getIt.registerFactory<EnhancedSearchCubit>(
    () => EnhancedSearchCubit(getIt(), getIt()),
  );

  getIt.registerLazySingleton<SearchWithFiltersRepo>(
    () => SearchWithFiltersRepoImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetCachedFilteredSearchUseCase>(
    () => GetCachedFilteredSearchUseCase(getIt()),
  );
  getIt.registerLazySingleton<SearchWithFiltersUseCase>(
    () => SearchWithFiltersUseCase(getIt()),
  );
  getIt.registerFactory<SearchWithFiltersCubit>(
    () => SearchWithFiltersCubit(getIt(), getIt()),
  );

  getIt.registerLazySingleton<SearchHistoryRepo>(
    () => SearchHistoryRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetSearchHistoryUseCase>(
    () => GetSearchHistoryUseCase(getIt()),
  );
  getIt.registerLazySingleton<AddSearchHistoryEntryUseCase>(
    () => AddSearchHistoryEntryUseCase(getIt()),
  );
  getIt.registerLazySingleton<DeleteSearchHistoryEntryUseCase>(
    () => DeleteSearchHistoryEntryUseCase(getIt()),
  );
  getIt.registerLazySingleton<ClearSearchHistoryUseCase>(
    () => ClearSearchHistoryUseCase(getIt()),
  );
  getIt.registerFactory<SearchHistoryCubit>(
    () => SearchHistoryCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
}

void _registerRandomAhadith() {
  getIt.registerLazySingleton<RandomAhadithRepo>(
    () => RandomAhadithRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetRandomAhadithUseCase>(
    () => GetRandomAhadithUseCase(getIt()),
  );
  getIt.registerFactory<RandomAhadithCubit>(() => RandomAhadithCubit(getIt()));
}

void _registerHadithAnalysis() {
  getIt.registerLazySingleton<HadithAnalysisRepo>(
    () => HadithAnalysisRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AnalyzeHadithUseCase>(
    () => AnalyzeHadithUseCase(getIt()),
  );
  getIt.registerFactory<HadithAnalysisCubit>(
    () => HadithAnalysisCubit(getIt()),
  );
}

void _registerSerag() {
  getIt.registerLazySingleton<SeragRepo>(() => SeragRepoImpl(getIt(), getIt()));
  getIt.registerLazySingleton<AskSeragUseCase>(() => AskSeragUseCase(getIt()));
  getIt.registerFactory<SeragCubit>(() => SeragCubit(getIt()));

  getIt.registerLazySingleton<ChatHistoryRepo>(() => ChatHistoryRepoImpl());
  getIt.registerLazySingleton<LoadChatHistoryUseCase>(
    () => LoadChatHistoryUseCase(getIt()),
  );
  getIt.registerLazySingleton<SaveChatHistoryUseCase>(
    () => SaveChatHistoryUseCase(getIt()),
  );
  getIt.registerLazySingleton<ClearChatHistoryUseCase>(
    () => ClearChatHistoryUseCase(getIt()),
  );
  getIt.registerFactory<ChatHistoryCubit>(
    () => ChatHistoryCubit(getIt(), getIt(), getIt()),
  );

  getIt.registerLazySingleton<RemainingQuestionsRepo>(
    () => RemainingQuestionsRepoImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetRemainingQuestionsUseCase>(
    () => GetRemainingQuestionsUseCase(getIt()),
  );
  getIt.registerFactory<RemainingQuestionsCubit>(
    () => RemainingQuestionsCubit(getIt()),
  );
}

void _registerPrayerTimes() {
  getIt.registerLazySingleton<PrayerTimesRepo>(
    () => PrayerTimesRepoImpl(
      PrayerLocationLocalDataSource(),
      PrayerTimesCalculator(),
      DeviceLocationDataSource(),
    ),
  );
  getIt.registerLazySingleton<GetSavedPrayerLocationUseCase>(
    () => GetSavedPrayerLocationUseCase(getIt()),
  );
  getIt.registerLazySingleton<SavePrayerLocationUseCase>(
    () => SavePrayerLocationUseCase(getIt()),
  );
  getIt.registerLazySingleton<CalculatePrayerTimesUseCase>(
    () => CalculatePrayerTimesUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetNextPrayerUseCase>(
    () => GetNextPrayerUseCase(),
  );
  getIt.registerLazySingleton<RequestLocationAccessUseCase>(
    () => RequestLocationAccessUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetDevicePositionUseCase>(
    () => GetDevicePositionUseCase(getIt()),
  );
  getIt.registerLazySingleton<RefreshPrayerHomeWidgetUseCase>(
    () => RefreshPrayerHomeWidgetUseCase(getIt()),
  );
  getIt.registerLazySingleton<PrayerNotificationsRepo>(
    () => PrayerNotificationsRepoImpl(),
  );
  getIt.registerLazySingleton<ReschedulePrayerNotificationsUseCase>(
    () => ReschedulePrayerNotificationsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetPrayerNotificationSettingsUseCase>(
    () => GetPrayerNotificationSettingsUseCase(getIt()),
  );
  getIt.registerLazySingleton<SetPrayerNotificationsEnabledUseCase>(
    () => SetPrayerNotificationsEnabledUseCase(getIt()),
  );
  getIt.registerLazySingleton<OpenBatteryOptimizationSettingsUseCase>(
    () => OpenBatteryOptimizationSettingsUseCase(getIt()),
  );
  getIt.registerFactory<PrayerNotificationsCubit>(
    () => PrayerNotificationsCubit(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<PrayerTimesCubit>(
    () => PrayerTimesCubit(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
}

void _registerQiblah() {
  getIt.registerLazySingleton<QiblahRepo>(() => QiblahRepoImpl());
  getIt.registerLazySingleton<CheckQiblahReadinessUseCase>(
    () => CheckQiblahReadinessUseCase(getIt()),
  );
  getIt.registerLazySingleton<DisposeQiblahCompassUseCase>(
    () => DisposeQiblahCompassUseCase(getIt()),
  );
  getIt.registerFactory<QiblahCubit>(() => QiblahCubit(getIt(), getIt()));
}

void _registerRamadanTasks() {
  getIt.registerLazySingleton<RamadanTasksLocalDataSource>(
    () => RamadanTasksLocalDataSource(),
  );
  getIt.registerLazySingleton<RamadanTasksRepository>(
    () => RamadanTasksRepositoryImpl(getIt<RamadanTasksLocalDataSource>()),
  );
  getIt.registerLazySingleton<RamadanConfigRemoteDataSource>(
    () => RamadanConfigRemoteDataSourceImpl(remoteConfig: getIt()),
  );
  getIt.registerLazySingleton<RamadanConfigRepository>(
    () => RamadanConfigRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<GetTasks>(() => GetTasks(getIt()));
  getIt.registerLazySingleton<AddTask>(() => AddTask(getIt()));
  getIt.registerLazySingleton<DeleteTask>(() => DeleteTask(getIt()));
  getIt.registerLazySingleton<UpdateTask>(() => UpdateTask(getIt()));
  getIt.registerLazySingleton<ToggleDailyCompletion>(
    () => ToggleDailyCompletion(getIt()),
  );
  getIt.registerLazySingleton<ToggleTodayOnlyCompletion>(
    () => ToggleTodayOnlyCompletion(getIt()),
  );
  getIt.registerLazySingleton<EnsureDailyReset>(
    () => EnsureDailyReset(getIt()),
  );
  getIt.registerLazySingleton<ComputeProgress>(() => ComputeProgress());
  getIt.registerLazySingleton<GetRamadanCalendarUseCase>(
    () => GetRamadanCalendarUseCase(getIt()),
  );
  getIt.registerLazySingleton<InitializeRamadanConfigUseCase>(
    () => InitializeRamadanConfigUseCase(getIt()),
  );
  getIt.registerFactory<RamadanTasksCubit>(
    () => RamadanTasksCubit(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
}

void _registerOnboarding() {
  getIt.registerLazySingleton<OnboardingRepo>(
    () => OnboardingRepoImpl(OnboardingLocalDataSource()),
  );
  getIt.registerLazySingleton<IsFirstLaunchUseCase>(
    () => IsFirstLaunchUseCase(getIt()),
  );
  getIt.registerLazySingleton<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(getIt()),
  );
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit(getIt()));
}

void _registerTheme() {
  getIt.registerLazySingleton<ThemeRepo>(
    () => ThemeRepoImpl(ThemeLocalDataSource()),
  );
  getIt.registerLazySingleton<GetThemeModeUseCase>(
    () => GetThemeModeUseCase(getIt()),
  );
  getIt.registerLazySingleton<SaveThemeModeUseCase>(
    () => SaveThemeModeUseCase(getIt()),
  );
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt(), getIt()));
}

void _registerSuggestions() {
  getIt.registerLazySingleton<SuggestionRepo>(
    () => SuggestionRepoImpl(SuggestionRemoteDataSource()),
  );
  getIt.registerLazySingleton<SendSuggestionUseCase>(
    () => SendSuggestionUseCase(getIt()),
  );
  getIt.registerFactory<SendSuggestionCubit>(
    () => SendSuggestionCubit(getIt()),
  );
}
