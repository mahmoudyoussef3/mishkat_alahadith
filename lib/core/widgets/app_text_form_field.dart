import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/colors.dart';
import '../theming/styles.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String hintText;
  final bool? isObscureText;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final TextEditingController? controller;
  final Function(String?) validator;
  const AppTextFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    required this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backgroundColor,
    this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorsManager.primaryPurple,
                width: 1.5,
              ),
              borderRadius: radius,
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: ColorsManager.mediumGray),
              borderRadius: radius,
            ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorsManager.error, width: 1.3),
          borderRadius: radius,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorsManager.error, width: 1.5),
          borderRadius: radius,
        ),
        hintStyle:
            hintStyle ??
            TextStyles.bodyMedium.copyWith(color: ColorsManager.secondaryText),
        hintText: hintText,
        suffixIcon: suffixIcon,
        fillColor: backgroundColor ?? ColorsManager.lightGray,
        filled: true,
      ),
      obscureText: isObscureText ?? false,
      style:
          inputTextStyle ??
          TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
      validator: (value) {
        return validator(value);
      },
    );
  }
}
