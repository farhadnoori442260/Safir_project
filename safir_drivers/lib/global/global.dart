import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart'; // 👈 اضافه شدن برای دسترسی به BuildContext
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/lang_helper.dart'; // 👈 صدا زدن هیلپر زبان سه‌زبانه شما

// اطلاعات عمومی کاربر و کلیدهای نقشه
String userName = '';
String userEmail = '';
const String googleMapKey = "";

// موقعیت اولیه نقشه سفیر (تنظیم شده روی کابل برای لود اولیه)
const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(34.5553, 69.2075),
  zoom: 14.0,
);

// استریم‌های فعال برای ردیابی زنده موقعیت مکانی راننده
StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

// مدت زمان هشدارهای درخواست سفر به ثانیه (۴۰ ثانیه فرصت برای قبول سفر)
int driverTripRequestTimeout = 40;

// پخش‌کننده صدای زنگ درخواست سفر سفیر
final audioPlayer = AssetsAudioPlayer();

// موقعیت مکانی زنده و فعلی راننده
Position? driverCurrentPosition;

// اطلاعات اختصاصی راننده جاری در سیستم سفیر
String driverName = "";
String driverPhone = "";
String driverPhoto = "";
String driverEmail = "";
String driverSecondName = "";
String address = "";
String rating = ""; // 👈 اصلاح غلط املایی از ratting به rating

// اطلاعات وسیله نقلیه (موتر، موتورسایکل یا ریکشا)
String vehicleType = "economic_car"; // 👈 متغیر کلیدی نوع وسیله نقلیه
String carModel = "";
String carColor = "";
String carNumber = "";

// متغیرهای مربوط به سیستم قیمت‌دهی و کرایه
String bidAmount = "";
String fareAmount = "";

// --- متغیرهای اختصاصی زبان سیستم سفیر ---
String currentLanguage = "fa"; // مقدار پیش‌فرض: فارسی

/// 👈 تابعی هوشمند برای تبدیل نوع وسیله نقلیه ذخیره شده به زبان انتخابی راننده با استفاده از هیلپر
String getTranslatedVehicleType(BuildContext context, String type) {
  // اگر نوع وسیله در دیتابیس یکی از این کلیدها بود، ترجمه سه‌زبانه‌اش را از هیلپر برمی‌گرداند
  if (type == "economic_car" || type == "modern_car" || type == "motorbike") {
    return tr(context, type);
  }
  return type; // در غیر این صورت خود متن را برمی‌گرداند
}
