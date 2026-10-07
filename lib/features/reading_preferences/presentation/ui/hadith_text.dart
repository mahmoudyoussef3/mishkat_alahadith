import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';

/// Hadith body text drawn at the reader's chosen size, on top of the
/// system text-size setting.
///
/// Rebuilds only when the size changes. Without a [HadithFontScaleCubit]
/// above it the designed size is kept.
class HadithText extends StatelessWidget {
  const HadithText(
    String this.data, {
    super.key,
    required TextStyle this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : span = null;

  /// Rich hadith text, e.g. with a highlighted search match. Every span is
  /// scaled, including ones with their own font size.
  const HadithText.rich(
    InlineSpan this.span, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : data = null;

  final String? data;
  final InlineSpan? span;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final factor = context.select<HadithFontScaleCubit?, double>(
      (cubit) => cubit?.state.factor ?? 1,
    );
    final scaler = _HadithTextScaler(MediaQuery.textScalerOf(context), factor);

    final span = this.span;
    if (span != null) {
      return Text.rich(
        span,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: scaler,
      );
    }
    return Text(
      data!,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      textScaler: scaler,
    );
  }
}

/// Multiplies font sizes by [factor] before applying the system [base].
@immutable
class _HadithTextScaler extends TextScaler {
  const _HadithTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize * factor);

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _HadithTextScaler &&
      other.base == base &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
