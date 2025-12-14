import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/profile/logic/cubit/cubit/user_stats_cubit.dart';
import 'package:mishkat_almasabih/features/profile/ui/widgets/stats_card.dart';
import '../../logic/cubit/profile_cubit.dart';
import 'last_activity_card.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<UserStatsCubit, UserStatsState>(
        builder: (context, state) {
          if (state is UserStatsLoading) {
            return _buildLoading();
          } else if (state is UserStatsError) {
            return _buildError(state.message);
          } else if (state is UserStatsLoaded ) {
            return _buildContent(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent(UserStatsLoaded state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          SizedBox(height: 16.h),
          _buildStatsGrid(state),
          if (state.stats.lastActivityAt != null) ...[
            SizedBox(height: 12.h),
            LastActivityCard(date: state.stats.lastActivityAt!),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.chartLine,
          size: 20.sp,
          color: ColorsManager.primaryPurple,
        ),
        SizedBox(width: 8.w),
        Text(
          "الإحصائيات",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(UserStatsLoaded state) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: "الإشارات المرجعية",
          value: "${state.stats.bookmarksCount}",
          icon: FontAwesomeIcons.bookmark,
          color: ColorsManager.primaryGreen,
        ),
        StatCard(
          title: "المجموعات",
          value: "${state.stats.collectionsCount}",
          icon: FontAwesomeIcons.folder,
          color: ColorsManager.primaryPurple,
        ),
        StatCard(
          title: "البطاقات",
          value: "${state.stats.cardsCount}",
          icon: FontAwesomeIcons.addressCard,
          color: ColorsManager.hadithWeak,
        ),
        StatCard(
          title: "عمليات البحث",
          value: "${state.stats.searchesCount}",
          icon: FontAwesomeIcons.magnifyingGlass,
          color: const Color(0xFF00BCD4),
        ),
      ],
    );
  }
}