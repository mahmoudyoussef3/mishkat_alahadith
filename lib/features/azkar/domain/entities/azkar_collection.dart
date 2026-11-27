/// Themes the chapters of Hisn Al-Muslim are grouped under for browsing.
/// Every chapter belongs to exactly one.
enum AzkarCollection {
  dayAndNight({27, 28, 1, 29, 30, 31}),
  prayer({
    6, 7, 8, 9, 12, 13, 14, 15, 16, 17, 18, //
    19, 20, 21, 22, 23, 24, 25, 26, 32, 33,
  }),
  homeAndClothing({2, 3, 4, 5, 10, 11}),
  distress({
    34, 35, 36, 37, 38, 39, 40, 41, 42, 43, //
    44, 45, 46, 88, 92, 94, 125, 126, 128,
  }),
  illness({49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 124}),
  nature({61, 62, 63, 64, 65, 66, 67, 110, 111}),
  food({68, 69, 70, 71, 72, 73, 74, 75, 76}),
  social({
    47, 48, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, //
    89, 90, 91, 93, 106, 108, 109, 112, 113, 114, 122, 123,
  }),
  travel({95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105}),
  hajj({115, 116, 117, 118, 119, 120, 121, 127}),
  remembrance({107, 129, 130, 131, 132});

  const AzkarCollection(this.categoryIds);

  final Set<int> categoryIds;

  bool contains(int categoryId) => categoryIds.contains(categoryId);
}
