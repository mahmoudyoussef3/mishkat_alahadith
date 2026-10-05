import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/siraj_mark.dart';

/// A question to start the conversation with.
class SirajStarter {
  const SirajStarter({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
}

/// Greeting shown before the first question: the hadith being discussed
/// and a few questions to start with.
class SirajWelcome extends StatelessWidget {
  const SirajWelcome({
    super.key,
    required this.hadithText,
    required this.onAsk,
  });

  final String hadithText;
  final ValueChanged<String> onAsk;

  static List<SirajStarter> get starters => [
    SirajStarter(
      icon: Icons.menu_book_rounded,
      title: 'اشرح هذا الحديث',
      subtitle: 'شرح مبسّط بلغة واضحة',
      background: ColorsManager.primarySoft,
      foreground: ColorsManager.purpleText,
    ),
    SirajStarter(
      icon: Icons.lightbulb_outline_rounded,
      title: 'ما فوائد هذا الحديث؟',
      subtitle: 'دروس عملية من الحديث',
      background: ColorsManager.goldSoft,
      foreground: ColorsManager.primaryGold,
    ),
    SirajStarter(
      icon: Icons.translate_rounded,
      title: 'ما معاني الكلمات الغريبة فيه؟',
      subtitle: 'غريب الحديث',
      background: ColorsManager.successSoft,
      foreground: ColorsManager.success,
    ),
    SirajStarter(
      icon: Icons.manage_search_rounded,
      title: 'اذكر أحاديث في المعنى نفسه',
      subtitle: 'مع ذكر المصدر والدرجة',
      background: ColorsManager.primarySoft,
      foreground: ColorsManager.purpleText,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final matn = HadithTextParts.split(hadithText).matn;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      children: [
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.heroBackground.withValues(alpha: 0.45),
                  blurRadius: 30,
                  spreadRadius: -14,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SirajMark(size: 72.r, onLight: true),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'السلام عليكم، كيف أعينك؟',
          textAlign: TextAlign.center,
          style: TextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'اسألني عن معنى هذا الحديث وفوائده وغريب ألفاظه، وسأجيبك مع ذكر المصادر.',
          textAlign: TextAlign.center,
          style: TextStyles.caption.copyWith(fontSize: 14.sp, height: 1.8),
        ),
        if (matn.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: ColorsManager.lightGray,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Text(
              matn,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.readingMedium.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        SizedBox(height: 22.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'جرّب أن تسأل',
            style: TextStyles.caption.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        for (final starter in starters) ...[
          _StarterTile(starter: starter, onTap: () => onAsk(starter.title)),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

class _StarterTile extends StatelessWidget {
  const _StarterTile({required this.starter, required this.onTap});

  final SirajStarter starter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: starter.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(starter.icon, size: 20.r, color: starter.foreground),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      starter.title,
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    Text(starter.subtitle, style: TextStyles.caption),
                  ],
                ),
              ),
              Icon(
                Icons.north_west_rounded,
                size: 20.r,
                color: ColorsManager.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
