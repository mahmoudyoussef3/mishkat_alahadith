class UserProfile {
  final int? id;
  final String? username;
  final String? email;
  final String? role;
  final String? avatarUrl;
  final String? createdAt;
  final int? bonusPoints;
  final int? weeklyAchievementCount;
  final String? lastWhiteDaysFastingDate;
  final int? whiteDaysFastingStreak;
  final int? whiteDaysFastingSubscription;
  final int? dailyHadithEmailEnabled;

  const UserProfile({
    this.id,
    this.username,
    this.email,
    this.role,
    this.avatarUrl,
    this.createdAt,
    this.bonusPoints,
    this.weeklyAchievementCount,
    this.lastWhiteDaysFastingDate,
    this.whiteDaysFastingStreak,
    this.whiteDaysFastingSubscription,
    this.dailyHadithEmailEnabled,
  });
}
