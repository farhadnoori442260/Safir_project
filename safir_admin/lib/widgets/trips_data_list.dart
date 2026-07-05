import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// ایمپورت اختصاصی پکیج سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';

class TripsDataList extends StatefulWidget {
  const TripsDataList({super.key});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}

class _TripsDataListState extends State<TripsDataList> {
  final completedTripsRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("tripRequest");

  // متد مسیریابی و نمایش نقشه مبدا و مقصد روی گوگل مپ
  Future<void> launchGoogleMapFromSourceToDestination(
    dynamic pickUpLat,
    dynamic pickUpLng,
    dynamic dropOffLat,
    dynamic dropOffLng,
  ) async {
    String directionAPIUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunchUrl(Uri.parse(directionAPIUrl))) {
      await launchUrl(Uri.parse(directionAPIUrl));
    } else {
      debugPrint("خطا: نقشه گوگل لود نشد.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color safirGreen = const Color(0xFF145A41); // رنگ اختصاصی سفیر

    return StreamBuilder(
      stream: completedTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "خطایی رخ داده است. لطفاً بعداً تلاش کنید.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshotData.hasData || snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "هیچ سفری ثبت نشده است.",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        
        // فیلتر کردن سفرها: فقط سفرهای پایان‌یافته (ended) به لیست اضافه می‌شوند
        dataMap.forEach((key, value) {
          if (value["status"] != null && value["status"] == "ended") {
            itemsList.add({"key": key, ...value});
          }
        });

        if (itemsList.isEmpty) {
          return const Center(
            child: Text(
              "هیچ سفر پایان‌یافته‌ای وجود ندارد.",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // برای اسکرول روان‌تر در وب پنل
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            // نمایش هزینه با واحد افغانی
            String fareText = itemsList[index]["fareAmount"] != null 
                ? "${itemsList[index]["fareAmount"]} افغانی" 
                : "0 افغانی";

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonMethods.data(
                  2,
                  Text(itemsList[index]["tripID"]?.toString() ?? "بدون شناسه", style: const TextStyle(fontSize: 12)),
                ),
                CommonMethods.data(
                  1,
                  Text(itemsList[index]["userName"]?.toString() ?? "ناشناس", style: const TextStyle(fontSize: 12)),
                ),
                CommonMethods.data(
                  1,
                  Text(itemsList[index]["driverName"]?.toString() ?? "ناشناس", style: const TextStyle(fontSize: 12)),
                ),
                CommonMethods.data(
                  1,
                  Text(itemsList[index]["carDetails"]?.toString() ?? "ثبت نشده", style: const TextStyle(fontSize: 12)),
                ),
                CommonMethods.data(
                  1,
                  Text(itemsList[index]["publishDateTime"]?.toString() ?? "بدون تاریخ", style: const TextStyle(fontSize: 12)),
                ),
                CommonMethods.data(
                  1,
                  Text(fareText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                CommonMethods.data(
                  1,
                  SizedBox(
                    height: 30, // ارتفاع مناسب برای دکمه وب
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: safirGreen, // رنگ سازمانی سبز سفیر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        var pickUp = itemsList[index]["pickUpLatLng"];
                        var dropOff = itemsList[index]["dropOffLatLng"];

                        if (pickUp != null && dropOff != null) {
                          launchGoogleMapFromSourceToDestination(
                            pickUp["latitude"],
                            pickUp["longitude"],
                            dropOff["latitude"],
                            dropOff["longitude"],
                          );
                        }
                      },
                      child: const Text(
                        "جزئیات بیشتر",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
