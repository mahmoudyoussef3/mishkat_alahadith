/// How large hadith text is drawn, as a multiple of its designed size.
///
/// Only hadith bodies scale; interface text keeps following the system
/// text-size setting.
enum HadithFontScale {
  small(0.88),
  medium(1.0),
  large(1.14),
  extraLarge(1.3);

  const HadithFontScale(this.factor);

  final double factor;

  bool get isSmallest => this == values.first;

  bool get isLargest => this == values.last;

  /// The next size up, or this one when already the largest.
  HadithFontScale get larger => isLargest ? this : values[index + 1];

  /// The next size down, or this one when already the smallest.
  HadithFontScale get smaller => isSmallest ? this : values[index - 1];
}
