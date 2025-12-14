import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/models/login_response_body.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/models/sign_up_request_body.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/models/sign_up_response_body.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_response.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/collection_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/models/hadith_analysis_request.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/models/hadith_analysis_response.dart';
import 'package:mishkat_almasabih/features/home/data/models/book_model.dart';
import 'package:mishkat_almasabih/features/home/data/models/library_statistics_model.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/local_hadith_navigation_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/navigation_hadith_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/stats_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:mishkat_almasabih/features/remaining_questions/data/models/remaining_questions_response_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/models/public_search_model.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/models/search_with_filters_model.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_response_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/authentication/login/data/models/login_request_body.dart';
import 'api_constants.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST(ApiConstants.login)
  Future<LoginResponseBody> login(@Body() LoginRequestBody loginRequestBody);

  @POST(ApiConstants.signup)
  Future<SignUpResponseBody> signup(
    @Body() SignupRequestBody signupRequestBody,
  );

  @POST(ApiConstants.googleLogin)
  Future<LoginResponseBody> googleLogin(@Body() Map<String, dynamic> data);
  @GET(ApiConstants.getAllBooksWithCategories)
  Future<BooksResponse> getAllBooksWithCategories();
  @GET(ApiConstants.getLibraryStatistics)
  Future<StatisticsResponse> getLibraryStatisctics();

  @GET(ApiConstants.getBooksByCategory)
  Future<CategoryResponse> getBookData(@Path("categoryId") String categoryId);

  @GET(ApiConstants.getBookChapters)
  Future<ChaptersModel> getBookChapters(
    @Path("bookSlug") String bookSlug,

  );

  @GET(ApiConstants.getChapterAhadiths)
  Future<HadithResponse> getChapterAhadiths(
    @Path("bookSlug") String bookSlug,
    @Path("chapterId") int chapterId,
    @Query("page") int page,
    @Query("paginate") int paginate,
  );

  @GET(ApiConstants.getChapterAhadiths)
  Future<LocalHadithResponse> getLocalChapterAhadiths(
    @Path("bookSlug") String bookSlug,
    @Path("chapterId") int chapterId,

  );

  @GET(ApiConstants.getLocalChapterAhadiths)
  Future<LocalHadithResponse> getThreeBooksLocalChapterAhadiths(
    @Path("bookSlug") String bookSlug,
    @Path("chapterId") int chapterId,

  );

  @GET(ApiConstants.getBookmarks)

  Future<BookmarksResponse> getUserBookmarks(
    @Header("x-auth-token") String token,
  );

  @DELETE(ApiConstants.deleteBookmark)
  Future<AddBookmarkResponse> deleteUserBookmsrk(
    @Path("bookmarkId") int bookmarkId,

    @Header("x-auth-token") String token,
  );

  @POST(ApiConstants.addBookmark)
  Future<AddBookmarkResponse> addBookmark(
    @Header("x-auth-token") String token,
    @Body() Bookmark body,
  );

  @GET(ApiConstants.publicSearch)
  Future<SearchResponse> getpublicSearch(@Path("query") String query);

  @GET(ApiConstants.hadithSearch)
  Future<SearchResponse> getHadithSearch(
    @Path("query") String query,

    @Path("bookSlug") String bookSlug,

    @Path("chapter") String chapterName,
  );

  @GET(ApiConstants.bookmarkCollection)
  Future<CollectionsResponse> getBookmarkCollection(
    @Header("x-auth-token") String token,
  );
  @GET(ApiConstants.navigationHadith)
  Future<NavigationHadithResponse> navigationHadith(
    @Path("hadithNumber") String hadithNumber,

    @Path("bookSlug") String bookSlug,

    @Path("chapterNumber") String chapterNumber,
  );

  @GET(ApiConstants.localNavigationHadith)
  Future<LocalNavigationHadithResponse> localNavigationHadith(
    @Path("hadithNumber") String hadithNumber,

    @Path("bookSlug") String bookSlug,
  );

  @GET(ApiConstants.searchWithFilters)
  Future<SearchWithFiltersModel> searchWithFilters(
    @Path("searchQuery") String searchQuery,

    @Path("bookSlug") String bookSlug,
    @Path("narrator") String narrator,
    @Path("grade") String grade,
    @Path("chapter") String chapter,
    @Path("category") String category,
  );

  @POST(ApiConstants.enhancedSearch)
  Future<EnhancedSearch> getEnhancedSearch(@Body() Map<String, dynamic> body);

  @GET(ApiConstants.getUserProfile)
  Future<UserResponseModel> getUserProfile(
    @Header("x-auth-token") String token,
  );
  @PUT(ApiConstants.updateUserProfile)
  @MultiPart()
  Future<UserResponseModel> updateUserProfile(
    @Header("x-auth-token") String token,
    @Part(name: "username") String username,
    @Part(name: "avatar") File? avatar,
  );

  @POST(ApiConstants.hadithAnalysis)
  Future<HadithAnalysisResponse> hadithAnalysis(
    @Body() HadithAnalysisRequest hadithAnalysisRequest,
    @Header("x-auth-token") String token,
  );

  @POST(ApiConstants.serag)
  Future<SeragResponseModel> serag(
    @Body() SeragRequestModel seragRequistModel,
    @Header("x-auth-token") String token,
  );
  @GET(ApiConstants.remainingQuestions)
  Future<RmainingQuestionsResponse> getReaminingQuestions(
    @Header("x-auth-token") String token,
  );

  // -----------------------------
  // Search History APIs
  // -----------------------------

  // 1. إضافة بحث جديد
  @POST(ApiConstants.addSearch)
  Future<AddSearchResponse> addSearch(
    @Header("x-auth-token") String token,
    @Body() AddSearchRequest body,
  );

  // 2. جلب تاريخ البحث
  @GET(ApiConstants.getSearchHistory)
  Future<GetSearchHistoryResponse> getSearchHistory(
    @Header("x-auth-token") String token,
  );

  // 3. جلب إحصائيات المستخدم
  @GET(ApiConstants.getUserStats)
  Future<StatsModel> getUserStats(
    @Header("x-auth-token") String token,
  );

  // 4. حذف بحث محدد
  @DELETE("${ApiConstants.deleteSearch}/{id}")
  Future<DeleteSearchResponse> deleteSearch(
    @Header("x-auth-token") String token,
    @Path("id") int searchId,
  );

  // 5. حذف كل تاريخ البحث
  @DELETE(ApiConstants.deleteAllSearch)
  Future<DeleteAllSearchResponse> deleteAllSearch(
    @Header("x-auth-token") String token,
    @Body() Map<String, dynamic> body,
  );
}
