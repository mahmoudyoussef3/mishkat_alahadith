import '../../domain/entities/search_history_entry.dart';
import '../models/search_history_models.dart';

extension SearchHistoryItemMapper on SearchHistoryItem {
  SearchHistoryEntry toEntity() => SearchHistoryEntry(
    id: id,
    title: title,
    time: time,
    date: date,
    createdAt: createdAt,
  );
}

extension NewSearchHistoryEntryMapper on NewSearchHistoryEntry {
  AddSearchRequest toRequest() => AddSearchRequest(
    title: title,
    time: time,
    date: date,
    searchType: searchType,
    resultsCount: resultsCount,
  );
}
