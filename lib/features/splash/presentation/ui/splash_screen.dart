import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/splash_styles.dart';
import 'package:mishkat_almasabih/core/theming/splash_decorations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startAnimations();
    _navigateToNextScreen();
  }

  void _initializeControllers() {
    _fadeController = AnimationController(
      duration: SplashDecorations.fadeAnimationDuration,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: SplashDecorations.scaleAnimationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: SplashDecorations.slideAnimationDuration,
      vsync: this,
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _timers.add(
      Timer(SplashDecorations.scaleAnimationDelay, _scaleController.forward),
    );
    _timers.add(
      Timer(SplashDecorations.slideAnimationDelay, _slideController.forward),
    );
  }

  void _navigateToNextScreen() {
    _timers.add(Timer(SplashDecorations.navigationDelay, _replaceWithHome));
  }

  void _replaceWithHome() {
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    if (route == null || route.isCurrent) {
      navigator.pushReplacementNamed(Routes.homeScreen);
      return;
    }
    // Already on its way out (e.g. a hadith link reset the stack).
    if (!route.isActive) return;

    // Something opened over the splash (a hadith link, a widget tap). Put
    // Home in the splash's place beneath it; pushReplacementNamed would
    // replace that screen instead.
    final home = navigator.widget.onGenerateRoute?.call(
      const RouteSettings(name: Routes.homeScreen),
    );
    if (home != null) navigator.replace(oldRoute: route, newRoute: home);
  }

  @override
  void dispose() {
    // Timers must not fire into disposed controllers or a dead context.
    for (final timer in _timers) {
      timer.cancel();
    }
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status bar icons over the violet background.
      value: AppTheme.systemBarsStyle(Brightness.dark),
      child: Scaffold(
        backgroundColor: SplashDecorations.scaffoldBackground,
        body: Container(
          decoration: SplashDecorations.backgroundGradient(),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoSection(),

                    SizedBox(height: SplashDecorations.spacingAfterLogo),

                    _buildAppNameSection(),

                    SizedBox(height: SplashDecorations.spacingAfterAppName),

                    _buildLoadingIndicator(),
                  ],
                ),
              ),

              SizedBox(height: SplashDecorations.bottomSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
          width: SplashDecorations.logoContainerSize,
          height: SplashDecorations.logoContainerSize,
          decoration: SplashDecorations.logoContainer(),
          child: Padding(
            padding: SplashDecorations.logoPadding,
            child: Image.asset(
              SplashDecorations.logoAssetPath,
              fit: BoxFit.contain,
            ),
          ),
        )
        .animate(controller: _scaleController)
        .scale(
          begin: SplashDecorations.logoScaleBegin,
          end: SplashDecorations.logoScaleEnd,
          curve: Curves.elasticOut,
        )
        .then()
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: SplashDecorations.logoShimmerDuration.ms,
          color: SplashDecorations.logoShimmerColor,
        );
  }

  Widget _buildAppNameSection() {
    return Column(
      children: [
        Text(
              SplashTextStyles.appNameText,
              style: SplashTextStyles.appNameArabic,
            )
            .animate(controller: _fadeController)
            .fadeIn(duration: SplashDecorations.appNameFadeInDuration.ms)
            .slideY(
              begin: SplashDecorations.appNameSlideYBegin,
              curve: Curves.easeOut,
            ),

        SizedBox(height: SplashDecorations.spacingAfterDescription),

        Container(
              padding: SplashDecorations.appDescriptionPadding,
              child: Text(
                SplashTextStyles.appDescriptionText,
                style: SplashTextStyles.appDescription,
                textAlign: TextAlign.center,
              ),
            )
            .animate(controller: _fadeController)
            .fadeIn(
              delay: SplashDecorations.appDescriptionFadeInDelay.ms,
              duration: SplashDecorations.appDescriptionFadeInDuration.ms,
            )
            .slideY(
              begin: SplashDecorations.appDescriptionSlideYBegin,
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: SplashDecorations.loadingDotMargin,
              child: Container(
                    width: SplashDecorations.loadingDotSize,
                    height: SplashDecorations.loadingDotSize,
                    decoration: SplashDecorations.loadingDotDecoration(),
                  )
                  .animate(controller: _slideController)
                  .fadeIn(
                    delay: (index * 100).ms,
                    duration: SplashDecorations.loadingDotFadeInDuration.ms,
                  )
                  .scale(begin: SplashDecorations.loadingDotScaleBegin)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: SplashDecorations.loadingDotScaleEnd1,
                    end: SplashDecorations.loadingDotScaleEnd2,
                    duration: SplashDecorations.loadingDotScaleDuration.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: SplashDecorations.loadingDotScaleEnd2,
                    end: SplashDecorations.loadingDotScaleEnd1,
                    duration: SplashDecorations.loadingDotScaleDuration.ms,
                    curve: Curves.easeInOut,
                  ),
            );
          }),
        ),
      ],
    );
  }
}
