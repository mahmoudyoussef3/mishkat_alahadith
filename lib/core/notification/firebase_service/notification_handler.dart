import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/screens/bookmark_screen.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/profile_screen.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/models/mushaf_reader_args.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The app's navigator once it is built, or null if it is not built within
/// [timeout].
///
/// A notification or widget tap that starts the app arrives before the
/// first screen does, and navigating before then would be lost.
Future<NavigatorState?> readyNavigator({
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (navigatorKey.currentState == null &&
      DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return navigatorKey.currentState;
}

abstract class NotificationHandler {
  void handleOnTap();
}

/// Opens the mushaf on the day's ayah, highlighted — from its notification
/// or from its home screen widget.
class OpenDailyAyah implements NotificationHandler {
  final DailyAyahPayload payload;

  OpenDailyAyah(this.payload);

  @override
  void handleOnTap() => unawaited(open());

  Future<void> open() async {
    final navigator = await readyNavigator();
    // Not awaited: a push completes only when its screen is closed.
    unawaited(
      navigator?.pushNamed(
        Routes.mushafReader,
        arguments: MushafReaderArgs(
          initialPage: payload.page,
          highlightAyahId: payload.ayahId,
          surahNumber: payload.surahNumber,
        ),
      ),
    );
  }
}

/// Opens the mushaf where the reader last stopped, for the daily wird, or
/// the Quran's index before they have read anything.
class OpenQuranWird implements NotificationHandler {
  @override
  void handleOnTap() => unawaited(open());

  Future<void> open() async {
    final lastRead = switch (await getIt<GetLastReadUseCase>()()) {
      ApiSuccess(:final data) => data,
      ApiFailure() => null,
    };
    final navigator = await readyNavigator();
    // Not awaited: a push completes only when its screen is closed.
    unawaited(
      lastRead == null
          ? navigator?.pushNamed(Routes.quranScreen)
          : navigator?.pushNamed(
            Routes.mushafReader,
            arguments: MushafReaderArgs(initialPage: lastRead.page),
          ),
    );
  }
}

class ProjectStatus implements NotificationHandler {
  @override
  void handleOnTap() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const BookmarkScreen()),
    );
  }
}

class OrderStatus implements NotificationHandler {
  @override
  void handleOnTap() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.homeScreen,
      (route) => false,
    );
  }
}

class AddCredit implements NotificationHandler {
  @override
  void handleOnTap() {
  }
}

class CheckCart implements NotificationHandler {
  @override
  void handleOnTap() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }
}

class CheckFavorite implements NotificationHandler {
  @override
  void handleOnTap() {
  }
}
