# 🍛 بلية - Baleyah

تطبيق طلبات كشري كامل بـ Flutter — الدفع **كاش عند الاستلام** فقط.

## ✨ الفيتشرز

| # | الفيتشر | الحالة |
|---|---------|--------|
| 1 | تسجيل دخول برقم الموبايل (OTP) | ✅ كود تجريبي: `123456` |
| 2 | قائمة منتجات + تصنيفات + بحث + فلترة | ✅ |
| 3 | سلة تسوق (أحجام + إضافات + كميات) | ✅ |
| 4 | إدارة العناوين المحفوظة | ✅ |
| 5 | تأكيد طلب COD + كوبون خصم 20% (`بلية20`) | ✅ |
| 6 | تتبع الطلب المباشر (5 مراحل متحركة) | ✅ محاكاة تلقائية |
| 7 | تقييم الطلب بعد الاستلام | ✅ |
| 8 | أنيميشن: Hero / طبق يطير للسلة / Stepper نابض / Shimmer | ✅ |

## 🎨 الألوان

- أساسي: `#D4A017` ذهبي
- ثانوي: `#C41E3A` أحمر
- خلفية: `#FFF8E7` كريمي
- نصوص: `#2C1810` بني داكن
- نجاح: `#4CAF50` — تحذير: `#FF9800`

## 🚀 التشغيل

```bash
cd baleyah
flutter create .          # يولّد مجلدات android/ios (مش هيمسح lib)
flutter pub get
flutter run
```

> أول تشغيل: سجل برقم أي موبايل مصري صحيح (مثال `01012345678`) والكود `123456`.

## 📁 الهيكل

```
lib/
├── core/        # constants, theme, routes
├── models/      # user, product, order, cart, category
├── services/    # auth (OTP mock), firestore (بيانات محلية), notifications
├── providers/   # cart, order, user, menu, ui (Provider state management)
├── screens/     # splash → onboarding → login → home/menu/cart/checkout/tracking/history/profile
└── widgets/     # appbar, product_card, animated_button, cart_badge, stepper, shimmer
```

## 🔌 التحويل لـ Firebase حقيقي

الكود معمول بطبقة services معزولة:

- `services/auth_service.dart` → استبدلها بـ `FirebaseAuth.verifyPhoneNumber`
- `services/firestore_service.dart` → استبدل الدوال بنفس أسماء collections من المواصفات:
  `users/{uid}`, `categories`, `products`, `orders`
- `notification_service.dart` → ركّب `firebase_messaging` واعرض الإشعارات من نفس النقطة `show()`

الموديلات جاهزة بنفس حقول الـ JSON بتاع المواصفات بالظبط (`toJson/fromJson`).

## ⚙️ ملاحظات

- الطلبات والسلة واليوزر محفوظين محلياً (`shared_preferences`) عشان التطبيق يشتغل standalone.
- تتبع الطلب بيتقدم تلقائياً (محاكاة): تأكيد ~15 ثانية، تحضير ~40، في الطريق ~70، توصيل ~120.
- التوصيل مجاني فوق 200 ج.م.
