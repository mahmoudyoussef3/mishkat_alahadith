class HadithNavigation {
  final String? bookName;
  final String? bookNameEn;
  final NavigationHadithRef? nextHadith;
  final NavigationHadithRef? prevHadith;
  final String? currentHadithNumber;
  final int? totalHadiths;

  const HadithNavigation({
    this.bookName,
    this.bookNameEn,
    this.nextHadith,
    this.prevHadith,
    this.currentHadithNumber,
    this.totalHadiths,
  });
}

class NavigationHadithRef {
  final String? id;
  final String? title;

  const NavigationHadithRef({this.id, this.title});
}
