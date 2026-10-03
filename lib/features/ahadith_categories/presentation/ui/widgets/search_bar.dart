import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class CategoriesSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const CategoriesSearchBar({super.key, required this.onSearch});

  @override
  State<CategoriesSearchBar> createState() => _CategoriesSearchBarState();
}

class _CategoriesSearchBarState extends State<CategoriesSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryPurple.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      widget.onSearch(_controller.text);
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      width: 72.w,
                      height: 44.h,
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorsManager.primaryPurple,
                            ColorsManager.secondaryPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'بحث',
                          style: TextStyles.font13BlueSemiBold.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (value) {
                      widget.onSearch(value);
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن حديث أو كلمة…',
                      hintStyle: TextStyles.font14GrayRegular.copyWith(
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    style: TextStyles.font14GrayRegular,
                  ),
                ),
                // Clear Button
                if (_controller.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.w),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _controller.clear();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[400],
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
