import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/bookmark/ui/screens/bookmark_screen.dart';
import 'package:mishkat_almasabih/features/home/ui/home_screen.dart';
import 'package:mishkat_almasabih/features/profile/ui/profile_screen.dart';
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
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}

class AddCredit implements NotificationHandler {
  @override
  void handleOnTap() {
    // Use the navigation service to navigate to profile tab
  //  NavigationService().navigateToProfile();
  }
}

class CheckCart implements NotificationHandler {
  @override
  void handleOnTap() {
    // Navigate to the cart screen
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }
}

class CheckFavorite implements NotificationHandler {
  @override
  void handleOnTap() {
    // Navigate to the favorite screen
 //   NavigationService().navigateToFavorite();
  }
}