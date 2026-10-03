import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// A single worship item tile with icon, title, and subtle tap animation.
class WorshipTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const WorshipTile({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<WorshipTile> createState() => _WorshipTileState();
}

class _WorshipTileState extends State<WorshipTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _ctrl.forward();

  void _handleTapUp(TapUpDetails _) {
    _ctrl.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _handleTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: BoxConstraints(minHeight: 52.h),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 19.sp,
                  color: widget.accentColor,
                ),
              ),
              SizedBox(width: 12.w),
              // Title
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.primaryText,
                    height: 1.3,
                  ),
                ),
              ),
              // Trailing add indicator
              Icon(
                Icons.add_circle_outline_rounded,
                size: 20.sp,
                color: widget.accentColor.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
