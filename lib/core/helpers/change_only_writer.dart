import 'dart:async';

/// Writes a value only when it differs from the one last written or read,
/// so a value reported over and over — the ayah on the player as its status
/// changes, say — is written once. Unknown until first [read] or written,
/// so the first write always goes through.
class ChangeOnlyWriter<T> {
  ChangeOnlyWriter(this._write);

  final Future<Object?> Function(T? value) _write;

  T? _value;
  var _known = false;

  /// [value] is what is stored now, as just read.
  void read(T? value) {
    _value = value;
    _known = true;
  }

  /// Stores [value], unless it is what is stored already. Not awaited: a
  /// write that fails leaves the value it replaces, as nothing waits on it.
  void write(T? value) {
    if (_known && value == _value) return;
    _value = value;
    _known = true;
    unawaited(_write(value));
  }
}
