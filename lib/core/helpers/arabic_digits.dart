/// Reads Arabic-Indic digits (٠‥٩) and the extended ones Persian and Urdu
/// keyboards type (۰‥۹) as Western digits, leaving every other character
/// untouched: «٢٥٥» → «255».
String toWesternDigits(String input) {
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    buffer.writeCharCode(switch (unit) {
      >= 0x0660 && <= 0x0669 => unit - 0x0660 + 0x30,
      >= 0x06F0 && <= 0x06F9 => unit - 0x06F0 + 0x30,
      _ => unit,
    });
  }
  return buffer.toString();
}

/// Writes Western digits as Arabic-Indic ones, leaving every other character
/// untouched: «255» → «٢٥٥».
String toArabicDigits(String input) {
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    buffer.writeCharCode(switch (unit) {
      >= 0x30 && <= 0x39 => unit - 0x30 + 0x0660,
      _ => unit,
    });
  }
  return buffer.toString();
}
