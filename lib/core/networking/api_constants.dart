import 'package:flutter/material.dart';

/// API Constants for Mishkat Al-Masabih Islamic Library App
/// Contains all endpoint URLs and configuration constants
class ApiConstants {
  // -----------------------------
  // Base URLs
  // -----------------------------
  static const String apiBaseUrl = "https://api.hadith-shareef.com/api/";
  static const String customBaseUrl = "https://api.hadith-shareef.com/api/";
  static const String randomAhadith = "hadith/random";

  // -----------------------------
  // Navigator Key
  // -----------------------------
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // -----------------------------
  // Authentication
  // -----------------------------
  static const String login = "auth/login";
  static const String signup = "auth/register";
  static const String googleLogin = "auth/google-login";
  static const String getUserProfile = "auth/profile";
  static const String updateUserProfile = "auth/update-profile";
  static const String getUserStats = "auth/profile/stats";

  // -----------------------------
  // Islamic Library
  // -----------------------------
  static const String getAllBooksWithCategories = "islamic-library/books";
  static const String getLibraryStatistics = "islamic-library/statistics";
  static const String getBooksByCategory =
      "islamic-library/categories/{categoryId}/books";
  static const String getBookChapters =
      "islamic-library/books/{bookSlug}/chapters";
  static const String getChapterAhadiths =
      "islamic-library/books/{bookSlug}/chapters/{chapterId}/hadiths";
  static const String getLocalChapterAhadiths =
      "islamic-library/local-books/{bookSlug}/chapters/{chapterId}/hadiths";

  // -----------------------------
  // Bookmarks
  // -----------------------------
  static const String getBookmarks = "islamic-bookmarks/user";
  static const String addBookmark = "islamic-bookmarks/add";
  static const String deleteBookmark = "islamic-bookmarks/remove/{bookmarkId}";
  static const String bookmarkCollection = "islamic-bookmarks/collections";

  // -----------------------------
  // Search
  // -----------------------------
  static const String publicSearch = "islamic-library/search?q={query}";
  static const String hadithSearch =
      "islamic-library/search?q={query}&book={bookSlug}&chapter={chapter}";
  static const String searchWithFilters =
      "islamic-library/search?q={searchQuery}&book={bookSlug}&narrator={narrator}&status={grade}&category={category}&chapter={chapter}&includeLocal=true&includeAPI=true";
  static const String enhancedSearch = "search";

  // -----------------------------
  // Navigation
  // -----------------------------
  static const String navigationHadith =
      "islamic-library/books/{bookSlug}/chapter/{chapterNumber}/hadith/{hadithNumber}/navigation";
  static const String localNavigationHadith =
      "islamic-library/local-books/{bookSlug}/hadiths/{hadithNumber}/navigation";

  // -----------------------------
  // AI / Hadith Analysis
  // -----------------------------
  static const String hadithAnalysis = "ai/analyze-hadith";
  static const String serag = "ai/chat";
  static const String remainingQuestions = "ai/remaining-questions";

  // -----------------------------
  // Daily Hadith
  // -----------------------------
  static const String dailyHadith = "daily-hadith";

  // -----------------------------
  // Search History
  // -----------------------------
  static const String addSearch = "/search-history";
  static const String getSearchHistory = "/search-history/user";
  static const String deleteSearch = "/search-history"; // /:id
  static const String deleteAllSearch = "/search-history/user";
}

const Map<String, String> bookWriters = {
  "Sahih Bukhari": "الإمام البخاري",
  "Sahih Muslim": "الإمام مسلم",
  "Jami' Al-Tirmidhi": "الإمام الترمذي",
  "Sunan Abu Dawood": "الإمام أبو داود السجستاني",
  "Sunan Ibn-e-Majah": "الإمام ابن ماجه القزويني",
  "Sunan An-Nasa`i": "الإمام النسائي",
  "Mishkat Al-Masabih": "الإمام الخطيب التبريزي",
  "رياض الصالحين": "الإمام يحيى بن شرف النووي",
  "موطأ مالك": "الإمام مالك بن أنس",
  "سنن الدارمي": "الإمام عبد الرحمن بن الدارمي",
  "بلوغ المرام": "الإمام ابن حجر العسقلاني",
  "الأربعون النووية": "الإمام يحيى بن شرف النووي",
  "الأربعون القدسية": "مجموعة من العلماء",
  "أربعون ولي الله الدهلوي": "الشاه ولي الله الدهلوي",
  "الأدب المفرد": "الإمام البخاري",
  "الشمائل المحمدية": "الإمام الترمذي",
  "حصن المسلم": "سعيد بن علي بن وهف القحطاني",
  "الأربعون الرياضية": "الشيخ محمد خير رمضان يوسف",
};

