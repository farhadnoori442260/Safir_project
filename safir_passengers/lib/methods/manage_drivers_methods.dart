// اصلاح ایمپورت قدیمی اوبر به ساختار جدید سفیر
import '../models/online_nearby_drivers.dart';

class ManageDriversMethods {
  // لیست رانندگان سفیر که در نزدیکی مسافر آنلاین هستند
  static List<OnlineNearbyDrivers> nearbyOnlineDriversList = [];

  // حذف راننده از لیست (مثلاً وقتی راننده آفلاین می‌شود یا سفری را قبول می‌کند)
  static void removeDriverFromList(String driverId) {
    int index = nearbyOnlineDriversList
        .indexWhere((driver) => driver.uidDriver == driverId);

    if (index != -1) {
      nearbyOnlineDriversList.removeAt(index);
    } else {
      print("راننده‌ای با آی‌دی $driverId در لیست پیدا نشد.");
    }
  }

  // به‌روزرسانی لحظه‌ای موقعیت مکانی رانندگان اطراف روی نقشه سفیر
  static void updateOnlineNearbyDriversLocation(
      OnlineNearbyDrivers nearbyOnlineDriverInformation) {
    int index = nearbyOnlineDriversList.indexWhere((driver) =>
        driver.uidDriver == nearbyOnlineDriverInformation.uidDriver);

    if (index != -1) {
      nearbyOnlineDriversList[index].latDriver =
          nearbyOnlineDriverInformation.latDriver;
      nearbyOnlineDriversList[index].lngDriver =
          nearbyOnlineDriverInformation.lngDriver;
    } else {
      print(
          "راننده‌ای با آی‌دی ${nearbyOnlineDriverInformation.uidDriver} برای به‌روزرسانی مختصات پیدا نشد.");
    }
  }
}
