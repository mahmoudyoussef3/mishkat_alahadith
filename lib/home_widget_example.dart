import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetExample extends StatefulWidget {
  @override
  _HomeWidgetExampleState createState() => _HomeWidgetExampleState();
}

class _HomeWidgetExampleState extends State<HomeWidgetExample> {
  
  // دالة لتحديث الويدجت
  Future<void> updateWidget() async {
    try {
      // حفظ البيانات
      await HomeWidget.saveWidgetData<String>('widget_title', 'عنوان جديد');
      await HomeWidget.saveWidgetData<String>('widget_message', 'محتوى محدث');
      
      // تحديث الويدجت
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider', // اسم الـ Provider في Android
        iOSName: 'HomeWidgetProvider', // لو بتستخدم iOS
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث الويدجت بنجاح!')),
      );
    } catch (e) {
      print('خطأ في تحديث الويدجت: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Widget Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: updateWidget,
          child: Text('تحديث الويدجت'),
        ),
      ),
    );
  }
}