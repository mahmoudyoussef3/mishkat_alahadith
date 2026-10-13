import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_switch.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_engine.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_settings_cubit.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_host.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/ui/read_aloud_labels.dart';

/// Listening settings: voice, engine, speed, pitch, volume and how a
/// reading proceeds. Changes are heard at once in a reading under way.
Future<void> showReadAloudSettingsSheet(BuildContext context) {
  final owner = ReadAloudHost.maybeOwnerOf(context);
  context.read<ReadAloudSettingsCubit>().inspectEngine();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder:
        (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: _ReadAloudSettingsSheet(owner: owner),
        ),
  );
}

class _ReadAloudSettingsSheet extends StatelessWidget {
  const _ReadAloudSettingsSheet({required this.owner});

  final Object? owner;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: 18.h);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        children: [
          Text('إعدادات الاستماع', style: TextStyles.sectionTitle),
          Text(
            'اختر الصوت العربي وسرعة القراءة وطريقة متابعتها',
            style: TextStyles.caption.copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: 14.h),
          const _EngineStatus(),
          _VoiceSection(owner: owner),
          const _EngineSection(),
          gap,
          const _RateSection(),
          gap,
          const _SoundSection(),
          gap,
          const _ReadingSection(),
          gap,
          const _GapSection(),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: context.read<ReadAloudSettingsCubit>().reset,
                  child: const Text('استعادة الافتراضي'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('تم'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Searching for voices, or why Arabic reading may not work.
class _EngineStatus extends StatelessWidget {
  const _EngineStatus();

  static String get _installHint =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'افتح الإعدادات ← تسهيلات الاستخدام ← المحتوى المنطوق ← الأصوات ← '
              'العربية، ثم نزّل صوتاً عربياً.'
          : 'افتح إعدادات الجهاز ← تحويل النص إلى كلام، ثم ثبّت بيانات '
              'اللغة العربية للمحرك.';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAloudSettingsCubit, ReadAloudSettingsState>(
      buildWhen:
          (previous, current) =>
              previous.report != current.report ||
              previous.inspecting != current.inspecting ||
              previous.inspectionFailed != current.inspectionFailed,
      builder: (context, state) {
        final report = state.report;
        final Widget? notice;
        if (state.inspectionFailed) {
          notice = _Notice(
            icon: Icons.error_outline_rounded,
            color: ColorsManager.error,
            background: ColorsManager.errorSoft,
            title: 'تعذر الوصول إلى محرك القراءة',
            body: 'تأكد من وجود محرك تحويل النص إلى كلام على جهازك.',
            action: TextButton(
              onPressed: context.read<ReadAloudSettingsCubit>().inspectEngine,
              child: const Text('إعادة المحاولة'),
            ),
          );
        } else if (report == null) {
          notice =
              state.inspecting
                  ? Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: const LinearProgressIndicator(minHeight: 2),
                  )
                  : null;
        } else if (report.chosenEngineFailed) {
          notice = _Notice(
            icon: Icons.memory_rounded,
            color: ColorsManager.goldInk,
            background: ColorsManager.goldSoft,
            title: 'تعذر تشغيل المحرك المختار',
            body: 'تتم القراءة بمحرك النظام الافتراضي.',
            action: TextButton(
              onPressed:
                  () =>
                      context.read<ReadAloudSettingsCubit>().selectEngine(null),
              child: const Text('استخدام الافتراضي'),
            ),
          );
        } else if (!report.arabicAvailable) {
          notice = _Notice(
            icon: Icons.record_voice_over_outlined,
            color: ColorsManager.error,
            background: ColorsManager.errorSoft,
            title: 'لا يتوفر صوت عربي على جهازك',
            body: _installHint,
          );
        } else if (report.needsNetwork) {
          notice = _Notice(
            icon: Icons.wifi_rounded,
            color: ColorsManager.goldInk,
            background: ColorsManager.goldSoft,
            title: 'يحتاج هذا الصوت إلى اتصال بالإنترنت',
            body: 'لتستمع دون إنترنت: $_installHint',
          );
        } else {
          notice = null;
        }
        if (notice == null) return const SizedBox.shrink();
        return Padding(padding: EdgeInsets.only(bottom: 14.h), child: notice);
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.r, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(body, style: TextStyles.caption.copyWith(height: 1.6)),
                if (action != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: action,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceSection extends StatelessWidget {
  const _VoiceSection({required this.owner});

  final Object? owner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAloudSettingsCubit, ReadAloudSettingsState>(
      buildWhen:
          (previous, current) =>
              previous.report != current.report ||
              previous.settings.voice != current.settings.voice,
      builder: (context, state) {
        final report = state.report;
        if (report == null || !report.arabicAvailable) {
          return const SizedBox.shrink();
        }
        final cubit = context.read<ReadAloudSettingsCubit>();
        final chosen = state.settings.voice;
        final autoVoice = report.autoVoice;

        return SettingsGroup(
          title: 'الصوت',
          footer: _PreviewButton(owner: owner),
          children: [
            _ChoiceTile(
              icon: Icons.auto_awesome_rounded,
              title: 'تلقائي',
              subtitle:
                  autoVoice == null
                      ? 'الصوت العربي الافتراضي للجهاز'
                      : 'أفضل صوت عربي متاح · '
                          '${autoVoice.displayName(report.voices.indexOf(autoVoice) + 1)}',
              selected: chosen == null,
              onTap: () => cubit.selectVoice(null),
            ),
            for (var i = 0; i < report.voices.length; i++)
              _ChoiceTile(
                icon: Icons.record_voice_over_rounded,
                title: report.voices[i].displayName(i + 1),
                subtitle: report.voices[i].details,
                selected: chosen != null && report.voices[i].matches(chosen),
                onTap:
                    report.voices[i].isReady
                        ? () => cubit.selectVoice(report.voices[i])
                        : null,
              ),
          ],
        );
      },
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.owner});

  final Object? owner;

  @override
  Widget build(BuildContext context) {
    final previewing = context.select<ReadAloudCubit, bool>(
      (cubit) => cubit.state.previewing,
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed:
            previewing
                ? null
                : () => context.read<ReadAloudCubit>().preview(owner: owner),
        icon:
            previewing
                ? SizedBox.square(
                  dimension: 16.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(Icons.play_circle_outline_rounded, size: 20.r),
        label: Text(previewing ? 'جارٍ تشغيل عيّنة…' : 'تجربة الصوت'),
      ),
    );
  }
}

/// Android only, and only when more than one engine is installed.
class _EngineSection extends StatelessWidget {
  const _EngineSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAloudSettingsCubit, ReadAloudSettingsState>(
      buildWhen:
          (previous, current) =>
              previous.report != current.report ||
              previous.settings.engine != current.settings.engine,
      builder: (context, state) {
        final SpeechEngineReport? report = state.report;
        if (report == null || !report.canChooseEngine) {
          return const SizedBox.shrink();
        }
        final cubit = context.read<ReadAloudSettingsCubit>();
        final chosen = state.settings.engine;
        final defaultEngine = report.defaultEngine;

        return Padding(
          padding: EdgeInsets.only(top: 18.h),
          child: SettingsGroup(
            title: 'محرك القراءة',
            children: [
              _ChoiceTile(
                icon: Icons.settings_suggest_rounded,
                title: 'افتراضي النظام',
                subtitle:
                    defaultEngine == null
                        ? null
                        : speechEngineLabel(defaultEngine),
                selected: chosen == null,
                onTap: () => cubit.selectEngine(null),
              ),
              for (final engine in report.engines)
                _ChoiceTile(
                  icon: Icons.memory_rounded,
                  title: speechEngineLabel(engine),
                  subtitle: engine,
                  selected: chosen == engine,
                  onTap: () => cubit.selectEngine(engine),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;

  /// Null shows the choice as unavailable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      selected: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: SettingsTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: enabled && !selected ? onTap : null,
          trailing: Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22.r,
            color: selected ? ColorsManager.primaryPurple : ColorsManager.gray,
          ),
        ),
      ),
    );
  }
}

class _RateSection extends StatelessWidget {
  const _RateSection();

  @override
  Widget build(BuildContext context) {
    final rate = context.select<ReadAloudSettingsCubit, double>(
      (cubit) => cubit.state.settings.rate,
    );
    const rates = ReadAloudSettings.rates;
    var selected = 0;
    for (var i = 1; i < rates.length; i++) {
      if ((rates[i] - rate).abs() < (rates[selected] - rate).abs()) {
        selected = i;
      }
    }
    return _Labeled(
      title: 'سرعة القراءة',
      child: SegmentedTabs(
        labels: [for (final option in rates) speechRateLabel(option)],
        selectedIndex: selected,
        onChanged:
            (index) =>
                context.read<ReadAloudSettingsCubit>().setRate(rates[index]),
      ),
    );
  }
}

class _SoundSection extends StatelessWidget {
  const _SoundSection();

  static String _pitchLabel(double pitch) {
    if ((pitch - 1).abs() < 0.01) return 'طبيعية';
    return toArabicDigits(pitch.toStringAsFixed(1)).replaceAll('.', '٫');
  }

  static String _volumeLabel(double volume) =>
      '${toArabicDigits('${(volume * 100).round()}')}٪';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReadAloudSettingsCubit>();
    final (pitch, volume) = context
        .select<ReadAloudSettingsCubit, (double, double)>(
          (cubit) => (cubit.state.settings.pitch, cubit.state.settings.volume),
        );

    return SettingsGroup(
      title: 'الصوت والنبرة',
      children: [
        _SliderTile(
          icon: Icons.graphic_eq_rounded,
          title: 'طبقة الصوت',
          value: pitch,
          min: ReadAloudSettings.minPitch,
          max: ReadAloudSettings.maxPitch,
          divisions: 10,
          label: _pitchLabel,
          onChanged: cubit.setPitch,
        ),
        _SliderTile(
          icon: Icons.volume_up_rounded,
          title: 'مستوى الصوت',
          value: volume,
          min: ReadAloudSettings.minVolume,
          max: ReadAloudSettings.maxVolume,
          divisions: 8,
          label: _volumeLabel,
          onChanged: cubit.setVolume,
        ),
      ],
    );
  }
}

/// A slider that saves when released, so a reading restarts once rather
/// than at every step of a drag.
class _SliderTile extends StatefulWidget {
  const _SliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double value) label;
  final ValueChanged<double> onChanged;

  @override
  State<_SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<_SliderTile> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final value = (_dragging ?? widget.value).clamp(widget.min, widget.max);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 20.r, color: ColorsManager.purpleText),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                widget.label(value),
                style: TextStyles.chipLabel.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ColorsManager.purpleText,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.label(value),
            activeColor: ColorsManager.primaryPurple,
            inactiveColor: ColorsManager.lightGray,
            semanticFormatterCallback: widget.label,
            onChanged: (next) => setState(() => _dragging = next),
            onChangeEnd: (next) {
              setState(() => _dragging = null);
              widget.onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _ReadingSection extends StatelessWidget {
  const _ReadingSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAloudSettingsCubit, ReadAloudSettingsState>(
      buildWhen: (previous, current) => previous.settings != current.settings,
      builder: (context, state) {
        final cubit = context.read<ReadAloudSettingsCubit>();
        final settings = state.settings;
        return SettingsGroup(
          title: 'أثناء القراءة',
          children: [
            _SwitchTile(
              icon: Icons.format_color_text_rounded,
              title: 'تمييز الكلمة المقروءة',
              subtitle: 'ومتابعتها على الشاشة',
              value: settings.highlightWords,
              onChanged: cubit.setHighlightWords,
            ),
            _SwitchTile(
              icon: Icons.title_rounded,
              title: 'قراءة العناوين',
              subtitle: 'رقم الحديث وعناوين الأقسام',
              value: settings.announceHeadings,
              onChanged: cubit.setAnnounceHeadings,
            ),
            _SwitchTile(
              icon: Icons.menu_book_rounded,
              title: 'قراءة الشرح والفوائد',
              subtitle: 'بعد نص الحديث، إن وُجدت',
              value: settings.readExplanation,
              onChanged: cubit.setReadExplanation,
            ),
            _SwitchTile(
              icon: Icons.playlist_play_rounded,
              title: 'الانتقال إلى الحديث التالي',
              subtitle: 'متابعة قراءة أحاديث الباب تلقائياً',
              value: settings.autoContinue,
              onChanged: cubit.setAutoContinue,
            ),
          ],
        );
      },
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: AppSwitch(
        value: value,
        onChanged: onChanged,
        semanticLabel: title,
      ),
    );
  }
}

class _GapSection extends StatelessWidget {
  const _GapSection();

  @override
  Widget build(BuildContext context) {
    final gap = context.select<ReadAloudSettingsCubit, SpeechPartGap>(
      (cubit) => cubit.state.settings.partGap,
    );
    return _Labeled(
      title: 'الوقفة بين أجزاء الحديث',
      child: SegmentedTabs(
        labels: [for (final option in SpeechPartGap.values) option.label],
        selectedIndex: gap.index,
        onChanged:
            (index) => context.read<ReadAloudSettingsCubit>().setPartGap(
              SpeechPartGap.values[index],
            ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
