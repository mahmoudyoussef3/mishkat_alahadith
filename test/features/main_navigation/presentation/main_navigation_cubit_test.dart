import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';

void main() {
  test('starts on the home tab', () async {
    final cubit = MainNavigationCubit();

    expect(cubit.state, MainTab.home);

    await cubit.close();
  });

  test('switches to the selected tab', () async {
    final cubit = MainNavigationCubit();

    cubit.select(MainTab.library);

    expect(cubit.state, MainTab.library);
    await cubit.close();
  });

  test('does not re-emit when the current tab is selected again', () async {
    final cubit = MainNavigationCubit()..select(MainTab.saved);
    final emitted = <MainTab>[];
    final subscription = cubit.stream.listen(emitted.add);

    cubit.select(MainTab.saved);
    await Future<void>.delayed(Duration.zero);

    expect(emitted, isEmpty);
    await subscription.cancel();
    await cubit.close();
  });
}
