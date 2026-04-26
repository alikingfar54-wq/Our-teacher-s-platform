# منصة أستاذنا - Flutter App

تطبيق Flutter احترافي لمنصة أستاذنا التعليمية مع أنيميشن متقدم.

## المتطلبات

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android Studio أو Xcode

## تشغيل التطبيق

```bash
# تثبيت الحزم
flutter pub get

# تشغيل على المحاكي
flutter run

# بناء APK للأندرويد
flutter build apk --release

# بناء للـ iOS
flutter build ios --release
```

## إعداد رابط الـ API

افتح الملف `lib/services/api_service.dart` وغيّر:
```dart
const String kApiBase = 'https://YOUR_API_DOMAIN/api';
```
إلى رابط خادمك الفعلي.

## هيكل المشروع

```
lib/
  main.dart              # نقطة البداية + AuthProvider
  theme/
    app_theme.dart       # ألوان وثيمات المنصة
  services/
    api_service.dart     # جميع استدعاءات الـ API
  widgets/
    animated_button.dart # زر مخصص مع Ripple + Scale
    shimmer_loading.dart # Shimmer للتحميل
  screens/
    splash_screen.dart   # Splash مع Fade + Scale + Elastic
    welcome_screen.dart  # اختيار الدور مع Hero Animation
    student/             # شاشات الطالب
    teacher/             # شاشات الأستاذ
    owner/               # شاشات المالك
```

## الأنيميشن المستخدم

- **Splash Screen**: Logo Scale (Elastic) + Text Slide + Glow Pulse + Progress Bar
- **Welcome Screen**: Cards Staggered Slide + Fade + Scale on Press
- **Navigation**: Slide Transition بين الصفحات
- **Shimmer**: تأثير تحميل احترافي
- **AnimatedButton**: Scale Down + Ripple + Haptic عند الضغط
- **Page Transitions**: Fade + Scale عند الانتقال
- **Lists**: Staggered Fade In لعناصر القائمة
