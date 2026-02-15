import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

import '../../../domain/entities/ramadan_task_entity.dart';
import '../../../domain/worship_templates.dart';
import '../../cubit/ramadan_tasks_cubit.dart';
import 'custom_task_dialog.dart';
import 'worship_tile.dart';

// ══════════════════════════════════════════════════════════════
// Public entry point — call from FAB / button
// ══════════════════════════════════════════════════════════════

/// Opens the Ramadan task-creation sheet.
///
/// [parentContext] must have [RamadanTasksCubit] in scope.
void showTaskCreationSheet(BuildContext parentContext) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder:
        (_) => BlocProvider.value(
          value: parentContext.read<RamadanTasksCubit>(),
          child: const _TaskCreationSheet(),
        ),
  );
}

// ══════════════════════════════════════════════════════════════
// Root sheet widget
// ══════════════════════════════════════════════════════════════

class _TaskCreationSheet extends StatelessWidget {
  const _TaskCreationSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.5, 0.88, 0.95],
        builder:
            (context, scrollCtrl) => Container(
              decoration: BoxDecoration(
                color: ColorsManager.primaryBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // ── Handle + header (non-scrollable) ──
                  _SheetHeader(scrollController: scrollCtrl),

                  // ── Scrollable content ──
                  Expanded(child: _SheetBody(scrollController: scrollCtrl)),
                ],
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Sheet header — handle bar + title row
// ══════════════════════════════════════════════════════════════

class _SheetHeader extends StatelessWidget {
  final ScrollController scrollController;
  const _SheetHeader({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 20.w,
        end: 20.w,
        top: 10.h,
        bottom: 4.h,
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.mediumGray,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 14.h),

          // Title + close
          Row(
            children: [
              // Icon badge
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.primaryPurple.withValues(alpha: 0.15),
                      ColorsManager.primaryPurple.withValues(alpha: 0.05),
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.add_task_rounded,
                  size: 22.sp,
                  color: ColorsManager.primaryPurple,
                ),
              ),
              SizedBox(width: 12.w),

              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة عبادة',
                      style: TextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'اختر من العبادات أو أضف عبادة مخصصة',
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.secondaryText,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              Material(
                color: ColorsManager.lightGray,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(8.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Subtle divider
          Divider(
            height: 1,
            color: ColorsManager.mediumGray.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Scrollable body — worship sections + custom button
// ══════════════════════════════════════════════════════════════

class _SheetBody extends StatelessWidget {
  final ScrollController scrollController;
  const _SheetBody({required this.scrollController});

  void _addTemplateTask(BuildContext context, WorshipTemplate template) {
    HapticFeedback.mediumImpact();
    context.read<RamadanTasksCubit>().addNewTask(
      title: template.title,
      type: TaskType.daily,
    );
    _showAddedSnackBar(context, template.title);
  }

  void _showAddedSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: ColorsManager.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تمت إضافة "$title"',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: ColorsManager.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: ColorsManager.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
  }

  void _openCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<RamadanTasksCubit>(),
            child: const CustomTaskDialog(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RamadanTasksCubit, RamadanTasksState>(
      buildWhen: (prev, curr) {
        if (curr is! RamadanTasksLoaded || prev is! RamadanTasksLoaded) {
          return true;
        }
        return prev.availableSuggestions != curr.availableSuggestions;
      },
      builder: (context, state) {
        final sections =
            state is RamadanTasksLoaded
                ? state.availableSuggestions
                : kWorshipSections;

        return ListView(
          controller: scrollController,
          padding: EdgeInsetsDirectional.only(
            start: 20.w,
            end: 20.w,
            top: 12.h,
            bottom: 32.h,
          ),
          children: [
            // ── Worship sections ──
            if (sections.isEmpty)
              _AllAddedBanner()
            else
              for (int i = 0; i < sections.length; i++) ...[
                _AnimatedSection(
                  key: ValueKey(sections[i].title),
                  section: sections[i],
                  onItemTap: (t) => _addTemplateTask(context, t),
                ),
                if (i < sections.length - 1) SizedBox(height: 6.h),
              ],

            SizedBox(height: 28.h),

            // ── Divider ──
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: ColorsManager.mediumGray.withValues(alpha: 0.4),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
                  child: Text(
                    'أو',
                    style: TextStyles.bodySmall.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: ColorsManager.mediumGray.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // ── Custom task button ──
            _CustomTaskButton(onTap: () => _openCustomDialog(context)),

            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Animated section — tracks item additions and animates removal
// ══════════════════════════════════════════════════════════════

class _AnimatedSection extends StatefulWidget {
  final WorshipSection section;
  final void Function(WorshipTemplate template) onItemTap;

  const _AnimatedSection({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<WorshipTemplate> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.section.items);
  }

  @override
  void didUpdateWidget(covariant _AnimatedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Find removed items and animate them out
    final newTitles = widget.section.items.map((i) => i.title).toSet();
    for (int i = _items.length - 1; i >= 0; i--) {
      if (!newTitles.contains(_items[i].title)) {
        final removed = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemoving(removed, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    // Find newly added items (if task was deleted and reappears)
    final oldTitles = _items.map((i) => i.title).toSet();
    for (final item in widget.section.items) {
      if (!oldTitles.contains(item.title)) {
        _items.add(item);
        _listKey.currentState?.insertItem(
          _items.length - 1,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  Widget _buildRemoving(WorshipTemplate item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: EdgeInsetsDirectional.only(bottom: 6.h),
          child: WorshipTile(
            title: item.title,
            icon: item.icon,
            accentColor: widget.section.accentColor,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4.w,
            bottom: 10.h,
            top: 4.h,
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: widget.section.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  widget.section.icon,
                  size: 16.sp,
                  color: widget.section.accentColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                widget.section.title,
                style: TextStyles.headlineSmall.copyWith(
                  color: ColorsManager.primaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
        // Animated items list
        AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: _items.length,
          itemBuilder: (context, i, animation) {
            if (i >= _items.length) return const SizedBox.shrink();
            final item = _items[i];
            return SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(bottom: 6.h),
                child: WorshipTile(
                  title: item.title,
                  icon: item.icon,
                  accentColor: widget.section.accentColor,
                  onTap: () => widget.onItemTap(item),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// All-added banner — shown when every template has been added
// ══════════════════════════════════════════════════════════════

class _AllAddedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 20.w,
        vertical: 28.h,
      ),
      decoration: BoxDecoration(
        color: ColorsManager.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 40.sp,
            color: ColorsManager.success,
          ),
          SizedBox(height: 12.h),
          Text(
            'ما شاء الله!',
            style: TextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: ColorsManager.success,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'تمت إضافة جميع العبادات المقترحة',
            style: TextStyles.bodyMedium.copyWith(
              color: ColorsManager.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Custom task CTA button
// ══════════════════════════════════════════════════════════════

class _CustomTaskButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CustomTaskButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: ColorsManager.primaryPurple.withValues(alpha: 0.25),
              width: 1.5,
            ),
            color: ColorsManager.primaryPurple.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 22.sp,
                  color: ColorsManager.primaryPurple,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة عبادة مخصصة',
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.primaryPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'أضف عبادتك الخاصة بعنوان ووصف',
                      style: TextStyles.bodySmall.copyWith(
                        color: ColorsManager.secondaryText,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: ColorsManager.primaryPurple.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
