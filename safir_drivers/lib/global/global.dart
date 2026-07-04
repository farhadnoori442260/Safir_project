import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// اطلاعات عمومی کاربر و کلیدهای نقشه
String userName = '';
String userEmail = '';
const String googleMapKey = "";

// موقعیت اولیه نقشه سفیر (تنظیم شده روی موقعیت حدودی منطقه برای لود اولیه سریع‌تر)
const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(34.5553, 69.2075), // تنظیم اولیه روی کابل (قابل تغییر به شهر مورد نظر شما)
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
String ratting = ""; // امتیاز راننده

// اطلاعات وسیله نقلیه (موتر، موتورسایکل یا ریکشا)
String carModel = "";
String carColor = "";
String carNumber = "";

// متغیرهای مربوط به سیستم قیمت‌دهی و کرایه
String bidAmount = "";
String fareAmount = "";
