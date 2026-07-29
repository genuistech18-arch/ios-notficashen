# 📱 ملف بيانات وهوية التطبيق (App Branding & Identity Info)

هذا الملف يجمع كافة البيانات الخاصة باسم التطبيق، عنوانه، صورته وأيقونته في مكان واحد ليسهل عليك نسخها أو تعديلها دون عناء البحث في المجلدات.

---

## 1. 🏷️ أسماء وعناوين التطبيق (App Name & Titles)

* **عنوان التطبيق المعروض (App Display Title):** `متابعة الطالب`
* **اسم الحزمة البرمجية (Package / System Name):** `mobile_app`
* **معرف التطبيق (Android Package ID / Namespace):** `com.example.mobile_app`
* **إصدار التطبيق (Version):** `1.0.0+1`
* **رابط التوصيل بالـ Backend السحابي الأونلاين:** `https://fatherpadge.onrender.com`

---

## 2. 🖼️ أيقونة وصورة التطبيق (App Icon & Assets)

* **الصورة المصدرية للوجو (Source Logo Image):**  
  `d:\fatherpadg\st logo 1.jpg`
* **أيقونة الأندرويد الرئيسية (Android Icon HD):**  
  `mobile_app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
* **مجلد جميع مقاسات أيقونات الأندرويد:**  
  `mobile_app/android/app/src/main/res/mipmap-*/`
* **مجلد أيقونات آيفون (iOS Icon Set):**  
  `mobile_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
* **مسار ملف الـ APK النهائي المحدث للجهار:**  
  `d:\fatherpadg\notification-app.apk`
* **مسار ملف الـ AAB للرفع على جوجل بلاي:**  
  `d:\fatherpadg\notification-app.aab`

---

## 3. 📝 ملفات التعديل والنسخ المباشر (Quick Copy & Edit Paths)

إذا أردت تغيير اسم أو أيقونة التطبيق مستقبلاً، يمكنك النسخ والتعديل مباشرة من هذه الملفات:

1. **اسم التطبيق وعنوانه:**
   - [app.dart](file:///d:/fatherpadg/mobile_app/lib/app/app.dart#L69) (السطر 69: `title: 'متابعة الطالب'`)
   - [pubspec.yaml](file:///d:/fatherpadg/mobile_app/pubspec.yaml#L1) (السطر 1: `name: mobile_app`)
   - [AndroidManifest.xml](file:///d:/fatherpadg/mobile_app/android/app/src/main/AndroidManifest.xml#L3) (`android:label="متابعة الطالب"`)
   - [build.gradle](file:///d:/fatherpadg/mobile_app/android/app/build.gradle#L24) (`applicationId = "com.example.mobile_app"`)

2. **أيقونات التطبيق:**
   - تم توليد أيقونات الأندرويد والآيفون تلقائياً من الصورة `st logo 1.jpg` باستخدام حزمة `flutter_launcher_icons`.