const Map<String, String> bookNamesArabic = {
  "Sahih Bukhari": "صحيح البخاري",
  "Sahih Muslim": "صحيح مسلم",
  "Jami' Al-Tirmidhi": "جامع الترمذي",
  "Sunan Abu Dawood": "سنن أبي داود",
  "Sunan Ibn-e-Majah": "سنن ابن ماجه",
  "Sunan An-Nasa`i": "سنن النسائي",
  "Mishkat Al-Masabih": "مشكات المصابيح",
  "رياض الصالحين": "رياض الصالحين",
  "موطأ مالك": "موطأ مالك",
  "سنن الدارمي": "سنن الدارمي",
  "بلوغ المرام": "بلوغ المرام",
  "الأربعون النووية": "الأربعون النووية",
  "الأربعون القدسية": "الأربعون القدسية",
  "أربعون ولي الله الدهلوي": "الأربعون لولي الله الدهلوي",
  "الأدب المفرد": "الأدب المفرد",
  "الشمائل المحمدية": "الشمائل المحمدية",
  "حصن المسلم": "حصن المسلم",
  "الأربعون الرياضية": "الأربعون الرياضية",
};

const Map<String, String> bookImages = {
  "Sahih Bukhari": "assets/images/book_covers/sahih-bukhari.jpeg",
  "Sahih Muslim": "assets/images/book_covers/sahih-muslim.jpeg",
  "Jami' Al-Tirmidhi": "assets/images/book_covers/al-tirmidhi.jpeg",
  "Sunan Abu Dawood": "assets/images/book_covers/abu-dawood.jpeg",
  "Sunan Ibn-e-Majah": "assets/images/book_covers/ibn-e-majah.jpeg",
  "Sunan An-Nasa`i": "assets/images/book_covers/sunan-nasai.jpeg",
  "Mishkat Al-Masabih": "assets/images/book_covers/mishkat.jpeg",
  "رياض الصالحين": "assets/images/book_covers/riyad_assalihin.jpeg",
  "موطأ مالك": "assets/images/book_covers/malik.jpeg",
  "سنن الدارمي": "assets/images/book_covers/darimi.jpeg",
  "بلوغ المرام": "assets/images/book_covers/bulugh_al_maram.jpeg",
  "الأربعون النووية": "assets/images/book_covers/nawawi40.jpeg",
  "الأربعون القدسية": "assets/images/book_covers/ahadith_qudsi.jpg",
  "أربعون ولي الله الدهلوي": "assets/images/book_covers/shahwaliullah40.jpeg",
  "الأدب المفرد": "assets/images/book_covers/aladab_almufrad.jpeg",
  "الشمائل المحمدية": "assets/images/book_covers/shamail_muhammadiyah.jpeg",
  "حصن المسلم": "assets/images/book_covers/hisnul_muslim.jpeg",
  "الأربعون الرياضية": "assets/images/book_covers/riyadiah40.jpeg",
};

class ApiErrors {
  static const String badRequestError = "badRequestError";
  static const String noContent = "noContent";
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String conflictError = "conflictError";
  static const String internalServerError = "internalServerError";
  static const String unknownError = "unknownError";
  static const String timeoutError = "timeoutError";
  static const String defaultError = "defaultError";
  static const String cacheError = "cacheError";
  static const String noInternetError = "noInternetError";
  static const String loadingMessage = "loading_message";
  static const String retryAgainMessage = "retry_again_message";
  static const String ok = "Ok";
}

final Map<String, String> booksMap = {
  'صحيح البخاري': 'sahih-bukhari',
  'صحيح مسلم': 'sahih-muslim',
  'سنن أبي داود': 'abu-dawood',
  'سنن الترمذي': 'al-tirmidhi',
  'سنن النسائي': 'sunan-nasai',
  'سنن ابن ماجة': 'ibn-e-majah',
  'موطأ مالك': 'malik',
  'مسند أحمد': 'musnad-ahmad',
  'سنن الدارمي': 'darimi',
  'بلوغ المرام': 'bulugh_al_maram',
  'رياض الصالحين': 'riyad_assalihin',
  'مشكات المصابيح': 'mishkat',
  'الأربعون النووية': 'nawawi40',
  'الأربعون القدسية': 'qudsi40',
  'أربعون ولي الله الدهلوي': 'shahwaliullah40',
  'الأدب المفرد': 'aladab_almufrad',
  'الشمائل المحمدية': 'shamail_muhammadiyah',
  'حصن المسلم': 'hisnul_muslim',
  'الاربعون الرياضية': 'riyadiah40',
};
