import 'package:json_annotation/json_annotation.dart';

part 'search_history_models.g.dart';

/// -----------------------------
/// إضافة بحث جديد (Request)
/// -----------------------------
@JsonSerializable()
class AddSearchRequest {
  final String title;
  final String time;
  final String date;
  @JsonKey(name: 'search_type')
  final String? searchType;
  @JsonKey(name: 'results_count')
  final int? resultsCount;

  AddSearchRequest({
    required this.title,
    required this.time,
    required this.date,
    this.searchType,
    this.resultsCount,
  });

  factory AddSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$AddSearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddSearchRequestToJson(this);
}

/// -----------------------------
/// إضافة بحث جديد (Response)
/// -----------------------------
@JsonSerializable()
class AddSearchResponse {
  final bool success;
  final String message;
  final AddSearchData data;

  AddSearchResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$AddSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddSearchResponseToJson(this);
}

@JsonSerializable()
class AddSearchData {
  final int id;

  AddSearchData({required this.id});

  factory AddSearchData.fromJson(Map<String, dynamic> json) =>
      _$AddSearchDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddSearchDataToJson(this);
}

/// -----------------------------
/// عنصر من تاريخ البحث
/// -----------------------------
@JsonSerializable()
class SearchHistoryItem {
  final int id;
  final String title;


  final String time;
  final String date;
  @JsonKey(name: 'created_at')
  final String createdAt;


  SearchHistoryItem({
    required this.id,
    required this.title,

    required this.time,
    required this.date,
    required this.createdAt,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryItemToJson(this);
}

/// -----------------------------
/// Pagination model
/// -----------------------------
@JsonSerializable()
class Pagination {
  final int total;
  final int limit;
  final int offset;
  @JsonKey(name: 'hasMore')
  final bool hasMore;

  Pagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

/// -----------------------------
/// Response جلب تاريخ البحث
/// -----------------------------
@JsonSerializable()
class GetSearchHistoryResponse {
  final bool success;
  final List<SearchHistoryItem> data;
  final Pagination pagination;

  GetSearchHistoryResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory GetSearchHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSearchHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetSearchHistoryResponseToJson(this);
}

/// -----------------------------
/// إحصائيات البحث
/// -----------------------------
@JsonSerializable()
class SearchStatsResponse {
  final bool success;
  final SearchStatsData data;

  SearchStatsResponse({required this.success, required this.data});

  factory SearchStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchStatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchStatsResponseToJson(this);
}

@JsonSerializable()
class SearchStatsData {
  @JsonKey(name: 'total_searches')
  final int totalSearches;
  @JsonKey(name: 'recent_searches')
  final int recentSearches;
  @JsonKey(name: 'top_searches')
  final List<TopSearch> topSearches;
  @JsonKey(name: 'search_types')
  final List<SearchTypeCount> searchTypes;
  @JsonKey(name: 'daily_stats')
  final List<DailyStat> dailyStats;
  @JsonKey(name: 'period_days')
  final int periodDays;

  SearchStatsData({
    required this.totalSearches,
    required this.recentSearches,
    required this.topSearches,
    required this.searchTypes,
    required this.dailyStats,
    required this.periodDays,
  });

  factory SearchStatsData.fromJson(Map<String, dynamic> json) =>
      _$SearchStatsDataFromJson(json);

  Map<String, dynamic> toJson() => _$SearchStatsDataToJson(this);
}

@JsonSerializable()
class TopSearch {
  final String title;
  final int count;

  TopSearch({required this.title, required this.count});

  factory TopSearch.fromJson(Map<String, dynamic> json) =>
      _$TopSearchFromJson(json);

  Map<String, dynamic> toJson() => _$TopSearchToJson(this);
}

@JsonSerializable()
class SearchTypeCount {
  @JsonKey(name: 'search_type')
  final String searchType;
  final int count;

  SearchTypeCount({required this.searchType, required this.count});

  factory SearchTypeCount.fromJson(Map<String, dynamic> json) =>
      _$SearchTypeCountFromJson(json);

  Map<String, dynamic> toJson() => _$SearchTypeCountToJson(this);
}

@JsonSerializable()
class DailyStat {
  final String date;
  final int count;

  DailyStat({required this.date, required this.count});

  factory DailyStat.fromJson(Map<String, dynamic> json) =>
      _$DailyStatFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStatToJson(this);
}

/// -----------------------------
/// حذف بحث محدد
/// -----------------------------
@JsonSerializable()
class DeleteSearchResponse {
  final bool success;
  final String message;

  DeleteSearchResponse({
    required this.success,
    required this.message,
  });

  factory DeleteSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteSearchResponseToJson(this);
}

/// -----------------------------
/// حذف كل تاريخ البحث
/// -----------------------------
@JsonSerializable()
class DeleteAllSearchResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'deleted_count')
  final int deletedCount;

  DeleteAllSearchResponse({
    required this.success,
    required this.message,
    required this.deletedCount,
  });

  factory DeleteAllSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteAllSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAllSearchResponseToJson(this);
}
