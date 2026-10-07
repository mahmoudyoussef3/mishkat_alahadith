import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/bookmark_collection.dart';
import 'package:mishkat_almasabih/features/bookmark/presentation/logic/collections/get_collections_bookmark_cubit.dart';

/// The user's bookmark collections as folder tiles that filter the list.
/// Hidden until the user has at least one named collection.
class BookmarkCollectionsRow extends StatelessWidget {
  /// Selected collection name; null means every collection.
  final String? selectedCollection;
  final ValueChanged<String?> onCollectionSelected;

  const BookmarkCollectionsRow({
    super.key,
    required this.selectedCollection,
    required this.onCollectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GetCollectionsBookmarkCubit,
      GetCollectionsBookmarkState
    >(
      builder: (context, state) {
        if (state is! GetCollectionsBookmarkSuccess) {
          return const SizedBox.shrink();
        }
        final collections = [
          for (final collection in state.collections)
            if (collection.collection?.trim().isNotEmpty ?? false) collection,
        ];
        if (collections.isEmpty) return const SizedBox.shrink();

        // Top inset, tile padding, icon and gap, then the name and count
        // lines at the user's text size.
        final height =
            14.h +
            24.r +
            22.r +
            6.h +
            MediaQuery.textScalerOf(context).scale(40.sp);
        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
            itemCount: collections.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CollectionTile(
                  name: 'الكل',
                  icon: Icons.folder_copy_rounded,
                  accent: _Accent.neutral,
                  selected: selectedCollection == null,
                  onTap: () => onCollectionSelected(null),
                );
              }
              final BookmarkCollection collection = collections[index - 1];
              final name = collection.collection!;
              final count = collection.count;
              return _CollectionTile(
                name: name,
                subtitle:
                    count == null
                        ? null
                        : arabicCount(count, ArabicNoun.hadith),
                icon: Icons.folder_rounded,
                accent: index.isOdd ? _Accent.purple : _Accent.gold,
                selected: selectedCollection == name,
                onTap: () => onCollectionSelected(name),
              );
            },
          ),
        );
      },
    );
  }
}

enum _Accent { neutral, purple, gold }

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.name,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String name;
  final String? subtitle;
  final IconData icon;
  final _Accent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (accent) {
      _Accent.neutral => (
        ColorsManager.cardBackground,
        ColorsManager.primaryText,
      ),
      _Accent.purple => (ColorsManager.primarySoft, ColorsManager.purpleText),
      _Accent.gold => (ColorsManager.goldSoft, ColorsManager.primaryGold),
    };
    final subtitle = this.subtitle;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(
            color:
                selected ? ColorsManager.primaryPurple : ColorsManager.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 132.w,
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 22.r, color: foreground),
                  SizedBox(height: 6.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.caption.copyWith(height: 1.4),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
