import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // 👈 جایگزین گوگل‌مپ برای OpenStreetMap
import '../global/global.dart';
import '../models/direction_details.dart';
import '../utils/lang_helper.dart';

class CommonMethods {
  // بررسی اتصال اینترنت راننده
  Future<void> checkConnectivity(BuildContext context) async {
    var connectionResults = await Connectivity().checkConnectivity();
    print("وضعیت اتصال: $connectionResults");

    if (connectionResults != ConnectivityResult.wifi &&
        connectionResults != ConnectivityResult.mobile) {
      if (!context.mounted) return;
      displaySnackBar(tr(context, 'no_internet_error'), context);
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

  // غیرفعال کردن ردیابی زنده لوکیشن
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

  // متد ارسال درخواست به API های عمومی
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

  // 👈 دریافت جزئیات و نقاط مسیر از سرویس رایگان OSRM برای OpenStreetMap
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    
    String urlDirectionsAPI =
        "https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);
    print("پاسخ وب‌سرویس مسیریابی OSRM: $responseFromDirectionsAPI");

    if (responseFromDirectionsAPI == "error" ||
        responseFromDirectionsAPI["routes"] == null ||
        (responseFromDirectionsAPI["routes"] as List).isEmpty) {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    // استخراج مسافت (به متر) و زمان (به ثانیه)
    double distanceInMeters =
        (responseFromDirectionsAPI["routes"][0]["distance"] as num).toDouble();
    double durationInSeconds =
        (responseFromDirectionsAPI["routes"][0]["duration"] as num).toDouble();

    detailsModel.distanceValueDigits = distanceInMeters.round();
    detailsModel.durationValueDigits = durationInSeconds.round();

    // تبدیل متنی مسافت و زمان
    double distanceInKm = distanceInMeters / 1000;
    double durationInMinutes = durationInSeconds / 60;

    detailsModel.distanceTextString = "${distanceInKm.toStringAsFixed(1)} km";
    detailsModel.durationTextString = "${durationInMinutes.round()} min";

    // استخراج مختصات نقاط مسیر برای رسم خط روی OpenStreetMap
    List<dynamic> coordinates =
        responseFromDirectionsAPI["routes"][0]["geometry"]["coordinates"];
    List<LatLng> polylinePointsList = [];

    for (var point in coordinates) {
      polylinePointsList.add(LatLng(point[1].toDouble(), point[0].toDouble()));
    }

    detailsModel.polylinePoints = polylinePointsList;

    return detailsModel;
  }

  // فرمول محاسبه هوشمند کرایه بر اساس مسافت و زمان سفر برای سیستم سفیر
  calculateFareAmount(DirectionDetails directionDetails,
      {double surgeMultiplier = 1.0}) {
    double distancePerKmAmount = 20;
    double durationPerMinuteAmount = 15;
    double baseFareAmount = 50;
    double bookingFee = 10;
    double minimumFare = 100;

    double totalDistanceTravelledFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;

    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    double totalFareBeforeSurge = baseFareAmount +
        totalDistanceTravelledFareAmount +
        totalDurationSpendFareAmount +
        bookingFee;

    double overAllTotalFareAmount = totalFareBeforeSurge * surgeMultiplier;

    if (overAllTotalFareAmount < minimumFare) {
      overAllTotalFareAmount = minimumFare;
    }

    return overAllTotalFareAmount.toStringAsFixed(2);
  }
}
