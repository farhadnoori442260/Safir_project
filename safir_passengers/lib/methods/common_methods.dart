import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ایمپورت‌های کاملاً هماهنگ با ساختار جدید گیت‌هاب سفیر
import '../globle/global_var.dart';
import '../pages/app_info.dart'; 
import '../models/address_models.dart';
import '../models/direction_details.dart';

class CommonMethods {
  
  // بررسی زنده بودن اتصال اینترنت کاربر
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar(
          "انترنت شما وصل نیست. لطفاً اتصال خود را بررسی کرده و دوباره تلاش کنید.",
          context);
    }
  }

  // نمایش پیام‌های سیستم به زبان فارسی/دری برای کاربران سفیر
  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText, textDirection: TextDirection.rtl));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // متد عمومی ارسال درخواست به وب‌سرویس‌ها
  static sendRequestToAPI(String apiUrl) async {
    try {
      http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));
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

  /// تبدیل مختصات به آدرس متنی (Reverse GeoCoding) کاملاً رایگان بدون نیاز به گوگل
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    
    // استفاده از سرور رایگان و بدون تحریم OpenStreetMap (Nominatim) به جای گوگل مپ پولی
    String apiGeoCodingUrl =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=fa,fa-AF";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error" && responseFromAPI["display_name"] != null) {
      humanReadableAddress = responseFromAPI["display_name"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = shortenAddress(humanReadableAddress); // خلاصه سازی آدرس طولانی نقشه باز
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfoClass>(context, listen: false)
          .updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  /// کوتاه‌سازی آدرس‌های بسیار طولانی OpenStreetMap برای نمایش تمیز در فیلدهای مبدأ و مقصد
  static String shortenAddress(String fullAddress) {
    List<String> parts = fullAddress.split(',');
    if (parts.length >= 3) {
      // استخراج بخش‌های کلیدی مثل نام خیابان، محله یا ساحه اصلی
      return "${parts[0].trim()}، ${parts[1].trim()}";
    }
    return fullAddress;
  }

  /// دریافت اطلاعات کامل مسیر (فاصله و زمان) به صورت کاملاً رایگان از OSRM
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      dynamic source, dynamic destination) async {
    
    // آدرس سرور مسیریابی OSRM هماهنگ با لایه جدید نقشه شما
    String urlDirectionAPI =
        "https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson";

    var responseFromDirectionAPI = await sendRequestToAPI(urlDirectionAPI);

    if (responseFromDirectionAPI == "error" || 
        responseFromDirectionAPI["routes"] == null || 
        responseFromDirectionAPI["routes"].isEmpty) {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    try {
      double distanceInMeters = responseFromDirectionAPI["routes"][0]["distance"].toDouble();
      double durationInSeconds = responseFromDirectionAPI["routes"][0]["duration"].toDouble();

      // تبدیل متر به کیلومتر و ثانیه به دقیقه جهت نمایش متنی
      directionDetails.distanceTextString = "${(distanceInMeters / 1000).toStringAsFixed(1)} کیلومتر";
      directionDetails.distanceValueDigit = distanceInMeters.toInt();
      
      directionDetails.durationTextString = "${(durationInSeconds / 60).toStringAsFixed(0)} دقیقه";
      directionDetails.durationValueDigit = durationInSeconds.toInt();
      
      // ذخیره مختصات خط مسیر
      directionDetails.encodedPoints = responseFromDirectionAPI["routes"][0]["geometry"]["coordinates"].toString();
    } catch (e) {
      return null;
    }
    return directionDetails;
  }

  /// محاسبه قیمت نهایی بر اساس سیستم مالی سفیر به افغانی (AFN)
  calculateFareAmountInAFN(DirectionDetails directionDetails,
      {double surgeMultiplier = 1.0}) {
    double distancePerKmAmountAFN = 10; // ۱۰ افغانی به ازای هر کیلومتر
    double durationPerMinuteAmountAFN = 2; // ۲ افغانی به ازای هر دقیقه سفر
    double baseFareAmountAFN = 30; // قیمت پایه (ورودی) ۳۰ افغانی
    double bookingFeeAFN = 10; // حق کمیسیون یا خدمات ۱۰ افغانی
    double minimumFareAFN = 40; // حداقل قیمت یک سفر ۴۰ افغانی

    // محاسبه بر اساس متراژ و زمان دریافتی از OSRM
    double totalDistanceTravelledFareAmountAFN =
        (directionDetails.distanceValueDigit! / 1000) * distancePerKmAmountAFN;
    double totalDurationSpendFareAmountAFN =
        (directionDetails.durationValueDigit! / 60) * durationPerMinuteAmountAFN;

    // مجموع قیمت قبل از اعمال ضریب ترافیک یا اوج تقاضا
    double totalFareBeforeSurgeAFN = baseFareAmountAFN +
        totalDistanceTravelledFareAmountAFN +
        totalDurationSpendFareAmountAFN +
        bookingFeeAFN;

    // اعمال ضریب ترافیک
    double overAllTotalFareAmountAFN = totalFareBeforeSurgeAFN * surgeMultiplier;

    // اعمال حداقل کرایه مجاز
    if (overAllTotalFareAmountAFN < minimumFareAFN) {
      overAllTotalFareAmountAFN = minimumFareAFN;
    }

    return overAllTotalFareAmountAFN.toStringAsFixed(0); // خروجی رند شده به افغانی
  }

  // تبدیل فرمت زمان به ساعت و دقیقه برای راحتی مسافران سفیر
  String formatTime(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours > 0) {
      return "$hours ساعت و $minutes دقیقه";
    } else {
      return "$minutes دقیقه";
    }
  }
}
