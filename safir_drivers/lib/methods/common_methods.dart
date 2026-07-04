import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:safir_drivers/const.dart'; // اصلاح نام پکیج به safir_drivers
import '../global/global.dart';
import '../models/direction_details.dart';

class CommonMethods {
  // بررسی اتصال اینترنت راننده
  Future<void> checkConnectivity(BuildContext context) async {
    var connectionResults = await Connectivity().checkConnectivity();
    print("وضعیت اتصال: $connectionResults");

    if (connectionResults != ConnectivityResult.wifi &&
        connectionResults != ConnectivityResult.mobile) {
      if (!context.mounted) return;
      displaySnackBar(
          "اتصال اینترنت شما برقرار نیست. لطفاً شبکه خود را بررسی کرده و دوباره تلاش کنید.",
          context);
    } else {
      print("اینترنت متصل است");
    }
  }

  // نمایش پیام‌های سیستم با فونت بومی سفیر
  void displaySnackBar(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'IranYekan', fontSize: 14),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // غیرفعال کردن ردیابی زنده لوکیشن (زمانی که راننده آفلاین می‌شود یا در صفحه اصلی نیست)
  void turnOffLocationUpdatesForHomePage() {
    if (positionStreamHomePage != null) {
      positionStreamHomePage!.pause();
    } else {
      print("positionStreamHomePage خالی است، امکان توقف وجود ندارد.");
    }
  }

  // فعال کردن ردیابی زنده و به‌روزرسانی آنلاین موقعیت راننده در Geofire فایربیس
  void turnOnLocationUpdatesForHomePage() {
    if (positionStreamHomePage != null) {
      positionStreamHomePage!.resume();
    } else {
      print("positionStreamHomePage خالی است، امکان شروع مجدد وجود ندارد.");
    }

    if (driverCurrentPosition != null) {
      Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );
    } else {
      print("موقعیت فعلی راننده یافت نشد، جیوفایر آپدیت نشد.");
    }
  }

  // متد ارسال درخواست به API های نقشه
  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  // دریافت جزئیات و خطوط مسیر بین مبدا و مقصد از گوگل
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);
    print("پاسخ وب‌سرویس مسیر یابی: $responseFromDirectionsAPI");
    if (responseFromDirectionsAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints =
        responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  // فرمول محاسبه هوشمند کرایه بر اساس مسافت و زمان سفر برای سیستم سفیر
  calculateFareAmount(DirectionDetails directionDetails,
      {double surgeMultiplier = 1.0}) {
    
    // مقادیر پایه قیمت‌گذاری (فرهاد جان، این اعداد را کاملاً بر اساس واحد پولی و سیستم خودت تغییر بده)
    double distancePerKmAmount = 20;     // هزینه به ازای هر کیلومتر مسافت
    double durationPerMinuteAmount = 15; // هزینه به ازای هر دقیقه زمان سفر
    double baseFareAmount = 50;          // ورودیه اولیه یا کرایه پایه
    double bookingFee = 10;              // حق کمیسیون یا هزینه خدمات خدمات
    double minimumFare = 100;            // حداقل کرایه ممکن برای یک سفر کوتاه

    // محاسبه قیمت بر اساس متراژ مسافت طی شده
    double totalDistanceTravelledFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
        
    // محاسبه قیمت بر اساس ثانیه‌های زمان سفر
    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    // مجموع کل کرایه قبل از اعمال ضریب شلوغی
    double totalFareBeforeSurge = baseFareAmount +
        totalDistanceTravelledFareAmount +
        totalDurationSpendFareAmount +
        bookingFee;

    // اعمال ضریب شلوغی (مثلاً زمان بارندگی یا ساعات اوج ترافیک)
    double overAllTotalFareAmount = totalFareBeforeSurge * surgeMultiplier;

    // بررسی حداقل کرایه (اگر مبلغ نهایی کمتر از کف قیمت بود، حداقل کرایه ثبت می‌شود)
    if (overAllTotalFareAmount < minimumFare) {
      overAllTotalFareAmount = minimumFare;
    }

    // بازگرداندن مبلغ نهایی تا دو رقم اعشار
    return overAllTotalFareAmount.toStringAsFixed(2);
  }
}
