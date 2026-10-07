import 'dart:io';

import 'package:flutter/material.dart';

/// Shape of the exported image.
enum ShareAspect {
  square(1, '١:١'),
  portrait(4 / 5, '٤:٥'),
  story(9 / 16, 'قصة');

  const ShareAspect(this.ratio, this.label);

  /// Width divided by height.
  final double ratio;
  final String label;

  IconData get icon => switch (this) {
    ShareAspect.square => Icons.crop_square_rounded,
    ShareAspect.portrait => Icons.crop_portrait_rounded,
    ShareAspect.story => Icons.smartphone_rounded,
  };
}

enum ShareFont {
  amiri('Amiri', 'أميري', FontWeight.w700),
  cairo('Cairo', 'القاهرة', FontWeight.w600);

  const ShareFont(this.family, this.label, this.weight);

  final String family;
  final String label;
  final FontWeight weight;
}

/// A ready-made look for the card.
class ShareTemplate {
  const ShareTemplate({
    required this.id,
    required this.label,
    required this.background,
    required this.ink,
    required this.accent,
    this.mosqueImage = false,
  });

  final String id;
  final String label;
  final Color background;
  final Color ink;
  final Color accent;

  /// Draws the mosque photograph, dimmed, behind the text.
  final bool mosqueImage;
}

/// The card's colours are fixed brand colours, not theme tokens: the
/// exported image must look the same whether the app is light or dark.
abstract final class ShareColors {
  static const paper = Color(0xFFFFFDF9);
  static const sand = Color(0xFFF7F4EE);
  static const gold = Color(0xFFF5ECD8);
  static const meadow = Color(0xFFE3EFE7);
  static const lilac = Color(0xFFEEEAF7);
  static const night = Color(0xFF1D1638);
  static const ink = Color(0xFF24202C);
  static const forest = Color(0xFF0F2A20);
  static const white = Color(0xFFFFFDF9);
  static const purple = Color(0xFF4E3BA8);
  static const goldInk = Color(0xFFA2741C);
  static const goldBright = Color(0xFFE8C77E);
  static const green = Color(0xFF2E7D55);
  static const muted = Color(0xFF6A6373);

  static const backgrounds = [paper, sand, gold, meadow, lilac, night, ink, forest];
  static const inks = [ink, white, purple, goldInk, green, muted];

  static bool isDark(Color color) => color == night || color == ink || color == forest;
}

const shareTemplates = [
  ShareTemplate(
    id: 'paper',
    label: 'ورق',
    background: ShareColors.paper,
    ink: ShareColors.ink,
    accent: ShareColors.purple,
  ),
  ShareTemplate(
    id: 'night',
    label: 'ليل',
    background: ShareColors.night,
    ink: ShareColors.white,
    accent: ShareColors.goldBright,
  ),
  ShareTemplate(
    id: 'mosque',
    label: 'مسجد',
    background: ShareColors.night,
    ink: ShareColors.white,
    accent: ShareColors.goldBright,
    mosqueImage: true,
  ),
  ShareTemplate(
    id: 'sand',
    label: 'رمل',
    background: ShareColors.gold,
    ink: Color(0xFF3A2A0A),
    accent: ShareColors.goldInk,
  ),
  ShareTemplate(
    id: 'meadow',
    label: 'روضة',
    background: ShareColors.meadow,
    ink: Color(0xFF173D2A),
    accent: ShareColors.green,
  ),
];

/// Everything the reader can change about the card.
@immutable
class ShareCardStyle {
  const ShareCardStyle({
    this.templateId = 'paper',
    this.background = ShareColors.paper,
    this.ink = ShareColors.ink,
    this.accent = ShareColors.purple,
    this.mosqueImage = false,
    this.photo,
    this.font = ShareFont.amiri,
    this.fontSize = 20,
    this.lineHeight = 1.9,
    this.align = TextAlign.right,
    this.aspect = ShareAspect.square,
    this.showIsnad = false,
  });

  static const minFontSize = 14.0;
  static const maxFontSize = 30.0;
  static const minLineHeight = 1.4;
  static const maxLineHeight = 2.6;

  /// The template last chosen, or null once colours were changed by hand.
  final String? templateId;
  final Color background;
  final Color ink;
  final Color accent;
  final bool mosqueImage;

  /// A photo from the gallery, drawn dimmed behind the text.
  final File? photo;
  final ShareFont font;
  final double fontSize;
  final double lineHeight;
  final TextAlign align;
  final ShareAspect aspect;
  final bool showIsnad;

  bool get hasImage => mosqueImage || photo != null;

  ShareCardStyle withTemplate(ShareTemplate template) => _copy(
    templateId: template.id,
    background: template.background,
    ink: template.ink,
    accent: template.accent,
    mosqueImage: template.mosqueImage,
    clearPhoto: true,
  );

  ShareCardStyle withBackground(Color color) {
    final dark = ShareColors.isDark(color);
    return _copy(
      clearTemplate: true,
      background: color,
      ink: dark ? ShareColors.white : ShareColors.ink,
      accent: dark ? ShareColors.goldBright : ShareColors.purple,
      mosqueImage: false,
      clearPhoto: true,
    );
  }

  ShareCardStyle withPhoto(File photo) => _copy(
    clearTemplate: true,
    photo: photo,
    mosqueImage: false,
    background: ShareColors.night,
    ink: ShareColors.white,
    accent: ShareColors.goldBright,
  );

  ShareCardStyle copyWith({
    Color? ink,
    ShareFont? font,
    double? fontSize,
    double? lineHeight,
    TextAlign? align,
    ShareAspect? aspect,
    bool? showIsnad,
  }) => _copy(
    ink: ink,
    font: font,
    fontSize: fontSize?.clamp(minFontSize, maxFontSize),
    lineHeight: lineHeight?.clamp(minLineHeight, maxLineHeight),
    align: align,
    aspect: aspect,
    showIsnad: showIsnad,
  );

  ShareCardStyle _copy({
    String? templateId,
    bool clearTemplate = false,
    Color? background,
    Color? ink,
    Color? accent,
    bool? mosqueImage,
    File? photo,
    bool clearPhoto = false,
    ShareFont? font,
    double? fontSize,
    double? lineHeight,
    TextAlign? align,
    ShareAspect? aspect,
    bool? showIsnad,
  }) => ShareCardStyle(
    templateId: clearTemplate ? null : templateId ?? this.templateId,
    background: background ?? this.background,
    ink: ink ?? this.ink,
    accent: accent ?? this.accent,
    mosqueImage: mosqueImage ?? this.mosqueImage,
    photo: clearPhoto ? null : photo ?? this.photo,
    font: font ?? this.font,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    align: align ?? this.align,
    aspect: aspect ?? this.aspect,
    showIsnad: showIsnad ?? this.showIsnad,
  );
}
