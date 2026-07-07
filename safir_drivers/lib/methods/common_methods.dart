import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:safir_drivers/const.dart'; 
import '../global/global.dart'; // 👈 استفاده از مسیر فایل تایید شده شما
import '../models/direction_details.dart';
import '../utils/lang_helper.dart'; // 👈 اضافه شدن هیلپر زبان

class CommonMethods {
  // بررسی اتصال اینترنت راننده
  Future<void> checkConnectivity(BuildContext context) async {
    var connectionResults = await Connectivity().checkConnectivity();
    print("وضعیت اتصال: $connectionResults");

    if (connectionResults != ConnectivityResult.wifi &&
        connectionResults != ConnectivityResult.mobile) {
      if (!context.mounted) return;
      // 👈 سه‌زبانه کردن پیام خطای اینترنت با استفاده از هیلپر
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
