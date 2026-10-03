abstract class HijriRepository {
  Future<void> initializeRemoteConfig();

  int getHijriDateOffset();
}
