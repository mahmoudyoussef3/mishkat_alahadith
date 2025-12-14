import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/notification/hadith_refresh_notifier.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:home_widget/home_widget.dart';

class HadithOfTheDayCard extends StatefulWidget {
  final SaveHadithDailyRepo repo;

  const HadithOfTheDayCard({super.key, required this.repo});

  @override
  State<HadithOfTheDayCard> createState() => _HadithOfTheDayCardState();
}

class _HadithOfTheDayCardState extends State<HadithOfTheDayCard> {
  late ValueNotifier<int> _refreshKey;
  final HadithRefreshNotifier _notifier = HadithRefreshNotifier();

  @override
  void initState() {
    super.initState();
    _refreshKey = ValueNotifier<int>(0);

    // ✅ ربط الكارد بالـ Notifier عشان تسمع التحديثات
    _notifier.addListener(_onHadithRefresh);

    debugPrint('🎧 HadithCard: Listening for notification updates');
  }

  @override
  void dispose() {
    // ✅ إزالة الـ Listener قبل الـ dispose
    _notifier.removeListener(_onHadithRefresh);
    _refreshKey.dispose();
    debugPrint('👋 HadithCard: Stopped listening');
    super.dispose();
  }

  /// يتم استدعاؤها تلقائياً لما notification تيجي
  void _onHadithRefresh() {
    debugPrint('🔄 HadithCard: Refresh triggered from notification');
    if (mounted) {
      _refreshKey.value++;
      _updateHadithWidget(); // Call to update the native widget
    }
  }

  /// دالة refresh يدوية (لو حابب تستخدمها من أي مكان)
  void refresh() {
    debugPrint('🔄 HadithCard: Manual refresh');
    _refreshKey.value++;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _refreshKey,
      builder: (context, value, child) {
        return FutureBuilder<NewDailyHadithModel?>(
          key: ValueKey(value),
          future: widget.repo.getHadith(),
          builder: (context, snapshot) {
            // حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryGreen,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
              );
            }

            // حالة الخطأ
            if (snapshot.hasError) {
              debugPrint(
                '❌ HadithCard: Error loading hadith - ${snapshot.error}',
              );
              return Container(
                margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    "حصل خطأ أثناء تحميل الحديث",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final hadith = snapshot.data;

            if (hadith == null) {
              debugPrint('⚠️ HadithCard: No hadith found, fetching default...');
              widget.repo
                  .fetchHadith("65060")
                  .then((fetchedHadith) {
                    if (fetchedHadith != null && mounted) {
                      debugPrint('✅ HadithCard: Default hadith fetched');
                      _refreshKey.value++;
                      _updateHadithWidget(); // Call to update the native widget after fetching default
                    }
                  })
                  .catchError((error) {
                    debugPrint(
                      '❌ HadithCard: Failed to fetch default hadith - $error',
                    );
                  });

              return Container(
                margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "جاري تحميل الحديث...",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ لو فيه حديث جاهز، نعرضه
            debugPrint('📖 HadithCard: Displaying hadith - ${hadith.title}');
            _updateHadithWidget(
              hadithText: hadith.hadeeth,
            ); // Update widget with the displayed hadith
            return GestureDetector(
              onTap:
                  () => context.pushNamed(
                    Routes.hadithOfTheDay,
                    arguments: hadith,
                  ),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: FadeInImage(
                            placeholder: MemoryImage(kTransparentImage),
                            image: const AssetImage(
                              "assets/images/moon-light-shine-through-window-into-islamic-mosque-interior.jpg",
                            ),
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 700),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 20.w,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                color: ColorsManager.secondaryBackground,
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "حديث اليوم",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsManager.secondaryBackground,
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Text(
                              hadith.hadeeth ?? "حديث اليوم",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: ColorsManager.secondaryBackground,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: Colors.white70),
                              ),
                              child: Text(
                                "اقرأ الحديث",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsManager.secondaryBackground,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24.r),
                            bottomLeft: Radius.circular(24.r),
                          ),
                        ),
                        child: Icon(
                          Icons.format_quote,
                          color: ColorsManager.secondaryBackground,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateHadithWidget({String? hadithText}) async {
    // Only update if a hadith text is provided or can be fetched
    if (hadithText != null) {
      await HomeWidget.saveWidgetData<String>('hadith_text', hadithText);
      await HomeWidget.updateWidget(
        name: 'HadithWidgetProvider',
        iOSName: 'HadithWidget',
      );
      debugPrint(
        '⬆️ HomeWidget: Data saved and widget updated with: $hadithText',
      );
    } else {
      final currentHadith = await widget.repo.getHadith();
      if (currentHadith != null) {
        await HomeWidget.saveWidgetData<String>(
          'hadith_text',
          currentHadith.hadeeth,
        );
        await HomeWidget.updateWidget(
          name: 'HadithWidgetProvider',
          iOSName: 'HadithWidget',
        );
        debugPrint(
          '⬆️ HomeWidget: Data saved and widget updated with current hadith: ${currentHadith.hadeeth}',
        );
      }
    }
  }
}
