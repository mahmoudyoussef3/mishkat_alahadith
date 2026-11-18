import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/change_only_writer.dart';

void main() {
  late List<int?> written;
  late ChangeOnlyWriter<int> writer;

  setUp(() {
    written = [];
    writer = ChangeOnlyWriter((value) async => written.add(value));
  });

  test('writes the first value, whatever it is', () {
    writer.write(null);

    expect(written, [null]);
  });

  test('writes a value once however often it is reported', () {
    writer
      ..write(1)
      ..write(1)
      ..write(1);

    expect(written, [1]);
  });

  test('writes each change', () {
    writer
      ..write(1)
      ..write(2)
      ..write(null);

    expect(written, [1, 2, null]);
  });

  test('does not write back what was just read', () {
    writer
      ..read(7)
      ..write(7);

    expect(written, isEmpty);
  });

  test('writes a change from what was read', () {
    writer
      ..read(7)
      ..write(null);

    expect(written, [null]);
  });
}
