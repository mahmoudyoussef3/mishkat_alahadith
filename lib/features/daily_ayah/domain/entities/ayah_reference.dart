/// An ayah named the way it is cited: its surah, and its number in it.
class AyahReference {
  final int surah;
  final int ayah;

  const AyahReference(this.surah, this.ayah);

  @override
  bool operator ==(Object other) =>
      other is AyahReference && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => '$surah:$ayah';
}
