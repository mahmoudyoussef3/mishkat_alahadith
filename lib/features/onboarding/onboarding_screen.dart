import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

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


  // Your custom primary color with related palette
  static const Color primaryPurple = Color(0xFF7440E9);
  static const Color lightPurple = Color(0xFF9B6FFF);
 
final List<OnboardingPage> _onboardingPages = [
  OnboardingPage(
    title: 'مشكاة الأحاديث',
    subtitle: 'مكتبة حديثية بين يديك',
    description:
        'استكشف 17 كتاباً من أمهات كتب الحديث مثل صحيح البخاري، مسلم، أبي داود، الترمذي، النسائي، وابن ماجه، والمزيد.',
    imageUrl: 'assets/images/first_onboardin.jpeg',
    icon: Icons.auto_stories_outlined,
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [primaryPurple, lightPurple],
    ),
  ),
  OnboardingPage(
    title: 'سراج - مساعدك الذكي',
    subtitle: 'شرح فوري مدعوم بالذكاء الاصطناعي',
    description:
        'اقرأ الحديث واحصل على شرح سريع ومبسط، واسأل "سراج" عن أي تفاصيل إضافية لفهم النصوص بعمق.',
    imageUrl: 'assets/images/serag_logo.jpg',
    icon: Icons.smart_toy_outlined,
   gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [primaryPurple, lightPurple],
    ),
  ),
  OnboardingPage(
    title: 'بحث متقدم',
    subtitle: 'العثور على أي حديث بسهولة',
    description:
        'ابحث في نصوص الأحاديث، أسماء الرواة، الأبواب والكتب مع نتائج دقيقة وخيارات فلترة ذكية.',
    imageUrl:
        'assets/images/search_logo.jpg',
    icon: Icons.search_outlined,
   gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [primaryPurple, lightPurple],
    ),
  ),
];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
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
    Future.delayed(const Duration(milliseconds: 50), () {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                _onboardingPages[_currentPage].gradient.colors.first
                    .withOpacity(0.08),
                Colors.white,
                _onboardingPages[_currentPage].gradient.colors.last.withOpacity(
                  0.03,
                ),
              ],
            ),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and app name
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple, primaryPurple.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'مشكاة الأحاديث',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryPurple,
                ),
              ),
            ],
          ),

          // Skip button
          TextButton(
            onPressed: _getStarted,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              'تخطي',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              _buildImageSection(page),
              SizedBox(height: 24.h),
              _buildTextContent(page),
              SizedBox(height: 20.h),
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
          top: 40.h,
          right: 30.w,
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: page.gradient,
              //    opacity: 0.2,
            ),
          ),
        ),
        Positioned(
          bottom: 60.h,
          left: 20.w,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: page.gradient,
//opacity: 0.15,
            ),
          ),
        ),

        // Islamic pattern background
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.r),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.r),
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
                        width: 260.w,
                        height: 260.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: page.gradient,
                          boxShadow: [
                            BoxShadow(
                              color: page.gradient.colors.first.withOpacity(
                                0.3,
                              ),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
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
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      page.gradient.colors.first.withOpacity(
                                        0.7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Icon overlay
                              Positioned(
                                bottom: 20.h,
                                right: 20.w,
                                child: Container(
                                  width: 56.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    page.icon,
                                    color: page.gradient.colors.first,
                                    size: 28.sp,
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
    final isSmallScreen = screenHeight < 700;

    return Column(
      children: [
        Text(
          page.title,
          style: TextStyle(
            fontSize: isSmallScreen ? 20.sp : 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: isSmallScreen ? 8.h : 12.h),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.w : 20.w,
            vertical: isSmallScreen ? 6.h : 8.h,
          ),
          decoration: BoxDecoration(
            gradient: page.gradient,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            page.subtitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 14.sp : 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: isSmallScreen ? 12.h : 16.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            page.description,
            style: TextStyle(
              fontSize: isSmallScreen ? 13.sp : 15.sp,
              color: const Color(0xFF718096),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: isSmallScreen ? 3 : 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(24.w),
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

          SizedBox(height: 32.h),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (_currentPage > 0)
                TextButton.icon(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'السابق',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                SizedBox(width: 80.w),

              Container(
                decoration: BoxDecoration(
                  gradient: _onboardingPages[_currentPage].gradient,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: _onboardingPages[_currentPage]
                          .gradient
                          .colors
                          .first
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _onboardingPages.length - 1
                            ? 'ابدأ الآن'
                            : 'التالي',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        _currentPage == _onboardingPages.length - 1
                            ? Icons.rocket_launch_outlined
                            : Icons.arrow_forward_ios,
                        size: 16.sp,
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
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 32.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        gradient: isActive ? _onboardingPages[_currentPage].gradient : null,
        color: isActive ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: _onboardingPages[_currentPage].gradient.colors.first
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
                : null,
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
