import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/onboarding_decorations.dart';
import 'package:mishkat_almasabih/core/theming/onboarding_styles.dart';

import 'sava_date_for_first_time.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  final List<OnboardingPage> _onboardingPages = [
    OnboardingPage(
      title: 'مشكاة الأحاديث',
      subtitle: 'مكتبة حديثية بين يديك',
      description:
          'استكشف 17 كتاباً من أمهات كتب الحديث مثل صحيح البخاري، مسلم، أبي داود، الترمذي، النسائي، وابن ماجه، والمزيد.',
      imageUrl: 'assets/images/first_onboardin.jpeg',
      icon: Icons.auto_stories_outlined,
      gradient: OnboardingDecorations.primaryGradient(),
    ),
    OnboardingPage(
      title: 'سراج - مساعدك الذكي',
      subtitle: 'شرح فوري مدعوم بالذكاء الاصطناعي',
      description:
          'اقرأ الحديث واحصل على شرح سريع ومبسط، واسأل "سراج" عن أي تفاصيل إضافية لفهم النصوص بعمق.',
      imageUrl: 'assets/images/serag_logo.jpg',
      icon: Icons.smart_toy_outlined,
      gradient: OnboardingDecorations.primaryGradient(),
    ),
    OnboardingPage(
      title: 'بحث متقدم',
      subtitle: 'العثور على أي حديث بسهولة',
      description:
          'ابحث في نصوص الأحاديث، أسماء الرواة، الأبواب والكتب مع نتائج دقيقة وخيارات فلترة ذكية.',
      imageUrl: 'assets/images/search_logo.jpg',
      icon: Icons.search_outlined,
      gradient: OnboardingDecorations.primaryGradient(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: OnboardingDecorations.animationDuration,
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: OnboardingDecorations.pageChangeDuration,
        curve: OnboardingDecorations.pageChangeCurve,
      );
    } else {
      _getStarted();
    }
  }

  void _getStarted() async {
    await SaveDataForFirstTime.setNotFirstTime();

    context.pushNamed(Routes.loginScreen);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _animationController.reset();
    Future.delayed(OnboardingDecorations.animationResetDelay, () {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: OnboardingDecorations.scaffoldBackgroundDecoration(
            _onboardingPages[_currentPage].gradient,
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingPages[index]);
                  },
                ),
              ),

              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: OnboardingDecorations.headerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and app name
          Row(
            children: [
              Container(
                width: OnboardingDecorations.logoWidth,
                height: OnboardingDecorations.logoHeight,
                decoration: OnboardingDecorations.logoContainerDecoration(),
                child: Icon(
                  OnboardingDecorations.logoIcon,
                  color: OnboardingDecorations.logoIconColor,
                  size: OnboardingDecorations.logoIconSize,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'مشكاة الأحاديث',
                style: OnboardingTextStyles.appNameStyle(
                  OnboardingDecorations.primaryPurple,
                ),
              ),
            ],
          ),

          // Skip button
          TextButton(
            onPressed: _getStarted,
            style: OnboardingDecorations.skipButtonStyle(),
            child: Text('تخطي', style: OnboardingTextStyles.skipButtonStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: OnboardingDecorations.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: OnboardingDecorations.spacingAtTopOfPage),
                _buildImageSection(page),
                SizedBox(height: OnboardingDecorations.spacingAfterImage),
                _buildTextContent(page),
                SizedBox(height: OnboardingDecorations.spacingAfterText),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(OnboardingPage page) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background decorative circles
        Positioned(
          top: OnboardingDecorations.largeCircleTop,
          right: OnboardingDecorations.largeCircleRight,
          child: Container(
            width: OnboardingDecorations.largeCircleSize,
            height: OnboardingDecorations.largeCircleSize,
            decoration: OnboardingDecorations.decorativeCircleDecoration(
              page.gradient,
            ),
          ),
        ),
        Positioned(
          bottom: OnboardingDecorations.smallCircleBottom,
          left: OnboardingDecorations.smallCircleLeft,
          child: Container(
            width: OnboardingDecorations.smallCircleSize,
            height: OnboardingDecorations.smallCircleSize,
            decoration: OnboardingDecorations.decorativeCircleDecoration(
              page.gradient,
            ),
          ),
        ),

        // Islamic pattern background
        Container(
          width: double.infinity,
          decoration: OnboardingDecorations.islamicPatternContainerDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              OnboardingDecorations.imageBorderRadius,
            ),
            child: Stack(
              children: [
                // Pattern overlay

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main image container
                      Container(
                        width: OnboardingDecorations.mainImageWidth,
                        height: OnboardingDecorations.mainImageHeight,
                        decoration:
                            OnboardingDecorations.mainImageContainerDecoration(
                              page.gradient,
                            ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            OnboardingDecorations.imageBorderRadius,
                          ),
                          child: Stack(
                            children: [
                              // Image
                              Container(
                                width: double.infinity,
                                //    height: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        page.imageUrl.contains('https')
                                            ? NetworkImage(page.imageUrl)
                                            : AssetImage(page.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // Gradient overlay
                              Container(
                                width: double.infinity,
                                //  height: double.infinity,
                                decoration:
                                    OnboardingDecorations.imageGradientOverlayDecoration(
                                      page.gradient,
                                    ),
                              ),

                              // Icon overlay
                              Positioned(
                                bottom: OnboardingDecorations.iconOverlayBottom,
                                right: OnboardingDecorations.iconOverlayRight,
                                child: Container(
                                  width: OnboardingDecorations.iconOverlayWidth,
                                  height:
                                      OnboardingDecorations.iconOverlayHeight,
                                  decoration:
                                      OnboardingDecorations.iconOverlayContainerDecoration(),
                                  child: Icon(
                                    page.icon,
                                    color: page.gradient.colors.first,
                                    size:
                                        OnboardingDecorations
                                            .iconOverlayIconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(OnboardingPage page) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen =
        screenHeight < OnboardingDecorations.smallScreenThreshold;

    return Column(
      children: [
        Text(
          page.title,
          style: OnboardingTextStyles.pageTitleStyle(isSmallScreen),
          textAlign: TextAlign.center,
          maxLines: OnboardingDecorations.titleMaxLines,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(
          height:
              isSmallScreen
                  ? OnboardingDecorations.spacingAfterTitleSmall
                  : OnboardingDecorations.spacingAfterTitleNormal,
        ),

        Container(
          padding:
              isSmallScreen
                  ? OnboardingDecorations.subtitlePaddingSmall
                  : OnboardingDecorations.subtitlePaddingNormal,
          decoration: OnboardingDecorations.subtitleContainerDecoration(
            page.gradient,
          ),
          child: Text(
            page.subtitle,
            style: OnboardingTextStyles.pageSubtitleStyle(isSmallScreen),
            textAlign: TextAlign.center,
            maxLines: OnboardingDecorations.subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(
          height:
              isSmallScreen
                  ? OnboardingDecorations.spacingAfterSubtitleSmall
                  : OnboardingDecorations.spacingAfterSubtitleNormal,
        ),

        Padding(
          padding: OnboardingDecorations.descriptionPadding,
          child: Text(
            page.description,
            style: OnboardingTextStyles.pageDescriptionStyle(isSmallScreen),
            textAlign: TextAlign.center,
            maxLines:
                isSmallScreen
                    ? OnboardingDecorations.descriptionMaxLinesSmall
                    : OnboardingDecorations.descriptionMaxLinesNormal,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: OnboardingDecorations.bottomNavigationPadding,
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingPages.length,
              (index) => _buildPageIndicator(index),
            ),
          ),

          SizedBox(
            height: OnboardingDecorations.spacingBetweenIndicatorsAndButtons,
          ),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (_currentPage > 0)
                TextButton.icon(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: OnboardingDecorations.backButtonDuration,
                      curve: OnboardingDecorations.backButtonCurve,
                    );
                  },
                  icon: Icon(
                    OnboardingDecorations.backButtonIcon,
                    size: OnboardingDecorations.backButtonIconSize,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'السابق',
                    style: OnboardingTextStyles.backButtonStyle,
                  ),
                )
              else
                SizedBox(width: OnboardingDecorations.backButtonFallbackWidth),

              Container(
                decoration: OnboardingDecorations.nextButtonDecoration(
                  _onboardingPages[_currentPage].gradient,
                ),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: OnboardingDecorations.nextButtonStyle(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _onboardingPages.length - 1
                            ? 'ابدأ الآن'
                            : 'التالي',
                        style: OnboardingTextStyles.nextButtonStyle,
                      ),
                      SizedBox(
                        width: OnboardingDecorations.nextButtonIconSpacing,
                      ),
                      Icon(
                        _currentPage == _onboardingPages.length - 1
                            ? OnboardingDecorations.startIcon
                            : OnboardingDecorations.nextIcon,
                        size: OnboardingDecorations.nextButtonIconSize,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: OnboardingDecorations.indicatorAnimationDuration,
      curve: OnboardingDecorations.indicatorAnimationCurve,
      margin: OnboardingDecorations.indicatorMargin,
      width:
          isActive
              ? OnboardingDecorations.activeIndicatorWidth
              : OnboardingDecorations.inactiveIndicatorWidth,
      height: OnboardingDecorations.indicatorHeight,
      decoration:
          isActive
              ? OnboardingDecorations.activeIndicatorDecoration(
                _onboardingPages[_currentPage].gradient,
              )
              : BoxDecoration(
                color: OnboardingDecorations.inactiveIndicatorColor,
                borderRadius: BorderRadius.circular(
                  OnboardingDecorations.indicatorBorderRadius,
                ),
              ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final IconData icon;
  final Gradient gradient;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.icon,
    required this.gradient,
  });
}
