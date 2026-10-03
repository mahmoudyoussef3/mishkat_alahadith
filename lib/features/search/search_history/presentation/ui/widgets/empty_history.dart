import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/icons/search_icon.png"),
            SizedBox(height: 12.h),
            Text(
              "لا يوجد سجل بحث بعد",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
    
}
