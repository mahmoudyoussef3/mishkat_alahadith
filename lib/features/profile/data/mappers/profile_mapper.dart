import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_stats.dart';
import '../models/stats_model.dart';
import '../models/user_response_model.dart';

extension UserResponseModelMapper on UserResponseModel {
  UserProfile toEntity() => UserProfile(
    id: id,
    username: username,
    email: email,
    role: role,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
    bonusPoints: bonusPoints,
    weeklyAchievementCount: weeklyAchievementCount,
    lastWhiteDaysFastingDate: lastWhiteDaysFastingDate,
    whiteDaysFastingStreak: whiteDaysFastingStreak,
    whiteDaysFastingSubscription: whiteDaysFastingSubscription,
    dailyHadithEmailEnabled: dailyHadithEmailEnabled,
  );

  UserResponseModel withoutSecrets() => UserResponseModel(
    id: id,
    username: username,
    email: email,
    role: role,
    googleId: googleId,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
    bonusPoints: bonusPoints,
    weeklyAchievementCount: weeklyAchievementCount,
    lastWhiteDaysFastingDate: lastWhiteDaysFastingDate,
    whiteDaysFastingStreak: whiteDaysFastingStreak,
    whiteDaysFastingSubscription: whiteDaysFastingSubscription,
    dailyHadithEmailEnabled: dailyHadithEmailEnabled,
  );
}

extension StatsModelMapper on StatsModel {
  UserStats toEntity() => UserStats(
    bookmarksCount: bookmarksCount,
    collectionsCount: collectionsCount,
    cardsCount: cardsCount,
    searchesCount: searchesCount,
    lastActivityAt: lastActivityAt,
    topCollections: [
      for (final collection in topCollections ?? const <TopCollection>[])
        TopCollectionStat(name: collection.name, count: collection.count),
    ],
  );
}
