import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import '../../core/theming/splash_styles.dart';
import '../../core/theming/splash_decorations.dart';

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
    Future.delayed(SplashDecorations.scaleAnimationDelay, () {
      _scaleController.forward();
    });
    Future.delayed(SplashDecorations.slideAnimationDelay, () {
      _slideController.forward();
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(SplashDecorations.navigationDelay, () {
      Navigator.pushReplacementNamed(context, Routes.homeScreen);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        // Arabic app name
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
        // Animated dots
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
