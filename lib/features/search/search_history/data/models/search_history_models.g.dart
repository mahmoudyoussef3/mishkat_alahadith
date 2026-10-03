// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddSearchRequest _$AddSearchRequestFromJson(Map<String, dynamic> json) =>
    AddSearchRequest(
      title: json['title'] as String,
      time: json['time'] as String,
      date: json['date'] as String,
      searchType: json['search_type'] as String?,
      resultsCount: (json['results_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AddSearchRequestToJson(AddSearchRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'time': instance.time,
      'date': instance.date,
      'search_type': instance.searchType,
      'results_count': instance.resultsCount,
    };

AddSearchResponse _$AddSearchResponseFromJson(Map<String, dynamic> json) =>
    AddSearchResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: AddSearchData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddSearchResponseToJson(AddSearchResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AddSearchData _$AddSearchDataFromJson(Map<String, dynamic> json) =>
    AddSearchData(id: (json['id'] as num).toInt());

Map<String, dynamic> _$AddSearchDataToJson(AddSearchData instance) =>
    <String, dynamic>{'id': instance.id};

SearchHistoryItem _$SearchHistoryItemFromJson(Map<String, dynamic> json) =>
    SearchHistoryItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      time: json['time'] as String,
      date: json['date'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SearchHistoryItemToJson(SearchHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'time': instance.time,
      'date': instance.date,
      'created_at': instance.createdAt,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  total: (json['total'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'total': instance.total,
      'limit': instance.limit,
      'offset': instance.offset,
      'hasMore': instance.hasMore,
    };

GetSearchHistoryResponse _$GetSearchHistoryResponseFromJson(
  Map<String, dynamic> json,
) => GetSearchHistoryResponse(
  success: json['success'] as bool,
  data:
      (json['data'] as List<dynamic>)
          .map((e) => SearchHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetSearchHistoryResponseToJson(
  GetSearchHistoryResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'pagination': instance.pagination,
};

SearchStatsResponse _$SearchStatsResponseFromJson(Map<String, dynamic> json) =>
    SearchStatsResponse(
      success: json['success'] as bool,
      data: SearchStatsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchStatsResponseToJson(
  SearchStatsResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

SearchStatsData _$SearchStatsDataFromJson(Map<String, dynamic> json) =>
    SearchStatsData(
      totalSearches: (json['total_searches'] as num).toInt(),
      recentSearches: (json['recent_searches'] as num).toInt(),
      topSearches:
          (json['top_searches'] as List<dynamic>)
              .map((e) => TopSearch.fromJson(e as Map<String, dynamic>))
              .toList(),
      searchTypes:
          (json['search_types'] as List<dynamic>)
              .map((e) => SearchTypeCount.fromJson(e as Map<String, dynamic>))
              .toList(),
      dailyStats:
          (json['daily_stats'] as List<dynamic>)
              .map((e) => DailyStat.fromJson(e as Map<String, dynamic>))
              .toList(),
      periodDays: (json['period_days'] as num).toInt(),
    );

Map<String, dynamic> _$SearchStatsDataToJson(SearchStatsData instance) =>
    <String, dynamic>{
      'total_searches': instance.totalSearches,
      'recent_searches': instance.recentSearches,
      'top_searches': instance.topSearches,
      'search_types': instance.searchTypes,
      'daily_stats': instance.dailyStats,
      'period_days': instance.periodDays,
    };

TopSearch _$TopSearchFromJson(Map<String, dynamic> json) => TopSearch(
  title: json['title'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$TopSearchToJson(TopSearch instance) => <String, dynamic>{
  'title': instance.title,
  'count': instance.count,
};

SearchTypeCount _$SearchTypeCountFromJson(Map<String, dynamic> json) =>
    SearchTypeCount(
      searchType: json['search_type'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$SearchTypeCountToJson(SearchTypeCount instance) =>
    <String, dynamic>{
      'search_type': instance.searchType,
      'count': instance.count,
    };

DailyStat _$DailyStatFromJson(Map<String, dynamic> json) => DailyStat(
  date: json['date'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$DailyStatToJson(DailyStat instance) => <String, dynamic>{
  'date': instance.date,
  'count': instance.count,
};

DeleteSearchResponse _$DeleteSearchResponseFromJson(
  Map<String, dynamic> json,
) => DeleteSearchResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
);

Map<String, dynamic> _$DeleteSearchResponseToJson(
  DeleteSearchResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

DeleteAllSearchResponse _$DeleteAllSearchResponseFromJson(
  Map<String, dynamic> json,
) => DeleteAllSearchResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  deletedCount: (json['deleted_count'] as num).toInt(),
);

Map<String, dynamic> _$DeleteAllSearchResponseToJson(
  DeleteAllSearchResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'deleted_count': instance.deletedCount,
};
