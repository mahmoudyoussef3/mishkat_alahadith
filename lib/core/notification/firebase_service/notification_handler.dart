import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/ui/screens/bookmark_screen.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/profile/presentation/ui/profile_screen.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


abstract class NotificationHandler {
  void handleOnTap();
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
