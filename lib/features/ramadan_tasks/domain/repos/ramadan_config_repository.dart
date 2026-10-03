abstract class RamadanConfigRepository {
  Future<void> initializeRemoteConfig();

  int getRamadanStartOffset();

  int getRamadanTotalDays();

  String getRamadanStartGregorian();
}
