import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/serag_decorations.dart';
import 'package:mishkat_almasabih/core/theming/serag_styles.dart';
import 'package:mishkat_almasabih/features/remaining_questions/logic/cubit/remaining_questions_cubit.dart';

class RemainingQuestionsCard extends StatelessWidget {
  const RemainingQuestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemainingQuestionsCubit, RemainingQuestionsState>(
      builder: (context, state) {
        if (state is RemainingQuestionsSuccess) {
          return Container(
            width: double.infinity,
            margin: SeragDecorations.remainingQuestionsCardMargin,
            padding: SeragDecorations.remainingQuestionsCardPadding,
            decoration: SeragDecorations.remainingQuestionsCard(),
            child: Row(
              children: [
                Container(
                  padding: SeragDecorations.iconContainerPadding,
                  decoration: BoxDecoration(
                    color: SeragDecorations.iconContainerBackground,
                    borderRadius: BorderRadius.circular(
                      SeragDecorations.iconContainerBorderRadius,
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: SeragDecorations.iconColor,
                    size: SeragDecorations.iconSize,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'لديك ${state.remainigQuestionsResponse.remaining} محاولات متبقية اليوم',
                    style: SeragTextStyles.remainingQuestionsText,
                  ),
                ),
              ],
            ),
          );
        } else if (state is RemainingQuestionsLoading) {
          return Container(
            width: double.infinity,
            margin: SeragDecorations.remainingQuestionsCardMargin,
            padding: SeragDecorations.remainingQuestionsCardPadding,
            decoration: SeragDecorations.shimmerLoadingCard(),
            child: Row(
              children: [
                _ShimmerBox(width: 34.w, height: 34.w, borderRadius: 8),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: double.infinity,
                        height: 16.h,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 4.h),
                      _ShimmerBox(width: 120.w, height: 12.h, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: SeragDecorations.shimmerAnimationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                SeragDecorations.shimmerGradientColors[0],
                SeragDecorations.shimmerGradientColors[1],
                SeragDecorations.shimmerGradientColors[2],
              ],
            ),
          ),
        );
      },
    );
  }
}
