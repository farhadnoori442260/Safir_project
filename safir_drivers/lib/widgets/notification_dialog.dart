import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../methods/common_method.dart';
import '../models/trip_details.dart';
import '../pages/newTrip/new_trip_page.dart';
import 'loading_dialog.dart';

class NotificationDialog extends StatefulWidget {
  final TripDetails? tripDetailsInfo;
  final String? fareAmount;
  final String? bidAmount;

  NotificationDialog({
    super.key,
    this.tripDetailsInfo,
    this.fareAmount,
    this.bidAmount,
  });

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();
  late Timer timer;
  final Color safirColor = const Color(0xFF145A41); // رنگ سازمانی سفیر

  cancelNotificationDialogAfter20Sec() {
    const oneTickPerSecond = Duration(seconds: 1);

    timer = Timer.periodic(oneTickPerSecond, (timer) {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if (tripRequestStatus == "accepted") {
        timer.cancel();
        driverTripRequestTimeout = 40;
        return;
      }

      if (driverTripRequestTimeout == 0) {
        timer.cancel();
        driverTripRequestTimeout = 40;
        audioPlayer.stop();

        if (mounted) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    cancelNotificationDialogAfter20Sec();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  checkAvailabilityOfTripRequest(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const LoadingDialog(
        messageText: 'لطفاً منتظر بمانید...',
      ),
    );

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once().then((snap) async {
      if (mounted) {
        Navigator.pop(context); // بستن دیالوگ لودینگ
        Navigator.pop(context); // بستن دیالوگ اعلان
      }

      String newTripStatusValue = snap.snapshot.value?.toString() ?? "";

      if (newTripStatusValue == widget.tripDetailsInfo?.tripID) {
        driverTripStatusRef.set("accepted");

        cMethods.turnOffLocationUpdatesForHomePage();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) =>
                NewTripPage(newTripDetailsInfo: widget.tripDetailsInfo),
          ),
        );
      } else {
        String message = newTripStatusValue == "cancelled"
            ? "درخواست سفر توسط مسافر لغو شد."
            : newTripStatusValue == "timeout"
                ? "زمان پاسخگویی به درخواست به پایان رسید."
                : "درخواست سفر یافت نشد یا حذف شده است.";
        cMethods.displaySnackBar(message, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String fareAmount = widget.fareAmount ?? "۰";
    final String bidAmount =
        widget.bidAmount == "null" || widget.bidAmount == null
            ? "بدون پیشنهاد قیمت"
            : "${widget.bidAmount} افغانی";

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کل محتوای کارت اعلان
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white, // اصلاح بک‌گراند به سفید یکدست
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // آیکون بالای دیالوگ به جای لوگوی پیش‌فرض
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: safirColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_taxi_rounded,
                  color: safirColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "درخواست سفر جدید",
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 15),

              // بخش آدرس‌های مبدا و مقصد
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: safirColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "مبدا (محل سوار شدن):",
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'IranYekan'),
                            ),
                            Text(
                              widget.tripDetailsInfo?.pickupAddress ?? "نامشخص",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "مقصد:",
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'IranYekan'),
                            ),
                            Text(
                              widget.tripDetailsInfo?.dropOffAddress ?? "نامشخص",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 15),

              // بخش مبالغ کرایه به افغانی
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("کرایه استاندارد:", style: TextStyle(fontFamily: 'IranYekan', color: Colors.black54)),
                        Text("$fareAmount افغانی", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("قیمت پیشنهادی مسافر:", style: TextStyle(fontFamily: 'IranYekan', color: Colors.black54)),
                        Text(bidAmount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: safirColor)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // دکمه‌های قبول یا رد سفر
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          audioPlayer.stop();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "رد کردن",
                          style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          audioPlayer.stop();
                          setState(() {
                            tripRequestStatus = "accepted";
                          });
                          await checkAvailabilityOfTripRequest(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: safirColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "قبول سفر",
                          style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
