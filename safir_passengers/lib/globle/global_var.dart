import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userEmail = "";
String userID = FirebaseAuth.instance.currentUser!.uid;

// کلیدهای ارتباطی گوگل و درگاه پرداخت (بعداً پر می‌شوند)
const String googleMapKey = "";
const String stripeSecretAPIKey = "";
const String stripePublishedKey = "";

// تنظیم موقعیت اولیه نقشه به محض باز شدن اپلیکیشن روی مرکز شهر کابل
const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(34.5553, 69.2075), // کابل، افغانستان
  zoom: 14.0, // زوم استاندارد برای نمایش خیابان‌ها
);
