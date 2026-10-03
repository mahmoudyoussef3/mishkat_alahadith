import '../../domain/entities/hadith_navigation.dart';
import '../models/local_hadith_navigation_model.dart' as local;
import '../models/navigation_hadith_model.dart' as remote;

extension NavigationHadithResponseMapper on remote.NavigationHadithResponse {
  HadithNavigation toEntity() => HadithNavigation(
    bookName: book?.bookName,
    bookNameEn: book?.bookNameEn,
    nextHadith: nextHadith?.toEntity(),
    prevHadith: prevHadith?.toEntity(),
    currentHadithNumber: currentHadithNumber,
    totalHadiths: totalHadiths,
  );
}

extension on remote.Hadith {
  NavigationHadithRef toEntity() => NavigationHadithRef(id: id, title: title);
}

extension LocalNavigationHadithResponseMapper
    on local.LocalNavigationHadithResponse {
  HadithNavigation toEntity() => HadithNavigation(
    bookName: book?.bookName,
    bookNameEn: book?.bookNameEn,
    nextHadith: nextHadith?.toEntity(),
    prevHadith: prevHadith?.toEntity(),
    currentHadithNumber: currentHadithNumber?.toString(),
    totalHadiths: totalHadiths,
  );
}

extension on local.Hadith {
  NavigationHadithRef toEntity() =>
      NavigationHadithRef(id: id?.toString(), title: title);
}
