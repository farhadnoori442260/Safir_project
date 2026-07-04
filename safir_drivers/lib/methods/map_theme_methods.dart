import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapThemeMethods {
  
  // متد اصلی بارگذاری استایل روی نقشه راننده
  void updateMapTheme(GoogleMapController controller) {
    // فرهاد جان، اینجا به صورت پیش‌فرض استایل شب را لود می‌کنیم
    // اگر بعداً خواستی استایل رترو یا دارک خالص شود، کافیست نام فایل را در خط زیر تغییر دهی
    getJsonFileFromThemes("themes/night_style.json").then((value) => setGoogleMapStyle(value, controller));
  }

  // متد کمکی برای خواندن فایل‌های متنی JSON از پوشه themes
  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  // اعمال نهایی استایل روی کنترلر نقشه گوگل
  void setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }
}
