import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/send_suggestion/send_suggestion_repo.dart';

class SuggestionForm extends StatefulWidget {
  const SuggestionForm({super.key});

  @override
  State<SuggestionForm> createState() => _SuggestionFormState();
}

class _SuggestionFormState extends State<SuggestionForm> {
  final TextEditingController _ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _onSend() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك اكتب اقتراحك أولًا')),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await SuggestionService().sendSuggestion(text);
    setState(() => _loading = false);

    if (!mounted) return;

    if (ok) {
      _ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorsManager.success,
          content: const Text('تم إرسال الاقتراح بنجاح ✓'),
        ),
      );
  Navigator.of(context).pop();
    } else {


      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorsManager.error,
          content: const Text('فشل إرسال الاقتراح — حاول مرة أخرى'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorsManager.secondaryBackground,
              ColorsManager.lightGray.withOpacity(0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:SafeArea(
              top: false,
        bottom: true,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40.w : 20.w,
                    vertical: 20.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),

                          // Main Card
                          Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 550 : double.infinity,
                              ),
                              child: Card(
                                elevation: 10,
                                shadowColor: ColorsManager.primaryPurple.withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(isTablet ? 32.w : 24.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Animated Icon
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.elasticOut,
                                        builder: (context, value, child) {
                                          return Transform.scale(scale: value, child: child);
                                        },
                                        child: Container(
                                          width: isTablet ? 90.w : 70.w,
                                          height: isTablet ? 90.w : 70.w,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                ColorsManager.primaryPurple.withOpacity(0.15),
                                                ColorsManager.primaryPurple.withOpacity(0.05),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.lightbulb_outline_rounded,
                                            color: ColorsManager.primaryPurple,
                                            size: isTablet ? 45.sp : 35.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 20.h : 16.h),

                                      // Title
                                      Text(
                                        'شاركنا اقتراحاتك',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isTablet ? 26.sp : 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsManager.primaryPurple,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),

                                      // Subtitle
                                      Text(
                                        'لتطوير التطبيق 🌿',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isTablet ? 20.sp : 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: ColorsManager.primaryPurple.withOpacity(0.7),
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),

                                      // Description
                                      Text(
                                        'اقتراحك يساعدنا في تحسين التجربة وتقديم أفضل محتوى',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isTablet ? 15.sp : 14.sp,
                                          color: ColorsManager.gray,
                                          height: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 28.h : 24.h),

                                      // TextField + Privacy Note
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: ColorsManager.white.withOpacity(0.08),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: _ctrl,
                                              maxLines: screenHeight > 700 ? 6 : 4,
                                              maxLength: 500,
                                              textAlign: TextAlign.right,
                                              decoration: InputDecoration(
                                                hintText: 'اكتب اقتراحك هنا...',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: isTablet ? 15.sp : 14.sp,
                                                ),
                                                filled: true,
                                                fillColor: ColorsManager.lightGray.withOpacity(0.1),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16.r),
                                                  borderSide: BorderSide(
                                                    color: ColorsManager.primaryPurple,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16.r),
                                                  borderSide: const BorderSide(
                                                    color: ColorsManager.primaryPurple,
                                                    width: 2,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 14.h,
                                                ),
                                                counterStyle: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: ColorsManager.gray,
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: isTablet ? 16.sp : 15.sp,
                                                height: 1.6,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            'لن يتم إرسال بريدك الإلكتروني أو اسم المستخدم، مجرد اقتراحك فقط.',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: isTablet ? 12.sp : 11.sp,
                                              color: ColorsManager.gray.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isTablet ? 28.h : 24.h),

                                      // Send Button
                                      SizedBox(
                                        height: isTablet ? 56.h : 52.h,
                                        child: ElevatedButton(
                                          onPressed: _loading ? null : _onSend,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: ColorsManager.primaryPurple,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: ColorsManager.primaryPurple.withOpacity(0.6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14.r),
                                            ),
                                            elevation: 3,
                                            shadowColor: ColorsManager.primaryPurple.withOpacity(0.3),
                                          ),
                                          child: _loading
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20.w,
                                                      height: 20.w,
                                                      child: const CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Text(
                                                      'جارٍ الإرسال...',
                                                      style: TextStyle(
                                                        fontSize: isTablet ? 17.sp : 16.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.send_rounded,
                                                      size: isTablet ? 22.sp : 20.sp,
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Text(
                                                      'إرسال الاقتراح',
                                                      style: TextStyle(
                                                        fontSize: isTablet ? 17.sp : 16.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(flex: 2),

                          // Footer note
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              'آراؤكم تهمنا وتساعدنا على التطور',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorsManager.gray.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
