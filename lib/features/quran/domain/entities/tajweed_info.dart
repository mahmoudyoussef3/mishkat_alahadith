/// Rule keys the domain refers to by name.
abstract final class TajweedRuleKeys {
  /// The natural madd: far the most frequent rule, so it has its own switch.
  static const String naturalMadd = 'maddNatural';
}

/// How many words on a page carry one tajweed rule.
///
/// [ruleKey] is the rule's stable identifier (the `TajweedRule` enum name in
/// the rendering package), so the domain stays free of any UI type.
class TajweedRuleCount {
  final String ruleKey;
  final int count;

  const TajweedRuleCount({required this.ruleKey, required this.count});
}

/// One tajweed rule over `[start, end)` of an ayah's text, in UTF-16 units.
class TajweedSegment {
  final int start;
  final int end;
  final String ruleKey;

  const TajweedSegment({
    required this.start,
    required this.end,
    required this.ruleKey,
  });
}
