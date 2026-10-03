import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Spacing {
  static const double _baseUnit = 4.0;
  
  static double get xs => _baseUnit.sp;
  static double get xs2 => (_baseUnit * 1.5).sp;
  
  static double get sm => (_baseUnit * 2).sp;
  static double get sm2 => (_baseUnit * 3).sp;
  
  static double get md => (_baseUnit * 4).sp;
  static double get md2 => (_baseUnit * 6).sp;
  
  static double get lg => (_baseUnit * 8).sp;
  static double get lg2 => (_baseUnit * 12).sp;
  
  static double get xl => (_baseUnit * 16).sp;
  static double get xl2 => (_baseUnit * 24).sp;
  
  static double get xxl => (_baseUnit * 32).sp;
  static double get xxl2 => (_baseUnit * 48).sp;
  
  static double get screenHorizontal => 16.sp;
  static double get screenVertical => 16.sp;
  
  static double get cardPadding => 16.sp;
  static double get cardMargin => 8.sp;
  static double get cardRadius => 12.sp;
  
  static double get buttonPadding => 16.sp;
  static double get buttonRadius => 8.sp;
  
  static double get inputPadding => 16.sp;
  static double get inputRadius => 8.sp;
  
  static double get listItemSpacing => 12.sp;
  static double get listItemPadding => 16.sp;
  
  static double get sectionSpacing => 24.sp;
  static double get sectionPadding => 20.sp;
}

extension SpacingExtension on Widget {
  Widget withPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
      child: this,
    );
  }
  
  Widget withMargin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
      child: this,
    );
  }
}
