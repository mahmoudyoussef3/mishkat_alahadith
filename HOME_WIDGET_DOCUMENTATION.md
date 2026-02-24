# 📖 توثيق Home Widget - مشكاة المصابيح

## 📋 جدول المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [المعمارية الكاملة](#المعمارية-الكاملة)
3. [مكونات النظام](#مكونات-النظام)
4. [سير العمل (Flow)](#سير-العمل-flow)
5. [شرح الملفات](#شرح-الملفات)
6. [كيفية التحديث](#كيفية-التحديث)
7. [أمثلة عملية](#أمثلة-عملية)
8. [استكشاف الأخطاء](#استكشاف-الأخطاء)
9. [أسئلة شائعة](#أسئلة-شائعة)

---

## 🎯 نظرة عامة

### ما هو Home Widget؟

**Home Widget** (أو App Widget في Android) هو **قطعة تفاعلية صغيرة** تظهر على شاشة الهاتف الرئيسية، تعرض معلومات من التطبيق بدون الحاجة لفتح التطبيق نفسه.

### في تطبيق مشكاة المصابيح:

- ✅ عرض **حديث اليوم** على شاشة الموبايل الرئيسية
- ✅ تحديث الحديث تلقائيًا عند تغييره في التطبيق
- ✅ النقر على الويدجيت يفتح التطبيق مباشرة
- ✅ تصميم جميل متناسق مع هوية التطبيق

### المشكلة التي تحلها:

بدلاً من أن يفتح المستخدم التطبيق كل مرة ليرى حديث اليوم، **الحديث يكون قدامه دايمًا** على الشاشة الرئيسية! 🎯

---

## 🏗️ المعمارية الكاملة

```
┌─────────────────────────────────────────────────────────────────────┐
│                    📱 FLUTTER APPLICATION LAYER                     │
│                          (Dart Language)                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  lib/features/home/ui/widgets/daily_hadith_card.dart         │  │
│  │                                                              │  │
│  │  • عرض الحديث داخل التطبيق                                  │  │
│  │  • مراقبة تغييرات الحديث                                    │  │
│  │  • استدعاء دالة التحديث عند كل حديث جديد                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                       │
│                              ▼                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  _updateHadithWidget() Method                                │  │
│  │                                                              │  │
│  │  Step 1: HomeWidget.saveWidgetData()     ← حفظ الداتا       │  │
│  │  Step 2: HomeWidget.updateWidget()       ← إرسال signal     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                       │
└──────────────────────────────┼───────────────────────────────────────┘
                               │
                               │ Platform Channel
                               │ (Flutter → Native Bridge)
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│              🔌 HOME_WIDGET PACKAGE (Bridge Layer)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  • تحويل Dart calls إلى Native calls                               │
│  • إدارة SharedPreferences                                          │
│  • إرسال Broadcast Intents                                          │
│                                                                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│          💾 SHARED STORAGE LAYER (SharedPreferences)                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  مخزن مشترك بين Flutter و Android Native:                          │
│                                                                     │
│  Key: "hadith_text"                                                 │
│  Value: "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى..."            │
│                                                                     │
│  ← Flutter يكتب هنا                                                 │
│  ← Android يقرأ من هنا                                              │
│                                                                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               │ Broadcast Intent
                               │ "APPWIDGET_UPDATE"
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  🤖 NATIVE ANDROID LAYER (Kotlin)                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  HadithWidgetProvider.kt (AppWidgetProvider)                 │  │
│  │                                                              │  │
│  │  override fun onUpdate() {                                   │  │
│  │    1. استقبال Broadcast                                      │  │
│  │    2. قراءة البيانات من SharedPreferences                    │  │
│  │    3. تحديث RemoteViews                                      │  │
│  │    4. إعادة رسم الويدجيت                                     │  │
│  │  }                                                           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                       │
│                              ▼                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  res/layout/hadith_widget.xml                                │  │
│  │                                                              │  │
│  │  • تصميم واجهة الويدجيت (XML Layout)                        │  │
│  │  • TextView للحديث                                          │  │
│  │  • أيقونات وتنسيقات                                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                       │
│                              ▼                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  res/xml/hadith_widget_info.xml                              │  │
│  │                                                              │  │
│  │  • معلومات الويدجيت (حجم، تحديثات دورية...)                │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                       │
└──────────────────────────────┼───────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  🏠 HOME SCREEN (الشاشة الرئيسية)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│          ┌────────────────────────────────────────┐                │
│          │  📖 حديث اليوم                         │                │
│          │  ───────────────────                   │                │
│          │                                        │                │
│          │  إنما الأعمال بالنيات وإنما لكل امرئ  │                │
│          │  ما نوى، فمن كانت هجرته إلى الله...   │                │
│          │                                        │                │
│          │             [اقرأ الحديث] 💎           │                │
│          └────────────────────────────────────────┘                │
│                     ▲ الويدجيت النهائية                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🧩 مكونات النظام

### 1️⃣ Flutter Layer Components

#### **الملف:** `lib/features/home/ui/widgets/daily_hadith_card.dart`

**الدور:**
- عرض الحديث داخل التطبيق
- مراقبة التغييرات في الحديث
- تحديث الويدجيت عند كل حديث جديد

**الكود الأساسي:**

```dart
// متغير لحفظ آخر حديث تم دفعه للويدجيت
String? _lastPushedToWidget;

// في build method:
final hadith = (state as DailyHadithSuccess).dailyHadithModel;

// التحقق من تغيير الحديث
if (hadith.hadeeth != null &&
    hadith.hadeeth!.isNotEmpty &&
    hadith.hadeeth != _lastPushedToWidget) {
  
  _lastPushedToWidget = hadith.hadeeth;
  _updateHadithWidget(hadithText: hadith.hadeeth);
}
```

#### **دالة التحديث:**

```dart
Future<void> _updateHadithWidget({String? hadithText}) async {
  if (hadithText != null) {
    // الخطوة 1: حفظ الحديث في المخزن المشترك
    await HomeWidget.saveWidgetData<String>('hadith_text', hadithText);
    
    // الخطوة 2: إخبار Android بالتحديث
    await HomeWidget.updateWidget(
      name: 'HadithWidgetProvider',
      iOSName: 'HadithWidget',
    );
    
    debugPrint('⬆️ HomeWidget: Data saved and widget updated');
  }
}
```

---

### 2️⃣ Bridge Layer (home_widget Package)

**الدور:**
- ربط Flutter بـ Native Android
- إدارة SharedPreferences
- إرسال Broadcast Intents

**الوظائف المستخدمة:**

| الوظيفة | الوصف | المثال |
|---------|-------|--------|
| `saveWidgetData<T>()` | حفظ بيانات في SharedPreferences | `await HomeWidget.saveWidgetData<String>('key', 'value')` |
| `updateWidget()` | إرسال signal للـ widget provider | `await HomeWidget.updateWidget(name: 'ProviderName')` |
| `getData()` | قراءة بيانات في Native side | `HomeWidgetPlugin.getData(context)` (Kotlin) |

---

### 3️⃣ Native Android Layer

#### **أ. HadithWidgetProvider.kt**

**المسار:** `android/app/src/main/kotlin/com/mishkat_almasabih/app/HadithWidgetProvider.kt`

**الدور:**
- استقبال Broadcast من Flutter
- قراءة البيانات من SharedPreferences
- تحديث واجهة الويدجيت

**الكود الكامل مع الشرح:**

```kotlin
package com.mishkat_almasabih.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.util.Log

class HadithWidgetProvider : AppWidgetProvider() {
    private val TAG = "HadithWidgetProvider"

    // ═══════════════════════════════════════════════════════════
    // دالة onUpdate: تُستدعى عند طلب تحديث الويدجيت
    // ═══════════════════════════════════════════════════════════
    override fun onUpdate(
        context: Context,                    // سياق التطبيق
        appWidgetManager: AppWidgetManager,  // مدير الويدجيتات
        appWidgetIds: IntArray               // IDs الويدجيتات المطلوب تحديثها
    ) {
        Log.d(TAG, "onUpdate: Widget update initiated.")
        
        // لكل ويدجيت على الشاشة (يمكن أن يكون هناك أكثر من واحدة)
        for (appWidgetId in appWidgetIds) {
            try {
                // ════════════════════════════════════════════
                // الخطوة 1: إنشاء RemoteViews (واجهة الويدجيت)
                // ════════════════════════════════════════════
                val views = RemoteViews(
                    context.packageName,
                    R.layout.hadith_widget
                ).apply {
                    // ════════════════════════════════════════════
                    // الخطوة 2: قراءة البيانات من SharedPreferences
                    // ════════════════════════════════════════════
                    val widgetData = HomeWidgetPlugin.getData(context)
                    val hadithText = widgetData.getString(
                        "hadith_text",
                        "إنما الأعمال بالنيات"  // قيمة افتراضية
                    )
                    
                    Log.d(TAG, "onUpdate: Retrieved hadithText: $hadithText")

                    // ════════════════════════════════════════════
                    // الخطوة 3: تحديث النص في TextView
                    // ════════════════════════════════════════════
                    setTextViewText(R.id.hadith_text, hadithText)

                    // ════════════════════════════════════════════
                    // الخطوة 4: إضافة Click Listener لفتح التطبيق
                    // ════════════════════════════════════════════
                    val intent = Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                                Intent.FLAG_ACTIVITY_CLEAR_TOP
                        putExtra("open_screen", "hadith_of_the_day")
                        putExtra("from_widget", true)
                    }

                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or 
                        PendingIntent.FLAG_IMMUTABLE
                    )

                    // ربط الـ click event بالويدجيت كاملة
                    setOnClickPendingIntent(R.id.hadith_widget_root, pendingIntent)
                    
                    Log.d(TAG, "Click listener set for widget $appWidgetId")
                }
                
                // ════════════════════════════════════════════
                // الخطوة 5: تطبيق التحديثات على الويدجيت
                // ════════════════════════════════════════════
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Widget $appWidgetId updated successfully.")
                
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget $appWidgetId: ${e.message}", e)
            }
        }
    }
}
```

#### **ب. hadith_widget.xml (Layout)**

**المسار:** `android/app/src/main/res/layout/hadith_widget.xml`

**الدور:** تحديد شكل وتصميم الويدجيت

**الهيكل:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout 
    android:id="@+id/hadith_widget_root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@drawable/widget_background_gradient"
    android:padding="16dp">

    <!-- ═══════════════════════════════════════ -->
    <!-- Header: أيقونة + عنوان "حديث اليوم"     -->
    <!-- ═══════════════════════════════════════ -->
    <LinearLayout
        android:id="@+id/header_container"
        ...>
        <ImageView ... />
        <TextView android:text="حديث اليوم" ... />
    </LinearLayout>

    <!-- ═══════════════════════════════════════ -->
    <!-- Body: نص الحديث (القابل للتحديث)        -->
    <!-- ═══════════════════════════════════════ -->
    <TextView
        android:id="@+id/hadith_text"
        android:text="جاري تحميل الحديث..."
        android:textColor="#FFFFFF"
        android:textSize="18sp"
        android:fontFamily="@font/ya_modernpro_bold"
        android:maxLines="4"
        android:ellipsize="end" />

    <!-- ═══════════════════════════════════════ -->
    <!-- Footer: زر "اقرأ الحديث" + أيقونة       -->
    <!-- ═══════════════════════════════════════ -->
    <RelativeLayout android:id="@+id/footer_container" ...>
        <LinearLayout ... >
            <TextView android:text="اقرأ الحديث" />
        </LinearLayout>
        <ImageView ... />
    </RelativeLayout>

</RelativeLayout>
```

#### **ج. hadith_widget_info.xml (Configuration)**

**المسار:** `android/app/src/main/res/xml/hadith_widget_info.xml`

**الدور:** تحديد خصائص الويدجيت

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider 
    xmlns:android="http://schemas.android.com/apk/res/android"
    
    <!-- الحجم الأدنى للويدجيت -->
    android:minWidth="250dp"
    android:minHeight="180dp"
    
    <!-- التحديث التلقائي كل 24 ساعة (86400000 ميلي ثانية) -->
    android:updatePeriodMillis="86400000"
    
    <!-- الـ Layout المستخدم -->
    android:initialLayout="@layout/hadith_widget"
    
    <!-- إمكانية تغيير الحجم -->
    android:resizeMode="horizontal|vertical"
    
    <!-- التصنيف: ويدجيت للشاشة الرئيسية -->
    android:widgetCategory="home_screen"
    
    <!-- الأيقونة عند الاختيار -->
    android:previewImage="@mipmap/launcher_icon"
    
    <!-- الوصف -->
    android:description="@string/widget_description" />
```

#### **د. AndroidManifest.xml (Registration)**

**المسار:** `android/app/src/main/AndroidManifest.xml`

**الدور:** تسجيل الويدجيت في النظام

```xml
<!-- ═══════════════════════════════════════════════════ -->
<!-- تسجيل Widget Provider كـ BroadcastReceiver         -->
<!-- ═══════════════════════════════════════════════════ -->
<receiver
    android:name=".HadithWidgetProvider"
    android:exported="true">
    
    <!-- الاستماع لحدث APPWIDGET_UPDATE -->
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>

    <!-- ربط ملف التكوين -->
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/hadith_widget_info" />
</receiver>
```

---

## 🔄 سير العمل (Flow)

### السيناريو الكامل: تحديث حديث اليوم

```
┌─────────────────────────────────────────────────────────────────┐
│ 🕐 TIME: يتم تغيير حديث اليوم (يدويًا أو بناءً على التاريخ)      │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 📱 STEP 1: Flutter UI يستقبل الحديث الجديد                      │
│                                                                 │
│  • DailyHadithCubit يجلب حديث جديد من Repository                │
│  • State يتحول إلى DailyHadithSuccess                           │
│  • UI يعيد بناء نفسه (rebuild)                                  │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 STEP 2: التحقق من التغيير                                    │
│                                                                 │
│  if (hadith.hadeeth != _lastPushedToWidget) {                  │
│    // الحديث تغير! محتاج نحدث الويدجيت                         │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 💾 STEP 3: حفظ البيانات في SharedPreferences                    │
│                                                                 │
│  await HomeWidget.saveWidgetData<String>(                      │
│      'hadith_text',                                             │
│      'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى'              │
│  );                                                             │
│                                                                 │
│  ✅ DATA SAVED:                                                 │
│  ┌──────────────────────────────────────────────┐              │
│  │ SharedPreferences                            │              │
│  │ ─────────────────                            │              │
│  │ hadith_text: "إنما الأعمال بالنيات..."       │              │
│  └──────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 📡 STEP 4: إرسال Broadcast Intent                              │
│                                                                 │
│  await HomeWidget.updateWidget(                                │
│      name: 'HadithWidgetProvider'                              │
│  );                                                             │
│                                                                 │
│  ✅ BROADCAST SENT:                                            │
│  Intent: "android.appwidget.action.APPWIDGET_UPDATE"           │
│  Target: HadithWidgetProvider                                  │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 📻 STEP 5: Android يستقبل Broadcast                             │
│                                                                 │
│  HadithWidgetProvider.onUpdate() {                             │
│    // تم استدعاء الدالة!                                        │
│  }                                                              │
│                                                                 │
│  📝 Log: "onUpdate: Widget update initiated."                  │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 📖 STEP 6: قراءة البيانات من SharedPreferences                  │
│                                                                 │
│  val widgetData = HomeWidgetPlugin.getData(context)            │
│  val hadithText = widgetData.getString("hadith_text", ...)     │
│                                                                 │
│  ✅ DATA RETRIEVED:                                            │
│  hadithText = "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى"     │
│                                                                 │
│  📝 Log: "Retrieved hadithText: ..."                           │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 🎨 STEP 7: تحديث RemoteViews (UI)                              │
│                                                                 │
│  val views = RemoteViews(...)                                  │
│  views.setTextViewText(R.id.hadith_text, hadithText)           │
│                                                                 │
│  ✅ UI UPDATED (لكن مش ظاهر بعد)                              │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 🖼️ STEP 8: تطبيق التحديثات على الويدجيت                        │
│                                                                 │
│  appWidgetManager.updateAppWidget(appWidgetId, views)          │
│                                                                 │
│  ✅ WIDGET REPAINTED!                                          │
│  📝 Log: "Widget updated successfully."                        │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 🏠 STEP 9: الشاشة الرئيسية تعرض الويدجيت المحدثة                │
│                                                                 │
│        ┌────────────────────────────────────────┐              │
│        │  📖 حديث اليوم                         │              │
│        │                                        │              │
│        │  إنما الأعمال بالنيات وإنما لكل امرئ  │ ← محدّث! ✨   │
│        │  ما نوى...                             │              │
│        │                                        │              │
│        │             [اقرأ الحديث]              │              │
│        └────────────────────────────────────────┘              │
│                                                                 │
│  🎉 SUCCESS! المستخدم يرى الحديث الجديد!                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 كيفية التحديث

### 1️⃣ تحديث يدوي (Manual Update)

**الاستخدام:** عندما تريد تحديث الويدجيت في لحظة معينة

```dart
// في أي مكان في تطبيق Flutter
Future<void> updateWidget() async {
  // حفظ البيانات
  await HomeWidget.saveWidgetData<String>('hadith_text', 'نص جديد');
  
  // تحديث الويدجيت
  await HomeWidget.updateWidget(name: 'HadithWidgetProvider');
}
```

### 2️⃣ تحديث تلقائي عند تغيير State

**الاستخدام:** المستخدم حاليًا في التطبيق

```dart
// في DailyHadithCard
BlocBuilder<DailyHadithCubit, DailyHadithState>(
  builder: (context, state) {
    if (state is DailyHadithSuccess) {
      final hadith = state.dailyHadithModel;
      
      // تحديث تلقائي عند تغيير الحديث
      if (hadith.hadeeth != _lastPushedToWidget) {
        _lastPushedToWidget = hadith.hadeeth;
        _updateHadithWidget(hadithText: hadith.hadeeth);
      }
    }
    return Container(...);
  },
)
```

### 3️⃣ تحديث دوري (Periodic Update)

**الاستخدام:** تحديثات خلفية كل فترة محددة

⚠️ **مهم:** Android قد يتجاهل التحديثات الدورية للحفاظ على البطارية!

```xml
<!-- في hadith_widget_info.xml -->
<appwidget-provider
    <!-- كل 24 ساعة = 86400000 ميلي ثانية -->
    android:updatePeriodMillis="86400000"
    ... />
```

**ملاحظات:**
- الحد الأدنى: 30 دقيقة (1800000 ms)
- يُفضل استخدام **WorkManager** للتحديثات المجدولة الموثوقة

### 4️⃣ تحديث عند إعادة تشغيل الجهاز

```kotlin
// في HadithWidgetProvider
override fun onEnabled(context: Context) {
    // أول مرة يتم إضافة الويدجيت
    super.onEnabled(context)
}

override fun onDisabled(context: Context) {
    // آخر ويدجيت تم حذفها
    super.onDisabled(context)
}
```

---

## 💡 أمثلة عملية

### مثال 1: تحديث الويدجيت عند فتح التطبيق

```dart
// في main.dart أو splash screen
class MyApp extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _refreshWidget();
  }

  Future<void> _refreshWidget() async {
    // جلب آخر حديث من الـ Repository
    final hadith = await getIt<SaveHadithDailyRepo>().getHadith();
    
    if (hadith != null) {
      await HomeWidget.saveWidgetData<String>(
        'hadith_text',
        hadith.hadeeth,
      );
      await HomeWidget.updateWidget(name: 'HadithWidgetProvider');
    }
  }
}
```

### مثال 2: تحديث الويدجيت عند ضغط زر

```dart
ElevatedButton(
  onPressed: () async {
    await HomeWidget.saveWidgetData<String>(
      'hadith_text',
      'حديث جديد من الزر!',
    );
    await HomeWidget.updateWidget(name: 'HadithWidgetProvider');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث الويدجيت!')),
    );
  },
  child: Text('تحديث الويدجيت'),
)
```

### مثال 3: فتح شاشة معينة عند النقر على الويدجيت

**في Kotlin:**

```kotlin
// في onUpdate()
val intent = Intent(context, MainActivity::class.java).apply {
    putExtra("open_screen", "hadith_details")
    putExtra("hadith_id", "123")
}
```

**في Flutter (MainActivity):**

```dart
// في main.dart
Future<void> handleWidgetClick() async {
  final initialUri = await getInitialUri();
  
  if (initialUri != null) {
    // افتح الشاشة المطلوبة بناءً على الـ Intent
    Navigator.pushNamed(context, '/hadith-details');
  }
}
```

---

## 🐛 استكشاف الأخطاء

### المشكلة 1: الويدجيت لا تتحدث

**الأسباب المحتملة:**

1. **لم يتم حفظ البيانات:**
   ```dart
   // ✅ صحيح
   await HomeWidget.saveWidgetData<String>('hadith_text', text);
   
   // ❌ خطأ
   HomeWidget.saveWidgetData<String>('hadith_text', text); // بدون await
   ```

2. **اسم الـ Provider خاطئ:**
   ```dart
   // ✅ صحيح (يطابق اسم الكلاس)
   await HomeWidget.updateWidget(name: 'HadithWidgetProvider');
   
   // ❌ خطأ
   await HomeWidget.updateWidget(name: 'HomeWidgetProvider');
   ```

3. **الويدجيت غير مسجلة في Manifest:**
   ```xml
   <!-- تأكد من وجود: -->
   <receiver android:name=".HadithWidgetProvider" ...>
   ```

**الحل:**
- افتح **Logcat** في Android Studio
- ابحث عن: `"HadithWidgetProvider"`
- راجع الـ Logs للأخطاء

---

### المشكلة 2: البيانات قديمة

**السبب:** البيانات محفوظة في SharedPreferences من جلسة سابقة

**الحل:**

```dart
// امسح البيانات القديمة
await HomeWidget.saveWidgetData<String>('hadith_text', null);

// ثم احفظ البيانات الجديدة
await HomeWidget.saveWidgetData<String>('hadith_text', newText);
await HomeWidget.updateWidget(name: 'HadithWidgetProvider');
```

---

### المشكلة 3: الويدجيت لا تظهر في قائمة الويدجيتات

**الأسباب:**

1. **لم يتم تسجيلها في Manifest**
2. **ملف `hadith_widget_info.xml` مفقود**
3. **خطأ في Build**

**الحل:**

```bash
# في Terminal
cd android
./gradlew clean

# ثم
flutter clean
flutter pub get
flutter run
```

---

## ❓ أسئلة شائعة

### س1: هل يمكن استخدام Flutter Widgets في Home Widget؟

**ج:** لا، `Home Widget` معمولة بـ **Native Android Views** (XML).

**لكن:** يمكنك إنشاء UI متشابهة باستخدام `RemoteViews`.

---

### س2: كم عدد الويدجيتات التي يمكن إضافتها؟

**ج:** **غير محدود!** المستخدم يمكنه إضافة أكثر من نسخة من الويدجيت.

لذلك في `onUpdate()` نمر على كل `appWidgetId`:

```kotlin
for (appWidgetId in appWidgetIds) {
    // تحديث كل ويدجيت على حدة
}
```

---

### س3: هل الويدجيت تتحدث لما التطبيق مقفول؟

**ج:** نعم! طالما أنك:
1. حفظت البيانات في `SharedPreferences`
2. أرسلت `updateWidget()`

Android سيقوم بتحديثها حتى لو التطبيق مقفول.

---

### س4: كيف أضيف صورة للويدجيت؟

**للصور الثابتة:**

```xml
<ImageView
    android:src="@drawable/my_image"
    ... />
```

**للصور الديناميكية:**

```kotlin
// في onUpdate()
views.setImageViewBitmap(R.id.my_imageview, bitmap)
```

**من URL:**

تحتاج library مثل `Glide` أو `Picasso` ولكن **RemoteViews محدودة**، الأفضل:
1. تحميل الصورة في Flutter
2. حفظ path الصورة
3. قراءته في Android

---

### س5: هل يمكن عمل Animation في الويدجيت؟

**ج:** **محدودة جدًا**. يمكنك:
- تغيير الألوان
- تغيير النصوص
- Fade In/Out بسيط

لكن **لا يمكن** عمل animations معقدة مثل Flutter.

---

### س6: كيف أتعامل مع RTL (من اليمين لليسار)؟

**ج:** في XML:

```xml
<TextView
    android:textDirection="rtl"
    android:layoutDirection="rtl"
    android:gravity="start"
    ... />
```

---

### س7: الويدجيت بتاكل بطارية؟

**ج:** **لا** إذا:
- لا تستخدم تحديثات متكررة جدًا
- لا تستخدم GPS أو Sensors
- التحديثات بناءً على احتياج فعلي (مش كل دقيقة!)

**نصيحة:** استخدم `WorkManager` للتحديثات المجدولة بكفاءة.

---

## 📚 مراجع إضافية

### الوثائق الرسمية:

1. **Android App Widgets:**
   https://developer.android.com/guide/topics/appwidgets

2. **home_widget Package:**
   https://pub.dev/packages/home_widget

3. **RemoteViews:**
   https://developer.android.com/reference/android/widget/RemoteViews

---

## ✅ Checklist للمطورين

عند إضافة أو تعديل Home Widget:

- [ ] حفظ البيانات بـ `saveWidgetData()`
- [ ] إرسال `updateWidget()` بعد الحفظ
- [ ] تأكيد اسم الـ Provider صحيح
- [ ] مراجعة `AndroidManifest.xml` (الـ receiver مسجل)
- [ ] التأكد من `hadith_widget_info.xml` موجود
- [ ] اختبار الويدجيت على أجهزة حقيقية
- [ ] مراجعة Logs في Logcat
- [ ] اختبار RTL layout
- [ ] اختبار Click events
- [ ] التأكد من Permissions (إن وجدت)

---

## 🎓 ملخص نهائي

**Home Widget = قطعة على الشاشة الرئيسية**

**رحلة البيانات:**
```
Flutter → SharedPreferences → Broadcast → Android → Widget → Home Screen
```

**أهم نقطة:**
البيانات **محفوظة في مكان مشترك** (SharedPreferences)، وAndroid **يقرأها بناءً على signal** من Flutter!

---

**تم إعداد هذا التوثيق بواسطة:** GitHub Copilot  
**التاريخ:** 23 فبراير 2026  
**المشروع:** مشكاة المصابيح - Mishkat Al-Masabih  

---

🌟 **للمساعدة أو الأسئلة، راجع الكود أو افتح Issue في الـ Repository!**
