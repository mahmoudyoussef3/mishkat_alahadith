import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/zekr_item.dart';
import 'package:mishkat_almasabih/features/daily_zekr/logic/cubit/daily_zekr_cubit.dart';
import 'package:mishkat_almasabih/features/daily_zekr/ui/widgets/zekr_card.dart';
import 'package:mishkat_almasabih/features/home/ui/widgets/build_header_app_bar.dart';

class DailyZekrScreen extends StatelessWidget {
  const DailyZekrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
              top: false,
        bottom: true,
          
          child: CustomScrollView(
            slivers: [
              const BuildHeaderAppBar(
                title: 'الذكر اليومي',
                description: 'نُذَكِّرُكَ بلطف: الأذكار والورد وحديث اليوم',
                pinned: true,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(child: _buildInfoCard()),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(child: _buildDivider()),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
                  child: Text(
                    'اختر ما أنجزته اليوم:',
                    style: TextStyles.headlineMedium.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
              SliverToBoxAdapter(
                child: BlocBuilder<DailyZekrCubit, DailyZekrState>(
                  builder: (context, state) {
                    if (state is DailyZekrLoading ||
                        state is DailyZekrInitial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state is DailyZekrError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            state.message,
                            style: TextStyles.bodyLarge,
                          ),
                        ),
                      );
                    }
                    final items = (state as DailyZekrLoaded).items;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        final content =
                            isWide
                                ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsetsDirectional.only(
                                    start: 16.w,
                                    end: 16.w,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12.w,
                                        mainAxisSpacing: 12.h,
                                        childAspectRatio: 3.6,
                                      ),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    IconData icon;
                                    switch (item.section) {
                                      case ZekrSection.hadithDaily:
                                        icon = Icons.menu_book_rounded;
                                      case ZekrSection.morningAdhkar:
                                        icon = Icons.wb_sunny_rounded;
                                      case ZekrSection.eveningAdhkar:
                                        icon = Icons.nightlight_round;
                                      case ZekrSection.dailyWard:
                                        icon = Icons.menu_book_sharp;
                                    }
                                    return ZekrCard(
                                      title: item.section.title,
                                      description: item.section.description,
                                      checked: item.checked,
                                      leadingIcon: icon,
                                      onTap:
                                          () => context
                                              .read<DailyZekrCubit>()
                                              .toggle(item.section),
                                      onChanged:
                                          (_) => context
                                              .read<DailyZekrCubit>()
                                              .toggle(item.section),
                                    );
                                  },
                                )
                                : Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    start: 16.w,
                                    end: 16.w,
                                  ),
                                  child: Column(
                                    children: [
                                      ...items.map(
                                        (item) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 12.h,
                                          ),
                                          child: ZekrCard(
                                            title: item.section.title,
                                            description:
                                                item.section.description,
                                            checked: item.checked,
                                            leadingIcon: () {
                                              switch (item.section) {
                                                case ZekrSection.hadithDaily:
                                                  return Icons
                                                      .menu_book_rounded;
                                                case ZekrSection.morningAdhkar:
                                                  return Icons.wb_sunny_rounded;
                                                case ZekrSection.eveningAdhkar:
                                                  return Icons.nightlight_round;
                                                case ZekrSection.dailyWard:
                                                  return Icons
                                                      .auto_awesome_rounded;
                                              }
                                            }(),
                                            onTap:
                                                () => context
                                                    .read<DailyZekrCubit>()
                                                    .toggle(item.section),
                                            onChanged:
                                                (_) => context
                                                    .read<DailyZekrCubit>()
                                                    .toggle(item.section),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: Column(
                              children: [
                                content,
                                SizedBox(height: 12.h),
                                _buildHintText(),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: ColorsManager.primaryGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorsManager.primaryGold.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: ColorsManager.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: ColorsManager.primaryGold,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كيف تعمل هذه الصفحة؟',
                    style: TextStyles.titleLarge.copyWith(
                      color: ColorsManager.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'ضع علامة الصح على البند الذي أنجزته اليوم. عند التفعيل يتوقف إرسال التذكير لهذا القسم. إذا تُرك بدون تفعيل سنذكّرك كل ساعة بإذن الله.',
                    style: TextStyles.bodyMedium.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: EdgeInsetsDirectional.only(
      start: 30.w,
      end: 30.w,
      top: 8.h,
      bottom: 8.h,
    ),
    child: Container(
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryPurple.withOpacity(0.3),
            ColorsManager.primaryGold.withOpacity(0.6),
            ColorsManager.primaryPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(1.r),
      ),
    ),
  );

  Widget _buildHintText() => Text(
    'تلميح: يمكنك تعديل الحالة في أي وقت، ولن تُرسل التنبيهات للأقسام المكتملة.',
    style: TextStyles.bodySmall.copyWith(color: ColorsManager.gray),
    textAlign: TextAlign.center,
  );
}
