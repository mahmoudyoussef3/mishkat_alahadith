import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/send_suggestion_styles.dart';
import 'package:mishkat_almasabih/core/theming/send_suggestion_decorations.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';
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
          backgroundColor: SendSuggestionDecorations.successSnackbarBackground,
          content: const Text('تم إرسال الاقتراح بنجاح ✓'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SendSuggestionDecorations.errorSnackbarBackground,
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
      backgroundColor: SendSuggestionDecorations.scaffoldBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: SendSuggestionDecorations.backgroundGradient(),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: CustomScrollView(
              slivers: [
                const BuildHeaderAppBar(
                  title: 'إرسال اقتراح',
                  description: 'آراؤكم تهمنا وتساعدنا على التطور',
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40.w : 20.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Card
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 550 : double.infinity,
                            ),
                            child: Card(
                              elevation: SendSuggestionDecorations.cardElevation,
                              shadowColor:
                                  SendSuggestionDecorations.cardShadowColor,
                              shape: SendSuggestionDecorations.cardShape,
                              child: Container(
                                padding: EdgeInsets.all(
                                  isTablet ? 32.w : 24.w,
                                ),
                                decoration:
                                    SendSuggestionDecorations.cardContainer(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Animated Icon
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration:
                                          SendSuggestionDecorations
                                              .iconAnimationDuration,
                                      curve:
                                          SendSuggestionDecorations
                                              .iconAnimationCurve,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        width:
                                            SendSuggestionDecorations
                                                .iconContainerSize(isTablet),
                                        height:
                                            SendSuggestionDecorations
                                                .iconContainerSize(isTablet),
                                        decoration:
                                            SendSuggestionDecorations
                                                .iconContainer(),
                                        child: Icon(
                                          Icons.lightbulb_outline_rounded,
                                          color:
                                              SendSuggestionDecorations
                                                  .iconColor,
                                          size:
                                              SendSuggestionDecorations.iconSize(
                                                isTablet,
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 20.h : 16.h),

                                    // Title
                                    Text(
                                      'شاركنا اقتراحاتك',
                                      textAlign: TextAlign.center,
                                      style:
                                          SendSuggestionTextStyles.title(
                                            isTablet,
                                          ),
                                    ),
                                    SizedBox(height: 8.h),

                                    // Subtitle
                                    Text(
                                      'لتطوير التطبيق 🌿',
                                      textAlign: TextAlign.center,
                                      style:
                                          SendSuggestionTextStyles.subtitle(
                                            isTablet,
                                          ),
                                    ),
                                    SizedBox(height: 12.h),

                                    // Description
                                    Text(
                                      'اقتراحك يساعدنا في تحسين التجربة وتقديم أفضل محتوى',
                                      textAlign: TextAlign.center,
                                      style:
                                          SendSuggestionTextStyles.description(
                                            isTablet,
                                          ),
                                    ),
                                    SizedBox(height: isTablet ? 28.h : 24.h),

                                    // TextField + Privacy Note
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          decoration:
                                              SendSuggestionDecorations
                                                  .textFieldShadowContainer(),
                                          child: TextField(
                                            controller: _ctrl,
                                            maxLines:
                                                screenHeight > 700 ? 6 : 4,
                                            maxLength: 500,
                                            textAlign: TextAlign.right,
                                            decoration: InputDecoration(
                                              hintText: 'اكتب اقتراحك هنا...',
                                              hintStyle:
                                                  SendSuggestionTextStyles
                                                      .textFieldHint(isTablet),
                                              filled: true,
                                              fillColor:
                                                  SendSuggestionDecorations
                                                      .textFieldFillColor,
                                              enabledBorder:
                                                  SendSuggestionDecorations
                                                      .textFieldEnabledBorder(),
                                              focusedBorder:
                                                  SendSuggestionDecorations
                                                      .textFieldFocusedBorder(),
                                              contentPadding:
                                                  SendSuggestionDecorations
                                                      .textFieldPadding,
                                              counterStyle:
                                                  SendSuggestionTextStyles
                                                      .textFieldCounter,
                                            ),
                                            style:
                                                SendSuggestionTextStyles
                                                    .textFieldInput(isTablet),
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          'لن يتم إرسال بريدك الإلكتروني أو اسم المستخدم، مجرد اقتراحك فقط.',
                                          textAlign: TextAlign.right,
                                          style:
                                              SendSuggestionTextStyles
                                                  .privacyNote(isTablet),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isTablet ? 28.h : 24.h),

                                    // Send Button
                                    SizedBox(
                                      height:
                                          SendSuggestionDecorations
                                              .sendButtonHeight(isTablet),
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _onSend,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              SendSuggestionDecorations
                                                  .sendButtonBackground,
                                          foregroundColor:
                                              SendSuggestionDecorations
                                                  .sendButtonForeground,
                                          disabledBackgroundColor:
                                              SendSuggestionDecorations
                                                  .sendButtonDisabledBackground,
                                          shape:
                                              SendSuggestionDecorations
                                                  .sendButtonShape,
                                          elevation:
                                              SendSuggestionDecorations
                                                  .sendButtonElevation,
                                          shadowColor:
                                              SendSuggestionDecorations
                                                  .sendButtonShadowColor,
                                        ),
                                        child:
                                            _loading
                                                ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          SendSuggestionDecorations
                                                              .loadingIndicatorSize,
                                                      height:
                                                          SendSuggestionDecorations
                                                              .loadingIndicatorSize,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth:
                                                            SendSuggestionDecorations
                                                                .loadingIndicatorStrokeWidth,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              SendSuggestionDecorations
                                                                  .loadingIndicatorColor,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Text(
                                                      'جارٍ الإرسال...',
                                                      style:
                                                          SendSuggestionTextStyles
                                                              .sendButtonLoadingText(
                                                                isTablet,
                                                              ),
                                                    ),
                                                  ],
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.send_rounded,
                                                      size:
                                                          SendSuggestionDecorations
                                                              .sendButtonIconSize(
                                                                isTablet,
                                                              ),
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Text(
                                                      'إرسال الاقتراح',
                                                      style:
                                                          SendSuggestionTextStyles
                                                              .sendButtonText(
                                                                isTablet,
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

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
